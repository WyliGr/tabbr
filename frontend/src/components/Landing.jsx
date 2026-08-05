import { useCallback, useEffect, useState } from 'react'

const CODE_LENGTH = 5

export default function Landing({ api, onJoined }) {
  const [mode, setMode] = useState('idle') // 'idle' | 'create' | 'join'
  const [code, setCode] = useState('')
  const [name, setName] = useState('')
  const [error, setError] = useState(null)
  const [busy, setBusy] = useState(false)

  useEffect(() => {
    if (mode !== 'join') return
    setCode((prev) => prev.toUpperCase().replace(/[^A-Z]/g, '').slice(0, CODE_LENGTH))
  }, [mode])

  const handleCreate = useCallback(
    async (e) => {
      e?.preventDefault?.()
      setError(null)
      setBusy(true)
      try {
        const trimmed = name.trim()
        const room = await api.createRoom(trimmed || null)
        api.storeCode(room.code)
        onJoined(room)
      } catch (err) {
        setError(err.message || 'Could not create room')
      } finally {
        setBusy(false)
      }
    },
    [api, name, onJoined]
  )

  const handleJoin = useCallback(
    async (e) => {
      e?.preventDefault?.()
      setError(null)
      const normalized = code.toUpperCase().replace(/[^A-Z]/g, '')
      if (normalized.length !== CODE_LENGTH) {
        setError(`Room code must be ${CODE_LENGTH} letters`)
        return
      }
      setBusy(true)
      try {
        const room = await api.getRoom(normalized)
        api.storeCode(room.code)
        onJoined(room)
      } catch (err) {
        setError(err.message || 'Room not found')
      } finally {
        setBusy(false)
      }
    },
    [api, code, onJoined]
  )

  if (mode === 'create') {
    return (
      <div className="landing">
        <form className="landing-card" onSubmit={handleCreate}>
          <button
            type="button"
            className="landing-back"
            onClick={() => {
              setMode('idle')
              setError(null)
            }}
            aria-label="Back"
          >
            ←
          </button>
          <div className="landing-eyebrow">New room</div>
          <h1 className="landing-title">Create a room</h1>
          <p className="landing-sub">
            Give it a name (optional) — we'll generate a 5-letter code to share.
          </p>
          <div className="field">
            <label className="field-label" htmlFor="room-name">
              Name
            </label>
            <input
              id="room-name"
              className="input"
              type="text"
              placeholder="e.g. Barcelona trip"
              value={name}
              onChange={(e) => setName(e.target.value)}
              maxLength={60}
              autoFocus
            />
          </div>
          {error && <div className="landing-error">{error}</div>}
          <button
            type="submit"
            className="btn btn-primary btn-block"
            disabled={busy}
          >
            {busy ? 'Creating…' : 'Create room'}
          </button>
        </form>
      </div>
    )
  }

  if (mode === 'join') {
    return (
      <div className="landing">
        <form className="landing-card" onSubmit={handleJoin}>
          <button
            type="button"
            className="landing-back"
            onClick={() => {
              setMode('idle')
              setError(null)
              setCode('')
            }}
            aria-label="Back"
          >
            ←
          </button>
          <div className="landing-eyebrow">Existing room</div>
          <h1 className="landing-title">Join a room</h1>
          <p className="landing-sub">
            Enter the 5-letter code your group shared with you.
          </p>
          <div className="field">
            <label className="field-label" htmlFor="room-code">
              Room code
            </label>
            <input
              id="room-code"
              className="input landing-code"
              type="text"
              placeholder="ABCDE"
              value={code}
              onChange={(e) =>
                setCode(
                  e.target.value
                    .toUpperCase()
                    .replace(/[^A-Z]/g, '')
                    .slice(0, CODE_LENGTH)
                )
              }
              maxLength={CODE_LENGTH}
              autoFocus
              autoComplete="off"
              spellCheck={false}
            />
          </div>
          {error && <div className="landing-error">{error}</div>}
          <button
            type="submit"
            className="btn btn-primary btn-block"
            disabled={busy || code.length !== CODE_LENGTH}
          >
            {busy ? 'Joining…' : 'Join room'}
          </button>
        </form>
      </div>
    )
  }

  return (
    <div className="landing">
      <div className="landing-card">
        <div className="landing-eyebrow">Tabbr</div>
        <h1 className="landing-title">Split bills with your group</h1>
        <p className="landing-sub">
          Create a room to start a new shared expense, or join an existing one
          with a 5-letter code.
        </p>
        <div className="landing-actions">
          <button
            type="button"
            className="btn btn-primary btn-block"
            onClick={() => setMode('create')}
          >
            Create a room
          </button>
          <button
            type="button"
            className="btn btn-ghost btn-block"
            onClick={() => setMode('join')}
          >
            Join a room
          </button>
        </div>
      </div>
    </div>
  )
}
