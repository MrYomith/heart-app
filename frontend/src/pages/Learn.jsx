import { educationTopics, recommendedVideos } from '../data/mockData'
import './Learn.css'

export default function Learn() {
  return (
    <div className="learn">
      {/* Header */}
      <div className="learn__header">
        <div className="learn__header-icon">📖</div>
        <div>
          <h1 className="learn__title">Education</h1>
          <p className="learn__sub">Knowledge empowers recovery. 💚</p>
        </div>
      </div>

      {/* Hero */}
      <div className="learn__hero">
        <div style={{ fontSize: 40, marginBottom: 12 }}>🫀</div>
        <h2 className="learn__hero-title">Learn. Understand.<br /><span style={{ color: 'var(--teal)' }}>Heal stronger.</span></h2>
        <p className="learn__hero-sub">Reliable information, step by step, for your heart health journey.</p>
      </div>

      <div style={{ padding: '0 16px' }}>
        {/* Topics */}
        <div className="section-row" style={{ marginTop: 20 }}>
          <span className="section-title">Explore by Topic</span>
          <button className="view-all">View all topics →</button>
        </div>
        <div className="learn__topics-scroll">
          {educationTopics.map(topic => (
            <button key={topic.id} className={`learn__topic-card${topic.active ? ' active' : ''}${topic.completed ? ' completed' : ''}`}>
              <div className="learn__topic-icon">{topic.icon}</div>
              <div className="learn__topic-name">{topic.title}</div>
              <div className="learn__topic-sub">{topic.subtitle}</div>
              {topic.completed && <div className="learn__topic-badge">✅</div>}
            </button>
          ))}
        </div>

        {/* Recommended Videos */}
        <div className="section-row" style={{ marginTop: 20 }}>
          <span className="section-title">Recommended for You</span>
          <button className="view-all">View all →</button>
        </div>
        <div className="learn__videos-scroll">
          {recommendedVideos.map(video => (
            <div key={video.id} className="learn__video-card">
              <div className="learn__video-thumb">
                <span>{video.thumbnail}</span>
                <div className="learn__video-duration">{video.duration}</div>
                <div className="learn__video-play">▶</div>
              </div>
              <div className="learn__video-title">{video.title}</div>
              <div className="learn__video-type">📹 Video</div>
            </div>
          ))}
        </div>

        {/* Guides + Quizzes + Progress */}
        <div className="learn__bottom-grid">
          <div className="card">
            <div className="learn__card-title">📚 Guides & Infographics</div>
            <div className="learn__card-sub">Easy to read, easy to follow.</div>
            {['5–7 Day Hospital Recovery Guide', 'Wound Care at Home', 'Nutrition After Surgery', 'Red Flags: When to Call Your Doctor', 'Activity Do\'s & Don\'ts'].map(g => (
              <button key={g} className="learn__guide-item">{g} →</button>
            ))}
          </div>

          <div className="card">
            <div className="learn__card-title">🎯 Check Your Knowledge</div>
            <div className="learn__card-sub">Short quizzes to reinforce learning.</div>
            {['Understanding Your Heart', 'Before Surgery', 'Recovery Basics', 'Medications & Safety'].map(q => (
              <button key={q} className="learn__quiz-item">
                <span>📝</span>
                <div style={{ flex: 1 }}>{q}<div style={{ fontSize: 10, color: 'var(--text-medium)' }}>5 questions</div></div>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 18l6-6-6-6" stroke="var(--text-light)" strokeWidth="2" strokeLinecap="round" /></svg>
              </button>
            ))}
            <button className="view-all" style={{ marginTop: 8 }}>View all quizzes →</button>
          </div>

          <div className="card">
            <div className="learn__card-title">📊 Your Learning Progress</div>
            <div className="learn__card-sub">Keep going! You're doing great.</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '12px 0' }}>
              <div style={{ position: 'relative', width: 64, height: 64 }}>
                <svg width="64" height="64" viewBox="0 0 64 64" style={{ transform: 'rotate(-90deg)' }}>
                  <circle cx="32" cy="32" r="26" fill="none" stroke="var(--border)" strokeWidth="6" />
                  <circle cx="32" cy="32" r="26" fill="none" stroke="var(--teal)" strokeWidth="6"
                    strokeDasharray={`${2 * Math.PI * 26}`}
                    strokeDashoffset={`${2 * Math.PI * 26 * 0.28}`}
                    strokeLinecap="round" />
                </svg>
                <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
                  <div style={{ fontSize: 14, fontWeight: 800, color: 'var(--text-dark)' }}>72%</div>
                  <div style={{ fontSize: 8, color: 'var(--text-medium)' }}>Completed</div>
                </div>
              </div>
              <div>
                {[['✅', 'Completed', 18, 'var(--success)'], ['🔄', 'In progress', 6, 'var(--warning)'], ['⭕', 'Not started', 4, 'var(--text-light)']].map(([icon, label, count, color]) => (
                  <div key={label} style={{ display: 'flex', gap: 6, alignItems: 'center', fontSize: 12, marginBottom: 4 }}>
                    <span>{icon}</span>
                    <span style={{ color: 'var(--text-medium)', flex: 1 }}>{label}</span>
                    <span style={{ fontWeight: 700, color }}>{count}</span>
                  </div>
                ))}
              </div>
            </div>
            <div className="learn__badges">
              {['📚', '❤️', '⭐', '🏆', '🛡️'].map((b, i) => (
                <div key={i} className={`learn__badge${i < 3 ? ' earned' : ''}`}>{b}</div>
              ))}
            </div>
            <button className="view-all" style={{ marginTop: 8 }}>View all badges →</button>
          </div>
        </div>

        {/* Education Journey */}
        <div className="card" style={{ marginTop: 12 }}>
          <div className="learn__card-title">Your Education Journey</div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0' }}>
            {educationTopics.map((topic, i) => (
              <div key={topic.id} style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                <div style={{ textAlign: 'center' }}>
                  <div style={{
                    width: 36, height: 36, borderRadius: '50%',
                    background: topic.completed ? 'var(--teal)' : topic.active ? 'var(--primary-light)' : 'var(--border)',
                    border: topic.active ? '2px solid var(--primary)' : 'none',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    margin: '0 auto 4px', fontSize: 16
                  }}>{topic.icon}</div>
                  <div style={{ fontSize: 9, color: topic.active ? 'var(--primary)' : 'var(--text-medium)', fontWeight: topic.active ? 700 : 400, whiteSpace: 'pre-line', lineHeight: 1.2, textAlign: 'center', maxWidth: 54 }}>
                    {topic.title.split(' ').slice(0, 2).join('\n')}
                  </div>
                  {topic.completed && <div style={{ fontSize: 9, color: 'var(--success)', fontWeight: 700 }}>Completed</div>}
                  {topic.active && <div style={{ fontSize: 9, color: 'var(--primary)', fontWeight: 700 }}>In progress</div>}
                  {!topic.completed && !topic.active && <div style={{ fontSize: 9, color: 'var(--text-light)' }}>Not started</div>}
                </div>
                {i < educationTopics.length - 1 && <div style={{ width: 12, height: 2, background: topic.completed ? 'var(--teal)' : 'var(--border)', flexShrink: 0, margin: '-12px 2px 0' }} />}
              </div>
            ))}
          </div>
        </div>

        {/* Ask question */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: 'var(--bg-teal-banner)', borderRadius: 'var(--radius-lg)', padding: 16, marginTop: 12, marginBottom: 16 }}>
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-dark)' }}>Have a question about something you learned?</div>
            <div style={{ fontSize: 11, color: 'var(--text-medium)', marginTop: 2 }}>Ask your care team or browse more resources.</div>
          </div>
          <button className="btn btn-teal" style={{ fontSize: 12, padding: '8px 14px', flexShrink: 0 }}>💬 Ask a Question</button>
        </div>
      </div>
    </div>
  )
}
