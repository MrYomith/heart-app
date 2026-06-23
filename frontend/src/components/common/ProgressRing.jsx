export default function ProgressRing({ value, max, size = 80, stroke = 7, color = 'var(--teal)', trackColor = '#E8E8E8', label, sublabel }) {
  const r = (size - stroke) / 2
  const circ = 2 * Math.PI * r
  const pct = Math.min(value / max, 1)
  const offset = circ * (1 - pct)

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={trackColor} strokeWidth={stroke} />
        <circle
          cx={size / 2} cy={size / 2} r={r} fill="none"
          stroke={color} strokeWidth={stroke}
          strokeDasharray={circ} strokeDashoffset={offset}
          strokeLinecap="round"
          style={{ transition: 'stroke-dashoffset 0.6s ease' }}
        />
      </svg>
      {label && (
        <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', textAlign: 'center' }}>
          <div style={{ fontSize: size > 70 ? 18 : 14, fontWeight: 800, color: 'var(--text-dark)', lineHeight: 1 }}>{label}</div>
          {sublabel && <div style={{ fontSize: 10, color: 'var(--text-medium)', marginTop: 2 }}>{sublabel}</div>}
        </div>
      )}
    </div>
  )
}
