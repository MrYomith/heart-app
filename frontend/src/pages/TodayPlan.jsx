import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import TaskItem from '../components/common/TaskItem'
import MioMascot from '../components/common/MioMascot'
import ProgressRing from '../components/common/ProgressRing'
import { todayTasks, user } from '../data/mockData'
import './TodayPlan.css'

export default function TodayPlan() {
  const navigate = useNavigate()
  const [tasks, setTasks] = useState(todayTasks)
  const done = tasks.filter(t => t.done).length
  const total = tasks.length

  const toggle = (id) => setTasks(prev => prev.map(t => t.id === id ? { ...t, done: !t.done } : t))

  const today = new Date().toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })

  return (
    <div className="today-plan">
      {/* Header */}
      <div className="today-plan__header">
        <button className="today-plan__back" onClick={() => navigate('/')}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
            <path d="M15 19l-7-7 7-7" stroke="var(--text-dark)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
        <div>
          <h1 className="today-plan__title">Today's Plan</h1>
          <p className="today-plan__date">{today}</p>
        </div>
        <button className="today-plan__cal-btn">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
            <rect x="3" y="4" width="18" height="18" rx="3" stroke="var(--text-dark)" strokeWidth="1.8" />
            <path d="M16 2v4M8 2v4M3 10h18" stroke="var(--text-dark)" strokeWidth="1.8" strokeLinecap="round" />
          </svg>
        </button>
      </div>

      {/* Hero Banner */}
      <div className="today-plan__hero">
        <MioMascot variant="happy" size={80} />
        <div className="today-plan__hero-text">
          <div className="today-plan__hi">Hi {user.name}! 👋</div>
          <p>Here is your personalised plan for today.</p>
          <div className="today-plan__motto">Small steps today, stronger heart tomorrow. 🤍</div>
        </div>
        <ProgressRing value={done} max={total} size={72} label={`${done}/${total}`} sublabel="Tasks" />
      </div>

      {/* Most important section */}
      <div style={{ padding: '16px 16px 0' }}>
        <div className="today-plan__section-header">
          <span className="today-plan__sparkle">✨</span>
          <div>
            <div className="section-title">Today's most important steps</div>
            <div className="section-subtitle" style={{ fontSize: 12 }}>Focus on these. You've got this!</div>
          </div>
          <div style={{ marginLeft: 'auto', display: 'flex', gap: 6, alignItems: 'center' }}>
            <span style={{ fontSize: 12, color: 'var(--teal)', fontWeight: 600 }}>Why these?</span>
            <span style={{ fontSize: 12, color: 'var(--text-light)', border: '1px solid var(--border)', borderRadius: '50%', width: 18, height: 18, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>i</span>
          </div>
        </div>

        <div className="card" style={{ marginTop: 8 }}>
          {tasks.map(task => (
            <TaskItem key={task.id} task={task} onToggle={toggle} />
          ))}
        </div>

        {/* Footer motivational */}
        <div className="today-plan__footer">
          <div className="today-plan__footer-icon">✅</div>
          <div>
            <div className="today-plan__footer-title">You're doing great, {user.name}!</div>
            <div className="today-plan__footer-sub">Every step you take is building your recovery.</div>
          </div>
          <MioMascot variant="celebrate" size={52} />
        </div>
      </div>
    </div>
  )
}
