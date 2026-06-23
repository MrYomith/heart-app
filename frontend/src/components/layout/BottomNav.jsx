import { useLocation, useNavigate } from 'react-router-dom'
import './BottomNav.css'

const tabs = [
  { id: 'home', label: 'Home', path: '/', icon: HomeIcon },
  { id: 'journey', label: 'Journey', path: '/journey', icon: JourneyIcon },
  { id: 'mio', label: 'MioHart', path: '/', icon: MioIcon, center: true },
  { id: 'learn', label: 'Learn', path: '/learn', icon: LearnIcon },
  { id: 'more', label: 'More', path: '/more', icon: MoreIcon },
]

export default function BottomNav() {
  const location = useLocation()
  const navigate = useNavigate()

  const isActive = (tab) => {
    if (tab.id === 'home') return location.pathname === '/'
    if (tab.id === 'journey') return location.pathname.startsWith('/journey')
    if (tab.id === 'learn') return location.pathname === '/learn'
    if (tab.id === 'more') return ['/more', '/messages', '/calendar'].includes(location.pathname)
    return false
  }

  return (
    <nav className="bottom-nav">
      {tabs.map((tab) => {
        const Icon = tab.icon
        const active = isActive(tab)
        if (tab.center) {
          return (
            <button
              key={tab.id}
              className="bottom-nav__center"
              onClick={() => navigate('/')}
              aria-label="MioHart"
            >
              <div className="bottom-nav__mio-btn">
                <span className="bottom-nav__mio-heart">🫀</span>
              </div>
              <span className="bottom-nav__center-label">MioHart</span>
            </button>
          )
        }
        return (
          <button
            key={tab.id}
            className={`bottom-nav__tab${active ? ' active' : ''}`}
            onClick={() => navigate(tab.path)}
          >
            <Icon active={active} />
            <span>{tab.label}</span>
          </button>
        )
      })}
    </nav>
  )
}

function HomeIcon({ active }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M3 9.5L12 3L21 9.5V20C21 20.55 20.55 21 20 21H15V15H9V21H4C3.45 21 3 20.55 3 20V9.5Z"
        fill={active ? 'var(--primary)' : 'none'}
        stroke={active ? 'var(--primary)' : 'var(--text-light)'}
        strokeWidth="1.8" strokeLinejoin="round" />
    </svg>
  )
}

function JourneyIcon({ active }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M5 20C5 20 5 14 12 14C19 14 19 8 19 8M19 8L15 4M19 8L15 12"
        stroke={active ? 'var(--teal)' : 'var(--text-light)'}
        strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
      <circle cx="5" cy="20" r="1.5" fill={active ? 'var(--teal)' : 'var(--text-light)'} />
    </svg>
  )
}

function MioIcon() {
  return null
}

function LearnIcon({ active }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M4 19V6C4 5.45 4.45 5 5 5H15L20 10V19C20 19.55 19.55 20 19 20H5C4.45 20 4 19.55 4 19Z"
        fill={active ? 'var(--teal-light)' : 'none'}
        stroke={active ? 'var(--teal)' : 'var(--text-light)'}
        strokeWidth="1.8" strokeLinejoin="round" />
      <path d="M15 5V10H20" stroke={active ? 'var(--teal)' : 'var(--text-light)'} strokeWidth="1.8" strokeLinejoin="round" />
      <line x1="8" y1="14" x2="16" y2="14" stroke={active ? 'var(--teal)' : 'var(--text-light)'} strokeWidth="1.5" strokeLinecap="round" />
      <line x1="8" y1="17" x2="13" y2="17" stroke={active ? 'var(--teal)' : 'var(--text-light)'} strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  )
}

function MoreIcon({ active }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <rect x="3" y="3" width="8" height="8" rx="2"
        fill={active ? 'var(--teal-light)' : 'none'}
        stroke={active ? 'var(--teal)' : 'var(--text-light)'} strokeWidth="1.8" />
      <rect x="13" y="3" width="8" height="8" rx="2"
        fill={active ? 'var(--teal-light)' : 'none'}
        stroke={active ? 'var(--teal)' : 'var(--text-light)'} strokeWidth="1.8" />
      <rect x="3" y="13" width="8" height="8" rx="2"
        fill={active ? 'var(--teal-light)' : 'none'}
        stroke={active ? 'var(--teal)' : 'var(--text-light)'} strokeWidth="1.8" />
      <rect x="13" y="13" width="8" height="8" rx="2"
        fill={active ? 'var(--teal-light)' : 'none'}
        stroke={active ? 'var(--teal)' : 'var(--text-light)'} strokeWidth="1.8" />
    </svg>
  )
}
