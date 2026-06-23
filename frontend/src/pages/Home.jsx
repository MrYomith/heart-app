import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import MioMascot from '../components/common/MioMascot'
import ProgressRing from '../components/common/ProgressRing'
import { user, todayTasks, wearableData } from '../data/mockData'
import './Home.css'

const quickActions = [
  { icon: '💚', label: 'Emotional\nCheck-in', sub: 'How are you\nfeeling today?', path: '/journey/inpatient' },
  { icon: '💊', label: 'Medications', sub: 'Next: 08:00\nAspirin', path: '/more' },
  { icon: '📅', label: 'Calendar', sub: 'Next: Pre-op\nappointment', path: '/calendar' },
  { icon: '❤️', label: 'Symptoms', sub: 'No alerts\ntoday', path: '/messages' },
  { icon: '🎯', label: 'Goals', sub: 'Stay active,\neat well, breathe', path: '/journey' },
  { icon: '⌚', label: 'Wearables', sub: 'Connected\nGood sync', path: '/more' },
  { icon: '💧', label: 'Glucose', sub: 'Last: 112 mg/dL\nThis morning', path: '/more' },
  { icon: '🎧', label: 'Contact Team', sub: "We're here\nto help", path: '/messages' },
]

export default function Home() {
  const navigate = useNavigate()
  const [tasks, setTasks] = useState(todayTasks)
  const doneTasks = tasks.filter(t => t.done).length

  const previewTasks = tasks.slice(0, 3)

  return (
    <div className="home">
      {/* Hero Banner */}
      <div className="home__hero">
        <div className="home__hero-left">
          <MioMascot variant="happy" size={90} />
        </div>
        <div className="home__hero-content">
          <div className="home__greeting">Good morning,</div>
          <div className="home__name">{user.name} <span>🤍</span></div>
          <p className="home__tagline">You're doing something amazing for your heart. We're in this together.</p>
          <div className="chip chip-teal" style={{ marginTop: 10, fontSize: 11 }}>
            🌱 Pre-op Preparation
          </div>
        </div>
        <div className="home__weather">
          ☀️ <span>15°C</span>
        </div>
      </div>

      {/* Quote card */}
      <div className="home__quote">
        <span className="home__quote-mark">"</span>
        Small steps today, stronger heart tomorrow.
        <span className="home__quote-heart"> 🤍</span>
      </div>

      {/* Journey progress bar */}
      <div className="home__progress-banner">
        <div className="home__path-visual">
          <div className="home__path-road" />
          <div className="home__path-flag">🚩</div>
        </div>
      </div>

      <div style={{ padding: '0 16px' }}>
        {/* Today's Plan + Progress side by side */}
        <div className="home__grid2">
          <div className="card">
            <div className="section-row">
              <span className="section-title" style={{ fontSize: 15 }}>📋 Today's Plan</span>
              <button className="view-all" onClick={() => navigate('/today')}>View all</button>
            </div>
            {previewTasks.map(task => (
              <div key={task.id} className="home__task-row">
                <span className="home__task-icon">{task.icon}</span>
                <div className="home__task-info">
                  <div className="home__task-name">{task.title}</div>
                  <div className="home__task-sub">{task.subtitle}</div>
                </div>
                <div className={`check-circle${task.done ? ' done' : ''}`} style={{ width: 24, height: 24 }} />
              </div>
            ))}
          </div>

          <div className="card">
            <div className="section-row">
              <span className="section-title" style={{ fontSize: 15 }}>📈 Your Progress</span>
              <button className="view-all" onClick={() => navigate('/journey')}>View journey</button>
            </div>
            <div style={{ display: 'flex', justifyContent: 'center', margin: '8px 0' }}>
              <ProgressRing value={user.journeyProgress} max={100} size={88} label={`${user.journeyProgress}%`} sublabel="of journey" />
            </div>
            <div className="home__progress-stepper">
              {[1,2,3,4,5].map(i => (
                <div key={i} className={`home__step-dot${i <= 3 ? ' done' : i === 3 ? ' active' : ''}`} />
              ))}
            </div>
            <div className="home__phase-label">Pre-op Preparation</div>
            <div className="home__phase-next">Next: Surgery Day</div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="section-row" style={{ marginTop: 20 }}>
          <span className="section-title">Quick Access</span>
        </div>
        <div className="home__actions-grid">
          {quickActions.map((action, i) => (
            <button key={i} className="home__action-card" onClick={() => navigate(action.path)}>
              <div className="home__action-icon">{action.icon}</div>
              <div className="home__action-label">{action.label}</div>
              <div className="home__action-sub">{action.sub}</div>
            </button>
          ))}
        </div>

        {/* Motivational Banner */}
        <div className="home__moti-banner">
          <div className="home__moti-shield">🛡️</div>
          <div className="home__moti-text">
            <div>Every action you take now</div>
            <div><strong>is building your stronger tomorrow.</strong></div>
          </div>
          <MioMascot variant="celebrate" size={60} style={{ marginLeft: 'auto' }} />
        </div>
      </div>
    </div>
  )
}
