import { useCallback, useEffect, useState } from 'react'
import Header from './Header.jsx'
import Stats from './Stats.jsx'
import ExpenseForm from './ExpenseForm.jsx'
import Balance from './Balance.jsx'
import Persons from './Persons.jsx'
import ExpensesTable from './ExpensesTable.jsx'
import Toast from './Toast.jsx'

export default function RoomView({ api, room, onLeave }) {
  const [members, setMembers] = useState([])
  const [expenses, setExpenses] = useState([])
  const [balance, setBalance] = useState({ balances: [] })
  const [loading, setLoading] = useState(true)
  const [toast, setToast] = useState(null)
  const [copied, setCopied] = useState(false)

  const showToast = useCallback((message, type = 'success') => {
    setToast({ message, type, id: Date.now() })
  }, [])

  const refresh = useCallback(async () => {
    try {
      const [ms, es, bs] = await Promise.all([
        api.listMembers(room.code),
        api.listExpenses(room.code),
        api.getBalance(room.code),
      ])
      setMembers(ms)
      setExpenses(es)
      setBalance(bs)
    } catch (err) {
      showToast(err.message || 'Failed to load', 'error')
    }
  }, [api, room.code, showToast])

  useEffect(() => {
    let cancelled = false
    setLoading(true)
    refresh().finally(() => {
      if (!cancelled) setLoading(false)
    })
    return () => {
      cancelled = true
    }
  }, [refresh])

  const handleAddMember = useCallback(
    async (name) => {
      try {
        await api.addMember(room.code, name)
        await refresh()
        showToast(`Added ${name}`)
      } catch (err) {
        showToast(err.message || 'Could not add member', 'error')
        throw err
      }
    },
    [api, room.code, refresh, showToast]
  )

  const handleDeleteMember = useCallback(
    async (id) => {
      try {
        await api.deleteMember(room.code, id)
        await refresh()
        showToast('Member removed')
      } catch (err) {
        showToast(err.message || 'Could not delete', 'error')
      }
    },
    [api, room.code, refresh, showToast]
  )

  const handleAddExpense = useCallback(
    async (payload) => {
      try {
        await api.createExpense(room.code, payload)
        await refresh()
        showToast('Expense added')
      } catch (err) {
        showToast(err.message || 'Could not save expense', 'error')
        throw err
      }
    },
    [api, room.code, refresh, showToast]
  )

  const handleDeleteExpense = useCallback(
    async (id) => {
      try {
        await api.deleteExpense(room.code, id)
        await refresh()
        showToast('Expense removed')
      } catch (err) {
        showToast(err.message || 'Could not delete expense', 'error')
      }
    },
    [api, room.code, refresh, showToast]
  )

  const handleDeleteRoom = useCallback(async () => {
    const ok = window.confirm(
      `Delete room "${room.name || room.code}"? This removes all members and expenses.`
    )
    if (!ok) return
    try {
      await api.deleteRoom(room.code)
      api.clearStoredCode()
      showToast('Room deleted')
      onLeave()
    } catch (err) {
      showToast(err.message || 'Could not delete room', 'error')
    }
  }, [api, room, onLeave, showToast])

  const handleCopyCode = useCallback(async () => {
    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(room.code)
      } else {
        const el = document.createElement('textarea')
        el.value = room.code
        document.body.appendChild(el)
        el.select()
        document.execCommand('copy')
        document.body.removeChild(el)
      }
      setCopied(true)
      window.setTimeout(() => setCopied(false), 1600)
    } catch {
      showToast('Could not copy code', 'error')
    }
  }, [room.code, showToast])

  const totalAmount = expenses.reduce(
    (sum, e) => sum + Number(e.amount || 0),
    0
  )

  return (
    <div className="app">
      <div className={`loading-bar${loading ? ' is-loading' : ''}`} />
      <Header />

      <div className="room-banner">
        <div className="container room-banner-inner">
          <div className="room-banner-info">
            <div className="room-banner-label">Room</div>
            <div className="room-banner-name">
              {room.name || 'Untitled room'}
            </div>
          </div>
          <button
            type="button"
            className="room-code"
            onClick={handleCopyCode}
            title="Copy code"
            aria-label="Copy room code"
          >
            <span className="room-code-label">code</span>
            <span className="room-code-value">{room.code}</span>
            <span className="room-code-copy">
              {copied ? 'copied' : 'copy'}
            </span>
          </button>
          <div className="room-banner-actions">
            <button
              type="button"
              className="btn btn-ghost"
              onClick={onLeave}
            >
              Leave
            </button>
            <button
              type="button"
              className="btn btn-ghost btn-danger"
              onClick={handleDeleteRoom}
            >
              Delete room
            </button>
          </div>
        </div>
      </div>

      <main className="main">
        <div className="container">
          <Stats
            personsCount={members.length}
            expensesCount={expenses.length}
            totalAmount={totalAmount}
          />

          <div className="grid">
            <ExpenseForm
              members={members}
              onSubmit={handleAddExpense}
            />
            <Balance balance={balance.balances} />
          </div>

          <div className="grid">
            <Persons
              persons={members}
              onAdd={handleAddMember}
              onDelete={handleDeleteMember}
            />
            <ExpensesTable
              expenses={expenses}
              members={members}
              onDelete={handleDeleteExpense}
            />
          </div>
        </div>
      </main>

      <footer className="footer">
        <div className="container">
          tabbr · keep tabs, split bills, settle up
        </div>
      </footer>

      <Toast toast={toast} onDismiss={() => setToast(null)} />
    </div>
  )
}
