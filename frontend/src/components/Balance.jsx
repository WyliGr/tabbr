import { colorFor, formatCurrency, initials } from '../utils.js'

export default function Balance({ balance, persons }) {
  const balances = Array.isArray(balance) ? balance : []

  return (
    <section className="card">
      <header className="card-header">
        <h2 className="card-title">
          <span className="index">/02</span>
          Balance
        </h2>
        <span className="card-badge">
          {balances.length === 0
            ? 'settled'
            : `${balances.length} ${balances.length === 1 ? 'transfer' : 'transfers'}`}
        </span>
      </header>
      <div className="card-body">
        {balances.length === 0 ? (
          <div className="balance-settled">
            <div className="check" aria-hidden="true">
              <svg
                width="16"
                height="16"
                viewBox="0 0 16 16"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M3 8.5L6.5 12L13 4.5"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </div>
            <div className="title">All settled!</div>
            <div>Nobody owes anybody anything.</div>
          </div>
        ) : (
          <div className="balance-list">
            {balances.map((b, i) => (
              <article className="balance-item" key={`${b.from_person}-${b.to_person}-${i}`}>
                <div className="balance-flow">
                  <div
                    className="balance-avatar"
                    style={{ background: colorFor(b.from_person_name) }}
                    aria-hidden="true"
                  >
                    {initials(b.from_person_name)}
                  </div>
                  <span className="arrow" aria-hidden="true">
                    →
                  </span>
                  <div
                    className="balance-avatar"
                    style={{ background: colorFor(b.to_person_name) }}
                    aria-hidden="true"
                  >
                    {initials(b.to_person_name)}
                  </div>
                </div>
                <div className="balance-flow-names">
                  <span className="balance-name">{b.from_person_name}</span>
                  <span style={{ color: 'var(--text-tertiary)' }}>owes</span>
                  <span className="balance-name">{b.to_person_name}</span>
                </div>
                <div className="balance-amount">
                  {formatCurrency(b.amount)}
                  <span className="currency">€</span>
                </div>
              </article>
            ))}
          </div>
        )}
      </div>
    </section>
  )
}
