import { useState } from 'react'
import { messages } from '../data/mockData'
import './Messages.css'

const categories = [
  { label: 'Care Team', icon: '👥', count: 12, sub: 'Appointments, instructions & follow-up' },
  { label: 'Physiotherapy', icon: '🏃', count: 8, sub: 'Exercises, progress & mobility' },
  { label: 'Education', icon: '📖', count: 7, sub: 'Tips, guides & learning' },
  { label: 'Emotional Support', icon: '❤️', count: 6, sub: 'Encouragement & wellbeing' },
  { label: 'Alerts', icon: '⚠️', count: 4, sub: 'Symptoms, concerns & safety', alert: true },
  { label: 'Family / Caregiver', icon: '👨‍👩‍👧', count: 3, sub: 'Updates & guidance for loved ones' },
]

const symptoms = [
  { icon: '🔴', label: 'Redness / swelling at incision' },
  { icon: '🔴', label: 'Fever (≥ 38°C)' },
  { icon: '🔴', label: 'Increased pain' },
  { icon: '🔴', label: 'Breathlessness' },
  { icon: '🟡', label: 'Dizziness / palpitations' },
  { icon: '🟡', label: 'Mood / anxiety concerns' },
]

export default function Messages() {
  const [selectedMsg, setSelectedMsg] = useState(messages[0])

  return (
    <div className="messages">
      {/* Header */}
      <div className="messages__header">
        <div className="messages__header-icon">💬</div>
        <div>
          <h1 className="messages__title">Messages</h1>
          <p className="messages__sub">Stay connected. Stay supported. You're not alone. 💚</p>
        </div>
      </div>

      {/* Care team banner */}
      <div className="messages__care-banner">
        <div className="messages__care-mio">🫀</div>
        <div className="messages__care-text">
          <div className="messages__care-label">CARE TEAM MESSAGE</div>
          <div className="messages__care-title">Your recovery is our priority.</div>
          <div className="messages__care-sub">We're here to guide you at every step of your heart healing journey.</div>
          <button className="btn btn-primary" style={{ fontSize: 12, marginTop: 10, padding: '8px 16px' }}>✏️ New Message</button>
        </div>
        <div className="messages__recent-list">
          {[['Wound review reminder', '10:30 AM'], ['Physiotherapy update', 'Yesterday'], ['Medication instruction', 'Yesterday'], ['Follow-up appointment', '2 days ago']].map(([label, time]) => (
            <div key={label} className="messages__recent-item">
              <span style={{ fontSize: 12, flex: 1, color: 'var(--text-dark)' }}>{label}</span>
              <span style={{ fontSize: 11, color: 'var(--text-medium)' }}>{time}</span>
            </div>
          ))}
          <button className="view-all" style={{ marginTop: 8 }}>View all messages →</button>
        </div>
      </div>

      <div style={{ padding: '0 16px' }}>
        {/* Categories */}
        <div className="section-title" style={{ margin: '16px 0 10px' }}>Message Categories</div>
        <div className="messages__cats-scroll">
          {categories.map(cat => (
            <button key={cat.label} className={`messages__cat-card${cat.alert ? ' alert' : ''}`}>
              <div className="messages__cat-count">{cat.count}</div>
              <div className="messages__cat-icon">{cat.icon}</div>
              <div className="messages__cat-label">{cat.label}</div>
              <div className="messages__cat-sub">{cat.sub}</div>
            </button>
          ))}
        </div>

        {/* All Messages + Detail */}
        <div className="messages__split">
          {/* List */}
          <div className="messages__list">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
              <span className="section-title" style={{ fontSize: 15 }}>All Messages</span>
              <div style={{ display: 'flex', gap: 8 }}>
                <span style={{ fontSize: 12, color: 'var(--primary)', fontWeight: 600 }}>All</span>
                <span style={{ fontSize: 16, cursor: 'pointer' }}>⚙️</span>
              </div>
            </div>
            {messages.map(msg => (
              <button key={msg.id} className={`messages__msg-item${selectedMsg?.id === msg.id ? ' active' : ''}`} onClick={() => setSelectedMsg(msg)}>
                <div className="messages__msg-avatar">{msg.avatar}</div>
                <div className="messages__msg-body">
                  <div className="messages__msg-sender">{msg.sender}</div>
                  <div className="messages__msg-subject">{msg.subject}</div>
                  <div className="messages__msg-preview">{msg.preview}</div>
                </div>
                <div className="messages__msg-meta">
                  <div className="messages__msg-time">{msg.time}</div>
                  {msg.unread > 0 && <div className="messages__msg-badge">{msg.unread}</div>}
                </div>
              </button>
            ))}
          </div>

          {/* Detail */}
          {selectedMsg && (
            <div className="messages__detail">
              <div className="messages__detail-header">
                <div className="messages__detail-avatar">{selectedMsg.avatar}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 700 }}>{selectedMsg.sender}</div>
                  <div style={{ fontSize: 12, color: 'var(--text-medium)' }}>{selectedMsg.time}</div>
                </div>
                <div style={{ display: 'flex', gap: 8 }}>
                  <span style={{ cursor: 'pointer', fontSize: 16 }}>⭐</span>
                  <span style={{ cursor: 'pointer', fontSize: 16 }}>⋮</span>
                </div>
              </div>
              <div className="messages__detail-subject">{selectedMsg.subject}</div>
              {selectedMsg.full ? (
                <div className="messages__detail-body">
                  {selectedMsg.full.split('\n').map((line, i) => (
                    line.trim() ? (
                      line.startsWith('Friday') || line.startsWith('HerzZentrum') || line.startsWith('Martini') ? (
                        <div key={i} style={{ display: 'flex', gap: 8, alignItems: 'center', background: 'var(--bg)', borderRadius: 8, padding: '6px 10px', margin: '4px 0', fontSize: 12 }}>
                          <span>{line.startsWith('Friday') ? '📅' : '📍'}</span>
                          <span>{line}</span>
                        </div>
                      ) : <p key={i} style={{ marginBottom: 6, fontSize: 13, lineHeight: 1.6 }}>{line}</p>
                    ) : <br key={i} />
                  ))}
                </div>
              ) : (
                <div style={{ padding: 16, fontSize: 13, color: 'var(--text-medium)', fontStyle: 'italic' }}>No full message content available.</div>
              )}
              <button className="btn btn-teal" style={{ width: '100%', marginTop: 12, fontSize: 13 }}>↩️ Reply to Care Team</button>
            </div>
          )}
        </div>

        {/* Smart Check-in + Symptom Escalation */}
        <div className="messages__bottom-grid">
          <div className="card">
            <div className="learn__card-title" style={{ fontSize: 14 }}>🔍 Smart Recovery Check-in</div>
            <div className="learn__card-sub">Help us understand how you're doing.</div>
            {[['🚶', "How was your walk today?", '✅'], ['💧', 'Any increased swelling?', 'No'], ['😣', 'How is your pain (0–10)?', '3'], ['🌙', 'Are you sleeping better?', 'Yes'], ['🫁', 'Any breathlessness?', 'No']].map(([icon, q, a]) => (
              <div key={q} style={{ display: 'flex', gap: 8, alignItems: 'center', padding: '8px 0', borderBottom: '1px solid var(--border)' }}>
                <span>{icon}</span>
                <div style={{ flex: 1, fontSize: 12, color: 'var(--text-dark)' }}>{q}</div>
                <span style={{ fontSize: 12, fontWeight: 700, color: a === '✅' ? 'var(--success)' : 'var(--teal)' }}>{a}</span>
              </div>
            ))}
            <button className="btn btn-outline" style={{ width: '100%', marginTop: 12, fontSize: 12 }}>Answer Check-in →</button>
          </div>

          <div className="card">
            <div className="learn__card-title" style={{ fontSize: 14 }}>⚠️ Symptom Escalation</div>
            <div className="learn__card-sub">Report if you're experiencing any of these.</div>
            {symptoms.map(s => (
              <button key={s.label} style={{ display: 'flex', gap: 8, alignItems: 'center', width: '100%', background: 'none', border: 'none', borderBottom: '1px solid var(--border)', padding: '8px 0', cursor: 'pointer', textAlign: 'left', fontSize: 12, color: 'var(--text-dark)', fontFamily: 'var(--font)' }}>
                <span>{s.icon}</span>
                <span style={{ flex: 1 }}>{s.label}</span>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg>
              </button>
            ))}
            <button className="btn btn-primary" style={{ width: '100%', marginTop: 12, fontSize: 12 }}>⚠️ Report a Symptom</button>
          </div>

          <div className="card" style={{ background: 'var(--bg-banner)' }}>
            <div style={{ fontSize: 24, marginBottom: 8 }}>🫀</div>
            <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--text-dark)', marginBottom: 6 }}>A little support goes a long way.</div>
            <div style={{ fontSize: 12, color: 'var(--text-medium)', lineHeight: 1.6 }}>
              Recovery can feel slow some days. That's normal.<br /><br />
              You've already come through the hardest part.<br /><br />
              <strong>We're proud of you!</strong>
            </div>
            <button className="btn btn-primary" style={{ width: '100%', marginTop: 12, fontSize: 12 }}>View Support Messages →</button>
          </div>
        </div>
      </div>
    </div>
  )
}
