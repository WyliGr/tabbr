export default function Header() {
  return (
    <header className="header">
      <div className="container header-inner">
        <div className="brand">
          <span className="brand-dot" aria-hidden="true" />
          <span className="brand-name">Tricount</span>
        </div>
        <div className="header-meta">
          <span className="live-dot" aria-hidden="true" />
          <span>online</span>
        </div>
      </div>
    </header>
  )
}
