import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/mio_app_bar.dart';
import '../providers/patient_providers.dart';
import '../utils/responsive.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  String _view = 'Month';

  // Real per-day markers for the current month, derived from the patient's
  // actual appointments (dates that parse and fall in this month).
  Set<int> _eventDays() {
    final now = DateTime.now();
    final appts = ref.watch(appointmentsProvider).valueOrNull ?? const [];
    final days = <int>{};
    for (final a in appts) {
      final d = DateTime.tryParse(a.date);
      if (d != null && d.year == now.year && d.month == now.month) days.add(d.day);
    }
    return days;
  }

  // Real upcoming appointments rendered from the backend.
  List<Widget> _appointmentCards(double fs) {
    return ref.watch(appointmentsProvider).when(
          loading: () => [const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator(color: AppColors.teal)))],
          error: (e, _) => [Padding(padding: const EdgeInsets.all(8), child: Text("Couldn't load appointments", style: GoogleFonts.poppins(color: AppColors.textMedium)))],
          data: (appts) => appts.isEmpty
              ? [Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('No upcoming appointments', style: GoogleFonts.poppins(fontSize: 13 * fs, color: AppColors.textLight)))]
              : appts
                  .map((a) => _AppointmentCard(a: {'icon': a.icon, 'title': a.title, 'date': a.date, 'time': a.time ?? '', 'location': a.location ?? a.subtitle ?? ''}, fs: fs))
                  .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);
    final pad = Responsive.hp(context);
    final fs = Responsive.fontScale(context);

    String monthLabel() {
      const names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      final now = DateTime.now();
      return '${names[now.month - 1]} ${now.year}';
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        automaticallyImplyLeading: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Calendar', style: GoogleFonts.poppins(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          Text(monthLabel(), style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textMedium)),
        ]),
        actions: mioActions(context),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
          child: isWide
              ? _buildWideLayout(context, pad, fs)
              : _buildPhoneLayout(context, pad, fs),
        ),
      ),
    );
  }

  // ── Phone layout (stacked) ────────────────────────────────
  Widget _buildPhoneLayout(BuildContext context, double pad, double fs) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _TimelineScroll(fs: fs),
        const SizedBox(height: 14),
        _ViewToggle(view: _view, onChanged: (v) => setState(() => _view = v)),
        const SizedBox(height: 14),
        _CalendarGrid(eventDays: _eventDays(), fs: fs),
        const SizedBox(height: 16),
        Text('Upcoming Appointments', style: GoogleFonts.poppins(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        ..._appointmentCards(fs),
        const SizedBox(height: 16),
        _RecoveryGuide(fs: fs),
        const SizedBox(height: 16),
        _PhysioPlan(fs: fs),
        const SizedBox(height: 16),
        _RecoveryPrediction(fs: fs),
        const SizedBox(height: 16),
      ]),
    );
  }

  // ── Tablet layout (side by side) ─────────────────────────
  Widget _buildWideLayout(BuildContext context, double pad, double fs) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _TimelineScroll(fs: fs),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: calendar
            Expanded(
              flex: 5,
              child: Column(children: [
                _ViewToggle(view: _view, onChanged: (v) => setState(() => _view = v)),
                const SizedBox(height: 14),
                _CalendarGrid(eventDays: _eventDays(), fs: fs),
                const SizedBox(height: 16),
                _RecoveryPrediction(fs: fs),
              ]),
            ),
            const SizedBox(width: 20),
            // Right: appointments
            Expanded(
              flex: 4,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Upcoming Appointments', style: GoogleFonts.poppins(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 10),
                ..._appointmentCards(fs),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _TimelineScroll extends ConsumerWidget {
  final double fs;
  const _TimelineScroll({required this.fs});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phases = ref.watch(journeyProvider).valueOrNull ?? const [];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Journey Timeline', style: GoogleFonts.poppins(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        if (phases.isEmpty)
          Text('Your journey timeline will appear here.', style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textLight))
        else
          SizedBox(
            height: 62,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in phases)
                  _TLItem(p.emoji, p.label, p.date ?? '', p.status == 'completed', p.status == 'active'),
              ],
            ),
          ),
      ]),
    );
  }
}

class _TLItem extends StatelessWidget {
  final String icon, label, date;
  final bool completed, active;
  const _TLItem(this.icon, this.label, this.date, this.completed, this.active);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.primary : completed ? AppColors.success : AppColors.border.withValues(alpha: 0.5)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 14))),
        ),
        Text(label, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
        Text(date, style: GoogleFonts.poppins(fontSize: 8, color: AppColors.textLight)),
      ]),
      Container(width: 20, height: 2, color: AppColors.border),
    ]);
  }
}

class _ViewToggle extends StatelessWidget {
  final String view;
  final ValueChanged<String> onChanged;
  const _ViewToggle({required this.view, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final views = ['Month', 'Week', 'List'];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Row(children: views.map((v) => Expanded(child: GestureDetector(
        onTap: () => onChanged(v),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(color: view == v ? AppColors.teal : Colors.transparent, borderRadius: BorderRadius.circular(8)),
          child: Text(v, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: view == v ? Colors.white : AppColors.textMedium), textAlign: TextAlign.center),
        ),
      ))).toList()),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final Set<int> eventDays;
  final double fs;
  const _CalendarGrid({required this.eventDays, required this.fs});

  static const _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    // Monday-first offset: DateTime.weekday is 1 (Mon) .. 7 (Sun).
    final firstWeekday = DateTime(now.year, now.month, 1).weekday; // 1..7
    final leading = firstWeekday - 1; // blank cells before day 1
    final totalCells = leading + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: Column(children: [
        Text('${_monthNames[now.month - 1]} ${now.year}', style: GoogleFonts.poppins(fontSize: 15 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
              .map((d) => SizedBox(width: 36, child: Text(d, style: GoogleFonts.poppins(fontSize: 11 * fs, fontWeight: FontWeight.w700, color: AppColors.textMedium), textAlign: TextAlign.center)))
              .toList(),
        ),
        const SizedBox(height: 4),
        ...List.generate(rows, (row) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (col) {
            final day = row * 7 + col - leading + 1;
            if (day < 1 || day > daysInMonth) return const SizedBox(width: 36, height: 36);
            final hasEvent = eventDays.contains(day);
            final isToday = day == today;
            return Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary : hasEvent ? AppColors.teal.withValues(alpha: 0.15) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$day', style: GoogleFonts.poppins(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: isToday ? Colors.white : AppColors.textDark)),
                if (hasEvent && !isToday) Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.teal)),
              ])),
            );
          }),
        )),
      ]),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map a;
  final double fs;
  const _AppointmentCard({required this.a, required this.fs});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: const BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
          child: Center(child: Text(a['icon']!, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a['title']!, style: GoogleFonts.poppins(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          Text('${a['date']} · ${a['time']}', style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textMedium)),
          Text(a['location']!, style: GoogleFonts.poppins(fontSize: 11 * fs, color: AppColors.textLight)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('Confirmed', style: GoogleFonts.poppins(fontSize: 10 * fs, fontWeight: FontWeight.w700, color: AppColors.success)),
        ),
      ]),
    );
  }
}

class _RecoveryPrediction extends ConsumerWidget {
  final double fs;
  const _RecoveryPrediction({required this.fs});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pred = ref.watch(recoveryPredictionProvider);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Recovery Prediction', style: GoogleFonts.poppins(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text('Based on your progress and adherence', style: GoogleFonts.poppins(fontSize: 11 * fs, color: AppColors.textMedium)),
        const SizedBox(height: 12),
        pred.when(
          loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (e, _) => Text('Could not load prediction.', style: GoogleFonts.poppins(fontSize: 11 * fs, color: AppColors.textMedium)),
          data: (p) {
            final onTrack = ((p['on_track_pct'] as num?) ?? 0).toDouble();
            final status = (p['status'] as String?) ?? 'on_track';
            final color = status == 'behind' ? AppColors.primary : AppColors.teal;
            final label = {'ahead': 'Ahead of schedule 🎉', 'on_track': 'On track ✅', 'behind': 'A little behind — keep going 💪'}[status] ?? status;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${onTrack.round()}%', style: GoogleFonts.poppins(fontSize: 30 * fs, fontWeight: FontWeight.w800, color: color)),
                const SizedBox(width: 6),
                Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('on track', style: GoogleFonts.poppins(fontSize: 11 * fs, color: AppColors.textMedium))),
              ]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: (onTrack / 100).clamp(0, 1), minHeight: 8, backgroundColor: AppColors.bg, color: color)),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.poppins(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: color)),
            ]);
          },
        ),
      ]),
    );
  }
}

// ─── Post-op Recovery Guide (Day 1–7) — FR-162 ────────────────────────────────
class _RecoveryGuide extends ConsumerWidget {
  final double fs;
  const _RecoveryGuide({required this.fs});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(recoveryGuideProvider).when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (guide) => Container(
            padding: const EdgeInsets.all(14),
            decoration: AppDecorations.card,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Post-op Recovery Guide', style: GoogleFonts.poppins(fontSize: 15 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              Text('Typically 5–7 days in hospital', style: GoogleFonts.poppins(fontSize: 11 * fs, color: AppColors.textMedium)),
              const SizedBox(height: 10),
              for (final g in guide)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 54, padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(6)),
                      child: Text(g['day'] as String? ?? '', textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 10 * fs, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(g['title'] as String? ?? '', style: GoogleFonts.poppins(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      Text(g['detail'] as String? ?? '', style: GoogleFonts.poppins(fontSize: 10.5 * fs, color: AppColors.textMedium)),
                    ])),
                  ]),
                ),
            ]),
          ),
        );
  }
}

// ─── Physiotherapy 7-session plan — FR-163 ────────────────────────────────────
class _PhysioPlan extends ConsumerWidget {
  final double fs;
  const _PhysioPlan({required this.fs});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(physioPlanProvider).when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (plan) => Container(
            padding: const EdgeInsets.all(14),
            decoration: AppDecorations.card,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Physiotherapy Plan', style: GoogleFonts.poppins(fontSize: 15 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              Text('7-session progressive programme', style: GoogleFonts.poppins(fontSize: 11 * fs, color: AppColors.textMedium)),
              const SizedBox(height: 10),
              for (final s in plan)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Icon(
                      (s['status'] == 'completed') ? Icons.check_circle_rounded : Icons.directions_run_rounded,
                      size: 18, color: (s['status'] == 'completed') ? AppColors.success : AppColors.teal,
                    ),
                    const SizedBox(width: 10),
                    SizedBox(width: 48, child: Text('Day ${s['session']}', style: GoogleFonts.poppins(fontSize: 11 * fs, fontWeight: FontWeight.w700, color: AppColors.textMedium))),
                    Expanded(child: Text(s['focus'] as String? ?? '', style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textDark))),
                    Text((s['date'] as String? ?? '').replaceFirst(RegExp(r'^\d{4}-'), ''),
                        style: GoogleFonts.poppins(fontSize: 10 * fs, color: AppColors.textLight)),
                  ]),
                ),
            ]),
          ),
        );
  }
}
