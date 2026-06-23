export const user = {
  id: 1,
  name: 'Ahmet',
  surgeryDate: '2024-05-28',
  currentPhase: 'inpatient',
  currentPhaseDay: 3,
  journeyProgress: 60,
}

export const journeyPhases = [
  { id: 'diagnosis', label: 'Diagnosis', emoji: '🫀', status: 'completed', date: null },
  { id: 'preop', label: 'Pre-op Preparation', emoji: '🛡️', status: 'completed', date: null },
  { id: 'surgery', label: 'Surgery Day', emoji: '🏥', status: 'completed', date: '28 May 2024' },
  { id: 'inpatient', label: 'Inpatient Recovery', emoji: '🩹', status: 'active', date: 'Days 1–7', subtitle: 'In progress' },
  { id: 'rehab', label: 'Post-Discharge Rehab', emoji: '🚶', status: 'upcoming', date: 'Week 2–8' },
  { id: 'thriving', label: 'Thriving', emoji: '⭐', status: 'upcoming', date: 'Week 9–12+' },
]

export const mioMessages = {
  diagnosis: "It's normal to feel uncertain. I'm here with you.",
  preop: "Every small step today prepares your heart for tomorrow.",
  surgery: "You are prepared. You are strong. I'll be here when you wake up.",
  inpatient: "Healing happens a little every day. Rest, breathe, and trust.",
  rehab: "Getting stronger step by step. Your heart is learning new strength.",
  thriving: "Look how far you've come! Your heart is strong and ready for life.",
}

export const todayTasks = [
  { id: 1, icon: '🫁', title: 'Breathing Exercise', subtitle: 'Incentive spirometry – 10 breaths', time: 'Morning', timeColor: 'teal', done: true, category: 'breathing' },
  { id: 2, icon: '🚶', title: 'Mobilisation', subtitle: 'Walk for 15–20 minutes', time: '10:00', timeColor: 'orange', done: false, category: 'activity' },
  { id: 3, icon: '🥗', title: 'Nutrition', subtitle: 'Eat a protein-rich meal & 2 fruits', time: 'Lunch', timeColor: 'teal', done: false, category: 'nutrition' },
  { id: 4, icon: '💧', title: 'Hydration', subtitle: 'Drink 6–8 glasses of water', time: 'Throughout day', timeColor: 'teal', done: true, category: 'hydration' },
  { id: 5, icon: '💊', title: 'Medications', subtitle: '2 scheduled medications', time: '14:00', timeColor: 'teal', done: true, category: 'medication' },
  { id: 6, icon: '🌙', title: 'Sleep Plan', subtitle: 'Aim for 7–8 hours of sleep', time: 'Tonight', timeColor: 'teal', done: false, category: 'sleep' },
  { id: 7, icon: '❤️', title: 'Emotional Check-in', subtitle: 'How are you feeling today?', time: 'Evening', timeColor: 'orange', done: false, category: 'emotional' },
  { id: 8, icon: '📖', title: 'Learn', subtitle: "Watch today's short video", time: 'Evening', timeColor: 'teal', done: false, category: 'education' },
  { id: 9, icon: '🩹', title: 'Wound Check Reminder', subtitle: 'Check dressing (do not open before Day 3)', time: '20:00', timeColor: 'teal', done: false, category: 'wound' },
  { id: 10, icon: '📅', title: 'Appointment', subtitle: 'Cardiology follow-up', time: 'Tomorrow 09:30', timeColor: 'orange', done: false, category: 'appointment' },
]

export const medications = [
  { id: 1, name: 'Aspirin', dose: '100 mg', schedule: '1 tablet every morning', times: ['08:00'], done: [true] },
  { id: 2, name: 'Metoprolol', dose: '25 mg', schedule: '1 tablet twice daily', times: ['08:00', '20:00'], done: [true, false] },
  { id: 3, name: 'Atorvastatin', dose: '40 mg', schedule: '1 tablet at bedtime', times: ['20:00'], done: [false] },
  { id: 4, name: 'Ramipril', dose: '5 mg', schedule: '1 tablet every morning', times: ['08:00'], done: [true] },
]

export const upcomingAppointments = [
  { id: 1, title: 'Follow-up with Surgeon', subtitle: 'Post-op Check', date: '07 Jun 2024', time: '10:30 AM', location: 'HerzZentrum Hamburg' },
  { id: 2, title: 'Follow-up with Cardiologist', subtitle: '', date: '14 Jun 2024', time: '11:00 AM', location: 'HerzZentrum Hamburg' },
  { id: 3, title: 'Wound Review & Progress Check', subtitle: '', date: '21 Jun 2024', time: '10:30 AM', location: 'HerzZentrum Hamburg' },
  { id: 4, title: 'Post-discharge Review', subtitle: '', date: '05 Jul 2024', time: '10:30 AM', location: 'HerzZentrum Hamburg' },
]

export const messages = [
  {
    id: 1,
    sender: 'Dr. Anna Müller',
    avatar: '👩‍⚕️',
    time: '10:30 AM',
    subject: 'Wound review reminder',
    preview: 'Hi Ahmet, this is a reminder for your wound...',
    unread: 1,
    full: `Hi Ahmet,\n\nThis is a reminder for your wound review appointment.\n\nFriday, 31 May 2024 – 10:30 AM\nHerzZentrum Hamburg\nMartinistraße 52, 20246 Hamburg\n\nPlease bring your medication list and report any new symptoms.\n\nWe look forward to seeing you.\n\n– Your Care Team`,
    date: '31 May 2024',
    location: 'HerzZentrum Hamburg',
  },
  {
    id: 2,
    sender: 'Physiotherapist Team',
    avatar: '🏃',
    time: 'Yesterday',
    subject: 'Great progress this week!',
    preview: 'Your walking distance has improved...',
    unread: 1,
    full: '',
    date: '',
    location: '',
  },
  {
    id: 3,
    sender: 'Care Team',
    avatar: '🛡️',
    time: '2 days ago',
    subject: 'Medication update',
    preview: 'Please continue taking your medications...',
    unread: 0,
    full: '',
    date: '',
    location: '',
  },
  {
    id: 4,
    sender: 'MioHart Support',
    avatar: '❤️',
    time: '3 days ago',
    subject: "You're doing great!",
    preview: 'Small steps every day lead to big changes...',
    unread: 0,
    full: '',
    date: '',
    location: '',
  },
]

export const educationTopics = [
  { id: 1, icon: '🫀', title: 'Understanding Your Heart', subtitle: 'Know your heart condition and treatment.', completed: true },
  { id: 2, icon: '📋', title: 'Before Surgery', subtitle: 'How to prepare your body and mind.', completed: true },
  { id: 3, icon: '🏥', title: 'Surgery & Hospital Stay', subtitle: 'What happens before, during and after surgery.', completed: false, active: true },
  { id: 4, icon: '🚶', title: 'Recovery & Rehabilitation', subtitle: 'Steps to heal safely and regain strength.', completed: false },
  { id: 5, icon: '🌿', title: 'Living Well Long-term', subtitle: 'Healthy habits for a strong heart for life.', completed: false },
]

export const recommendedVideos = [
  { id: 1, title: 'How to do breathing exercises correctly', duration: '2:45', thumbnail: '🫁' },
  { id: 2, title: 'Walking after heart surgery: a step-by-step guide', duration: '3:18', thumbnail: '🚶' },
  { id: 3, title: 'Heart-healthy eating made simple', duration: '2:36', thumbnail: '🥗' },
  { id: 4, title: 'Sleep better, recover faster', duration: '2:10', thumbnail: '🌙' },
  { id: 5, title: 'Your medications: why and when', duration: '1:58', thumbnail: '💊' },
]

export const wearableData = {
  heartRate: 72,
  steps: 5240,
  stepsGoal: 7000,
  activity: 45,
  sleep: '7h 15m',
  spo2: 98,
  hrv: 62,
}
