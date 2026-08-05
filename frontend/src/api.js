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

const ROOM_STORAGE_KEY = 'tabbr.currentRoomCode'

function loadStoredCode() {
  try {
    return localStorage.getItem(ROOM_STORAGE_KEY) || null
  } catch {
    return null
  }
}

function storeCode(code) {
  try {
    if (code) localStorage.setItem(ROOM_STORAGE_KEY, code)
    else localStorage.removeItem(ROOM_STORAGE_KEY)
  } catch {}
}

export const api = {
  // Rooms
  createRoom: (name) =>
    request('/rooms', { method: 'POST', body: { name: name || null } }),
  getRoom: (code) => request(`/rooms/${code}`),
  deleteRoom: (code) => request(`/rooms/${code}`, { method: 'DELETE' }),

  // Members
  listMembers: (code) => request(`/rooms/${code}/members`),
  addMember: (code, name) =>
    request(`/rooms/${code}/members`, { method: 'POST', body: { name } }),
  deleteMember: (code, id) =>
    request(`/rooms/${code}/members/${id}`, { method: 'DELETE' }),

  // Expenses
  listExpenses: (code) => request(`/rooms/${code}/expenses`),
  createExpense: (code, payload) =>
    request(`/rooms/${code}/expenses`, { method: 'POST', body: payload }),
  deleteExpense: (code, id) =>
    request(`/rooms/${code}/expenses/${id}`, { method: 'DELETE' }),

  // Balance
  getBalance: (code) => request(`/rooms/${code}/balance`),

  // Local code persistence
  loadStoredCode,
  storeCode,
  clearStoredCode: () => storeCode(null),
}
