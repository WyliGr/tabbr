import os
import random
import string
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
    UniqueConstraint,
    delete,
    select,
)
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship, selectinload

DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite+aiosqlite:////tmp/tabbr.db")

engine = create_async_engine(DATABASE_URL, echo=False)
async_session_maker = async_sessionmaker(
    engine, expire_on_commit=False, class_=AsyncSession
)


class Base(DeclarativeBase):
    pass


ROOM_CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ"  # 24 letters, no O/I
ROOM_CODE_LENGTH = 5


def _generate_room_code() -> str:
    return "".join(random.choices(ROOM_CODE_ALPHABET, k=ROOM_CODE_LENGTH))


class Room(Base):
    __tablename__ = "rooms"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    code: Mapped[str] = mapped_column(String, unique=True, index=True, nullable=False)
    name: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    members: Mapped[List["RoomMember"]] = relationship(
        back_populates="room", cascade="all, delete-orphan"
    )
    expenses: Mapped[List["Expense"]] = relationship(
        back_populates="room", cascade="all, delete-orphan"
    )


class RoomMember(Base):
    __tablename__ = "room_members"
    __table_args__ = (UniqueConstraint("room_id", "name", name="uq_room_members_room_name"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    room_id: Mapped[int] = mapped_column(
        ForeignKey("rooms.id", ondelete="CASCADE"), nullable=False, index=True
    )
    name: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    room: Mapped["Room"] = relationship(back_populates="members")
    splits: Mapped[List["ExpenseSplit"]] = relationship(
        back_populates="member", cascade="all, delete-orphan"
    )
    expenses_paid: Mapped[List["Expense"]] = relationship(
        back_populates="payer", cascade="all, delete-orphan"
    )


class Expense(Base):
    __tablename__ = "expenses"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    description: Mapped[str] = mapped_column(String, nullable=False)
    payer_id: Mapped[int] = mapped_column(
        ForeignKey("room_members.id"), nullable=False
    )
    room_id: Mapped[int] = mapped_column(
        ForeignKey("rooms.id", ondelete="CASCADE"), nullable=False, index=True
    )
    date: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    payer: Mapped["RoomMember"] = relationship(back_populates="expenses_paid")
    room: Mapped["Room"] = relationship(back_populates="expenses")
    splits: Mapped[List["ExpenseSplit"]] = relationship(
        back_populates="expense", cascade="all, delete-orphan"
    )


class ExpenseSplit(Base):
    __tablename__ = "expense_splits"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    expense_id: Mapped[int] = mapped_column(
        ForeignKey("expenses.id"), nullable=False
    )
    member_id: Mapped[int] = mapped_column(
        ForeignKey("room_members.id"), nullable=False
    )
    share: Mapped[float] = mapped_column(Float, nullable=False)

    expense: Mapped["Expense"] = relationship(back_populates="splits")
    member: Mapped["RoomMember"] = relationship(back_populates="splits")


# Legacy global Person model — kept for backward-compatible endpoints.
class Person(Base):
    __tablename__ = "persons"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    splits: Mapped[List["LegacyExpenseSplit"]] = relationship(
        back_populates="person", cascade="all, delete-orphan"
    )
    expenses_paid: Mapped[List["LegacyExpense"]] = relationship(
        back_populates="payer", cascade="all, delete-orphan"
    )


# Legacy split table — kept for backward-compatible endpoints.
class LegacyExpenseSplit(Base):
    __tablename__ = "expense_splits_legacy"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    expense_id: Mapped[int] = mapped_column(
        ForeignKey("expenses_legacy.id"), nullable=False
    )
    person_id: Mapped[int] = mapped_column(ForeignKey("persons.id"), nullable=False)
    share: Mapped[float] = mapped_column(Float, nullable=False)

    expense: Mapped["LegacyExpense"] = relationship(back_populates="splits")
    person: Mapped["Person"] = relationship(back_populates="splits")


class LegacyExpense(Base):
    __tablename__ = "expenses_legacy"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    description: Mapped[str] = mapped_column(String, nullable=False)
    payer_id: Mapped[int] = mapped_column(ForeignKey("persons.id"), nullable=False)
    date: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    payer: Mapped["Person"] = relationship(back_populates="expenses_paid")
    splits: Mapped[List["LegacyExpenseSplit"]] = relationship(
        back_populates="expense", cascade="all, delete-orphan"
    )


# ---------- Schemas ----------

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


class RoomCreate(BaseModel):
    name: Optional[str] = None


class RoomOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    code: str
    name: Optional[str]
    created_at: datetime


class RoomMemberCreate(BaseModel):
    name: str


class RoomMemberOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    room_id: int
    name: str
    created_at: datetime


class RoomSplitIn(BaseModel):
    member_id: int
    share: float


class RoomExpenseCreate(BaseModel):
    amount: float
    description: str
    payer_id: int
    date: Optional[datetime] = None
    splits: Optional[List[RoomSplitIn]] = None


class RoomSplitOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    member_id: int
    share: float


class RoomExpenseOut(BaseModel):
    id: int
    amount: float
    description: str
    payer_id: int
    payer_name: str
    date: datetime
    created_at: datetime
    splits: List[RoomSplitOut]


class RoomBalanceEntry(BaseModel):
    from_person: int
    from_person_name: str
    to_person: int
    to_person_name: str
    amount: float


class RoomBalanceResponse(BaseModel):
    balances: List[RoomBalanceEntry]


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


# ---------- Helpers ----------

def _serialize_expense(expense: Expense, payer_name: str) -> ExpenseOut:
    return ExpenseOut(
        id=expense.id,
        amount=expense.amount,
        description=expense.description,
        payer_id=expense.payer_id,
        payer_name=payer_name,
        date=expense.date,
        created_at=expense.created_at,
        splits=[SplitOut(person_id=s.person_id, share=s.share) for s in expense.splits],
    )


def _serialize_room_expense(expense: Expense, payer_name: str) -> RoomExpenseOut:
    return RoomExpenseOut(
        id=expense.id,
        amount=expense.amount,
        description=expense.description,
        payer_id=expense.payer_id,
        payer_name=payer_name,
        date=expense.date,
        created_at=expense.created_at,
        splits=[RoomSplitOut(member_id=s.member_id, share=s.share) for s in expense.splits],
    )


async def _get_room_by_code(session: AsyncSession, code: str) -> Room:
    result = await session.execute(select(Room).where(Room.code == code))
    room = result.scalars().first()
    if room is None:
        raise HTTPException(status_code=404, detail="Room not found")
    return room


async def _generate_unique_room_code(session: AsyncSession, max_attempts: int = 25) -> str:
    for _ in range(max_attempts):
        code = _generate_room_code()
        result = await session.execute(select(Room.id).where(Room.code == code))
        if result.scalars().first() is None:
            return code
    raise HTTPException(status_code=500, detail="Could not generate a unique room code")


# ---------- Legacy global endpoints (backward compat) ----------

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
            select(LegacyExpense, Person.name)
            .join(Person, LegacyExpense.payer_id == Person.id)
            .options(selectinload(LegacyExpense.splits))
            .order_by(LegacyExpense.date.desc(), LegacyExpense.id.desc())
        )
        rows = result.all()
        return [
            ExpenseOut(
                id=expense.id,
                amount=expense.amount,
                description=expense.description,
                payer_id=expense.payer_id,
                payer_name=name,
                date=expense.date,
                created_at=expense.created_at,
                splits=[SplitOut(person_id=s.person_id, share=s.share) for s in expense.splits],
            )
            for expense, name in rows  # type: ignore[misc]
        ]


@app.post("/api/expenses", response_model=ExpenseOut)
async def create_expense(payload: ExpenseCreate) -> ExpenseOut:
    async with async_session_maker() as session:
        payer = await session.get(Person, payload.payer_id)
        if payer is None:
            raise HTTPException(status_code=404, detail="Payer not found")

        expense_date = payload.date
        if expense_date and expense_date.tzinfo is not None:
            expense_date = expense_date.replace(tzinfo=None)

        expense = LegacyExpense(
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
                    LegacyExpenseSplit(
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
                    LegacyExpenseSplit(
                        expense_id=expense.id,
                        person_id=person.id,
                        share=share,
                    )
                )

        await session.commit()
        result = await session.execute(
            select(LegacyExpense)
            .options(selectinload(LegacyExpense.splits))
            .where(LegacyExpense.id == expense.id)
        )
        expense = result.scalars().first()
        return ExpenseOut(
            id=expense.id,
            amount=expense.amount,
            description=expense.description,
            payer_id=expense.payer_id,
            payer_name=payer.name,
            date=expense.date,
            created_at=expense.created_at,
            splits=[SplitOut(person_id=s.person_id, share=s.share) for s in expense.splits],
        )


@app.delete("/api/expenses/{expense_id}")
async def delete_expense(expense_id: int) -> dict:
    async with async_session_maker() as session:
        expense = await session.get(LegacyExpense, expense_id)
        if expense is None:
            raise HTTPException(status_code=404, detail="Expense not found")
        await session.execute(delete(LegacyExpense).where(LegacyExpense.id == expense_id))
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
            select(LegacyExpense).options(selectinload(LegacyExpense.splits))
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


# ---------- Room endpoints ----------

@app.post("/api/rooms", response_model=RoomOut)
async def create_room(payload: RoomCreate) -> RoomOut:
    name = payload.name.strip() if payload.name else None
    name = name or None
    async with async_session_maker() as session:
        code = await _generate_unique_room_code(session)
        room = Room(code=code, name=name)
        session.add(room)
        await session.commit()
        await session.refresh(room)
        return RoomOut.model_validate(room)


@app.get("/api/rooms/{code}", response_model=RoomOut)
async def get_room(code: str) -> RoomOut:
    async with async_session_maker() as session:
        room = await _get_room_by_code(session, code)
        return RoomOut.model_validate(room)


@app.delete("/api/rooms/{code}")
async def delete_room(code: str) -> dict:
    async with async_session_maker() as session:
        room = await _get_room_by_code(session, code)
        await session.execute(delete(Room).where(Room.id == room.id))
        await session.commit()
        return {"ok": True}


@app.post(
    "/api/rooms/{code}/members", response_model=RoomMemberOut, status_code=201
)
async def add_room_member(code: str, payload: RoomMemberCreate) -> RoomMemberOut:
    name = payload.name.strip()
    if not name:
        raise HTTPException(status_code=400, detail="Name is required")
    async with async_session_maker() as session:
        room = await _get_room_by_code(session, code)
        existing = await session.execute(
            select(RoomMember).where(
                RoomMember.room_id == room.id, RoomMember.name == name
            )
        )
        if existing.scalars().first() is not None:
            raise HTTPException(
                status_code=409,
                detail=f"Member named '{name}' already exists in this room",
            )
        member = RoomMember(room_id=room.id, name=name)
        session.add(member)
        try:
            await session.commit()
        except Exception:
            await session.rollback()
            raise HTTPException(
                status_code=409,
                detail=f"Member named '{name}' already exists in this room",
            )
        await session.refresh(member)
        return RoomMemberOut.model_validate(member)


@app.get(
    "/api/rooms/{code}/members", response_model=List[RoomMemberOut]
)
async def list_room_members(code: str) -> List[RoomMemberOut]:
    async with async_session_maker() as session:
        room = await _get_room_by_code(session, code)
        result = await session.execute(
            select(RoomMember)
            .where(RoomMember.room_id == room.id)
            .order_by(RoomMember.id)
        )
        members = result.scalars().all()
        return [RoomMemberOut.model_validate(m) for m in members]


@app.delete("/api/rooms/{code}/members/{member_id}")
async def delete_room_member(code: str, member_id: int) -> dict:
    async with async_session_maker() as session:
        room = await _get_room_by_code(session, code)
        member = await session.get(RoomMember, member_id)
        if member is None or member.room_id != room.id:
            raise HTTPException(status_code=404, detail="Member not found")
        await session.execute(
            delete(RoomMember).where(RoomMember.id == member_id)
        )
        await session.commit()
        return {"ok": True}


@app.post(
    "/api/rooms/{code}/expenses", response_model=RoomExpenseOut, status_code=201
)
async def create_room_expense(
    code: str, payload: RoomExpenseCreate
) -> RoomExpenseOut:
    async with async_session_maker() as session:
        room = await _get_room_by_code(session, code)

        payer = await session.get(RoomMember, payload.payer_id)
        if payer is None or payer.room_id != room.id:
            raise HTTPException(status_code=404, detail="Payer not found in room")

        expense_date = payload.date
        if expense_date and expense_date.tzinfo is not None:
            expense_date = expense_date.replace(tzinfo=None)

        expense = Expense(
            room_id=room.id,
            amount=payload.amount,
            description=payload.description,
            payer_id=payload.payer_id,
            date=expense_date or datetime.utcnow(),
        )
        session.add(expense)
        await session.flush()

        if payload.splits:
            for split in payload.splits:
                member = await session.get(RoomMember, split.member_id)
                if member is None or member.room_id != room.id:
                    raise HTTPException(
                        status_code=404,
                        detail=f"Member {split.member_id} not found in room",
                    )
                session.add(
                    ExpenseSplit(
                        expense_id=expense.id,
                        member_id=split.member_id,
                        share=split.share,
                    )
                )
        else:
            members_result = await session.execute(
                select(RoomMember).where(RoomMember.room_id == room.id)
            )
            members = members_result.scalars().all()
            if not members:
                raise HTTPException(
                    status_code=400,
                    detail="No members available to split expense equally",
                )
            share = payload.amount / len(members)
            for member in members:
                session.add(
                    ExpenseSplit(
                        expense_id=expense.id,
                        member_id=member.id,
                        share=share,
                    )
                )

        await session.commit()

        result = await session.execute(
            select(Expense)
            .options(selectinload(Expense.splits))
            .where(Expense.id == expense.id)
        )
        expense = result.scalars().first()
        return _serialize_room_expense(expense, payer.name)


@app.get(
    "/api/rooms/{code}/expenses", response_model=List[RoomExpenseOut]
)
async def list_room_expenses(code: str) -> List[RoomExpenseOut]:
    async with async_session_maker() as session:
        room = await _get_room_by_code(session, code)
        result = await session.execute(
            select(Expense, RoomMember.name)
            .join(RoomMember, Expense.payer_id == RoomMember.id)
            .options(selectinload(Expense.splits))
            .where(Expense.room_id == room.id)
            .order_by(Expense.date.desc(), Expense.id.desc())
        )
        rows = result.all()
        return [_serialize_room_expense(expense, name) for expense, name in rows]  # type: ignore[misc]


@app.delete("/api/rooms/{code}/expenses/{expense_id}")
async def delete_room_expense(code: str, expense_id: int) -> dict:
    async with async_session_maker() as session:
        room = await _get_room_by_code(session, code)
        expense = await session.get(Expense, expense_id)
        if expense is None or expense.room_id != room.id:
            raise HTTPException(status_code=404, detail="Expense not found")
        await session.execute(delete(Expense).where(Expense.id == expense_id))
        await session.commit()
        return {"ok": True}


@app.get(
    "/api/rooms/{code}/balance", response_model=RoomBalanceResponse
)
async def get_room_balance(code: str) -> RoomBalanceResponse:
    async with async_session_maker() as session:
        room = await _get_room_by_code(session, code)

        members_result = await session.execute(
            select(RoomMember).where(RoomMember.room_id == room.id)
        )
        members = {m.id: m for m in members_result.scalars().all()}

        expenses_result = await session.execute(
            select(Expense)
            .options(selectinload(Expense.splits))
            .where(Expense.room_id == room.id)
        )
        expenses = expenses_result.scalars().all()

        net: dict[int, float] = {mid: 0.0 for mid in members}
        for expense in expenses:
            net[expense.payer_id] = net.get(expense.payer_id, 0.0) + expense.amount
            for split in expense.splits:
                net[split.member_id] = net.get(split.member_id, 0.0) - split.share

        payments = _minimize_transactions(net)
        entries = [
            RoomBalanceEntry(
                from_person=p["from"],
                from_person_name=members[p["from"]].name,
                to_person=p["to"],
                to_person_name=members[p["to"]].name,
                amount=p["amount"],
            )
            for p in payments
        ]
        return RoomBalanceResponse(balances=entries)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
