import PhaseLayout from './PhaseLayout'
import { medications } from '../../data/mockData'

const sideNav = [
  { icon: '🏥', label: 'A. Rehab Centre Information' },
  { icon: '🛡️', label: 'B. Sternal Protection' },
  { icon: '🏠', label: 'C. Home Recovery' },
  { icon: '🚭', label: 'D. Smoking & Alcohol' },
  { icon: '❤️', label: 'E. Sexual Health & Intimacy' },
  { icon: '💊', label: 'F. Medication & Treatment' },
  { icon: '💼', label: 'G. Return to Work' },
  { icon: '🧠', label: 'H. Emotional & Psychological' },
  { icon: '👥', label: 'I. Community & Peer Support' },
]

export default function PostDischargeRehab() {
  return (
    <PhaseLayout
      title="Post-Discharge Rehabilitation"
      subtitle="Returning to life. 😊"
      icon="🚶"
      variant="teal"
      mioVariant="happy"
      heroMsg="Great progress, Ahmet! ☀️ You're doing something amazing for your heart and your future."
      mottoMsg="Keep moving forward. We're proud of you! 💚"
      focusItems={[
        { icon: '🚶', label: 'Move' },
        { icon: '🛡️', label: 'Protect' },
        { icon: '❤️', label: 'Recover' },
        { icon: '😊', label: 'Stay positive' },
      ]}
      sideNav={sideNav}
      sections={<RehabSections />}
    />
  )
}

function RehabSections() {
  return (
    <>
      {/* A + B */}
      <div className="phase-section__grid2">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>A. Rehab Centre Information</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Your recovery journey continues here.</div>
          <div style={{ background: 'var(--bg)', borderRadius: 10, padding: 12, marginBottom: 10 }}>
            <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>Rehab Centre</div>
            <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--text-dark)' }}>HerzZentrum Hamburg</div>
            <div style={{ fontSize: 11, color: 'var(--text-medium)', marginTop: 4 }}>📍 Hamburg, Germany</div>
          </div>
          <button className="btn btn-outline" style={{ width: '100%', fontSize: 12, marginBottom: 12 }}>View centre details →</button>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 6 }}>
            {[['📋', 'Programme Overview'], ['📅', 'Daily Schedule'], ['🚌', 'Transport Info'], ['🎒', 'What to Bring']].map(([icon, label]) => (
              <button key={label} className="phase-section__icon-btn" style={{ fontSize: 9 }}>
                <span>{icon}</span>{label}
              </button>
            ))}
          </div>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>B. Sternal Protection & Safe Movement</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Protect your sternum. Heal with confidence.</div>
          {[['🛏️', 'Getting in & out of bed'], ['😤', 'Coughing & sneezing'], ['🏋️', 'Lifting restrictions'], ['🚗', 'Driving guidance'], ['🏠', 'Safe daily activities']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg>
            </button>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Watch all videos ▶️ →</button>
        </div>
      </div>

      {/* C + D + E */}
      <div className="phase-section__grid3">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>C. Home Recovery Guidance</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Recover at home safely and steadily.</div>
          {[['⚡', 'Energy management'], ['🩹', 'Swelling & wound care'], ['🥗', 'Nutrition & hydration'], ['⚠️', 'When to seek help']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg>
            </button>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>View full guide →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>D. Smoking & Alcohol Abstinence</div>
          <div style={{ textAlign: 'center', padding: '10px 0' }}>
            <div style={{ fontSize: 36, fontWeight: 900, color: 'var(--teal)' }}>36</div>
            <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--teal)' }}>Days smoke-free</div>
            <div style={{ fontSize: 11, color: 'var(--success)' }}>Keep going!</div>
          </div>
          {[['🍬', 'Coping with cravings'], ['📊', 'Track your progress'], ['🤝', 'Get support']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg>
            </button>
          ))}
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>E. Sexual Health & Intimacy</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>It's normal to have questions.</div>
          {[['✅', "When it's safe"], ['❤️', 'Managing intimacy'], ['💪', 'Body confidence'], ['👫', 'Tips for you & partner']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg>
            </button>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Learn more →</button>
        </div>
      </div>

      {/* F. Medications */}
      <div id="section-5" className="phase-section">
        <div className="phase-section__title">F. Medication & Treatment</div>
        <div className="phase-section__sub">Take your medications as prescribed.</div>
        {medications.map(med => (
          <div key={med.id} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 0', borderBottom: '1px solid var(--border)' }}>
            <span style={{ fontSize: 18 }}>💊</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-dark)' }}>{med.name} {med.dose}</div>
              <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>{med.schedule}</div>
              <div style={{ fontSize: 11, color: 'var(--text-light)' }}>{med.times.join(' / ')}</div>
            </div>
            {med.done.every(d => d) && <span style={{ color: 'var(--success)', fontSize: 20 }}>✅</span>}
          </div>
        ))}
        <button className="phase-section__view-link">View all medications →</button>
      </div>

      {/* G + H */}
      <div className="phase-section__grid2">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>G. Return to Work Planning</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Plan your return with confidence.</div>
          <div className="phase-section__row">
            <span>💼</span>
            <div style={{ flex: 1, fontSize: 12 }}>My job type</div>
            <span style={{ fontSize: 12, color: 'var(--teal)', fontWeight: 600 }}>Desk-based</span>
          </div>
          <div className="phase-section__row">
            <span>📅</span>
            <div style={{ flex: 1, fontSize: 12 }}>Target return date</div>
            <span style={{ fontSize: 12, color: 'var(--teal)', fontWeight: 600 }}>15 Aug 2024</span>
          </div>
          <div className="phase-section__row">
            <span>🎯</span>
            <div style={{ flex: 1, fontSize: 12 }}>My recovery goal</div>
            <span style={{ fontSize: 12, color: 'var(--teal)', fontWeight: 600 }}>Build stamina</span>
          </div>
          <button className="phase-section__view-link">View your plan →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>H. Emotional & Psychological</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Your mind is healing too.</div>
          {[['😟', 'Managing stress & worry'], ['⭐', 'Building motivation'], ['😊', 'Positive mindset'], ['🗣️', 'Talk to a professional']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
            </button>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Explore support →</button>
        </div>
      </div>

      {/* I. Community + Daily Steps */}
      <div className="phase-section__grid2">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>I. Community & Peer Support</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>You are not alone.</div>
          <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
            {[['📖', 'Stories from others', 'Real patients. Real journeys.'], ['🏆', 'Milestone celebrations', 'Share your wins.']].map(([icon, label, sub]) => (
              <div key={label} style={{ flex: 1, background: 'var(--bg)', borderRadius: 8, padding: 8 }}>
                <span style={{ fontSize: 18 }}>{icon}</span>
                <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--text-dark)', marginTop: 4 }}>{label}</div>
                <div style={{ fontSize: 10, color: 'var(--text-medium)' }}>{sub}</div>
              </div>
            ))}
          </div>
          <button className="btn btn-teal" style={{ width: '100%', fontSize: 12 }}>Join the community →</button>
        </div>

        <div className="phase-section" style={{ background: 'var(--success-bg)' }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--text-dark)', marginBottom: 4 }}>Daily Move Goal</div>
          <div style={{ textAlign: 'center', padding: '8px 0' }}>
            <div style={{ fontSize: 28, fontWeight: 900, color: 'var(--success)' }}>5,240</div>
            <div style={{ fontSize: 12, color: 'var(--text-medium)' }}>/ 7,000 steps</div>
            <div style={{ height: 6, background: 'var(--border)', borderRadius: 3, marginTop: 8 }}>
              <div style={{ height: '100%', width: '75%', background: 'var(--success)', borderRadius: 3 }} />
            </div>
          </div>
          <div style={{ fontSize: 12, color: 'var(--success)', fontWeight: 700, textAlign: 'center' }}>Well done! Keep moving every day. 🚶</div>
        </div>
      </div>
    </>
  )
}
