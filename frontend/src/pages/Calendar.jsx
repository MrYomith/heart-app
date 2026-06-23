import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { journeyPhases, upcomingAppointments } from '../data/mockData'
import './Calendar.css'

const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
const MONTH = 'May – June 2024'

const calData = {
  28: { label: 'Surgery Day', color: '#E8614D', icon: '🏥' },
  29: { label: 'Hospital Day 1', color: '#5BA5A0', icon: '🏥' },
  30: { label: 'Hospital Day 2', color: '#5BA5A0', icon: '🏥' },
  31: { label: 'Hospital Day 3', color: '#5BA5A0', icon: '🏥' },
}

export default function Calendar() {
  const navigate = useNavigate()
  const [view, setView] = useState('Month')
  const today = 28

  return (
    <div className="calendar">
      {/* Header */}
      <div className="calendar__header">
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <span style={{ fontSize: 22 }}>📅</span>
          <div>
            <h1 className="calendar__title">Calendar & Recovery Plan</h1>
            <p className="calendar__sub">Your personalised recovery journey, day by day.</p>
          </div>
        </div>
        <div style={{ width: 32 }} />
      </div>

      <div style={{ padding: '0 16px' }}>
        {/* Journey Timeline */}
        <div style={{ marginTop: 16 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
            <span className="section-title">Your Recovery Journey</span>
            <span style={{ fontSize: 12, color: 'var(--text-medium)' }}>Predicted Full Recovery: <strong>12 Weeks</strong> ℹ️</span>
          </div>
          <div className="calendar__journey-scroll">
            {journeyPhases.map((phase, i) => (
              <div key={phase.id} style={{ display: 'flex', alignItems: 'center', gap: 4, flexShrink: 0 }}>
                <div style={{ textAlign: 'center' }}>
                  <div style={{
                    width: 48, height: 48, borderRadius: '50%',
                    background: phase.status === 'completed' ? 'var(--teal)' : phase.status === 'active' ? 'var(--primary-light)' : 'var(--border)',
                    border: phase.status === 'active' ? '2px solid var(--primary)' : 'none',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    margin: '0 auto 6px', fontSize: 22,
                  }}>{phase.emoji}</div>
                  <div style={{ fontSize: 9, color: 'var(--text-dark)', fontWeight: 700, whiteSpace: 'nowrap', maxWidth: 64, overflow: 'hidden', textOverflow: 'ellipsis' }}>{phase.label}</div>
                  <div style={{ fontSize: 9, color: phase.status === 'completed' ? 'var(--success)' : phase.status === 'active' ? 'var(--primary)' : 'var(--text-light)', fontWeight: 600, marginTop: 2 }}>
                    {phase.status === 'completed' ? 'Completed' : phase.status === 'active' ? phase.subtitle || 'In progress' : phase.date || 'Upcoming'}
                  </div>
                </div>
                {i < journeyPhases.length - 1 && (
                  <div style={{ width: 24, height: 2, background: phase.status === 'completed' ? 'var(--teal)' : 'var(--border)', margin: '-14px 2px 0', flexShrink: 0 }} />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Month view */}
        <div className="card" style={{ marginTop: 16 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <button style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: 16, padding: 2 }}>‹</button>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <button style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: 12, color: 'var(--teal)', fontWeight: 600 }}>Today</button>
                <span style={{ fontWeight: 700, fontSize: 15 }}>{MONTH}</span>
              </div>
              <button style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: 16, padding: 2 }}>›</button>
            </div>
            <div style={{ display: 'flex', gap: 6 }}>
              {['Month', 'Week', 'List'].map(v => (
                <button key={v} onClick={() => setView(v)}
                  style={{ background: view === v ? 'var(--teal)' : 'var(--bg)', color: view === v ? 'white' : 'var(--text-medium)', border: 'none', borderRadius: 'var(--radius-full)', padding: '4px 10px', fontSize: 11, cursor: 'pointer', fontFamily: 'var(--font)', fontWeight: 600 }}>
                  {v}
                </button>
              ))}
              <button style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: 14 }}>⚙️</button>
            </div>
          </div>

          {/* Calendar grid */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 2 }}>
            {DAYS.map(d => (
              <div key={d} style={{ textAlign: 'center', fontSize: 11, fontWeight: 700, color: 'var(--text-medium)', padding: '4px 0' }}>{d}</div>
            ))}
            {/* Week 1: 27-2 */}
            {[{n: 27}, {n: 28, surgery: true}, {n: 29, hosp: 1}, {n: 30, hosp: 2}, {n: 31, hosp: 3}, {n: '1 Jun', hosp: 4}, {n: '2', hosp: '5–7'}].map((day, i) => (
              <div key={i} style={{
                borderRadius: 8, padding: '4px 2px', minHeight: 48,
                background: day.n === today || day.n === 28 ? 'var(--primary)' : 'transparent',
                textAlign: 'center', cursor: 'pointer',
              }}>
                <div style={{ fontSize: 12, fontWeight: day.n === 28 ? 800 : 400, color: day.n === 28 ? 'white' : 'var(--text-dark)' }}>{day.n}</div>
                {day.surgery && <div style={{ fontSize: 8, background: '#E8614D', color: 'white', borderRadius: 4, padding: '1px 3px', marginTop: 2 }}>🏥 Surgery</div>}
                {day.hosp && <div style={{ fontSize: 8, background: 'var(--teal-light)', color: 'var(--teal)', borderRadius: 4, padding: '1px 3px', marginTop: 2 }}>🏥 Hosp {day.hosp}</div>}
              </div>
            ))}
            {/* Week 2: 3-9 */}
            {[{n: 3}, {n: 4, followup: '7 Jun'}, {n: 5}, {n: 6, physio: 1}, {n: 7}, {n: 8, physio: 2}, {n: 9, rest: true}].map((day, i) => (
              <div key={`w2-${i}`} style={{ borderRadius: 8, padding: '4px 2px', minHeight: 48, textAlign: 'center', cursor: 'pointer' }}>
                <div style={{ fontSize: 12, color: 'var(--text-dark)' }}>{day.n}</div>
                {day.followup && <div style={{ fontSize: 8, background: '#EEF4FF', color: '#5B8DEF', borderRadius: 4, padding: '1px 3px', marginTop: 2 }}>📋 Follow-up</div>}
                {day.physio && <div style={{ fontSize: 8, background: 'var(--success-bg)', color: 'var(--success)', borderRadius: 4, padding: '1px 3px', marginTop: 2 }}>🏃 Physio</div>}
                {day.rest && <div style={{ fontSize: 8, background: 'var(--primary-light)', color: 'var(--primary)', borderRadius: 4, padding: '1px 3px', marginTop: 2 }}>❤️ Rest</div>}
              </div>
            ))}
          </div>

          {/* Legend */}
          <div style={{ display: 'flex', gap: 10, marginTop: 12, flexWrap: 'wrap' }}>
            {[['#E8614D', 'Surgery / Hospital'], ['#5B8DEF', 'Follow-up'], ['var(--success)', 'Physiotherapy'], ['var(--warning)', 'Medication / Reminders'], ['var(--border)', 'Other']].map(([color, label]) => (
              <div key={label} style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 10, color: 'var(--text-medium)' }}>
                <div style={{ width: 10, height: 10, borderRadius: 3, background: color }} />
                {label}
              </div>
            ))}
          </div>
        </div>

        {/* Bottom info row */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginTop: 12 }}>
          {/* Post-op guide */}
          <div className="card">
            <div className="learn__card-title" style={{ fontSize: 13 }}>Post-op Recovery Guide</div>
            <div className="learn__card-sub" style={{ fontSize: 11 }}>Typically 5–7 days in hospital</div>
            {[['Day 1', 'Monitoring & pain management'], ['Day 2', 'Sitting up & breathing exercises'], ['Day 3', 'Walking with support'], ['Day 4', 'Increasing activity'], ['Day 5–7', 'Preparing for discharge']].map(([day, label]) => (
              <div key={day} style={{ display: 'flex', gap: 8, padding: '5px 0', borderLeft: '3px solid var(--primary)', paddingLeft: 8, marginBottom: 4 }}>
                <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--primary)', width: 40, flexShrink: 0 }}>{day}</span>
                <span style={{ fontSize: 11, color: 'var(--text-medium)' }}>{label}</span>
              </div>
            ))}
            <button className="view-all" style={{ marginTop: 6 }}>View full guide →</button>
          </div>

          {/* Upcoming appointments */}
          <div className="card">
            <div className="learn__card-title" style={{ fontSize: 13 }}>Upcoming Appointments</div>
            {upcomingAppointments.slice(0, 3).map(apt => (
              <div key={apt.id} style={{ padding: '8px 0', borderBottom: '1px solid var(--border)' }}>
                <div style={{ display: 'flex', gap: 6, alignItems: 'flex-start' }}>
                  <span style={{ fontSize: 14, marginTop: 2 }}>📅</span>
                  <div>
                    <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--text-dark)' }}>{apt.date}</div>
                    <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>{apt.title}</div>
                    <div style={{ fontSize: 11, color: 'var(--teal)', fontWeight: 600 }}>{apt.time}</div>
                  </div>
                </div>
              </div>
            ))}
            <button className="view-all" style={{ marginTop: 8 }}>Add to calendar →</button>
          </div>
        </div>

        {/* Recovery prediction */}
        <div className="card" style={{ marginTop: 12, display: 'flex', gap: 12, alignItems: 'center' }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-dark)', marginBottom: 4 }}>Recovery Prediction</div>
            <div style={{ fontSize: 11, color: 'var(--text-medium)', marginBottom: 8 }}>Based on your progress & wearable data</div>
            <div style={{ fontSize: 28, fontWeight: 900, color: 'var(--teal)' }}>85%</div>
            <div style={{ fontSize: 12, color: 'var(--success)', fontWeight: 700 }}>On track for full recovery</div>
            <div style={{ fontSize: 11, color: 'var(--text-medium)', marginTop: 4 }}>Expected full recovery in 12 weeks<br />(18 Aug 2024)</div>
          </div>
          <div style={{ flex: 1 }}>
            {/* Simple line chart placeholder */}
            <svg width="140" height="80" viewBox="0 0 140 80">
              <polyline points="0,70 20,60 40,55 60,45 80,35 100,25 120,18 140,12" fill="none" stroke="var(--teal)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
              <polygon points="0,70 20,60 40,55 60,45 80,35 100,25 120,18 140,12 140,80 0,80" fill="var(--teal)" opacity="0.08" />
            </svg>
          </div>
        </div>

        {/* Bottom banner */}
        <div style={{ background: 'var(--bg-card)', borderRadius: 'var(--radius-lg)', padding: 14, marginTop: 12, marginBottom: 8, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <span style={{ fontSize: 18 }}>🔔</span>
            <div style={{ fontSize: 12, color: 'var(--text-dark)' }}>
              <strong>Don't forget to complete your daily plan</strong>
              <div style={{ fontSize: 11, color: 'var(--text-medium)' }}>Consistency today, strength tomorrow.</div>
            </div>
          </div>
          <button className="view-all" onClick={() => navigate('/today')}>View My Plan →</button>
        </div>
      </div>
    </div>
  )
}
