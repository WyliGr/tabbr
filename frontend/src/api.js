const BASE = '/api'

async function request(path, options = {}) {
  const opts = {
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
    ...options,
  }
  if (opts.body && typeof opts.body !== 'string') {
    opts.body = JSON.stringify(opts.body)
  }
  const res = await fetch(`${BASE}${path}`, opts)
  if (!res.ok) {
    let detail = `${res.status} ${res.statusText}`
    try {
      const data = await res.json()
      if (data?.detail) detail = data.detail
    } catch {}
    throw new Error(detail)
  }
  if (res.status === 204) return null
  return res.json()
}

export const api = {
  listPersons: () => request('/persons'),
  createPerson: (name) => request('/persons', { method: 'POST', body: { name } }),
  deletePerson: (id) => request(`/persons/${id}`, { method: 'DELETE' }),

  listExpenses: () => request('/expenses'),
  createExpense: (payload) =>
    request('/expenses', { method: 'POST', body: payload }),
  deleteExpense: (id) => request(`/expenses/${id}`, { method: 'DELETE' }),

  getBalance: () => request('/balance'),
}
