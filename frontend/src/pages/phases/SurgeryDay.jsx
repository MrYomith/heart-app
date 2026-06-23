import PhaseLayout from './PhaseLayout'

const sideNav = [
  { icon: '🍽️', label: 'A. Fasting & Carbohydrate' },
  { icon: '👨‍👩‍👧', label: 'B. Family Contact' },
  { icon: '🎤', label: 'C. Voice Memo for Family' },
  { icon: '💨', label: 'D. Calm & Breathing' },
  { icon: '➡️', label: 'E. What Happens Next' },
  { icon: '💌', label: 'F. Personal Message' },
  { icon: '⚠️', label: 'G. Important Reminders' },
]

export default function SurgeryDay() {
  return (
    <PhaseLayout
      title="Surgery Day"
      subtitle="You're in good hands. We're with you."
      icon="🏥"
      variant="coral"
      mioVariant="medical"
      heroMsg="Good morning, Ahmet! ☀️ Today is the day. You've prepared well, and now you're ready."
      mottoMsg="Take a deep breath. You've got this. 🤍"
      focusItems={null}
      sideNav={sideNav}
      sections={<SurgerySections />}
    />
  )
}

function SurgerySections() {
  return (
    <>
      {/* Surgery time */}
      <div style={{ background: 'var(--bg-card)', borderRadius: 'var(--radius-lg)', padding: 16, display: 'flex', justifyContent: 'space-between', alignItems: 'center', boxShadow: 'var(--shadow-sm)' }}>
        <div>
          <div style={{ fontSize: 12, color: 'var(--text-medium)' }}>Surgery time</div>
          <div style={{ fontSize: 36, fontWeight: 900, color: 'var(--text-dark)', lineHeight: 1 }}>08:30</div>
          <div style={{ fontSize: 13, color: 'var(--text-medium)', marginTop: 4 }}>28 May 2024</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'var(--success-bg)', padding: '8px 14px', borderRadius: 'var(--radius-full)', color: 'var(--success)' }}>
            <span>✅</span>
            <span style={{ fontWeight: 700, fontSize: 13 }}>All set! You're ready.</span>
          </div>
        </div>
      </div>

      {/* A. Fasting */}
      <div id="section-0" className="phase-section">
        <div className="phase-section__title">A. Fasting & Carbohydrate</div>
        <div className="phase-section__sub">Follow your fasting and carbohydrate loading plan (ERAS protocol).</div>
        <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--primary)', marginBottom: 8 }}>Your schedule</div>
        {[['⏰', 'No solid food after', '00:30', '(8 hours before surgery)'],
          ['🧃', 'Clear fluids until', '04:30', '(4 hours before surgery)'],
          ['🥤', 'Carbohydrate drink', '06:30', '(2 hours before surgery)']].map(([icon, label, time, note]) => (
          <div key={label} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 0', borderBottom: '1px solid var(--border)' }}>
            <span style={{ fontSize: 18 }}>{icon}</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, color: 'var(--text-dark)' }}>{label}</div>
              <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>{note}</div>
            </div>
            <div style={{ fontSize: 15, fontWeight: 700, color: 'var(--primary)' }}>{time}</div>
          </div>
        ))}
        <div style={{ marginTop: 12, background: 'var(--bg)', borderRadius: 10, padding: 12 }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--primary)', marginBottom: 6 }}>Carbohydrate loading</div>
          <div style={{ display: 'flex', gap: 10, alignItems: 'flex-start' }}>
            <span style={{ fontSize: 28 }}>🧃</span>
            <div style={{ fontSize: 12, color: 'var(--text-medium)', lineHeight: 1.5 }}>
              Drink 400 ml of carbohydrate beverage (12.5% maltodextrin) 2 hours before surgery. This helps reduce stress, maintains energy and improves recovery.
            </div>
          </div>
        </div>
        <button className="phase-section__view-link">View full fasting guide →</button>
      </div>

      {/* B & C grid */}
      <div className="phase-section__grid2">
        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>B. Family Contact Reminder</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>It's a good idea to speak with your loved ones before surgery.</div>
          <div style={{ background: 'var(--bg)', borderRadius: 10, padding: 12, marginBottom: 10 }}>
            <div style={{ fontSize: 12, color: 'var(--text-medium)', marginBottom: 10 }}>Have you spoken with your family?</div>
            <button className="btn btn-teal" style={{ width: '100%', fontSize: 13 }}>📞 Call a loved one</button>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: 12, color: 'var(--text-medium)' }}>
            <span>Remind me again in</span>
            <span style={{ fontWeight: 700, color: 'var(--teal)' }}>30 min ▾</span>
          </div>
        </div>

        <div className="phase-section">
          <div className="phase-section__title" style={{ fontSize: 13 }}>C. Voice Memo for Family</div>
          <div className="phase-section__sub" style={{ fontSize: 11 }}>Record a message for your loved ones to listen whenever they need.</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--bg)', borderRadius: 10, padding: 12, marginBottom: 10 }}>
            <div style={{ flex: 1, display: 'flex', gap: 2 }}>
              {[3,4,3,5,4,3,5,6,4,3].map((h, i) => (
                <div key={i} style={{ width: 3, height: h * 4, background: 'var(--teal)', borderRadius: 2, opacity: 0.6 }} />
              ))}
            </div>
            <span style={{ fontSize: 12, color: 'var(--text-medium)' }}>00:00</span>
            <button style={{ background: 'var(--primary)', border: 'none', borderRadius: '50%', width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', fontSize: 16 }}>🎙️</button>
          </div>
          <button className="phase-section__view-link">My recordings (2) →</button>
        </div>
      </div>

      {/* D. Calm & Breathing */}
      <div id="section-3" className="phase-section">
        <div className="phase-section__title">D. Calm & Breathing</div>
        <div className="phase-section__sub">Take a moment to relax and centre yourself.</div>
        <div className="phase-section__grid3">
          {[['💨', 'Guided Breathing', '5 min'], ['🧘', 'Calm Meditation', '10 min'], ['🎵', 'Soothing Music', '15 min']].map(([icon, label, dur]) => (
            <button key={label} className="phase-section__icon-btn">
              <span>{icon}</span>
              <div style={{ fontWeight: 700, fontSize: 11 }}>{label}</div>
              <div style={{ color: 'var(--primary)', fontSize: 10 }}>{dur}</div>
            </button>
          ))}
        </div>
        <button className="phase-section__view-link">Open Calm Mode →</button>
      </div>

      {/* E. What Happens Next */}
      <div id="section-4" className="phase-section">
        <div className="phase-section__title">E. What Happens Next</div>
        <div className="phase-section__sub">Here's what to expect, step by step.</div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 0' }}>
          {[['🏥', 'Anaesthetic\nRoom'], ['🧑‍⚕️', 'Operating\nTheatre'], ['❤️', 'Surgery'], ['🛏️', 'ICU\nRecovery'], ['🏥', 'Ward\nStay']].map(([icon, label], i, arr) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
              <div style={{ textAlign: 'center' }}>
                <div style={{ fontSize: 18 }}>{icon}</div>
                <div style={{ fontSize: 9, color: 'var(--text-medium)', whiteSpace: 'pre-line', textAlign: 'center', lineHeight: 1.3 }}>{label}</div>
              </div>
              {i < arr.length - 1 && <div style={{ width: 12, height: 2, background: 'var(--border)', margin: '0 2px' }} />}
            </div>
          ))}
        </div>
        <button className="phase-section__view-link">See full timeline →</button>
      </div>

      {/* F. Personal Message */}
      <div id="section-5" className="phase-section" style={{ background: 'var(--bg-banner)' }}>
        <div className="phase-section__title">F. Personal Message from Your Team</div>
        <div className="phase-section__sub">A message from your surgical team.</div>
        <div style={{ borderLeft: '3px solid var(--primary)', paddingLeft: 12, margin: '10px 0', fontSize: 14, fontStyle: 'italic', lineHeight: 1.7, color: 'var(--text-dark)' }}>
          "We're ready for you, Ahmet. You're in the best hands. We'll take care of you."
        </div>
        <div style={{ fontSize: 13, color: 'var(--primary)', fontWeight: 600 }}>– Your Surgical Team ❤️</div>
        <button className="phase-section__view-link" style={{ color: 'var(--primary)' }}>Meet your team →</button>
      </div>

      {/* G. Reminders */}
      <div id="section-6" className="phase-section">
        <div className="phase-section__title">G. Important Reminders</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginTop: 8 }}>
          {[
            ['💊', 'Take your allowed medications with a sip of water'],
            ['👕', 'Wear your comfortable hospital clothes'],
            ['🪪', 'Bring ID & insurance documents'],
            ['💍', 'Remove jewellery, contacts, nail polish'],
          ].map(([icon, label]) => (
            <div key={label} style={{ display: 'flex', gap: 8, alignItems: 'flex-start', background: 'var(--bg)', padding: 10, borderRadius: 10 }}>
              <span style={{ fontSize: 20 }}>{icon}</span>
              <div style={{ fontSize: 11, color: 'var(--text-medium)', lineHeight: 1.4 }}>{label}</div>
              <span style={{ marginLeft: 'auto', fontSize: 14 }}>✅</span>
            </div>
          ))}
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 12, fontSize: 12, color: 'var(--text-medium)' }}>
          <span>Anything you're worried about? Talk to your care team.</span>
          <button className="btn btn-teal" style={{ fontSize: 11, padding: '6px 12px' }}>💬 Contact Team</button>
        </div>
      </div>
    </>
  )
}
