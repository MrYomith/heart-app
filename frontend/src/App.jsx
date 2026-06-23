import { Routes, Route } from 'react-router-dom'
import BottomNav from './components/layout/BottomNav'
import Home from './pages/Home'
import TodayPlan from './pages/TodayPlan'
import Journey from './pages/Journey'
import Learn from './pages/Learn'
import Messages from './pages/Messages'
import Calendar from './pages/Calendar'
import More from './pages/More'
import DiagnosisPhase from './pages/phases/DiagnosisPhase'
import PreopPhase from './pages/phases/PreopPhase'
import SurgeryDay from './pages/phases/SurgeryDay'
import InpatientRecovery from './pages/phases/InpatientRecovery'
import PostDischargeRehab from './pages/phases/PostDischargeRehab'
import Thriving from './pages/phases/Thriving'
import './App.css'

export default function App() {
  return (
    <div className="app-shell">
      <div className="page-scroll">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/today" element={<TodayPlan />} />
          <Route path="/journey" element={<Journey />} />
          <Route path="/journey/diagnosis" element={<DiagnosisPhase />} />
          <Route path="/journey/preop" element={<PreopPhase />} />
          <Route path="/journey/surgery" element={<SurgeryDay />} />
          <Route path="/journey/inpatient" element={<InpatientRecovery />} />
          <Route path="/journey/rehab" element={<PostDischargeRehab />} />
          <Route path="/journey/thriving" element={<Thriving />} />
          <Route path="/learn" element={<Learn />} />
          <Route path="/messages" element={<Messages />} />
          <Route path="/calendar" element={<Calendar />} />
          <Route path="/more" element={<More />} />
        </Routes>
      </div>
      <BottomNav />
    </div>
  )
}
