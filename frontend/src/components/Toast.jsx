import { useEffect } from 'react'

export default function Toast({ toast, onDismiss }) {
  useEffect(() => {
    if (!toast) return undefined
    const t = setTimeout(onDismiss, 2400)
    return () => clearTimeout(t)
  }, [toast, onDismiss])

  if (!toast) return null

  return (
    <div className="toast-wrap" role="status" aria-live="polite">
      <div className={`toast${toast.type === 'error' ? ' error' : ''}`}>
        <span className="dot" aria-hidden="true" />
        <span>{toast.message}</span>
      </div>
    </div>
  )
}
