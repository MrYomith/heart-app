import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String _view = 'Month';

  final _events = [
    {'day': 16, 'title': 'Pre-op Assessment', 'color': 0xFFE8614D},
    {'day': 18, 'title': 'Blood Tests', 'color': 0xFF4A7C79},
    {'day': 22, 'title': 'Surgery Day', 'color': 0xFFE8614D},
    {'day': 30, 'title': 'Post-op Check', 'color': 0xFF4A7C79},
  ];

  final _upcoming = [
    {'icon': '🏥', 'title': 'Pre-op Assessment', 'date': 'Thu 16 May', 'time': '09:00', 'location': 'Cardiology Clinic, Floor 3'},
    {'icon': '🩸', 'title': 'Blood Tests', 'date': 'Sat 18 May', 'time': '08:00', 'location': 'Pathology Lab'},
    {'icon': '💉', 'title': 'Surgery Day', 'date': 'Wed 22 May', 'time': '07:00', 'location': 'OR Suite 4'},
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);
    final pad = Responsive.hp(context);
    final fs = Responsive.fontScale(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        automaticallyImplyLeading: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Calendar', style: GoogleFonts.inter(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          Text('May 2024', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
        ]),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12), child: Icon(Icons.add_rounded, color: AppColors.textDark, size: 24)),
        ],
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
        _CalendarGrid(events: _events, fs: fs),
        const SizedBox(height: 16),
        Text('Upcoming Appointments', style: GoogleFonts.inter(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        ..._upcoming.map((a) => _AppointmentCard(a: a, fs: fs)),
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
                _CalendarGrid(events: _events, fs: fs),
                const SizedBox(height: 16),
                _RecoveryPrediction(fs: fs),
              ]),
            ),
            const SizedBox(width: 20),
            // Right: appointments
            Expanded(
              flex: 4,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Upcoming Appointments', style: GoogleFonts.inter(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 10),
                ..._upcoming.map((a) => _AppointmentCard(a: a, fs: fs)),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _TimelineScroll extends StatelessWidget {
  final double fs;
  const _TimelineScroll({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Journey Timeline', style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        SizedBox(
          height: 62,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _TLItem('🔍', 'Diagnosis', 'Mar 2024', true, false),
              _TLItem('📋', 'Pre-op', 'May 2024', true, false),
              _TLItem('🏥', 'Surgery', 'May 22', false, true),
              _TLItem('🛏️', 'Inpatient', 'Jun 2024', false, false),
              _TLItem('🏠', 'Rehab', 'Jul 2024', false, false),
              _TLItem('🌟', 'Thriving', 'Ongoing', false, false),
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
        Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
        Text(date, style: GoogleFonts.inter(fontSize: 8, color: AppColors.textLight)),
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
          child: Text(v, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: view == v ? Colors.white : AppColors.textMedium), textAlign: TextAlign.center),
        ),
      ))).toList()),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final List events;
  final double fs;
  const _CalendarGrid({required this.events, required this.fs});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Icon(Icons.chevron_left, color: AppColors.textMedium),
          Text('May 2024', style: GoogleFonts.inter(fontSize: 15 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const Icon(Icons.chevron_right, color: AppColors.textMedium),
        ]),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
              .map((d) => SizedBox(width: 36, child: Text(d, style: GoogleFonts.inter(fontSize: 11 * fs, fontWeight: FontWeight.w700, color: AppColors.textMedium), textAlign: TextAlign.center)))
              .toList(),
        ),
        const SizedBox(height: 4),
        ...List.generate(5, (row) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (col) {
            final day = row * 7 + col - 1;
            if (day < 1 || day > 31) return const SizedBox(width: 36, height: 36);
            final event = events.where((e) => e['day'] == day).firstOrNull;
            final isToday = day == 16;
            return Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary : event != null ? Color(event['color'] as int).withValues(alpha: 0.15) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$day', style: GoogleFonts.inter(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: isToday ? Colors.white : AppColors.textDark)),
                if (event != null && !isToday) Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: Color(event['color'] as int))),
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
          Text(a['title']!, style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          Text('${a['date']} · ${a['time']}', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
          Text(a['location']!, style: GoogleFonts.inter(fontSize: 11 * fs, color: AppColors.textLight)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('Confirmed', style: GoogleFonts.inter(fontSize: 10 * fs, fontWeight: FontWeight.w700, color: AppColors.success)),
        ),
      ]),
    );
  }
}

class _RecoveryPrediction extends StatelessWidget {
  final double fs;
  const _RecoveryPrediction({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Recovery Prediction', style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text('Based on your progress and adherence', style: GoogleFonts.inter(fontSize: 11 * fs, color: AppColors.textMedium)),
        const SizedBox(height: 12),
        SizedBox(height: 80, child: CustomPaint(size: const Size(double.infinity, 80), painter: _LineChartPainter())),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4', 'Wk 6', 'Wk 8']
              .map((w) => Text(w, style: GoogleFonts.inter(fontSize: 9 * fs, color: AppColors.textLight)))
              .toList(),
        ),
      ]),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A7C79)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final points = [
      Offset(0, size.height * 0.9),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
    canvas.drawCircle(points[2], 4, Paint()..color = const Color(0xFFE8614D));
  }
  @override
  bool shouldRepaint(_) => false;
}
