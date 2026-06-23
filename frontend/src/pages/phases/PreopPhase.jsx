import PhaseLayout from './PhaseLayout'

const sideNav = [
  { icon: '✅', label: 'A. ERAS Preparation' },
  { icon: '📱', label: 'B. Telemedicine' },
  { icon: '🏃', label: 'C. Physical Optimisation' },
  { icon: '🫁', label: 'D. Respiratory Prehab' },
  { icon: '🥗', label: 'E. Nutrition & Hydration' },
  { icon: '🌙', label: 'F. Sleep Optimisation' },
  { icon: '📖', label: 'G. Surgical Education' },
  { icon: '🤝', label: 'H. Shared Decision-Making' },
  { icon: '📅', label: 'I. Surgery Plan Overview' },
]

const erasItems = [
  { icon: '🚭', label: 'Smoking\nCessation', pct: 75 },
  { icon: '🥗', label: 'Nutrition\nOptimisation', pct: 60 },
  { icon: '🏃', label: 'Exercise\nTraining', pct: 80 },
  { icon: '🫁', label: 'Breathing\nExercises', pct: 70 },
  { icon: '💊', label: 'Medications\nReview', pct: 90 },
  { icon: '🧴', label: 'Skin & Body\nPreparation', pct: 50 },
  { icon: '📖', label: 'Education\nCompleted', pct: 65 },
]

export default function PreopPhase() {
  return (
    <PhaseLayout
      title="Pre-operative Preparation"
      subtitle="Preparing body and mind for your surgery."
      icon="🛡️"
      variant="coral"
      mioVariant="happy"
      heroMsg="Hi Ahmet! 👋 Great progress! Small steps now lead to a stronger recovery."
      mottoMsg=""
      focusItems={null}
      sideNav={sideNav}
      sections={<PreopSections />}
    />
  )
}

function PreopSections() {
  return (
    <>
      {/* Surgery countdown */}
      <div style={{ background: 'var(--bg-banner)', borderRadius: 'var(--radius-lg)', padding: '14px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <button className="btn btn-teal" style={{ fontSize: 12, padding: '8px 14px' }}>Your preparation summary →</button>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>Surgery in</div>
          <div style={{ fontSize: 32, fontWeight: 900, color: 'var(--teal)', lineHeight: 1 }}>12</div>
          <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>days</div>
          <div style={{ fontSize: 10, color: 'var(--text-light)' }}>Target: 28 May 2024</div>
        </div>
      </div>

      {/* A. ERAS */}
      <div id="section-0" className="phase-section">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
          <div className="phase-section__title">A. ERAS Preparation Checklist</div>
          <button className="phase-section__view-link" style={{ borderTop: 'none', paddingTop: 0, margin: 0 }}>View details →</button>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8, marginBottom: 12 }}>
          {erasItems.slice(0, 4).map(item => (
            <div key={item.label} style={{ textAlign: 'center' }}>
              <div style={{ position: 'relative', width: 44, height: 44, margin: '0 auto 4px' }}>
                <svg width="44" height="44" viewBox="0 0 44 44" style={{ transform: 'rotate(-90deg)' }}>
                  <circle cx="22" cy="22" r="18" fill="none" stroke="var(--border)" strokeWidth="4" />
                  <circle cx="22" cy="22" r="18" fill="none" stroke="var(--teal)" strokeWidth="4"
                    strokeDasharray={`${2 * Math.PI * 18}`}
                    strokeDashoffset={`${2 * Math.PI * 18 * (1 - item.pct / 100)}`}
                    strokeLinecap="round" />
                </svg>
                <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 8, fontWeight: 700, color: 'var(--teal)' }}>{item.pct}%</div>
              </div>
              <div style={{ fontSize: 9, color: 'var(--text-medium)', whiteSpace: 'pre-line', lineHeight: 1.3 }}>{item.label}</div>
            </div>
          ))}
        </div>
        <div className="phase-section__progress-row">
          <span style={{ fontSize: 12, color: 'var(--text-medium)' }}>Overall preparation progress</span>
          <span style={{ fontSize: 12, fontWeight: 700, color: 'var(--teal)' }}>70%</span>
        </div>
        <div className="phase-section__progress-bar">
          <div className="phase-section__progress-fill" style={{ width: '70%' }} />
        </div>
      </div>

      {/* B + C + D grid */}
      <div className="phase-section__grid2">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>B. Telemedicine & Contact</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginBottom: 8 }}>
            <div style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--success)' }} />
            <span style={{ fontSize: 11, color: 'var(--success)', fontWeight: 600 }}>Available</span>
          </div>
          <div style={{ fontSize: 11, color: 'var(--text-medium)', marginBottom: 10 }}>Ask questions or schedule a video consultation with your care team.</div>
          {[['💬', 'Send a message'], ['📞', 'Request a call'], ['🎥', 'Video consultation']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
            </button>
          ))}
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>C. Physical Optimisation</div>
          <div className="phase-section__row">
            <span className="phase-section__row-icon">🚶</span>
            <div className="phase-section__row-text" style={{ fontSize: 12 }}>Walk 20–30 min daily</div>
            <span style={{ fontSize: 11, color: 'var(--teal)', fontWeight: 600 }}>5/7</span>
          </div>
          <div className="phase-section__row">
            <span className="phase-section__row-icon">💪</span>
            <div className="phase-section__row-text" style={{ fontSize: 12 }}>Strength exercises</div>
            <span style={{ fontSize: 11, color: 'var(--teal)', fontWeight: 600 }}>3/7</span>
          </div>
          <div className="phase-section__row">
            <span className="phase-section__row-icon">🤸</span>
            <div className="phase-section__row-text" style={{ fontSize: 12 }}>Mobility & flexibility</div>
            <span style={{ fontSize: 11, color: 'var(--teal)', fontWeight: 600 }}>4/7</span>
          </div>
          <button className="phase-section__view-link">View exercise plan →</button>
        </div>
      </div>

      {/* E + F */}
      <div className="phase-section__grid2">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>E. Nutrition & Hydration</div>
          {[['🥩', 'High protein diet', true], ['🌿', 'Iron rich foods', true], ['💧', 'Hydration goal 6–8 glasses/day', true], ['🍹', 'Carbohydrate loading', null]].map(([icon, label, done]) => (
            <div key={label} className="phase-section__row">
              <span className="phase-section__row-icon">{icon}</span>
              <div className="phase-section__row-text" style={{ fontSize: 11 }}>{label}</div>
              <span>{done === true ? '✅' : done === null ? 'ℹ️' : ''}</span>
            </div>
          ))}
          <button className="phase-section__view-link">View nutrition plan →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>F. Sleep Optimisation</div>
          {[['🌙', 'Aim for 7–8 hours of quality sleep'], ['📱', 'Reduce screen time before bed'], ['💆', 'Relaxation routine 10 min before sleep']].map(([icon, label]) => (
            <div key={label} className="phase-section__row">
              <span className="phase-section__row-icon">{icon}</span>
              <div className="phase-section__row-text" style={{ fontSize: 11 }}>{label}</div>
            </div>
          ))}
          <button className="phase-section__view-link">Sleep tips →</button>
        </div>
      </div>

      {/* I. Surgery Plan */}
      <div id="section-8" className="phase-section">
        <div className="phase-section__title">I. Surgery Plan Overview</div>
        <div className="phase-section__sub">Here's what to expect:</div>
        {[['Pre-op assessment', 'Completed', true], ['Day before surgery', '27 May'], ['Surgery day', '28 May'], ['ICU stay', '1–2 days'], ['Ward recovery', '3–5 days']].map(([label, val, done]) => (
          <div key={label} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '8px 0', borderBottom: '1px solid var(--border)' }}>
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <div style={{ width: 8, height: 8, borderRadius: '50%', background: done ? 'var(--success)' : 'var(--teal)' }} />
              <span style={{ fontSize: 13, color: 'var(--text-dark)' }}>{label}</span>
            </div>
            <span style={{ fontSize: 12, color: done ? 'var(--success)' : 'var(--text-medium)', fontWeight: done ? 700 : 400 }}>{val}</span>
          </div>
        ))}
        <button className="phase-section__view-link">Full timeline →</button>
      </div>

      {/* Info card */}
      <div style={{ background: 'var(--teal-light)', borderRadius: 'var(--radius-lg)', padding: 16, display: 'flex', gap: 12, alignItems: 'flex-start' }}>
        <span style={{ fontSize: 24 }}>🛡️</span>
        <div>
          <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--teal-dark)' }}>You're in good hands</div>
          <div style={{ fontSize: 12, color: 'var(--teal)', marginTop: 4 }}>Following this plan helps reduce complications and supports a faster recovery.</div>
          <div style={{ fontSize: 12, fontWeight: 600, color: 'var(--teal)', marginTop: 8 }}>Keep going, Ahmet! We're here for you.</div>
        </div>
      </div>
    </>
  )
}
