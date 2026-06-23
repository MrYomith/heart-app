import PhaseLayout from './PhaseLayout'

const sideNav = [
  { icon: '❤️', label: 'A. Understand Your Condition' },
  { icon: '💚', label: 'B. Emotional Check-In' },
  { icon: '🧠', label: 'C. Psychological Support' },
  { icon: '💊', label: 'D. Medications' },
  { icon: '🥗', label: 'E. Nutrition Optimisation' },
  { icon: '🚶', label: 'F. Physical Activity' },
  { icon: '🚭', label: 'G. Smoking & Alcohol' },
  { icon: '👨‍👩‍👧', label: 'H. Family & Caregiver' },
  { icon: '📅', label: 'I. Surgery Timeline' },
]

export default function DiagnosisPhase() {
  return (
    <PhaseLayout
      title="Diagnosis Phase"
      subtitle="Understanding what lies ahead."
      icon="❤️"
      variant="coral"
      mioVariant="default"
      heroMsg="Understanding your heart is the first step to healing."
      heroSub="Mio is here to guide you through every question."
      mottoMsg="Knowledge is strength. 💪"
      focusItems={[
        { icon: '❤️', label: 'Learn about your condition' },
        { icon: '💬', label: 'Ask your care team' },
        { icon: '🧘', label: 'Stay calm & informed' },
      ]}
      sideNav={sideNav}
      sections={<DiagnosisSections />}
    />
  )
}

function DiagnosisSections() {
  return (
    <>
      {/* A. Understand Condition */}
      <div id="section-0" className="phase-section">
        <div className="phase-section__title">A. Understand Your Condition</div>
        <div className="phase-section__sub">Learn about your heart condition and the recommended surgery.</div>
        <div style={{ display: 'flex', gap: 12, alignItems: 'center', background: 'var(--bg)', borderRadius: 10, padding: 12 }}>
          <div style={{ fontSize: 40 }}>🫀</div>
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-dark)' }}>Coronary Artery Disease</div>
            <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>Tap to watch explainer video</div>
          </div>
          <div style={{ marginLeft: 'auto', fontSize: 22 }}>▶️</div>
        </div>
        <button className="btn btn-teal" style={{ width: '100%', marginTop: 10 }}>Watch explainer videos ▶</button>
      </div>

      {/* B. Emotional Check-In */}
      <div id="section-1" className="phase-section">
        <div className="phase-section__title">B. Emotional Check-In</div>
        <div className="phase-section__sub">How are you feeling today?</div>
        <div style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0' }}>
          {['😢', '😟', '😐', '😊', '😄'].map((e, i) => (
            <button key={i} style={{ background: 'none', border: '2px solid var(--border)', borderRadius: '50%', width: 44, height: 44, fontSize: 20, cursor: 'pointer', transition: 'all 0.2s' }}
              onMouseOver={e2 => e2.currentTarget.style.borderColor = 'var(--teal)'}
              onMouseOut={e2 => e2.currentTarget.style.borderColor = 'var(--border)'}>
              {e}
            </button>
          ))}
        </div>
        <div style={{ fontSize: 11, color: 'var(--text-medium)', textAlign: 'center', marginBottom: 8 }}>Tap to rate</div>
        <button className="btn btn-outline" style={{ width: '100%', fontSize: 13 }}>📊 View trends</button>
      </div>

      {/* C. Psychological Support */}
      <div id="section-2" className="phase-section">
        <div className="phase-section__title">C. Psychological Support</div>
        <div className="phase-section__sub">Tools to help you manage worry and build resilience.</div>
        <div className="phase-section__grid3" style={{ gridTemplateColumns: 'repeat(4, 1fr)' }}>
          {[['💨', 'Calm Breathing'], ['🧘', 'Guided Meditations'], ['🌙', 'Sleep Support'], ['😰', 'Anxiety Support']].map(([icon, label]) => (
            <button key={label} className="phase-section__icon-btn">
              <span>{icon}</span>{label}
            </button>
          ))}
        </div>
      </div>

      {/* D. Medications */}
      <div id="section-3" className="phase-section">
        <div className="phase-section__title">D. Medications</div>
        <div className="phase-section__sub">Manage your medications and get surgery-specific guidance.</div>
        {[['💊', 'My medications'], ['🛡️', 'Surgery medication guide'], ['⚠️', 'Allergies']].map(([icon, label]) => (
          <button key={label} className="phase-section__action-btn">
            <span style={{ display: 'flex', gap: 8, alignItems: 'center' }}><span>{icon}</span>{label}</span>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg>
          </button>
        ))}
        <button className="phase-section__view-link">Review all →</button>
      </div>

      {/* E. Nutrition */}
      <div id="section-4" className="phase-section">
        <div className="phase-section__title">E. Nutrition Optimisation</div>
        <div className="phase-section__sub">Eat well to prepare your body for healing.</div>
        <div className="phase-section__grid2" style={{ gridTemplateColumns: 'repeat(4, 1fr)' }}>
          {[['🐟', 'Protein Goals'], ['🌿', 'Iron & Anaemia'], ['💧', 'Hydration Tracker'], ['🥗', 'Diet Plan']].map(([icon, label]) => (
            <button key={label} className="phase-section__icon-btn">
              <span>{icon}</span>{label}
            </button>
          ))}
        </div>
        <button className="phase-section__view-link">View nutrition plan →</button>
      </div>

      {/* F. Physical Activity */}
      <div id="section-5" className="phase-section">
        <div className="phase-section__title">F. Physical Activity</div>
        <div className="phase-section__sub">Recommended activity based on your NYHA class.</div>
        <div style={{ background: 'var(--bg)', borderRadius: 10, padding: 12, display: 'flex', alignItems: 'center', gap: 12 }}>
          <span style={{ fontSize: 36 }}>🚶</span>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, color: 'var(--text-medium)' }}>Your NYHA Class</div>
            <div style={{ fontSize: 22, fontWeight: 800, color: 'var(--teal)' }}>II</div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>Today's Goal</div>
            <div style={{ fontSize: 16, fontWeight: 700, color: 'var(--teal)' }}>20 min walk</div>
          </div>
        </div>
        <button className="phase-section__view-link">View exercise plan →</button>
      </div>

      {/* G. Smoking & Alcohol */}
      <div id="section-6" className="phase-section">
        <div className="phase-section__title">G. Smoking & Alcohol Support</div>
        <div className="phase-section__sub">You're not alone. We're here to help you quit.</div>
        <button className="phase-section__action-btn"><span>🚭 Smoking cessation plan</span><svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg></button>
        <button className="phase-section__action-btn"><span>🍷 Alcohol reduction plan</span><svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg></button>
        <button className="phase-section__view-link">📊 Track your progress →</button>
      </div>

      {/* H. Family & Caregiver */}
      <div id="section-7" className="phase-section">
        <div className="phase-section__title">H. Family & Caregiver Hub</div>
        <div className="phase-section__sub">Information and support for the people who care for you.</div>
        {[['👁️', 'What to expect'], ['❤️', 'How to help'], ['➕', 'Invite a caregiver']].map(([icon, label]) => (
          <button key={label} className="phase-section__action-btn">
            <span style={{ display: 'flex', gap: 8 }}><span>{icon}</span>{label}</span>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg>
          </button>
        ))}
      </div>

      {/* I. Surgery Timeline */}
      <div id="section-8" className="phase-section">
        <div className="phase-section__title">I. Surgery Timeline</div>
        <div className="phase-section__sub">See what happens from now until recovery.</div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0' }}>
          {[['📍', 'Pre-op\nPrep'], ['🏥', 'Surgery\nDay'], ['🛏️', 'ICU'], ['🏥', 'Ward'], ['🏠', 'Recovery\nat Home']].map(([icon, label], i, arr) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
              <div style={{ textAlign: 'center' }}>
                <div style={{ fontSize: 18 }}>{icon}</div>
                <div style={{ fontSize: 9, color: 'var(--text-medium)', whiteSpace: 'pre-line', textAlign: 'center' }}>{label}</div>
              </div>
              {i < arr.length - 1 && <div style={{ width: 16, height: 2, background: 'var(--border)', flexShrink: 0 }} />}
            </div>
          ))}
        </div>
        <button className="phase-section__view-link">View full timeline →</button>
      </div>
    </>
  )
}
