import { useState } from 'react'
import PhaseLayout from './PhaseLayout'

const sideNav = [
  { icon: '😣', label: 'A. Pain Tracking' },
  { icon: '🫁', label: 'B. Breathing Exercises' },
  { icon: '🚶', label: 'C. Mobilisation Tracking' },
  { icon: '🧠', label: 'D. Delirium & Cognitive' },
  { icon: '🩹', label: 'E. Wound Care & Dressing' },
  { icon: '❤️', label: 'F. Emotional Wellbeing' },
  { icon: '🧘', label: 'G. Meditation & Relaxation' },
  { icon: '🥗', label: 'H. Nutrition Recovery' },
  { icon: '📖', label: 'I. ICU/Ward Education' },
]

export default function InpatientRecovery() {
  return (
    <PhaseLayout
      title="Inpatient Recovery"
      subtitle="Healing step by step."
      icon="🩹"
      variant="coral"
      mioVariant="medical"
      heroMsg="Good job, Ahmet! 👋 Every breath, every step, is your heart getting stronger."
      heroSub="You're healing, and we're here with you. ❤️"
      focusItems={[
        { icon: '😣', label: 'Pain control' },
        { icon: '🫁', label: 'Deep breaths' },
        { icon: '🚶', label: 'Walk a little more' },
        { icon: '🥗', label: 'Eat & hydrate' },
      ]}
      sideNav={sideNav}
      sections={<InpatientSections />}
    />
  )
}

function PainSlider({ label, value }) {
  const [val, setVal] = useState(value)
  const emoji = val <= 3 ? '😊' : val <= 6 ? '😐' : '😣'
  return (
    <div style={{ marginBottom: 12 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
        <span style={{ fontSize: 20 }}>{emoji}</span>
        <span style={{ fontSize: 13, color: 'var(--text-medium)', flex: 1 }}>{label}</span>
        <span style={{ fontSize: 15, fontWeight: 700, color: 'var(--primary)' }}>{val}/10</span>
      </div>
      <input type="range" min={0} max={10} value={val} onChange={e => setVal(+e.target.value)}
        style={{ width: '100%', accentColor: 'var(--teal)', height: 6 }} />
    </div>
  )
}

function InpatientSections() {
  return (
    <>
      {/* A + B + C grid */}
      <div className="phase-section__grid3">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>A. Pain Tracking</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>How is your pain?</div>
          <PainSlider label="At rest" value={3} />
          <PainSlider label="Coughing" value={5} />
          <PainSlider label="Moving" value={6} />
          <button className="phase-section__view-link">📊 View pain history →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>B. Breathing Exercises</div>
          <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>Next reminder in</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 12 }}>
            <span style={{ fontSize: 14 }}>⏱️</span>
            <span style={{ fontSize: 18, fontWeight: 800, color: 'var(--teal)' }}>45 min</span>
          </div>
          <div style={{ width: 60, height: 60, borderRadius: '50%', border: '4px solid var(--teal)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 12px', fontSize: 28 }}>🫁</div>
          <div style={{ fontSize: 11, color: 'var(--text-medium)', textAlign: 'center', marginBottom: 10 }}>Keep up the great work!<br />10 deep breaths every hour helps your lungs heal.</div>
          <button className="btn btn-teal" style={{ width: '100%', fontSize: 12, padding: '8px' }}>▶ Start Breathing Coach</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>C. Mobilisation Tracking</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Your progress</div>
          {[['🧍', 'Sitting up'], ['🧍', 'Standing'], ['🚶', 'First walk']].map(([icon, label]) => (
            <div key={label} className="phase-section__row">
              <span className="phase-section__row-icon" style={{ fontSize: 16 }}>{icon}</span>
              <div className="phase-section__row-text" style={{ fontSize: 12 }}>{label}</div>
              <span style={{ color: 'var(--success)' }}>✅</span>
            </div>
          ))}
          <div className="phase-section__row">
            <span className="phase-section__row-icon" style={{ fontSize: 16 }}>👟</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 12, color: 'var(--text-dark)' }}>Today's goal</div>
              <div style={{ fontSize: 11, color: 'var(--primary)', fontWeight: 700 }}>3 walks</div>
            </div>
          </div>
          <button className="phase-section__view-link">Log your walk →</button>
        </div>
      </div>

      {/* D + E + F grid */}
      <div className="phase-section__grid3">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>D. Delirium & Cognitive</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Stay oriented, stay strong.</div>
          {[['📅', 'What day is it today?', '✅'], ['📍', 'Where are you?', '✅'], ['🌙', 'How is your sleep?', null]].map(([icon, label, done]) => (
            <div key={label} className="phase-section__row">
              <span style={{ fontSize: 16 }}>{icon}</span>
              <div className="phase-section__row-text" style={{ fontSize: 12 }}>{label}</div>
              {done ? <span style={{ color: 'var(--success)' }}>✅</span> : <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg>}
            </div>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Tips for better sleep →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>E. Wound Care & Dressing</div>
          <div style={{ fontSize: 11, color: 'var(--text-medium)', marginBottom: 8 }}>Sternotomy incision</div>
          <div style={{ background: 'var(--bg)', borderRadius: 10, padding: 10, marginBottom: 10, textAlign: 'center' }}>
            <div style={{ fontSize: 32 }}>🩹</div>
            <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>Dressing changed</div>
            <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--teal)' }}>20 May, 08:30</div>
          </div>
          <div style={{ display: 'flex', gap: 6, background: 'var(--warning-bg)', borderRadius: 8, padding: 8, fontSize: 11, color: 'var(--warning)' }}>
            <span>🔒</span>
            <span>Do not remove dressing before Day 3 (23 May)</span>
          </div>
          <button className="phase-section__view-link">View wound log →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>F. Emotional Wellbeing</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>How are you feeling today?</div>
          <div style={{ display: 'flex', gap: 4, marginBottom: 10 }}>
            {['😢', '😟', '😐', '😊', '😄'].map((e, i) => (
              <div key={i} style={{ flex: 1, textAlign: 'center', fontSize: 20, padding: 4, borderRadius: 8, background: i === 3 ? 'var(--success-bg)' : 'transparent', cursor: 'pointer' }}>{e}</div>
            ))}
          </div>
          <div style={{ fontSize: 11, color: 'var(--success)', fontWeight: 600, marginBottom: 10 }}>You rated: Good</div>
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>📊 View mood trend →</button>
          <button style={{ background: 'var(--primary-light)', border: 'none', borderRadius: 8, padding: '8px 10px', width: '100%', fontSize: 11, color: 'var(--primary)', cursor: 'pointer', display: 'flex', gap: 6, alignItems: 'center', marginTop: 6 }}>
            <span>💬</span> Talk to someone – We're here to listen.
          </button>
        </div>
      </div>

      {/* G + H + I grid */}
      <div className="phase-section__grid3">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>G. Meditation & Relaxation</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Take a moment for yourself.</div>
          <div className="phase-section__grid3">
            {[['💨', 'Calm Breathing', '5 min'], ['🧘', 'Guided Meditation', '10 min'], ['🧘‍♀️', 'Body Scan Relaxation', '15 min']].map(([icon, label, dur]) => (
              <button key={label} className="phase-section__icon-btn" style={{ fontSize: 9 }}>
                <span>{icon}</span>
                <div>{label}</div>
                <div style={{ color: 'var(--teal)', fontSize: 9 }}>{dur}</div>
              </button>
            ))}
          </div>
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Explore all sessions →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>H. Nutrition Recovery</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Today's goals</div>
          {[['🥩', 'Protein intake', 75, 'var(--primary)'],
            ['💧', 'Fluids', 60, 'var(--teal)'],
            ['🍽️', 'Small frequent meals', null, null]].map(([icon, label, pct, color]) => (
            <div key={label} style={{ marginBottom: 8 }}>
              <div style={{ display: 'flex', gap: 6, alignItems: 'center', marginBottom: 3, fontSize: 12 }}>
                <span style={{ fontSize: 14 }}>{icon}</span>
                <span style={{ flex: 1, color: 'var(--text-dark)' }}>{label}</span>
                <span style={{ fontWeight: 700, color: color || 'var(--success)' }}>{pct ? `${pct}%` : '3/5'}</span>
              </div>
              {pct && <div className="phase-section__progress-bar"><div className="phase-section__progress-fill" style={{ width: `${pct}%`, background: color }} /></div>}
            </div>
          ))}
          <div style={{ display: 'flex', gap: 6, fontSize: 12, color: 'var(--success)', fontWeight: 600 }}><span>✅</span> Bowel movement</div>
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Log your meal →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>I. ICU/Ward Education</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Understand your recovery.</div>
          {[['📄', 'Tubes, drains & wires'], ['📄', 'Normal after surgery'], ['📄', 'Pain management'], ['📄', 'When can I go home?']].map(([icon, label]) => (
            <div key={label} className="phase-section__row">
              <span style={{ fontSize: 14 }}>{icon}</span>
              <div className="phase-section__row-text" style={{ fontSize: 12 }}>{label}</div>
              <span style={{ fontSize: 14 }}>▶️</span>
            </div>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>View all lessons →</button>
        </div>
      </div>

      {/* Bottom motivation */}
      <div style={{ background: 'var(--teal-light)', borderRadius: 'var(--radius-lg)', padding: 16, display: 'flex', alignItems: 'center', gap: 12 }}>
        <span style={{ fontSize: 28 }}>🛡️</span>
        <div>
          <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--teal-dark)' }}>You're making progress every day!</div>
          <div style={{ fontSize: 12, color: 'var(--teal)' }}>Small steps today, stronger heart tomorrow.</div>
        </div>
      </div>
    </>
  )
}
