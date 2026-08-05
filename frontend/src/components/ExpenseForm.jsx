import { useEffect, useMemo, useState } from 'react'
import { todayInputValue } from '../utils.js'

const MODE_EQUAL = 'equal'
const MODE_CUSTOM = 'custom'

export default function ExpenseForm({ persons, onSubmit }) {
  const [amount, setAmount] = useState('')
  const [description, setDescription] = useState('')
  const [payerId, setPayerId] = useState('')
  const [date, setDate] = useState(todayInputValue())
  const [mode, setMode] = useState(MODE_EQUAL)
  const [included, setIncluded] = useState({})
  const [shares, setShares] = useState({})
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    if (!persons.length) {
      setPayerId('')
      return
    }
    if (!persons.find((p) => String(p.id) === String(payerId))) {
      setPayerId(String(persons[0].id))
    }
  }, [persons, payerId])

  useEffect(() => {
    const next = {}
    persons.forEach((p) => {
      next[p.id] = true
    })
    setIncluded(next)
  }, [persons])

  const amountNum = Number(amount)
  const includedPersons = useMemo(
    () => persons.filter((p) => included[p.id]),
    [persons, included]
  )

  const splitsTotal = useMemo(() => {
    if (mode !== MODE_CUSTOM) return 0
    return Object.entries(shares).reduce((sum, [pid, val]) => {
      if (!included[pid]) return sum
      const n = Number(val)
      return sum + (Number.isFinite(n) ? n : 0)
    }, 0)
  }, [mode, shares, included])

  const splitsValid = useMemo(() => {
    if (mode !== MODE_CUSTOM) return true
    if (includedPersons.length === 0) return false
    const diff = Math.abs(amountNum - splitsTotal)
    return diff < 0.01 && splitsTotal > 0
  }, [mode, amountNum, splitsTotal, includedPersons.length])

  const splitsMismatch = mode === MODE_CUSTOM && amountNum > 0 && !splitsValid

  const canSubmit =
    !submitting &&
    persons.length > 0 &&
    description.trim().length > 0 &&
    Number.isFinite(amountNum) &&
    amountNum > 0 &&
    payerId &&
    splitsValid

  function togglePerson(id) {
    setIncluded((prev) => ({ ...prev, [id]: !prev[id] }))
  }

  function distributeEvenly() {
    if (!amountNum || includedPersons.length === 0) return
    const each = amountNum / includedPersons.length
    const next = { ...shares }
    persons.forEach((p) => {
      next[p.id] = included[p.id] ? Number(each.toFixed(2)) : 0
    })
    setShares(next)
  }

  async function handleSubmit(e) {
    e.preventDefault()
    if (!canSubmit) return
    setSubmitting(true)
    try {
      const payload = {
        amount: amountNum,
        description: description.trim(),
        payer_id: Number(payerId),
        date: new Date(`${date}T12:00:00`).toISOString(),
      }
      if (mode === MODE_CUSTOM) {
        payload.splits = includedPersons.map((p) => ({
          person_id: p.id,
          share: Number(shares[p.id] || 0),
        }))
      }
      await onSubmit(payload)
      setAmount('')
      setDescription('')
      setDate(todayInputValue())
      setMode(MODE_EQUAL)
      const reset = {}
      persons.forEach((p) => {
        reset[p.id] = true
      })
      setIncluded(reset)
      setShares({})
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <section className="card">
      <header className="card-header">
        <h2 className="card-title">
          <span className="index">/01</span>
          Add Expense
        </h2>
      </header>
      <div className="card-body">
        {persons.length === 0 ? (
          <div className="empty">
            Add people first to start splitting expenses.
          </div>
        ) : (
          <form onSubmit={handleSubmit}>
            <div className="field">
              <label className="field-label" htmlFor="amount">
                Amount
              </label>
              <input
                id="amount"
                className="input"
                type="number"
                step="0.01"
                min="0"
                placeholder="0.00"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                inputMode="decimal"
              />
            </div>

            <div className="field">
              <label className="field-label" htmlFor="description">
                Description
              </label>
              <input
                id="description"
                className="input"
                type="text"
                placeholder="Dinner, taxi, tickets…"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                maxLength={120}
              />
            </div>

            <div className="field-row">
              <div className="field">
                <label className="field-label" htmlFor="payer">
                  Paid by
                </label>
                <select
                  id="payer"
                  className="select"
                  value={payerId}
                  onChange={(e) => setPayerId(e.target.value)}
                >
                  {persons.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name}
                    </option>
                  ))}
                </select>
              </div>
              <div className="field">
                <label className="field-label" htmlFor="date">
                  Date
                </label>
                <input
                  id="date"
                  className="input"
                  type="date"
                  value={date}
                  onChange={(e) => setDate(e.target.value)}
                />
              </div>
            </div>

            <div className="field">
              <span className="field-label">Split</span>
              <div
                className="toggle"
                role="tablist"
                aria-label="Split mode"
              >
                <button
                  type="button"
                  className={`toggle-option${
                    mode === MODE_EQUAL ? ' is-active' : ''
                  }`}
                  onClick={() => setMode(MODE_EQUAL)}
                  role="tab"
                  aria-selected={mode === MODE_EQUAL}
                >
                  Equal split
                </button>
                <button
                  type="button"
                  className={`toggle-option${
                    mode === MODE_CUSTOM ? ' is-active' : ''
                  }`}
                  onClick={() => setMode(MODE_CUSTOM)}
                  role="tab"
                  aria-selected={mode === MODE_CUSTOM}
                >
                  Custom splits
                </button>
              </div>
            </div>

            {mode === MODE_EQUAL ? (
              <div className="field">
                <span className="field-label">Between</span>
                <div className="split-list">
                  {persons.map((p) => (
                    <label
                      key={p.id}
                      className={`split-row${
                        included[p.id] ? ' is-included' : ''
                      }`}
                    >
                      <span
                        className={`split-name${
                          !included[p.id] ? ' is-muted' : ''
                        }`}
                      >
                        <input
                          type="checkbox"
                          className="split-checkbox"
                          checked={!!included[p.id]}
                          onChange={() => togglePerson(p.id)}
                        />
                        {p.name}
                      </span>
                      <span
                        className="split-input"
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'flex-end',
                          padding: '0 10px',
                        }}
                      >
                        {included[p.id] && includedPersons.length > 0
                          ? (amountNum / includedPersons.length || 0).toFixed(
                              2
                            )
                          : '—'}
                      </span>
                    </label>
                  ))}
                </div>
              </div>
            ) : (
              <div className="field">
                <div
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginBottom: 6,
                  }}
                >
                  <span className="field-label">Each share</span>
                  <button
                    type="button"
                    className="btn btn-ghost"
                    style={{ height: 28, padding: '0 12px', fontSize: 12 }}
                    onClick={distributeEvenly}
                    disabled={!amountNum || includedPersons.length === 0}
                  >
                    Distribute evenly
                  </button>
                </div>
                <div className="split-list">
                  {persons.map((p) => (
                    <label
                      key={p.id}
                      className={`split-row${
                        included[p.id] ? ' is-included' : ''
                      }`}
                    >
                      <span
                        className={`split-name${
                          !included[p.id] ? ' is-muted' : ''
                        }`}
                      >
                        <input
                          type="checkbox"
                          className="split-checkbox"
                          checked={!!included[p.id]}
                          onChange={() => togglePerson(p.id)}
                        />
                        {p.name}
                      </span>
                      <input
                        type="number"
                        className="split-input"
                        min="0"
                        step="0.01"
                        value={shares[p.id] ?? ''}
                        disabled={!included[p.id]}
                        onChange={(e) =>
                          setShares((prev) => ({
                            ...prev,
                            [p.id]: e.target.value,
                          }))
                        }
                        placeholder="0.00"
                      />
                    </label>
                  ))}
                </div>
                <div className="split-hint">
                  <span>
                    {includedPersons.length} included ·{' '}
                    {formatNum(splitsTotal)}
                  </span>
                  <span
                    className={
                      splitsMismatch ? 'warn' : splitsValid ? 'ok' : ''
                    }
                  >
                    {amountNum > 0
                      ? `of ${amountNum.toFixed(2)}`
                      : 'enter amount'}
                  </span>
                </div>
              </div>
            )}

            <button
              type="submit"
              className="btn btn-primary btn-block"
              disabled={!canSubmit}
              style={{ marginTop: 16 }}
            >
              {submitting ? 'Saving…' : 'Add expense'}
            </button>
          </form>
        )}
      </div>
    </section>
  )
}

function formatNum(n) {
  if (!Number.isFinite(n)) return '—'
  return n.toFixed(2)
}
