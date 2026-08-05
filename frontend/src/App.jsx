import { useCallback, useEffect, useState } from 'react'
import { api } from './api.js'
import Landing from './components/Landing.jsx'
import RoomView from './components/RoomView.jsx'
import Toast from './components/Toast.jsx'

function App() {
  const [room, setRoom] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [toast, setToast] = useState(null)

  const showToast = useCallback((message, type = 'success') => {
    setToast({ message, type, id: Date.now() })
  }, [])

  useEffect(() => {
    let cancelled = false
    const code = api.loadStoredCode()
    if (!code) {
      setLoading(false)
      return
    }
    setLoading(true)
    api
      .getRoom(code)
      .then((r) => {
        if (cancelled) return
        setRoom(r)
      })
      .catch((err) => {
        if (cancelled) return
        api.clearStoredCode()
        setError(err.message || 'Could not load room')
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [])

  const handleJoined = useCallback((r) => {
    setRoom(r)
    setError(null)
  }, [])

  const handleLeave = useCallback(() => {
    api.clearStoredCode()
    setRoom(null)
  }, [])

  if (loading) {
    return (
      <div className="app">
        <div className="loading-bar is-loading" />
      </div>
    )
  }

  if (room) {
    return <RoomView api={api} room={room} onLeave={handleLeave} />
  }

  return (
    <>
      <Landing api={api} onJoined={handleJoined} />
      <Toast
        toast={error ? { message: error, type: 'error', id: Date.now() } : toast}
        onDismiss={() => {
          setError(null)
          setToast(null)
        }}
      />
    </>
  )
}

export default App
