import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/task.dart';
import '../utils/responsive.dart';
import '../widgets/mio_mascot.dart';
import '../widgets/progress_ring.dart';
import '../widgets/task_item.dart';

class TodayPlanScreen extends StatefulWidget {
  const TodayPlanScreen({super.key});

  @override
  State<TodayPlanScreen> createState() => _TodayPlanScreenState();
}

class _TodayPlanScreenState extends State<TodayPlanScreen> {
  List<Task> _tasks = todayTasks.toList();

  void _toggle(int id) {
    setState(() {
      _tasks = _tasks.map((t) => t.id == id ? t.copyWith(done: !t.done) : t).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final done = _tasks.where((t) => t.done).length;
    final total = _tasks.length;
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);
    final pad = Responsive.hp(context);
    final fs = Responsive.fontScale(context);
    final ringSize = Responsive.value<double>(context, phone: 70, tablet: 90);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Today's Plan", style: GoogleFonts.inter(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          Text('Thursday, 16 May 2024', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
        ]),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12), child: Icon(Icons.calendar_today_rounded, color: AppColors.textDark, size: 22)),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
          child: Column(
            children: [
              // Hero
              Container(
                color: AppColors.bgBanner,
                padding: EdgeInsets.symmetric(horizontal: pad, vertical: isWide ? 20 : 16),
                child: Row(children: [
                  MioMascot(variant: MioVariant.happy, size: isWide ? 88 : 72),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Hi $userName! 👋', style: GoogleFonts.inter(fontSize: (isWide ? 19 : 17) * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text('Here is your personalised plan for today.', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
                    const SizedBox(height: 6),
                    Text('Small steps today, stronger heart tomorrow. 🤍', style: GoogleFonts.inter(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ])),
                  const SizedBox(width: 10),
                  ProgressRing(value: done.toDouble(), max: total.toDouble(), size: ringSize, label: '$done/$total', sublabel: 'Tasks'),
                ]),
              ),

              // Section header
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 14, pad, 0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('✨', style: TextStyle(fontSize: 20 * fs)),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Today's most important steps", style: GoogleFonts.inter(fontSize: 16 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Text("Focus on these. You've got this!", style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
                  ])),
                  Text('Why these?', style: GoogleFonts.inter(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: AppColors.teal)),
                  const SizedBox(width: 4),
                  Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), shape: BoxShape.circle),
                    child: Center(child: Text('i', style: GoogleFonts.inter(fontSize: 10 * fs, color: AppColors.textMedium))),
                  ),
                ]),
              ),

              // Task list — 1 col phone, 2 col tablet
              Expanded(
                child: isWide
                    ? _buildWideList(context, pad, fs)
                    : _buildPhoneList(context, pad, fs),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneList(BuildContext context, double pad, double fs) {
    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 10, pad, 16),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          decoration: AppDecorations.card,
          child: Column(children: _tasks.map((t) => TaskItem(task: t, onToggle: () => _toggle(t.id))).toList()),
        ),
        const SizedBox(height: 16),
        _encouragementBanner(fs),
      ],
    );
  }

  Widget _buildWideList(BuildContext context, double pad, double fs) {
    final half = (_tasks.length / 2).ceil();
    final leftTasks = _tasks.sublist(0, half);
    final rightTasks = _tasks.sublist(half);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 10, pad, 16),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              decoration: AppDecorations.card,
              child: Column(children: leftTasks.map((t) => TaskItem(task: t, onToggle: () => _toggle(t.id))).toList()),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              decoration: AppDecorations.card,
              child: Column(children: rightTasks.map((t) => TaskItem(task: t, onToggle: () => _toggle(t.id))).toList()),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _encouragementBanner(fs),
      ]),
    );
  }

  Widget _encouragementBanner(double fs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Text('✅', style: TextStyle(fontSize: 26 * fs)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("You're doing great, $userName!", style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
          Text('Every step you take is building your recovery.', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.teal)),
        ])),
        const MioMascot(variant: MioVariant.celebrate, size: 50),
      ]),
    );
  }
}
