// MioHeart clinician dashboard — API client (same FastAPI backend as the patient app).
// In production (Netlify) VITE_API_BASE is '' so calls go same-origin and the
// netlify.toml proxy forwards /auth & /api to the EC2 backend (avoids HTTPS→HTTP
// mixed-content blocking). Locally it defaults to the dev backend.
const BASE = (import.meta.env.VITE_API_BASE ?? 'http://localhost:8000') as string;
const TOKEN_KEY = 'mioheart_clinician_token';

const ROLE_KEY = 'mioheart_clinician_role';
export const token = {
  get: () => localStorage.getItem(TOKEN_KEY),
  set: (t: string) => localStorage.setItem(TOKEN_KEY, t),
  clear: () => { localStorage.removeItem(TOKEN_KEY); localStorage.removeItem(ROLE_KEY); },
};
export const role = {
  get: () => localStorage.getItem(ROLE_KEY) || 'clinician',
  set: (r: string) => localStorage.setItem(ROLE_KEY, r),
};

async function req(path: string, opts: RequestInit = {}) {
  const res = await fetch(BASE + path, {
    ...opts,
    headers: {
      'Content-Type': 'application/json',
      ...(token.get() ? { Authorization: `Bearer ${token.get()}` } : {}),
      ...(opts.headers || {}),
    },
  });
  if (res.status === 401) {
    token.clear();
    throw new Error('Session expired. Please log in again.');
  }
  const data = await res.json().catch(() => null);
  if (!res.ok) throw new Error((data && data.detail) || 'Something went wrong.');
  return data;
}

export interface Patient {
  id: string; name: string; surgery_type: string | null;
  current_phase: string; journey_progress: number;
  alert_level: 'red' | 'amber' | 'green'; open_alerts: number;
}
export interface AlertItem {
  id: string; patient_id: string; patient_name: string;
  type: string; severity: string; triggered_at: string | null; acknowledged: boolean;
}
export interface PatientDetail {
  id: string; name: string; email: string; surgery_type: string | null;
  surgery_date: string | null; nyha_class: string | null;
  current_phase: string; journey_progress: number;
  open_alerts: AlertItem[];
  recent_pain: { type: string; value: number; recorded_at: string | null }[];
  recent_mood: { type: string; value: number; recorded_at: string | null }[];
  clinical_scores: { score_type: string; score: number; severity: string | null; administered_at: string | null }[];
  wound_photos: { id: string; day_post_op: number | null; uploaded_at: string | null; reviewed: boolean }[];
  medications: { name: string; dose: string; schedule: string; is_anticoagulant: boolean }[];
}

export interface PendingEnrollment {
  enrollment_id: string; patient_name: string | null; patient_email: string | null;
  hospital_id: string | null; status: string;
}

export const PHASES = ['diagnosis', 'preop', 'surgery', 'inpatient', 'rehab', 'thriving'];
export const phaseLabel = (k: string) =>
  (({ diagnosis: 'Diagnosis', preop: 'Pre-op', surgery: 'Surgery', inpatient: 'Inpatient', rehab: 'Rehab', thriving: 'Thriving' }) as Record<string, string>)[k] || k;

export const api = {
  login: (email: string, password: string) =>
    req('/auth/login', { method: 'POST', body: JSON.stringify({ email, password }) }),
  patients: (): Promise<Patient[]> => req('/api/clinician/patients'),
  alerts: (): Promise<AlertItem[]> => req('/api/clinician/alerts'),
  ackAlert: (id: string): Promise<AlertItem> => req(`/api/clinician/alerts/${id}/ack`, { method: 'PATCH' }),
  patientDetail: (id: string): Promise<PatientDetail> => req(`/api/clinician/patients/${id}`),
  // FR-035 stage control
  controlStage: (patientId: string, action: 'set' | 'pause' | 'resume', to_phase?: string, reason?: string) =>
    req(`/api/clinician/patients/${patientId}/stage`, { method: 'PATCH', body: JSON.stringify({ action, to_phase, reason }) }),
  // Coordinator enrollment approval
  pendingEnrollments: (): Promise<PendingEnrollment[]> => req('/api/enrollment/pending'),
  approveEnrollment: (id: string) => req(`/api/enrollment/${id}/approve`, { method: 'POST' }),
  rejectEnrollment: (id: string) => req(`/api/enrollment/${id}/reject`, { method: 'POST' }),
  // Step 3 — edit patient data & plans
  updateProfile: (pid: string, body: Record<string, unknown>) =>
    req(`/api/clinician/patients/${pid}/profile`, { method: 'PATCH', body: JSON.stringify(body) }),
  listMeds: (pid: string): Promise<Med[]> => req(`/api/clinician/patients/${pid}/medications`),
  addMed: (pid: string, body: Med) => req(`/api/clinician/patients/${pid}/medications`, { method: 'POST', body: JSON.stringify(body) }),
  editMed: (pid: string, mid: string, body: Med) => req(`/api/clinician/patients/${pid}/medications/${mid}`, { method: 'PATCH', body: JSON.stringify(body) }),
  stopMed: (pid: string, mid: string) => req(`/api/clinician/patients/${pid}/medications/${mid}`, { method: 'DELETE' }),
  listAppts: (pid: string): Promise<Appt[]> => req(`/api/clinician/patients/${pid}/appointments`),
  addAppt: (pid: string, body: Appt) => req(`/api/clinician/patients/${pid}/appointments`, { method: 'POST', body: JSON.stringify(body) }),
  editAppt: (pid: string, aid: string, body: Appt) => req(`/api/clinician/patients/${pid}/appointments/${aid}`, { method: 'PATCH', body: JSON.stringify(body) }),
  cancelAppt: (pid: string, aid: string) => req(`/api/clinician/patients/${pid}/appointments/${aid}`, { method: 'DELETE' }),
  recordReading: (pid: string, type: string, value: number) =>
    req(`/api/clinician/patients/${pid}/readings`, { method: 'POST', body: JSON.stringify({ type, value }) }),
};

export const READING_TYPES = ['bp_systolic', 'bp_diastolic', 'ldl', 'hba1c', 'bmi', 'weight', 'heart_rate'];

export interface Med {
  id?: string; name: string; dose?: string | null; schedule?: string | null;
  times?: string | null; is_anticoagulant: boolean; purpose_de?: string | null; is_active?: boolean;
}
export interface Appt {
  id?: string; title: string; subtitle?: string | null; date: string;
  time?: string | null; location?: string | null; appointment_type?: string;
}
export const SURGERY_TYPES = ['cabg', 'valve', 'tavi', 'aortic', 'combined'];
export const NYHA_CLASSES = ['I', 'II', 'III', 'IV'];
export const SPECIALTIES = ['surgeon', 'nurse', 'physio', 'psychokardiologist', 'admin'];

async function upload(path: string, file: File) {
  const fd = new FormData();
  fd.append('file', file);
  const res = await fetch(BASE + path, {
    method: 'POST',
    headers: { ...(token.get() ? { Authorization: `Bearer ${token.get()}` } : {}) },
    body: fd,
  });
  const data = await res.json().catch(() => null);
  if (!res.ok) throw new Error((data && data.detail) || 'Upload failed.');
  return data;
}

export const CONTENT_TYPES = ['video', 'audio', 'guide', 'infographic'];
export const CONTENT_TOPICS = ['understanding_heart', 'before_surgery', 'surgery_stay', 'recovery', 'living_well'];

export const adminApi = {
  stats: () => req('/api/admin/stats'),
  content: () => req('/api/admin/content'),
  addContent: (b: Record<string, unknown>) => req('/api/admin/content', { method: 'POST', body: JSON.stringify(b) }),
  updateContent: (id: string, b: Record<string, unknown>) => req(`/api/admin/content/${id}`, { method: 'PATCH', body: JSON.stringify(b) }),
  deleteContent: (id: string) => req(`/api/admin/content/${id}`, { method: 'DELETE' }),
  uploadContentMedia: (id: string, file: File) => upload(`/api/admin/content/${id}/upload`, file),
  hospitals: () => req('/api/admin/hospitals'),
  addHospital: (b: Record<string, unknown>) => req('/api/admin/hospitals', { method: 'POST', body: JSON.stringify(b) }),
  codes: () => req('/api/admin/codes'),
  addCode: (b: Record<string, unknown>) => req('/api/admin/codes', { method: 'POST', body: JSON.stringify(b) }),
  toggleCode: (id: string) => req(`/api/admin/codes/${id}/toggle`, { method: 'PATCH' }),
  clinicians: () => req('/api/admin/clinicians'),
  addClinician: (b: Record<string, unknown>) => req('/api/admin/clinicians', { method: 'POST', body: JSON.stringify(b) }),
  templates: () => req('/api/admin/templates'),
  addTemplate: (b: Record<string, unknown>) => req('/api/admin/templates', { method: 'POST', body: JSON.stringify(b) }),
  deleteTemplate: (id: string) => req(`/api/admin/templates/${id}`, { method: 'DELETE' }),
  // App content catalogs (symptoms, phase resources, emergency contacts, etc.)
  appContent: (category?: string) => req(`/api/admin/app-content${category ? `?category=${category}` : ''}`),
  addAppContent: (b: Record<string, unknown>) => req('/api/admin/app-content', { method: 'POST', body: JSON.stringify(b) }),
  updateAppContent: (id: string, b: Record<string, unknown>) => req(`/api/admin/app-content/${id}`, { method: 'PATCH', body: JSON.stringify(b) }),
  deleteAppContent: (id: string) => req(`/api/admin/app-content/${id}`, { method: 'DELETE' }),
};

export const CONTENT_CATEGORIES = ['symptom', 'phase_resource', 'emergency_contact', 'fasting_step', 'surgery_reminder', 'support_resource'];
export const CONTENT_STAGES = ['diagnosis', 'preop', 'surgery', 'inpatient', 'rehab', 'thriving'];
