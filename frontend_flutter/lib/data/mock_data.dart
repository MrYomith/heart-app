import '../models/task.dart';
import '../models/journey_phase.dart';
import '../models/medication.dart';
import '../models/message.dart';

const String userName = 'Ahmet';
const String surgeryDate = '28 May 2024';
const String currentPhase = 'inpatient';
const int journeyProgress = 60;

const List<Task> todayTasks = [
  Task(id: 1, icon: '🫁', title: 'Breathing Exercise', subtitle: 'Incentive spirometry – 10 breaths', time: 'Morning', timeColor: 'teal', done: true, category: 'breathing'),
  Task(id: 2, icon: '🚶', title: 'Mobilisation', subtitle: 'Walk for 15–20 minutes', time: '10:00', timeColor: 'orange', done: false, category: 'activity'),
  Task(id: 3, icon: '🥗', title: 'Nutrition', subtitle: 'Eat a protein-rich meal & 2 fruits', time: 'Lunch', timeColor: 'teal', done: false, category: 'nutrition'),
  Task(id: 4, icon: '💧', title: 'Hydration', subtitle: 'Drink 6–8 glasses of water', time: 'Throughout day', timeColor: 'teal', done: true, category: 'hydration'),
  Task(id: 5, icon: '💊', title: 'Medications', subtitle: '2 scheduled medications', time: '14:00', timeColor: 'teal', done: true, category: 'medication'),
  Task(id: 6, icon: '🌙', title: 'Sleep Plan', subtitle: 'Aim for 7–8 hours of sleep', time: 'Tonight', timeColor: 'teal', done: false, category: 'sleep'),
  Task(id: 7, icon: '❤️', title: 'Emotional Check-in', subtitle: 'How are you feeling today?', time: 'Evening', timeColor: 'orange', done: false, category: 'emotional'),
  Task(id: 8, icon: '📖', title: 'Learn', subtitle: "Watch today's short video", time: 'Evening', timeColor: 'teal', done: false, category: 'education'),
  Task(id: 9, icon: '🩹', title: 'Wound Check Reminder', subtitle: 'Check dressing (do not open before Day 3)', time: '20:00', timeColor: 'teal', done: false, category: 'wound'),
  Task(id: 10, icon: '📅', title: 'Appointment', subtitle: 'Cardiology follow-up', time: 'Tomorrow 09:30', timeColor: 'orange', done: false, category: 'appointment'),
];

const List<JourneyPhase> journeyPhases = [
  JourneyPhase(id: 'diagnosis', label: 'Diagnosis', emoji: '🫀', status: 'completed', mioMessage: "It's normal to feel uncertain. I'm here with you."),
  JourneyPhase(id: 'preop', label: 'Pre-op Preparation', emoji: '🛡️', status: 'completed', mioMessage: 'Every small step today prepares your heart for tomorrow.'),
  JourneyPhase(id: 'surgery', label: 'Surgery Day', emoji: '🏥', status: 'completed', date: '28 May 2024', mioMessage: "You are prepared. You are strong. I'll be here when you wake up."),
  JourneyPhase(id: 'inpatient', label: 'Inpatient Recovery', emoji: '🩹', status: 'active', date: 'Days 1–7', subtitle: 'In progress', mioMessage: 'Healing happens a little every day. Rest, breathe, and trust.'),
  JourneyPhase(id: 'rehab', label: 'Post-Discharge Rehab', emoji: '🚶', status: 'upcoming', date: 'Week 2–8', mioMessage: 'Getting stronger step by step. Your heart is learning new strength.'),
  JourneyPhase(id: 'thriving', label: 'Thriving', emoji: '⭐', status: 'upcoming', date: 'Week 9–12+', mioMessage: "Look how far you've come! Your heart is strong and ready for life."),
];

const List<Medication> medications = [
  Medication(id: 1, name: 'Aspirin', dose: '100 mg', schedule: '1 tablet every morning', times: ['08:00']),
  Medication(id: 2, name: 'Metoprolol', dose: '25 mg', schedule: '1 tablet twice daily', times: ['08:00', '20:00']),
  Medication(id: 3, name: 'Atorvastatin', dose: '40 mg', schedule: '1 tablet at bedtime', times: ['20:00']),
  Medication(id: 4, name: 'Ramipril', dose: '5 mg', schedule: '1 tablet every morning', times: ['08:00']),
];

const List<ChatMessage> messages = [
  ChatMessage(id: 1, sender: 'Dr. Anna Müller', avatar: '👩‍⚕️', sentAt: '10:30 AM', subject: 'Wound review reminder', preview: 'Hi Ahmet, this is a reminder for your wound...', body: 'Hi Ahmet,\n\nThis is a reminder for your wound review appointment.\n\nFriday, 31 May 2024 – 10:30 AM\nHerzZentrum Hamburg\n\nPlease bring your medication list and report any new symptoms.\n\n– Your Care Team', isRead: false, category: 'Appointments'),
  ChatMessage(id: 2, sender: 'Physiotherapist Team', avatar: '🏃', sentAt: 'Yesterday', subject: 'Great progress this week!', preview: 'Your walking distance has improved greatly...', body: 'Your walking distance has improved greatly this week. Keep it up!', isRead: false, category: 'Education'),
  ChatMessage(id: 3, sender: 'Care Team', avatar: '🛡️', sentAt: '2 days ago', subject: 'Medication update', preview: 'Please continue taking your medications as prescribed.', body: 'Please continue taking your medications as prescribed. Do not stop without consulting your doctor.', isRead: true, category: 'Prescriptions'),
  ChatMessage(id: 4, sender: 'MioHart Support', avatar: '❤️', sentAt: '3 days ago', subject: "You're doing great!", preview: 'Small steps every day lead to big changes...', body: 'Small steps every day lead to big changes. You are an inspiration to everyone on our team!', isRead: true, category: 'Support'),
];

const Map<String, String> wearableData = {
  'heartRate': '72 bpm',
  'steps': '5,240',
  'stepsGoal': '7,000',
  'activity': '45 min',
  'sleep': '7h 15m',
  'spo2': '98%',
  'hrv': '62 ms',
};
