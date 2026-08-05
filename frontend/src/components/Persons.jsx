import { useState } from 'react'
import { colorFor, initials } from '../utils.js'

export default function Persons({ persons, onAdd, onDelete }) {
  const [name, setName] = useState('')
  const [busy, setBusy] = useState(false)

  async function handleSubmit(e) {
    e.preventDefault()
    const trimmed = name.trim()
    if (!trimmed || busy) return
    setBusy(true)
    try {
      await onAdd(trimmed)
      setName('')
    } catch {
      // toast handled in parent
    } finally {
      setBusy(false)
    }
  }

  return (
    <section className="card">
      <header className="card-header">
        <h2 className="card-title">
          <span className="index">/03</span>
          People
        </h2>
        <span className="card-badge">{persons.length}</span>
      </header>
      <div className="card-body">
        <form className="person-add" onSubmit={handleSubmit}>
          <input
            className="input"
            type="text"
            placeholder="Add a person…"
            value={name}
            onChange={(e) => setName(e.target.value)}
            maxLength={40}
            aria-label="New person name"
          />
          <button
            className="btn btn-primary"
            type="submit"
            disabled={!name.trim() || busy}
          >
            Add
          </button>
        </form>

        {persons.length === 0 ? (
          <div className="empty">No people yet — add one to begin.</div>
        ) : (
          <ul className="person-list">
            {persons.map((p) => (
              <li key={p.id} className="person-item">
                <span
                  className="avatar"
                  style={{ background: colorFor(p.name) }}
                  aria-hidden="true"
                >
                  {initials(p.name)}
                </span>
                <span className="person-name">{p.name}</span>
                <span className="person-id">#{p.id}</span>
                <button
                  type="button"
                  className="btn-icon"
                  aria-label={`Delete ${p.name}`}
                  title={`Delete ${p.name}`}
                  onClick={() => onDelete(p.id)}
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
              </li>
            ))}
          </ul>
        )}
      </div>
    </section>
  )
}
