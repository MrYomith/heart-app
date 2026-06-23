import './TaskItem.css'

export default function TaskItem({ task, onToggle }) {
  const timeColor = task.timeColor === 'orange' ? 'var(--warning)' :
    task.timeColor === 'red' ? 'var(--primary)' : 'var(--teal)'

  return (
    <div className={`task-item${task.done ? ' task-item--done' : ''}`} onClick={() => onToggle(task.id)}>
      <div className="task-item__icon">{task.icon}</div>
      <div className="task-item__body">
        <div className="task-item__title">{task.title}</div>
        <div className="task-item__subtitle">{task.subtitle}</div>
      </div>
      <div className="task-item__right">
        <div className="task-item__time" style={{ color: timeColor }}>
          <svg width="13" height="13" viewBox="0 0 16 16" fill="none" style={{ marginRight: 3, flexShrink: 0 }}>
            <circle cx="8" cy="8" r="7" stroke="currentColor" strokeWidth="1.4" />
            <path d="M8 4.5V8L10.5 10.5" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" />
          </svg>
          {task.time}
        </div>
        <div className={`check-circle${task.done ? ' done' : ''}`} />
      </div>
    </div>
  )
}
