import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_providers.dart';
import '../utils/responsive.dart';
import '../widgets/mio_mascot.dart';
import '../widgets/progress_ring.dart';
import '../widgets/task_item.dart';

class TodayPlanScreen extends ConsumerWidget {
  const TodayPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = Responsive.fontScale(context);
    final tasksAsync = ref.watch(todayTasksProvider);
    final name = ref.watch(authControllerProvider).user?.firstName ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Today's Plan", style: GoogleFonts.inter(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.teal)),
        error: (e, _) => _ErrorState(onRetry: () => ref.read(todayTasksProvider.notifier).load()),
        data: (tasks) => _content(context, ref, tasks, name, fs),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, List<Task> tasks, String name, double fs) {
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);
    final pad = Responsive.hp(context);
    final ringSize = Responsive.value<double>(context, phone: 70, tablet: 90);
    final done = tasks.where((t) => t.done).length;
    final total = tasks.length;
    void toggle(String id) => ref.read(todayTasksProvider.notifier).toggle(id);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
        child: Column(children: [
          // Hero
          Container(
            color: AppColors.bgBanner,
            padding: EdgeInsets.symmetric(horizontal: pad, vertical: isWide ? 20 : 16),
            child: Row(children: [
              MioMascot(variant: MioVariant.happy, size: isWide ? 88 : 72),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hi $name! 👋', style: GoogleFonts.inter(fontSize: (isWide ? 19 : 17) * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('Here is your personalised plan for today.', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
              ])),
              const SizedBox(width: 10),
              ProgressRing(value: done.toDouble(), max: total == 0 ? 1 : total.toDouble(), size: ringSize, label: '$done/$total', sublabel: 'Tasks'),
            ]),
          ),
          Expanded(
            child: total == 0
                ? _EmptyState(fs: fs)
                : (isWide ? _wideList(context, tasks, toggle, pad, fs) : _phoneList(context, tasks, toggle, pad, fs)),
          ),
        ]),
      ),
    );
  }

  Widget _phoneList(BuildContext context, List<Task> tasks, void Function(String) toggle, double pad, double fs) {
    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 16),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          decoration: AppDecorations.card,
          child: Column(children: tasks.map((t) => TaskItem(task: t, onToggle: () => toggle(t.id))).toList()),
        ),
        const SizedBox(height: 16),
        _banner(fs),
      ],
    );
  }

  Widget _wideList(BuildContext context, List<Task> tasks, void Function(String) toggle, double pad, double fs) {
    final half = (tasks.length / 2).ceil();
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 16),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container(padding: const EdgeInsets.fromLTRB(12, 4, 12, 0), decoration: AppDecorations.card, child: Column(children: tasks.sublist(0, half).map((t) => TaskItem(task: t, onToggle: () => toggle(t.id))).toList()))),
          const SizedBox(width: 14),
          Expanded(child: Container(padding: const EdgeInsets.fromLTRB(12, 4, 12, 0), decoration: AppDecorations.card, child: Column(children: tasks.sublist(half).map((t) => TaskItem(task: t, onToggle: () => toggle(t.id))).toList()))),
        ]),
        const SizedBox(height: 16),
        _banner(fs),
      ]),
    );
  }

  Widget _banner(double fs) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Text('✅', style: TextStyle(fontSize: 26 * fs)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("You're doing great!", style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
            Text('Every step you take is building your recovery.', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.teal)),
          ])),
          const MioMascot(variant: MioVariant.celebrate, size: 50),
        ]),
      );
}

class _EmptyState extends StatelessWidget {
  final double fs;
  const _EmptyState({required this.fs});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const MioMascot(variant: MioVariant.calm, size: 80),
            const SizedBox(height: 16),
            Text('No tasks for today yet', style: GoogleFonts.inter(fontSize: 16 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text('Your plan will appear here each morning.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13 * fs, color: AppColors.textMedium)),
          ]),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text("Couldn't load your plan", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ]),
      );
}
