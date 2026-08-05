from datetime import datetime
from typing import List, Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict
from sqlalchemy import (
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    delete,
    select,
)
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship, selectinload
import os

DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite+aiosqlite:////tmp/tabbr.db")

engine = create_async_engine(DATABASE_URL, echo=False)
async_session_maker = async_session_maker = async_sessionmaker(
    engine, expire_on_commit=False, class_=AsyncSession
)


class Base(DeclarativeBase):
    pass


class Person(Base):
    __tablename__ = "persons"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    splits: Mapped[List["ExpenseSplit"]] = relationship(
        back_populates="person", cascade="all, delete-orphan"
    )
    expenses_paid: Mapped[List["Expense"]] = relationship(
        back_populates="payer", cascade="all, delete-orphan"
    )


class Expense(Base):
    __tablename__ = "expenses"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    description: Mapped[str] = mapped_column(String, nullable=False)
    payer_id: Mapped[int] = mapped_column(ForeignKey("persons.id"), nullable=False)
    date: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    payer: Mapped["Person"] = relationship(back_populates="expenses_paid")
    splits: Mapped[List["ExpenseSplit"]] = relationship(
        back_populates="expense", cascade="all, delete-orphan"
    )


class ExpenseSplit(Base):
    __tablename__ = "expense_splits"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    expense_id: Mapped[int] = mapped_column(
        ForeignKey("expenses.id"), nullable=False
    )
    person_id: Mapped[int] = mapped_column(ForeignKey("persons.id"), nullable=False)
    share: Mapped[float] = mapped_column(Float, nullable=False)

    expense: Mapped["Expense"] = relationship(back_populates="splits")
    person: Mapped["Person"] = relationship(back_populates="splits")


class PersonCreate(BaseModel):
    name: str


class PersonOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    created_at: datetime


class SplitIn(BaseModel):
    person_id: int
    share: float


class ExpenseCreate(BaseModel):
    amount: float
    description: str
    payer_id: int
    date: Optional[datetime] = None
    splits: Optional[List[SplitIn]] = None


class SplitOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    person_id: int
    share: float


class ExpenseOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    amount: float
    description: str
    payer_id: int
    payer_name: str
    date: datetime
    created_at: datetime
    splits: List[SplitOut]


class BalanceEntry(BaseModel):
    from_person: int
    from_person_name: str
    to_person: int
    to_person_name: str
    amount: float


class BalanceResponse(BaseModel):
    balances: List[BalanceEntry]


app = FastAPI(title="Tabbr")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def on_startup() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


def _serialize_expense(expense: Expense, payer_name: str) -> ExpenseOut:
    return ExpenseOut(
        id=expense.id,
        amount=expense.amount,
        description=expense.description,
        payer_id=expense.payer_id,
        payer_name=payer_name,
        date=expense.date,
        created_at=expense.created_at,
        splits=[SplitOut.model_validate(s) for s in expense.splits],
    )


@app.get("/api/persons", response_model=List[PersonOut])
async def list_persons() -> List[PersonOut]:
    async with async_session_maker() as session:
        result = await session.execute(select(Person).order_by(Person.id))
        persons = result.scalars().all()
        return [PersonOut.model_validate(p) for p in persons]


@app.post("/api/persons", response_model=PersonOut)
async def create_person(payload: PersonCreate) -> PersonOut:
    async with async_session_maker() as session:
        person = Person(name=payload.name)
        session.add(person)
        await session.commit()
        await session.refresh(person)
        return PersonOut.model_validate(person)


@app.delete("/api/persons/{person_id}")
async def delete_person(person_id: int) -> dict:
    async with async_session_maker() as session:
        person = await session.get(Person, person_id)
        if person is None:
            raise HTTPException(status_code=404, detail="Person not found")
        await session.execute(delete(Person).where(Person.id == person_id))
        await session.commit()
        return {"ok": True}


@app.get("/api/expenses", response_model=List[ExpenseOut])
async def list_expenses() -> List[ExpenseOut]:
    async with async_session_maker() as session:
        result = await session.execute(
            select(Expense, Person.name)
            .join(Person, Expense.payer_id == Person.id)
            .options(selectinload(Expense.splits))
            .order_by(Expense.date.desc(), Expense.id.desc())
        )
        rows = result.all()
        return [_serialize_expense(expense, name) for expense, name in rows]  # type: ignore[misc] 


@app.post("/api/expenses", response_model=ExpenseOut)
async def create_expense(payload: ExpenseCreate) -> ExpenseOut:
    async with async_session_maker() as session:
        payer = await session.get(Person, payload.payer_id)
        if payer is None:
            raise HTTPException(status_code=404, detail="Payer not found")

        # Strip timezone info to match TIMESTAMP WITHOUT TIME ZONE columns
        expense_date = payload.date
        if expense_date and expense_date.tzinfo is not None:
            expense_date = expense_date.replace(tzinfo=None)

        expense = Expense(
            amount=payload.amount,
            description=payload.description,
            payer_id=payload.payer_id,
            date=expense_date or datetime.utcnow(),
        )
        session.add(expense)
        await session.flush()

        if payload.splits:
            for split in payload.splits:
                person = await session.get(Person, split.person_id)
                if person is None:
                    raise HTTPException(
                        status_code=404,
                        detail=f"Person {split.person_id} not found",
                    )
                session.add(
                    ExpenseSplit(
                        expense_id=expense.id,
                        person_id=split.person_id,
                        share=split.share,
                    )
                )
        else:
            persons_result = await session.execute(select(Person))
            persons = persons_result.scalars().all()
            if not persons:
                raise HTTPException(
                    status_code=400,
                    detail="No persons available to split expense equally",
                )
            share = payload.amount / len(persons)
            for person in persons:
                session.add(
                    ExpenseSplit(
                        expense_id=expense.id,
                        person_id=person.id,
                        share=share,
                    )
                )

        await session.commit()
        # Re-query with selectinload to avoid async lazy-load greenlet error
        result = await session.execute(
            select(Expense)
            .options(selectinload(Expense.splits))
            .where(Expense.id == expense.id)
        )
        expense = result.scalars().first()
        return _serialize_expense(expense, payer.name)


@app.delete("/api/expenses/{expense_id}")
async def delete_expense(expense_id: int) -> dict:
    async with async_session_maker() as session:
        expense = await session.get(Expense, expense_id)
        if expense is None:
            raise HTTPException(status_code=404, detail="Expense not found")
        await session.execute(delete(Expense).where(Expense.id == expense_id))
        await session.commit()
        return {"ok": True}


def _minimize_transactions(net_balances: dict[int, float]) -> List[dict[int, float]]:
    creditors = sorted(
        [(pid, amt) for pid, amt in net_balances.items() if amt > 0.0001],
        key=lambda x: x[1],
        reverse=True,
    )
    debtors = sorted(
        [(pid, -amt) for pid, amt in net_balances.items() if amt < -0.0001],
        key=lambda x: x[1],
    )
    payments: List[dict[int, float]] = []
    i = j = 0
    while i < len(debtors) and j < len(creditors):
        debtor_id, debt_amt = debtors[i]
        creditor_id, credit_amt = creditors[j]
        pay = min(debt_amt, credit_amt)
        payments.append(
            {"from": debtor_id, "to": creditor_id, "amount": round(pay, 2)}
        )
        debtors[i] = (debtor_id, debt_amt - pay)
        creditors[j] = (creditor_id, credit_amt - pay)
        if debtors[i][1] < 0.0001:
            i += 1
        if creditors[j][1] < 0.0001:
            j += 1
    return payments


@app.get("/api/balance", response_model=BalanceResponse)
async def get_balance() -> BalanceResponse:
    async with async_session_maker() as session:
        persons_result = await session.execute(select(Person))
        persons = {p.id: p for p in persons_result.scalars().all()}

        expenses_result = await session.execute(
            select(Expense).options(selectinload(Expense.splits))
        )
        expenses = expenses_result.scalars().all()

        net: dict[int, float] = {pid: 0.0 for pid in persons}
        for expense in expenses:
            net[expense.payer_id] = net.get(expense.payer_id, 0.0) + expense.amount
            for split in expense.splits:
                net[split.person_id] = net.get(split.person_id, 0.0) - split.share

        payments = _minimize_transactions(net)
        entries = [
            BalanceEntry(
                from_person=p["from"],
                from_person_name=persons[p["from"]].name,
                to_person=p["to"],
                to_person_name=persons[p["to"]].name,
                amount=p["amount"],
            )
            for p in payments
        ]
        return BalanceResponse(balances=entries)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
