import { formatCurrency } from '../utils.js'

export default function Stats({ personsCount, expensesCount, totalAmount }) {
  return (
    <section className="stats" aria-label="Summary">
      <div className="stat-card">
        <span className="stat-label">People</span>
        <span className="stat-value">{personsCount}</span>
      </div>
      <div className="stat-card">
        <span className="stat-label">Expenses</span>
        <span className="stat-value">{expensesCount}</span>
      </div>
      <div className="stat-card">
        <span className="stat-label">Total Spent</span>
        <span className="stat-value">
          {formatCurrency(totalAmount)}
          <span className="currency">EUR</span>
        </span>
      </div>
    </section>
  )
}
