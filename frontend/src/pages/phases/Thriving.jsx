import PhaseLayout from './PhaseLayout'

const sideNav = [
  { icon: '💪', label: 'A. Long-term Health' },
  { icon: '🏃', label: 'B. Physical Fitness' },
  { icon: '🥗', label: 'C. Nutrition & Habits' },
  { icon: '🧘', label: 'D. Mental Wellbeing' },
  { icon: '👥', label: 'E. Relationships' },
  { icon: '💼', label: 'F. Work & Purpose' },
  { icon: '✈️', label: 'G. Travel & Adventure' },
  { icon: '📊', label: 'H. Routine Check-ups' },
  { icon: '❤️', label: 'I. Give Back & Inspire' },
]

export default function Thriving() {
  return (
    <PhaseLayout
      title="Thriving"
      subtitle="Living beyond surgery. ❤️"
      icon="⭐"
      variant="green"
      mioVariant="thriving"
      heroMsg="You did it, Ahmet. ✨ Every choice, every step, brought you here."
      heroSub="You're not just recovering — you're thriving."
      mottoMsg="Live fully. Love deeply. Keep inspiring. 💚"
      focusItems={[
        { icon: '🚶', label: 'Move' },
        { icon: '🥗', label: 'Nourish' },
        { icon: '👥', label: 'Connect' },
        { icon: '🌱', label: 'Grow' },
        { icon: '💜', label: 'Be grateful' },
      ]}
      sideNav={sideNav}
      sections={<ThrivingSections />}
    />
  )
}

function ThrivingSections() {
  return (
    <>
      {/* A + B + C */}
      <div className="phase-section__grid3">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>A. Long-term Health Maintenance</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Small habits. Big impact.</div>
          {[['💊', 'Take medications as prescribed'], ['🥗', 'Eat balanced meals'], ['🏃', 'Stay physically active'], ['🧘', 'Manage stress'], ['🌙', 'Sleep well']].map(([icon, label]) => (
            <div key={label} className="phase-section__row">
              <span style={{ fontSize: 14 }}>{icon}</span>
              <div className="phase-section__row-text" style={{ fontSize: 12 }}>{label}</div>
              <span style={{ color: 'var(--success)' }}>✅</span>
            </div>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>View your health plan →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>B. Physical Fitness & Mobility</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Keep your body strong and flexible.</div>
          <div style={{ textAlign: 'center', padding: '8px 0' }}>
            <div style={{ fontSize: 28, fontWeight: 900, color: 'var(--teal)' }}>150/150</div>
            <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>Weekly activity goal (min)</div>
            <div style={{ height: 6, background: 'var(--border)', borderRadius: 3, margin: '8px 0' }}>
              <div style={{ height: '100%', width: '100%', background: 'var(--success)', borderRadius: 3 }} />
            </div>
            <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--success)' }}>Great job!</div>
          </div>
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Log your activity →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>C. Nutrition & Healthy Habits</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Fuel your body. Nourish your future.</div>
          {[['🥗', 'Eat mindfully'], ['💧', 'Hydrate well'], ['🥦', 'Choose whole foods'], ['🚫', 'Limit sugar & salt']].map(([icon, label]) => (
            <div key={label} className="phase-section__row">
              <span style={{ fontSize: 14 }}>{icon}</span>
              <div className="phase-section__row-text" style={{ fontSize: 12 }}>{label}</div>
              <span style={{ color: 'var(--success)', fontSize: 14 }}>✅</span>
            </div>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Log your meals →</button>
        </div>
      </div>

      {/* D + E + F */}
      <div className="phase-section__grid3">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>D. Mental Wellbeing & Mindfulness</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>A calm mind creates a happy life.</div>
          <div className="phase-section__grid3">
            {[['🧘', 'Meditation', '10 min'], ['📔', 'Gratitude Journal', ''], ['💨', 'Breathing Exercise', '']].map(([icon, label, dur]) => (
              <button key={label} className="phase-section__icon-btn" style={{ fontSize: 9 }}>
                <span>{icon}</span>{label}{dur && <span style={{ color: 'var(--teal)', fontSize: 9 }}>{dur}</span>}
              </button>
            ))}
          </div>
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Explore mind tools →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>E. Relationships & Social Life</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>You're not alone. Stay connected.</div>
          {[['👨‍👩‍👧', 'Family & friends'], ['👥', 'Community'], ['📸', 'Make new memories']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg>
            </button>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Strengthen connections →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>F. Work, Purpose & Productivity</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Do what matters. At your pace.</div>
          {[['✅', 'Set meaningful goals'], ['💪', 'Stay productive'], ['🎯', 'Find purpose daily']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
            </button>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Plan your goals →</button>
        </div>
      </div>

      {/* G + H + I */}
      <div className="phase-section__grid3">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>G. Travel & Adventure</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Explore the world again. You've earned it.</div>
          {[['🗺️', 'Plan your trips'], ['💡', 'Travel tips'], ['✅', 'Safety checklist']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
            </button>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>Explore more →</button>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>H. Routine Check-ups</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Stay ahead. Stay healthy.</div>
          {[['📅', 'Upcoming appointments'], ['📊', 'Track your progress'], ['🧪', 'Lab & test results']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
            </button>
          ))}
          <button className="phase-section__view-link" style={{ fontSize: 11 }}>View health dashboard →</button>
        </div>

        <div className="phase-section" style={{ background: 'var(--primary-light)' }}>
          <div className="phase-section__title" style={{ fontSize: 13 }}>I. Give Back & Inspire Others</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Your journey can light the way for others.</div>
          {[['📖', 'Share your story'], ['❤️', 'Support others'], ['🏅', 'Be a mentor']].map(([icon, label]) => (
            <button key={label} className="phase-section__action-btn" style={{ fontSize: 12 }}>
              <span style={{ display: 'flex', gap: 6 }}><span>{icon}</span>{label}</span>
            </button>
          ))}
          <button className="phase-section__view-link" style={{ color: 'var(--primary)', fontSize: 11 }}>Inspire someone today →</button>
        </div>
      </div>

      {/* Journey highlights */}
      <div className="phase-section">
        <div className="phase-section__title">Your Journey Highlights</div>
        <div className="phase-section__sub">Look how far you've come!</div>
        <div style={{ display: 'flex', justifyContent: 'space-between', margin: '12px 0', textAlign: 'center' }}>
          {[['❤️', 'Stronger\nthan before'], ['🚶', 'More active\nevery day'], ['🥗', 'Healthier\nchoices'], ['🧠', 'Mentally\nresilient'], ['👥', 'Connected\n& supported'], ['⭐', 'Living\nwith purpose']].map(([icon, label]) => (
            <div key={label} style={{ flex: 1 }}>
              <div style={{ fontSize: 20, marginBottom: 4 }}>{icon}</div>
              <div style={{ fontSize: 9, color: 'var(--text-medium)', whiteSpace: 'pre-line', lineHeight: 1.3 }}>{label}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Final quote */}
      <div style={{ background: 'linear-gradient(135deg, var(--teal-light), var(--bg-banner))', borderRadius: 'var(--radius-lg)', padding: 16 }}>
        <div style={{ fontSize: 13, fontStyle: 'italic', color: 'var(--text-dark)', lineHeight: 1.7, marginBottom: 8 }}>
          "This is your new beginning. Keep growing. Keep glowing."
        </div>
        <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--teal)' }}>– Team MioHart ❤️</div>
      </div>
    </>
  )
}
