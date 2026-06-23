import { useNavigate } from 'react-router-dom'
import { journeyPhases, mioMessages } from '../data/mockData'
import MioMascot from '../components/common/MioMascot'
import './Journey.css'

const phaseVariant = { completed: 'calm', active: 'happy', upcoming: 'default' }

export default function Journey() {
  const navigate = useNavigate()

  return (
    <div className="journey">
      {/* Header */}
      <div className="journey__header">
        <h1 className="journey__title">My Journey</h1>
        <p className="journey__sub">Your heart surgery journey, step by step.</p>
      </div>

      {/* Mio intro */}
      <div className="journey__mio-banner">
        <MioMascot variant="happy" size={70} />
        <div>
          <div className="journey__mio-title">Mio grows with you</div>
          <div className="journey__mio-sub">through your journey 💪</div>
          <div className="journey__mio-msg">"We'll do this together."</div>
        </div>
      </div>

      {/* Phase timeline */}
      <div className="journey__phases">
        {journeyPhases.map((phase, i) => (
          <div key={phase.id} className="journey__phase-row">
            {/* connector line */}
            {i < journeyPhases.length - 1 && (
              <div className={`journey__connector${phase.status !== 'upcoming' ? ' done' : ''}`} />
            )}

            <button
              className={`journey__phase-card journey__phase-card--${phase.status}`}
              onClick={() => navigate(`/journey/${phase.id}`)}
            >
              <div className="journey__phase-avatar">
                <MioMascot variant={phaseVariant[phase.status]} size={52} />
                {phase.status === 'completed' && <div className="journey__check">✓</div>}
                {phase.status === 'active' && <div className="journey__active-dot" />}
              </div>
              <div className="journey__phase-body">
                <div className="journey__phase-name">{phase.label}</div>
                {phase.date && <div className="journey__phase-date">{phase.date}</div>}
                {phase.subtitle && <div className="journey__phase-status chip chip-coral">{phase.subtitle}</div>}
                {phase.status === 'completed' && <div className="journey__phase-status chip chip-green">Completed</div>}
                {phase.status === 'upcoming' && <div className="journey__phase-status chip" style={{ background: 'var(--border)', color: 'var(--text-medium)' }}>Upcoming</div>}
                <div className="journey__phase-quote">{mioMessages[phase.id]}</div>
              </div>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0, color: 'var(--text-light)' }}>
                <path d="M9 18l6-6-6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </button>
          </div>
        ))}
      </div>

      {/* Footer */}
      <div className="journey__footer">
        <div style={{ fontSize: 13, color: 'var(--text-medium)', textAlign: 'center' }}>
          You are not alone. We're with you, every step of the way.
        </div>
        <div style={{ fontSize: 11, color: 'var(--text-light)', textAlign: 'center', marginTop: 4 }}>
          Keep going, {`Ahmet`}. Your heart is healing. Your future is bright. ⭐
        </div>
      </div>
    </div>
  )
}
