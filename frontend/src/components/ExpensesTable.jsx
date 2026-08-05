import { formatCurrency, formatDateShort } from '../utils.js'

export default function ExpensesTable({ expenses, members, onDelete }) {
  const byId = new Map(members.map((m) => [m.id, m]))

  return (
    <section className="card">
      <header className="card-header">
        <h2 className="card-title">
          <span className="index">/04</span>
          Expenses
        </h2>
        <span className="card-badge">
          {expenses.length} {expenses.length === 1 ? 'entry' : 'entries'}
        </span>
      </header>
      {expenses.length === 0 ? (
        <div className="card-body">
          <div className="empty">
            No expenses yet — add one on the left to get going.
          </div>
        </div>
      ) : (
        <div className="table-scroll">
          <table className="expense-table">
            <thead>
              <tr>
                <th className="col-date">Date</th>
                <th>Description</th>
                <th className="col-payer">Payer</th>
                <th className="col-splits">Splits</th>
                <th className="col-amount">Amount</th>
                <th className="col-actions" aria-label="Actions" />
              </tr>
            </thead>
            <tbody>
              {expenses.map((e) => (
                <tr key={e.id}>
                  <td className="expense-date col-date">
                    {formatDateShort(e.date)}
                  </td>
                  <td className="expense-desc">{e.description}</td>
                  <td className="col-payer">
                    <span className="expense-payer">{e.payer_name}</span>
                  </td>
                  <td className="col-splits">
                    <div className="expense-splits">
                      {e.splits.map((s) => {
                        const member = byId.get(s.member_id)
                        return (
                          <span className="split-tag" key={s.member_id}>
                            {member?.name ?? `#${s.member_id}`}{' '}
                            {formatCurrency(s.share)}
                          </span>
                        )
                      })}
                    </div>
                  </td>
                  <td className="expense-amount col-amount">
                    {formatCurrency(e.amount)}
                    <span className="currency">€</span>
                  </td>
                  <td className="col-actions">
                    <button
                      type="button"
                      className="btn-icon"
                      aria-label={`Delete ${e.description}`}
                      title="Delete expense"
                      onClick={() => onDelete(e.id)}
                    >
                      <svg
                        width="14"
                        height="14"
                        viewBox="0 0 14 14"
                        fill="none"
                        xmlns="http://www.w3.org/2000/svg"
                      >
                        <path
                          d="M3 3L11 11M11 3L3 11"
                          stroke="currentColor"
                          strokeWidth="1.5"
                          strokeLinecap="round"
                        />
                      </svg>
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </section>
  )
}
