const variants = {
  default: { bg: '#E8614D', emoji: '🫀', sparkle: false },
  happy: { bg: '#E8614D', emoji: '🫀', sparkle: true },
  calm: { bg: '#4A7C79', emoji: '🫀', sparkle: false },
  medical: { bg: '#5BA5A0', emoji: '🫀', sparkle: false },
  celebrate: { bg: '#E8614D', emoji: '🫀', sparkle: true },
  thriving: { bg: '#48BB78', emoji: '🫀', sparkle: true },
}

export default function MioMascot({ variant = 'default', size = 80, style = {} }) {
  const v = variants[variant] || variants.default
  return (
    <div style={{
      width: size,
      height: size,
      borderRadius: '50%',
      background: `radial-gradient(circle at 35% 35%, ${v.bg}dd, ${v.bg})`,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontSize: size * 0.5,
      boxShadow: `0 4px 16px ${v.bg}44`,
      flexShrink: 0,
      position: 'relative',
      ...style,
    }}>
      🫀
      {v.sparkle && (
        <span style={{ position: 'absolute', top: -4, right: -4, fontSize: 14 }}>✨</span>
      )}
    </div>
  )
}
