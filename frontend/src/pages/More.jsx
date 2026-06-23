import { useNavigate } from 'react-router-dom'
import { user, wearableData } from '../data/mockData'
import ProgressRing from '../components/common/ProgressRing'

const menuSections = [
  {
    title: 'My Health',
    items: [
      { icon: '📊', label: 'Reports', sub: 'Progress reports & summaries', path: null },
      { icon: '⌚', label: 'Wearables', sub: `Heart: ${wearableData.heartRate} bpm · Steps: ${wearableData.steps.toLocaleString()}`, path: null },
      { icon: '💊', label: 'Medications', sub: '4 active medications', path: null },
      { icon: '📅', label: 'Appointments', sub: 'Next: 7 Jun 2024 – 10:30 AM', path: '/calendar' },
      { icon: '🏃', label: 'Physiotherapy', sub: 'Day 1 · 7 sessions planned', path: null },
    ],
  },
  {
    title: 'Communication',
    items: [
      { icon: '💬', label: 'Messages', sub: '3 unread messages', path: '/messages' },
      { icon: '📖', label: 'Education', sub: '72% learning completed', path: '/learn' },
    ],
  },
  {
    title: 'Settings & Support',
    items: [
      { icon: '👤', label: 'My Profile', sub: `${user.name} · Surgery Day: 28 May`, path: null },
      { icon: '🔔', label: 'Notifications', sub: 'Manage reminders & alerts', path: null },
      { icon: '🌐', label: 'Language', sub: 'English (UK) · Deutsch', path: null },
      { icon: '🔒', label: 'Privacy & GDPR', sub: 'Data & permissions', path: null },
      { icon: '🎧', label: 'Help & Support', sub: 'Contact care team or MioHart support', path: null },
      { icon: 'ℹ️', label: 'About MioHart', sub: 'Version 1.0.0', path: null },
    ],
  },
]

export default function More() {
  const navigate = useNavigate()

  return (
    <div style={{ background: 'var(--bg)', paddingBottom: 16 }}>
      {/* Header */}
      <div style={{ background: 'var(--bg-card)', padding: 16, borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 48, height: 48, borderRadius: '50%', background: 'var(--bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, border: '2px solid var(--border)' }}>👤</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 18, fontWeight: 800, color: 'var(--text-dark)' }}>{user.name}</div>
          <div style={{ fontSize: 12, color: 'var(--text-medium)' }}>Surgery: 28 May 2024 · Inpatient Recovery</div>
          <div style={{ display: 'flex', gap: 4, marginTop: 4 }}>
            <div className="chip chip-coral" style={{ fontSize: 10 }}>Day {user.currentPhaseDay}</div>
            <div className="chip chip-teal" style={{ fontSize: 10 }}>85% on track</div>
          </div>
        </div>
        <ProgressRing value={user.journeyProgress} max={100} size={52} label={`${user.journeyProgress}%`} />
      </div>

      {/* Wearable snapshot */}
      <div style={{ background: 'var(--bg-teal-banner)', padding: '14px 16px', display: 'flex', gap: 12, overflowX: 'auto' }}>
        {[
          ['❤️', `${wearableData.heartRate} bpm`, 'Heart Rate'],
          ['👟', `${wearableData.steps.toLocaleString()}`, 'Steps'],
          ['⚡', `${wearableData.activity} min`, 'Activity'],
          ['🌙', wearableData.sleep, 'Sleep'],
          ['💧', `${wearableData.spo2}%`, 'SpO₂'],
          ['📊', `${wearableData.hrv} ms`, 'HRV'],
        ].map(([icon, val, label]) => (
          <div key={label} style={{ flex: 'none', textAlign: 'center', minWidth: 56 }}>
            <div style={{ fontSize: 20 }}>{icon}</div>
            <div style={{ fontSize: 14, fontWeight: 800, color: 'var(--text-dark)' }}>{val}</div>
            <div style={{ fontSize: 10, color: 'var(--text-medium)' }}>{label}</div>
          </div>
        ))}
      </div>

      {/* Menu sections */}
      {menuSections.map(section => (
        <div key={section.title} style={{ padding: '16px 16px 0' }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--text-light)', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 8 }}>{section.title}</div>
          <div style={{ background: 'var(--bg-card)', borderRadius: 'var(--radius-lg)', overflow: 'hidden', boxShadow: 'var(--shadow-sm)' }}>
            {section.items.map((item, i) => (
              <button
                key={item.label}
                onClick={() => item.path && navigate(item.path)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 12,
                  width: '100%',
                  background: 'none',
                  border: 'none',
                  borderBottom: i < section.items.length - 1 ? '1px solid var(--border)' : 'none',
                  padding: '14px 16px',
                  cursor: item.path ? 'pointer' : 'default',
                  fontFamily: 'var(--font)',
                  textAlign: 'left',
                  transition: 'background 0.15s',
                }}
                onMouseOver={e => e.currentTarget.style.background = item.path ? 'var(--bg)' : 'none'}
                onMouseOut={e => e.currentTarget.style.background = 'none'}
              >
                <div style={{ width: 36, height: 36, borderRadius: 10, background: 'var(--bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18, flexShrink: 0 }}>{item.icon}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 600, color: 'var(--text-dark)' }}>{item.label}</div>
                  <div style={{ fontSize: 12, color: 'var(--text-medium)', marginTop: 1 }}>{item.sub}</div>
                </div>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                  <path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </button>
            ))}
          </div>
        </div>
      ))}

      {/* Sign out */}
      <div style={{ padding: '20px 16px 8px' }}>
        <button style={{ width: '100%', background: 'var(--primary-light)', color: 'var(--primary)', border: 'none', borderRadius: 'var(--radius-lg)', padding: 14, fontSize: 14, fontWeight: 700, cursor: 'pointer', fontFamily: 'var(--font)' }}>
          Sign Out
        </button>
      </div>

      <div style={{ textAlign: 'center', padding: '8px', fontSize: 11, color: 'var(--text-light)' }}>
        MioHart v1.0.0 · GDPR Compliant · CE Mark Pending
      </div>
    </div>
  )
}
