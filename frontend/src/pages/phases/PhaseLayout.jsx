import { useNavigate } from 'react-router-dom'
import MioMascot from '../../components/common/MioMascot'
import './PhaseLayout.css'

export default function PhaseLayout({ title, subtitle, icon, variant, mioVariant = 'happy', heroMsg, heroSub, mottoMsg, focusItems, sections, sideNav }) {
  const navigate = useNavigate()

  return (
    <div className="phase-layout">
      {/* Top bar */}
      <div className="phase-layout__topbar">
        <button className="phase-layout__back" onClick={() => navigate('/journey')}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
            <path d="M15 19l-7-7 7-7" stroke="var(--text-dark)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
        <div className="phase-layout__topbar-center">
          <div className="phase-layout__icon">{icon}</div>
          <div>
            <h1 className="phase-layout__title">{title}</h1>
            <p className="phase-layout__subtitle">{subtitle}</p>
          </div>
        </div>
        <div style={{ width: 32 }} />
      </div>

      <div className="phase-layout__body">
        {/* Sidebar nav */}
        {sideNav && (
          <div className="phase-layout__sidebar">
            {sideNav.map((item, i) => (
              <a key={i} href={`#section-${i}`} className="phase-layout__nav-item">
                <span className="phase-layout__nav-icon">{item.icon}</span>
                <span>{item.label}</span>
              </a>
            ))}
            <div className="phase-layout__nav-help">
              <span>🎧</span>
              <div>
                <div style={{ fontWeight: 600, fontSize: 11 }}>Need something?</div>
                <div style={{ fontSize: 10, color: 'var(--primary)', marginTop: 2 }}>Contact your care team</div>
              </div>
            </div>
          </div>
        )}

        {/* Main content */}
        <div className="phase-layout__main">
          {/* Hero */}
          <div className={`phase-layout__hero phase-layout__hero--${variant}`}>
            <div className="phase-layout__hero-text">
              <div className="phase-layout__hero-title">{heroMsg}</div>
              {heroSub && <div className="phase-layout__hero-sub">{heroSub}</div>}
              {mottoMsg && <div className="phase-layout__motto">{mottoMsg}</div>}
            </div>
            <MioMascot variant={mioVariant} size={72} />
            {focusItems && (
              <div className="phase-layout__focus">
                <div className="phase-layout__focus-title">Today's Focus</div>
                {focusItems.map((f, i) => (
                  <div key={i} className="phase-layout__focus-item">
                    <span>{f.icon}</span> {f.label}
                  </div>
                ))}
                <div className="phase-layout__focus-motto">You've got this!</div>
              </div>
            )}
          </div>

          {/* Sections */}
          <div className="phase-layout__sections">
            {sections}
          </div>
        </div>
      </div>
    </div>
  )
}
