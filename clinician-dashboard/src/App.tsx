import { useEffect, useState } from 'react';
import { api, adminApi, token, role, PHASES, phaseLabel, SURGERY_TYPES, NYHA_CLASSES, SPECIALTIES, CONTENT_TYPES, CONTENT_TOPICS, CONTENT_CATEGORIES, CONTENT_STAGES, READING_TYPES, type Patient, type AlertItem, type PatientDetail, type PendingEnrollment, type Med, type Appt } from './api';

export default function App() {
  const [authed, setAuthed] = useState(!!token.get());
  if (!authed) return <Login onLogin={() => setAuthed(true)} />;
  return <Dashboard onLogout={() => { token.clear(); setAuthed(false); }} />;
}

/* ─────────── Login ─────────── */
function Login({ onLogin }: { onLogin: () => void }) {
  const [email, setEmail] = useState('nurse@herzzentrum.de');
  const [password, setPassword] = useState('');
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setErr(null); setBusy(true);
    try {
      const res = await api.login(email.trim(), password);
      token.set(res.access_token);
      if (res.user?.role) role.set(res.user.role);
      onLogin();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="login-wrap">
      <form className="login-card" onSubmit={submit}>
        <div className="login-logo"><div className="heart">🫀</div><h1>MioHeart</h1></div>
        <p className="login-sub">Clinician Dashboard · secure sign in</p>
        {err && <div className="err">{err}</div>}
        <div className="field"><label>Email</label><input type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="you@hospital.de" /></div>
        <div className="field"><label>Password</label><input type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="Your password" /></div>
        <button className="btn-primary" disabled={busy}>{busy ? 'Signing in…' : 'Sign in'}</button>
      </form>
    </div>
  );
}

/* ─────────── Dashboard shell ─────────── */
function Dashboard({ onLogout }: { onLogout: () => void }) {
  const isAdmin = role.get() === 'admin';
  const [view, setView] = useState<'patients' | 'alerts' | 'pending' | 'admin'>('patients');
  const [selected, setSelected] = useState<string | null>(null);
  const [patients, setPatients] = useState<Patient[]>([]);
  const [alerts, setAlerts] = useState<AlertItem[]>([]);
  const [pending, setPending] = useState<PendingEnrollment[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    setLoading(true);
    try {
      const [p, a, pe] = await Promise.all([api.patients(), api.alerts(), api.pendingEnrollments().catch(() => [])]);
      setPatients(p); setAlerts(a); setPending(pe);
    } catch { /* token handler logs out */ }
    setLoading(false);
  }
  useEffect(() => { load(); }, []);

  const reds = patients.filter(p => p.alert_level === 'red').length;
  const ambers = patients.filter(p => p.alert_level === 'amber').length;

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand"><div className="heart">🫀</div><b>MioHeart</b></div>
        <button className={`nav-item ${view === 'patients' && !selected ? 'active' : ''}`} onClick={() => { setView('patients'); setSelected(null); }}>👥 Patients</button>
        <button className={`nav-item ${view === 'alerts' && !selected ? 'active' : ''}`} onClick={() => { setView('alerts'); setSelected(null); }}>
          🔔 Alerts {alerts.length > 0 && <span className="badge">{alerts.length}</span>}
        </button>
        <button className={`nav-item ${view === 'pending' && !selected ? 'active' : ''}`} onClick={() => { setView('pending'); setSelected(null); }}>
          ✅ Approvals {pending.length > 0 && <span className="badge">{pending.length}</span>}
        </button>
        {isAdmin && (
          <button className={`nav-item ${view === 'admin' && !selected ? 'active' : ''}`} onClick={() => { setView('admin'); setSelected(null); }}>
            ⚙️ Admin
          </button>
        )}
        <div className="who">{isAdmin ? 'Admin' : 'Nurse'} · HerzZentrum Hamburg<br /><button className="logout" onClick={onLogout}>Sign out</button></div>
      </aside>

      <main className="main">
        {selected ? (
          <PatientDetailView id={selected} onBack={() => setSelected(null)} onChanged={load} />
        ) : loading ? (
          <div className="spinner" />
        ) : view === 'patients' ? (
          <>
            <div className="topbar"><div><h2>Patients</h2><div className="sub">{patients.length} assigned · sorted by priority</div></div></div>
            <div className="stat-row">
              <div className="stat"><div className="n red">{reds}</div><div className="l">Critical</div></div>
              <div className="stat"><div className="n amber">{ambers}</div><div className="l">Warning</div></div>
              <div className="stat"><div className="n green">{patients.length - reds - ambers}</div><div className="l">Stable</div></div>
            </div>
            <div className="card">
              <table className="plist">
                <thead><tr><th></th><th>Patient</th><th>Surgery</th><th>Stage</th><th>Progress</th><th>Alerts</th></tr></thead>
                <tbody>
                  {patients.map(p => (
                    <tr key={p.id} className="clickable" onClick={() => setSelected(p.id)}>
                      <td><span className={`dot ${p.alert_level}`} /></td>
                      <td style={{ fontWeight: 700 }}>{p.name}</td>
                      <td>{(p.surgery_type || '—').toUpperCase()}</td>
                      <td><span className="pill teal">{p.current_phase}</span></td>
                      <td>{Math.round(p.journey_progress)}%</td>
                      <td>{p.open_alerts > 0 ? <span className={`pill ${p.alert_level}`}>{p.open_alerts} open</span> : '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {patients.length === 0 && <div className="empty">No patients assigned yet.</div>}
            </div>
          </>
        ) : view === 'alerts' ? (
          <AlertCentre alerts={alerts} onAck={async (id) => { await api.ackAlert(id); load(); }} />
        ) : view === 'pending' ? (
          <PendingView pending={pending} onAction={load} />
        ) : (
          <AdminBoard />
        )}
      </main>
    </div>
  );
}

/* ─────────── Alert centre ─────────── */
const ALERT_LABELS: Record<string, string> = {
  pain_high: 'High pain score (≥7)', mood_low_3day: 'Low mood — 3 days', fever: 'Fever ≥38°C',
  delirium: 'Possible delirium', missed_dressing: 'Missed Day-3 dressing', missed_meds: 'Missed medications',
  wound_concern: 'Wound concern', symptom_report: 'Symptom reported', abnormal_vital: 'Abnormal vital sign',
};
function AlertCentre({ alerts, onAck }: { alerts: AlertItem[]; onAck: (id: string) => void }) {
  return (
    <>
      <div className="topbar"><div><h2>Alert Centre</h2><div className="sub">{alerts.length} open · newest first</div></div></div>
      <div className="card">
        {alerts.length === 0 ? <div className="empty">🎉 No open alerts. All patients stable.</div> :
          alerts.map(a => (
            <div className="alert-row" key={a.id}>
              <div className={`alert-icon ${a.severity}`}>{a.severity === 'critical' ? '🔴' : a.severity === 'warning' ? '🟠' : '🔵'}</div>
              <div className="alert-meta">
                <div className="t">{a.patient_name} — {ALERT_LABELS[a.type] || a.type}</div>
                <div className="s">{a.triggered_at ? new Date(a.triggered_at).toLocaleString() : ''}</div>
              </div>
              <button className="btn-ack" onClick={() => onAck(a.id)}>Acknowledge</button>
            </div>
          ))}
      </div>
    </>
  );
}

/* ─────────── Patient detail ─────────── */
function PatientDetailView({ id, onBack, onChanged }: { id: string; onBack: () => void; onChanged: () => void }) {
  const [d, setD] = useState<PatientDetail | null>(null);
  const [tab, setTab] = useState<'overview' | 'manage'>('overview');
  const reload = () => api.patientDetail(id).then(setD).catch(() => {});
  useEffect(() => { reload(); }, [id]);
  if (!d) return <div className="spinner" />;

  const maxPain = 10;
  return (
    <>
      <button className="back" onClick={onBack}>← Back to patients</button>
      <div className="topbar">
        <div><h2>{d.name}</h2><div className="sub">{(d.surgery_type || '—').toUpperCase()} · {d.current_phase} · NYHA {d.nyha_class || '—'}</div></div>
        <div className="tabs">
          <button className={tab === 'overview' ? 'tab active' : 'tab'} onClick={() => setTab('overview')}>Overview</button>
          <button className={tab === 'manage' ? 'tab active' : 'tab'} onClick={() => setTab('manage')}>Manage plan</button>
        </div>
      </div>

      {tab === 'manage' ? (
        <ManagePanel d={d} onChanged={() => { reload(); onChanged(); }} />
      ) : (
      <>


      {d.open_alerts.length > 0 && (
        <div className="card" style={{ marginBottom: 16 }}>
          {d.open_alerts.map(a => (
            <div className="alert-row" key={a.id}>
              <div className={`alert-icon ${a.severity}`}>{a.severity === 'critical' ? '🔴' : '🟠'}</div>
              <div className="alert-meta"><div className="t">{ALERT_LABELS[a.type] || a.type}</div><div className="s">{a.triggered_at ? new Date(a.triggered_at).toLocaleString() : ''}</div></div>
              <button className="btn-ack" onClick={async () => { await api.ackAlert(a.id); onChanged(); api.patientDetail(id).then(setD); }}>Acknowledge</button>
            </div>
          ))}
        </div>
      )}

      <StageControl id={id} currentPhase={d.current_phase} onChanged={() => { onChanged(); api.patientDetail(id).then(setD); }} />

      <div className="detail-grid">
        <div className="panel">
          <h3>Pain (last readings)</h3>
          {d.recent_pain.length === 0 ? <div className="empty">No pain readings.</div> : (
            <div className="bars">
              {[...d.recent_pain].reverse().map((v, i) => (
                <div key={i} className={`bar ${v.value >= 7 ? 'high' : ''}`} style={{ height: `${(v.value / maxPain) * 100}%` }} title={`${v.type} ${v.value}`} />
              ))}
            </div>
          )}
        </div>
        <div className="panel">
          <h3>Mood (last 14)</h3>
          {d.recent_mood.length === 0 ? <div className="empty">No mood readings.</div> : (
            <div className="bars">
              {[...d.recent_mood].reverse().map((v, i) => (
                <div key={i} className="bar" style={{ height: `${(v.value / 5) * 100}%`, background: v.value <= 2 ? 'var(--red)' : 'var(--teal)' }} title={`mood ${v.value}/5`} />
              ))}
            </div>
          )}
        </div>
        <div className="panel">
          <h3>Medications</h3>
          {d.medications.length === 0 ? <div className="empty">None.</div> : d.medications.map((m, i) => (
            <div className="kv" key={i}><span className="k">{m.name} {m.dose}{m.is_anticoagulant ? ' ⚠️' : ''}</span><span className="v">{m.schedule}</span></div>
          ))}
        </div>
        <div className="panel">
          <h3>Clinical scores</h3>
          {d.clinical_scores.length === 0 ? <div className="empty">None recorded.</div> : d.clinical_scores.map((s, i) => (
            <div className="kv" key={i}><span className="k">{s.score_type.toUpperCase()}</span><span className="v">{s.score} {s.severity ? `· ${s.severity}` : ''}</span></div>
          ))}
        </div>
        <div className="panel" style={{ gridColumn: '1 / -1' }}>
          <h3>Wound photos ({d.wound_photos.length})</h3>
          {d.wound_photos.length === 0 ? <div className="empty">No wound photos uploaded.</div> : d.wound_photos.map(w => (
            <div className="kv" key={w.id}><span className="k">Day {w.day_post_op ?? '—'} · {w.uploaded_at ? new Date(w.uploaded_at).toLocaleDateString() : ''}</span><span className="v">{w.reviewed ? '✓ reviewed' : 'pending review'}</span></div>
          ))}
        </div>
      </div>
      </>
      )}
    </>
  );
}

/* ─────────── Manage plan (Step 3 — edit patient data) ─────────── */
function ManagePanel({ d, onChanged }: { d: PatientDetail; onChanged: () => void }) {
  return (
    <>
      <ProfileEditor d={d} onChanged={onChanged} />
      <ReadingsEditor pid={d.id} onChanged={onChanged} />
      <MedsEditor pid={d.id} onChanged={onChanged} />
      <ApptsEditor pid={d.id} onChanged={onChanged} />
    </>
  );
}

function ReadingsEditor({ pid, onChanged }: { pid: string; onChanged: () => void }) {
  const [type, setType] = useState('bp_systolic');
  const [value, setValue] = useState('');
  const [msg, setMsg] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  async function save() {
    const v = parseFloat(value);
    if (isNaN(v)) return;
    setBusy(true); setMsg(null);
    try { await api.recordReading(pid, type, v); setMsg(`Recorded ${type} = ${v}`); setValue(''); onChanged(); }
    catch (e: any) { setMsg(e.message); }
    finally { setBusy(false); }
  }
  return (
    <div className="card" style={{ marginBottom: 16 }}>
      <h3>Clinical readings <span className="sub">(BP, LDL, HbA1c, weight…)</span></h3>
      <div className="form-row">
        <select value={type} onChange={e => setType(e.target.value)}>
          {READING_TYPES.map(t => <option key={t} value={t}>{t.replace(/_/g, ' ')}</option>)}
        </select>
        <input placeholder="Value" value={value} onChange={e => setValue(e.target.value)} style={{ maxWidth: 120 }} />
        <button className="btn-primary sm" disabled={busy} onClick={save}>Record</button>
        {msg && <span className="sc-msg">{msg}</span>}
      </div>
    </div>
  );
}

function ProfileEditor({ d, onChanged }: { d: PatientDetail; onChanged: () => void }) {
  const [surgeryType, setSurgeryType] = useState(d.surgery_type || '');
  const [surgeryDate, setSurgeryDate] = useState(d.surgery_date || '');
  const [nyha, setNyha] = useState(d.nyha_class || '');
  const [msg, setMsg] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function save() {
    setBusy(true); setMsg(null);
    const body: Record<string, unknown> = {};
    if (surgeryType) body.surgery_type = surgeryType;
    if (surgeryDate) body.surgery_date = surgeryDate;
    if (nyha) body.nyha_class = nyha;
    try { await api.updateProfile(d.id, body); setMsg('Saved — journey will re-sync by date.'); onChanged(); }
    catch (e: any) { setMsg(e.message); }
    finally { setBusy(false); }
  }
  return (
    <div className="card" style={{ marginBottom: 16 }}>
      <h3>Clinical profile</h3>
      <div className="form-row">
        <label>Surgery type
          <select value={surgeryType} onChange={e => setSurgeryType(e.target.value)}>
            <option value="">—</option>{SURGERY_TYPES.map(s => <option key={s} value={s}>{s.toUpperCase()}</option>)}
          </select>
        </label>
        <label>Surgery date<input type="date" value={surgeryDate} onChange={e => setSurgeryDate(e.target.value)} /></label>
        <label>NYHA
          <select value={nyha} onChange={e => setNyha(e.target.value)}>
            <option value="">—</option>{NYHA_CLASSES.map(n => <option key={n} value={n}>{n}</option>)}
          </select>
        </label>
        <button className="btn-primary sm" disabled={busy} onClick={save}>Save</button>
      </div>
      {msg && <div className="sc-msg">{msg}</div>}
    </div>
  );
}

function MedsEditor({ pid, onChanged }: { pid: string; onChanged: () => void }) {
  const [meds, setMeds] = useState<Med[]>([]);
  const [name, setName] = useState(''); const [dose, setDose] = useState(''); const [sched, setSched] = useState('');
  const [anti, setAnti] = useState(false); const [busy, setBusy] = useState(false);
  const load = () => api.listMeds(pid).then(setMeds).catch(() => {});
  useEffect(() => { load(); }, [pid]);

  async function add() {
    if (!name.trim()) return;
    setBusy(true);
    try { await api.addMed(pid, { name, dose, schedule: sched, is_anticoagulant: anti }); setName(''); setDose(''); setSched(''); setAnti(false); load(); onChanged(); }
    finally { setBusy(false); }
  }
  async function stop(mid: string) { await api.stopMed(pid, mid); load(); onChanged(); }

  return (
    <div className="card" style={{ marginBottom: 16 }}>
      <h3>Medications</h3>
      {meds.filter(m => m.is_active).map(m => (
        <div className="kv" key={m.id}>
          <span className="k">{m.name} {m.dose}{m.is_anticoagulant ? ' ⚠️' : ''} <span className="sub">{m.schedule}</span></span>
          <button className="btn-ghost xs" onClick={() => stop(m.id!)}>Discontinue</button>
        </div>
      ))}
      {meds.filter(m => m.is_active).length === 0 && <div className="empty">No active medications.</div>}
      <div className="form-row" style={{ marginTop: 10 }}>
        <input placeholder="Name" value={name} onChange={e => setName(e.target.value)} />
        <input placeholder="Dose (e.g. 100 mg)" value={dose} onChange={e => setDose(e.target.value)} />
        <input placeholder="Schedule" value={sched} onChange={e => setSched(e.target.value)} />
        <label className="chk"><input type="checkbox" checked={anti} onChange={e => setAnti(e.target.checked)} /> Anticoagulant</label>
        <button className="btn-primary sm" disabled={busy} onClick={add}>Add</button>
      </div>
    </div>
  );
}

function ApptsEditor({ pid, onChanged }: { pid: string; onChanged: () => void }) {
  const [appts, setAppts] = useState<Appt[]>([]);
  const [title, setTitle] = useState(''); const [date, setDate] = useState(''); const [time, setTime] = useState('');
  const [busy, setBusy] = useState(false);
  const load = () => api.listAppts(pid).then(setAppts).catch(() => {});
  useEffect(() => { load(); }, [pid]);

  async function add() {
    if (!title.trim() || !date) return;
    setBusy(true);
    try { await api.addAppt(pid, { title, date, time }); setTitle(''); setDate(''); setTime(''); load(); onChanged(); }
    finally { setBusy(false); }
  }
  async function cancel(aid: string) { await api.cancelAppt(pid, aid); load(); onChanged(); }

  return (
    <div className="card" style={{ marginBottom: 16 }}>
      <h3>Appointments</h3>
      {appts.map(a => (
        <div className="kv" key={a.id}>
          <span className="k">{a.title} <span className="sub">{a.date}{a.time ? ` · ${a.time}` : ''}</span></span>
          <button className="btn-ghost xs" onClick={() => cancel(a.id!)}>Cancel</button>
        </div>
      ))}
      {appts.length === 0 && <div className="empty">No appointments.</div>}
      <div className="form-row" style={{ marginTop: 10 }}>
        <input placeholder="Title" value={title} onChange={e => setTitle(e.target.value)} />
        <input type="date" value={date} onChange={e => setDate(e.target.value)} />
        <input type="time" value={time} onChange={e => setTime(e.target.value)} />
        <button className="btn-primary sm" disabled={busy} onClick={add}>Add</button>
      </div>
    </div>
  );
}

/* ─────────── Stage control (FR-035 clinician override) ─────────── */
function StageControl({ id, currentPhase, onChanged }: { id: string; currentPhase: string; onChanged: () => void }) {
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  async function move(to: string) {
    if (to === currentPhase) return;
    const reason = window.prompt(`Move this patient to "${phaseLabel(to)}"? Add a reason (logged for audit):`, '');
    if (reason === null) return;
    setBusy(true); setMsg(null);
    try { await api.controlStage(id, 'set', to, reason || undefined); setMsg(`Moved to ${phaseLabel(to)}.`); onChanged(); }
    catch (e: any) { setMsg(e.message); }
    finally { setBusy(false); }
  }
  async function pauseResume(action: 'pause' | 'resume') {
    setBusy(true); setMsg(null);
    try { await api.controlStage(id, action); setMsg(action === 'pause' ? 'Auto-advance paused.' : 'Auto-advance resumed.'); onChanged(); }
    catch (e: any) { setMsg(e.message); }
    finally { setBusy(false); }
  }

  return (
    <div className="card" style={{ marginBottom: 16 }}>
      <div className="stage-control">
        <div className="sc-label">Journey stage <span className="sub">— override (auto-advances by date)</span></div>
        <div className="sc-track">
          {PHASES.map((p, i) => (
            <button key={p} disabled={busy} onClick={() => move(p)}
              className={`sc-step ${p === currentPhase ? 'current' : ''} ${PHASES.indexOf(currentPhase) > i ? 'done' : ''}`}>
              {phaseLabel(p)}
            </button>
          ))}
        </div>
        <div className="sc-actions">
          <button className="btn-ghost" disabled={busy} onClick={() => pauseResume('pause')}>⏸ Pause</button>
          <button className="btn-ghost" disabled={busy} onClick={() => pauseResume('resume')}>▶ Resume</button>
          {msg && <span className="sc-msg">{msg}</span>}
        </div>
      </div>
    </div>
  );
}

/* ─────────── Admin board (role=admin) ─────────── */
function AdminBoard() {
  const [tab, setTab] = useState<'hospitals' | 'codes' | 'team' | 'templates' | 'content' | 'catalog'>('hospitals');
  const [stats, setStats] = useState<any>(null);
  useEffect(() => { adminApi.stats().then(setStats).catch(() => {}); }, []);
  return (
    <>
      <div className="topbar"><div><h2>Admin</h2><div className="sub">Manage hospitals, codes, care team & templates</div></div></div>
      {stats && (
        <div className="stat-row">
          <div className="stat"><div className="n teal">{stats.patients}</div><div className="l">Patients</div></div>
          <div className="stat"><div className="n teal">{stats.clinicians}</div><div className="l">Clinicians</div></div>
          <div className="stat"><div className="n teal">{stats.hospitals}</div><div className="l">Hospitals</div></div>
          <div className="stat"><div className="n red">{stats.open_alerts}</div><div className="l">Open alerts</div></div>
        </div>
      )}
      <div className="tabs" style={{ margin: '12px 0' }}>
        {(['hospitals', 'codes', 'team', 'templates', 'content', 'catalog'] as const).map(t => (
          <button key={t} className={tab === t ? 'tab active' : 'tab'} onClick={() => setTab(t)}>
            {{ hospitals: 'Hospitals', codes: 'Enrollment codes', team: 'Care team', templates: 'Templates', content: 'Education content', catalog: 'App content' }[t]}
          </button>
        ))}
      </div>
      {tab === 'hospitals' && <AdminHospitals />}
      {tab === 'codes' && <AdminCodes />}
      {tab === 'team' && <AdminTeam />}
      {tab === 'templates' && <AdminTemplates />}
      {tab === 'content' && <AdminContent />}
      {tab === 'catalog' && <AdminAppContent />}
    </>
  );
}

function AdminHospitals() {
  const [rows, setRows] = useState<any[]>([]);
  const [name, setName] = useState(''); const [city, setCity] = useState(''); const [msg, setMsg] = useState('');
  const load = () => adminApi.hospitals().then(setRows).catch(() => {});
  useEffect(() => { load(); }, []);
  async function add() { if (!name.trim()) return; await adminApi.addHospital({ name, city, surgeon_message: msg }); setName(''); setCity(''); setMsg(''); load(); }
  return (
    <div className="card">
      {rows.map(h => <div className="kv" key={h.id}><span className="k">{h.name} <span className="sub">{h.city || ''}</span></span><span className="v">{h.type}</span></div>)}
      {rows.length === 0 && <div className="empty">No hospitals.</div>}
      <div className="form-row" style={{ marginTop: 10 }}>
        <input placeholder="Hospital name" value={name} onChange={e => setName(e.target.value)} />
        <input placeholder="City" value={city} onChange={e => setCity(e.target.value)} />
        <input placeholder="Surgeon welcome message" value={msg} onChange={e => setMsg(e.target.value)} />
        <button className="btn-primary sm" onClick={add}>Add hospital</button>
      </div>
    </div>
  );
}

function AdminCodes() {
  const [rows, setRows] = useState<any[]>([]); const [hospitals, setHospitals] = useState<any[]>([]);
  const [hid, setHid] = useState(''); const [label, setLabel] = useState('');
  const load = () => adminApi.codes().then(setRows).catch(() => {});
  useEffect(() => { load(); adminApi.hospitals().then((h: any[]) => { setHospitals(h); if (h[0]) setHid(h[0].id); }); }, []);
  async function gen() { if (!hid) return; await adminApi.addCode({ hospital_id: hid, label }); setLabel(''); load(); }
  return (
    <div className="card">
      {rows.map(c => (
        <div className="kv" key={c.id}>
          <span className="k">{c.code} <span className="sub">{c.label || ''} · used {c.used_count}{c.max_uses ? `/${c.max_uses}` : ''}</span></span>
          <button className="btn-ghost xs" onClick={async () => { await adminApi.toggleCode(c.id); load(); }}>{c.is_active ? 'Deactivate' : 'Activate'}</button>
        </div>
      ))}
      {rows.length === 0 && <div className="empty">No codes yet.</div>}
      <div className="form-row" style={{ marginTop: 10 }}>
        <select value={hid} onChange={e => setHid(e.target.value)}>{hospitals.map(h => <option key={h.id} value={h.id}>{h.name}</option>)}</select>
        <input placeholder="Label (e.g. Cardiac ward)" value={label} onChange={e => setLabel(e.target.value)} />
        <button className="btn-primary sm" onClick={gen}>Generate code</button>
      </div>
    </div>
  );
}

function AdminTeam() {
  const [rows, setRows] = useState<any[]>([]); const [hospitals, setHospitals] = useState<any[]>([]);
  const [name, setName] = useState(''); const [email, setEmail] = useState(''); const [pw, setPw] = useState('');
  const [spec, setSpec] = useState('nurse'); const [hid, setHid] = useState(''); const [err, setErr] = useState('');
  const load = () => adminApi.clinicians().then(setRows).catch(() => {});
  useEffect(() => { load(); adminApi.hospitals().then((h: any[]) => { setHospitals(h); if (h[0]) setHid(h[0].id); }); }, []);
  async function add() {
    setErr('');
    try { await adminApi.addClinician({ name, email, password: pw, specialty: spec, hospital_id: hid }); setName(''); setEmail(''); setPw(''); load(); }
    catch (e: any) { setErr(e.message); }
  }
  return (
    <div className="card">
      {rows.map(c => <div className="kv" key={c.id}><span className="k">{c.name} <span className="sub">{c.email}</span></span><span className="v">{c.specialty}</span></div>)}
      {err && <div className="err" style={{ marginTop: 8 }}>{err}</div>}
      <div className="form-row" style={{ marginTop: 10 }}>
        <input placeholder="Name" value={name} onChange={e => setName(e.target.value)} />
        <input placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} />
        <input placeholder="Temp password" value={pw} onChange={e => setPw(e.target.value)} />
        <select value={spec} onChange={e => setSpec(e.target.value)}>{SPECIALTIES.map(s => <option key={s} value={s}>{s}</option>)}</select>
        <select value={hid} onChange={e => setHid(e.target.value)}>{hospitals.map(h => <option key={h.id} value={h.id}>{h.name}</option>)}</select>
        <button className="btn-primary sm" onClick={add}>Add clinician</button>
      </div>
    </div>
  );
}

function AdminTemplates() {
  const [rows, setRows] = useState<any[]>([]);
  const [title, setTitle] = useState(''); const [body, setBody] = useState('');
  const load = () => adminApi.templates().then(setRows).catch(() => {});
  useEffect(() => { load(); }, []);
  async function add() { if (!title.trim() || !body.trim()) return; await adminApi.addTemplate({ title, body }); setTitle(''); setBody(''); load(); }
  return (
    <div className="card">
      {rows.map(t => (
        <div className="kv" key={t.id}>
          <span className="k">{t.title} <span className="sub">{t.body.slice(0, 40)}…</span></span>
          <button className="btn-ghost xs" onClick={async () => { await adminApi.deleteTemplate(t.id); load(); }}>Delete</button>
        </div>
      ))}
      {rows.length === 0 && <div className="empty">No templates.</div>}
      <div className="form-row" style={{ marginTop: 10 }}>
        <input placeholder="Title" value={title} onChange={e => setTitle(e.target.value)} />
        <input placeholder="Message body" value={body} onChange={e => setBody(e.target.value)} style={{ flex: 1 }} />
        <button className="btn-primary sm" onClick={add}>Add template</button>
      </div>
    </div>
  );
}

function AdminContent() {
  const [rows, setRows] = useState<any[]>([]);
  const [editId, setEditId] = useState<string | null>(null);
  const [title, setTitle] = useState(''); const [type, setType] = useState('video');
  const [topic, setTopic] = useState('understanding_heart');
  const [stage, setStage] = useState(''); const [mins, setMins] = useState('');
  const [busy, setBusy] = useState(false);
  const load = () => adminApi.content().then(setRows).catch(() => {});
  useEffect(() => { load(); }, []);

  function reset() { setEditId(null); setTitle(''); setType('video'); setTopic('understanding_heart'); setStage(''); setMins(''); }
  function startEdit(c: any) {
    setEditId(c.id); setTitle(c.title); setType(c.type || 'video'); setTopic(c.topic || 'understanding_heart');
    setStage(c.stage || ''); setMins(c.duration_sec ? String(Math.round(c.duration_sec / 60)) : '');
  }
  async function save() {
    if (!title.trim()) return;
    setBusy(true);
    const body: Record<string, unknown> = { title, type, topic, stage: stage || null, duration_sec: mins ? parseInt(mins) * 60 : null };
    try {
      if (editId) await adminApi.updateContent(editId, body);
      else await adminApi.addContent({ ...body, published: true });
      reset(); load();
    } finally { setBusy(false); }
  }
  async function togglePub(c: any) { await adminApi.updateContent(c.id, { published: !c.published }); load(); }
  async function onUpload(id: string, file: File | undefined) {
    if (!file) return;
    setBusy(true);
    try { await adminApi.uploadContentMedia(id, file); load(); }
    finally { setBusy(false); }
  }
  return (
    <div className="card">
      {rows.map(c => (
        <div className="kv" key={c.id}>
          <span className="k">{c.title} <span className="sub">{c.type} · {c.topic || '—'}{c.stage ? ` · ${c.stage}` : ''} {c.has_media ? '· 📎' : ''} {c.published ? '' : '· draft'}</span></span>
          <span style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
            <button className="btn-ghost xs" onClick={() => startEdit(c)}>Edit</button>
            <button className="btn-ghost xs" onClick={() => togglePub(c)}>{c.published ? 'Unpublish' : 'Publish'}</button>
            <label className="btn-ghost xs" style={{ cursor: 'pointer' }}>
              {c.has_media ? 'Replace' : 'Upload'}<input type="file" hidden onChange={e => onUpload(c.id, e.target.files?.[0])} />
            </label>
            <button className="btn-ghost xs" onClick={async () => { await adminApi.deleteContent(c.id); load(); }}>Delete</button>
          </span>
        </div>
      ))}
      {rows.length === 0 && <div className="empty">No education content yet.</div>}
      <div className="form-row" style={{ marginTop: 10 }}>
        <input placeholder="Title" value={title} onChange={e => setTitle(e.target.value)} style={{ flex: 1 }} />
        <select value={type} onChange={e => setType(e.target.value)}>{CONTENT_TYPES.map(t => <option key={t} value={t}>{t}</option>)}</select>
        <select value={topic} onChange={e => setTopic(e.target.value)}>{CONTENT_TOPICS.map(t => <option key={t} value={t}>{t.replace(/_/g, ' ')}</option>)}</select>
        <select value={stage} onChange={e => setStage(e.target.value)}>
          <option value="">(any stage)</option>{CONTENT_STAGES.map(s => <option key={s} value={s}>{s}</option>)}
        </select>
        <input placeholder="Min" value={mins} onChange={e => setMins(e.target.value.replace(/[^0-9]/g, ''))} style={{ maxWidth: 60 }} />
        <button className="btn-primary sm" disabled={busy} onClick={save}>{editId ? 'Save' : 'Add content'}</button>
        {editId && <button className="btn-ghost xs" onClick={reset}>Cancel</button>}
      </div>
    </div>
  );
}

function AdminAppContent() {
  const [category, setCategory] = useState('symptom');
  const [rows, setRows] = useState<any[]>([]);
  const [editId, setEditId] = useState<string | null>(null);
  const [title, setTitle] = useState(''); const [emoji, setEmoji] = useState('');
  const [body, setBody] = useState(''); const [severity, setSeverity] = useState('');
  const [stage, setStage] = useState(''); const [busy, setBusy] = useState(false);
  const load = () => adminApi.appContent(category).then(setRows).catch(() => {});
  useEffect(() => { load(); }, [category]);

  const showStage = category === 'phase_resource' || category === 'fasting_step' || category === 'surgery_reminder';
  const showSeverity = category === 'symptom';

  function reset() { setEditId(null); setTitle(''); setEmoji(''); setBody(''); setSeverity(''); setStage(''); }
  function startEdit(r: any) {
    setEditId(r.id); setTitle(r.title || ''); setEmoji(r.emoji || ''); setBody(r.body || '');
    setSeverity(r.severity || ''); setStage(r.stage || '');
  }
  async function save() {
    if (!title.trim()) return;
    setBusy(true);
    const payload: Record<string, unknown> = {
      title, emoji: emoji || null, body: body || null,
      severity: showSeverity ? (severity || 'warning') : null,
      stage: showStage ? (stage || null) : null,
    };
    try {
      if (editId) await adminApi.updateAppContent(editId, payload);
      else await adminApi.addAppContent({ ...payload, category, published: true });
      reset(); load();
    } finally { setBusy(false); }
  }
  async function togglePub(r: any) { await adminApi.updateAppContent(r.id, { published: !r.published }); load(); }

  return (
    <div className="card">
      <div className="form-row" style={{ marginBottom: 12 }}>
        <label>Category
          <select value={category} onChange={e => { reset(); setCategory(e.target.value); }}>
            {CONTENT_CATEGORIES.map(c => <option key={c} value={c}>{c.replace(/_/g, ' ')}</option>)}
          </select>
        </label>
      </div>
      {rows.map(r => (
        <div className="kv" key={r.id}>
          <span className="k">{r.emoji ?? ''} {r.title} <span className="sub">{[r.severity, r.stage, r.body].filter(Boolean).join(' · ').slice(0, 50)}{r.published ? '' : ' · draft'}</span></span>
          <span style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
            <button className="btn-ghost xs" onClick={() => startEdit(r)}>Edit</button>
            <button className="btn-ghost xs" onClick={() => togglePub(r)}>{r.published ? 'Unpublish' : 'Publish'}</button>
            <button className="btn-ghost xs" onClick={async () => { await adminApi.deleteAppContent(r.id); load(); }}>Delete</button>
          </span>
        </div>
      ))}
      {rows.length === 0 && <div className="empty">No items in this category yet.</div>}
      <div className="form-row" style={{ marginTop: 10 }}>
        <input placeholder="Emoji" value={emoji} onChange={e => setEmoji(e.target.value)} style={{ maxWidth: 70 }} />
        <input placeholder="Title" value={title} onChange={e => setTitle(e.target.value)} />
        {showSeverity && (
          <select value={severity} onChange={e => setSeverity(e.target.value)}>
            <option value="warning">warning</option><option value="critical">critical</option>
          </select>
        )}
        {showStage && (
          <select value={stage} onChange={e => setStage(e.target.value)}>
            <option value="">(any stage)</option>{CONTENT_STAGES.map(s => <option key={s} value={s}>{s}</option>)}
          </select>
        )}
        <input placeholder="Body / detail (optional)" value={body} onChange={e => setBody(e.target.value)} style={{ flex: 1 }} />
        <button className="btn-primary sm" disabled={busy} onClick={save}>{editId ? 'Save' : 'Add'}</button>
        {editId && <button className="btn-ghost xs" onClick={reset}>Cancel</button>}
      </div>
    </div>
  );
}

/* ─────────── Pending approvals (coordinator) ─────────── */
function PendingView({ pending, onAction }: { pending: PendingEnrollment[]; onAction: () => void }) {
  const [busy, setBusy] = useState<string | null>(null);
  async function act(id: string, approve: boolean) {
    setBusy(id);
    try { approve ? await api.approveEnrollment(id) : await api.rejectEnrollment(id); onAction(); }
    catch { /* ignore */ }
    finally { setBusy(null); }
  }
  return (
    <>
      <div className="topbar"><div><h2>Pending Approvals</h2><div className="sub">{pending.length} patient(s) requesting to join your hospital</div></div></div>
      <div className="card">
        {pending.length === 0 ? <div className="empty">No patients waiting for approval.</div> :
          pending.map(p => (
            <div className="alert-row" key={p.enrollment_id}>
              <div className="alert-icon">🧑</div>
              <div className="alert-meta"><div className="t">{p.patient_name || 'New patient'}</div><div className="s">{p.patient_email}</div></div>
              <button className="btn-ack" disabled={busy === p.enrollment_id} onClick={() => act(p.enrollment_id, true)}>Approve</button>
              <button className="btn-ghost" disabled={busy === p.enrollment_id} onClick={() => act(p.enrollment_id, false)}>Reject</button>
            </div>
          ))}
      </div>
    </>
  );
}
