import { useCallback, useEffect, useState } from 'react'
import { api } from './api.js'
import Header from './components/Header.jsx'
import Stats from './components/Stats.jsx'
import ExpenseForm from './components/ExpenseForm.jsx'
import Balance from './components/Balance.jsx'
import Persons from './components/Persons.jsx'
import ExpensesTable from './components/ExpensesTable.jsx'
import Toast from './components/Toast.jsx'

function App() {
  const [persons, setPersons] = useState([])
  const [expenses, setExpenses] = useState([])
  const [balance, setBalance] = useState({ balances: [] })
  const [loading, setLoading] = useState(true)
  const [toast, setToast] = useState(null)

  const showToast = useCallback((message, type = 'success') => {
    setToast({ message, type, id: Date.now() })
  }, [])

  const refresh = useCallback(async () => {
    try {
      const [ps, es, bs] = await Promise.all([
        api.listPersons(),
        api.listExpenses(),
        api.getBalance(),
      ])
      setPersons(ps)
      setExpenses(es)
      setBalance(bs)
    } catch (err) {
      showToast(err.message || 'Failed to load', 'error')
    }
  }, [showToast])

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

  const handleAddPerson = useCallback(
    async (name) => {
      try {
        await api.createPerson(name)
        await refresh()
        showToast(`Added ${name}`)
      } catch (err) {
        showToast(err.message || 'Could not add person', 'error')
        throw err
      }
    },
    [refresh, showToast]
  )

  const handleDeletePerson = useCallback(
    async (id) => {
      try {
        await api.deletePerson(id)
        await refresh()
        showToast('Person removed')
      } catch (err) {
        showToast(err.message || 'Could not delete', 'error')
      }
    },
    [refresh, showToast]
  )

  const handleAddExpense = useCallback(
    async (payload) => {
      try {
        await api.createExpense(payload)
        await refresh()
        showToast('Expense added')
      } catch (err) {
        showToast(err.message || 'Could not save expense', 'error')
        throw err
      }
    },
    [refresh, showToast]
  )

  const handleDeleteExpense = useCallback(
    async (id) => {
      try {
        await api.deleteExpense(id)
        await refresh()
        showToast('Expense removed')
      } catch (err) {
        showToast(err.message || 'Could not delete expense', 'error')
      }
    },
    [refresh, showToast]
  )

  const totalAmount = expenses.reduce((sum, e) => sum + Number(e.amount || 0), 0)

  return (
    <div className="app">
      <div className={`loading-bar${loading ? ' is-loading' : ''}`} />
      <Header />
      <main className="main">
        <div className="container">
          <Stats
            personsCount={persons.length}
            expensesCount={expenses.length}
            totalAmount={totalAmount}
          />

          <div className="grid">
            <ExpenseForm
              persons={persons}
              onSubmit={handleAddExpense}
            />
            <Balance
              balance={balance.balances}
              persons={persons}
            />
          </div>

          <div className="grid">
            <Persons
              persons={persons}
              onAdd={handleAddPerson}
              onDelete={handleDeletePerson}
            />
            <ExpensesTable
              expenses={expenses}
              persons={persons}
              onDelete={handleDeleteExpense}
            />
          </div>
        </div>
      </main>

      <footer className="footer">
        <div className="container">
          tricount · split cleanly · all data lives on your local network
        </div>
      </footer>

      <Toast toast={toast} onDismiss={() => setToast(null)} />
    </div>
  )
}

export default App
