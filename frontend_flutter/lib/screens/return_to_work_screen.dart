import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// Return-to-work planner (FR-123).
class ReturnToWorkScreen extends ConsumerStatefulWidget {
  const ReturnToWorkScreen({super.key});
  @override
  ConsumerState<ReturnToWorkScreen> createState() => _ReturnToWorkScreenState();
}

const _jobs = [
  ('desk', '💻', 'Desk / office work'),
  ('light_physical', '🧰', 'Light physical work'),
  ('heavy_physical', '🏗️', 'Heavy physical work'),
];

class _ReturnToWorkScreenState extends ConsumerState<ReturnToWorkScreen> {
  Map<String, dynamic>? _plan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ref.read(patientRepositoryProvider).returnToWork();
      if (mounted) setState(() { _plan = p['plan'] != null ? p : null; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _set(String jobType) async {
    setState(() => _loading = true);
    final p = await ref.read(patientRepositoryProvider).setReturnToWork(jobType);
    if (mounted) setState(() { _plan = p; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.bgCard, title: Text('Return to Work', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              Text('What kind of work do you do?', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 10),
              for (final j in _jobs)
                Container(
                  margin: const EdgeInsets.only(bottom: 8), decoration: AppDecorations.card,
                  child: ListTile(
                    leading: Text(j.$2, style: const TextStyle(fontSize: 24)),
                    title: Text(j.$3, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMedium),
                    onTap: () => _set(j.$1),
                  ),
                ),
              if (_plan?['plan'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16), decoration: AppDecorations.card,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Your plan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.teal)),
                    const SizedBox(height: 6),
                    Text((_plan!['plan']['guidance'] as String?) ?? '', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark, height: 1.4)),
                    if ((_plan!['target_date']) != null) ...[
                      const SizedBox(height: 8),
                      Text('Target return date: ${_plan!['target_date']}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMedium)),
                    ],
                    const Divider(height: 22),
                    for (final m in (((_plan!['plan'] as Map?)?['milestones'] as List?) ?? []))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(8)),
                            child: Text('Wk ${m['week']}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(m['note'] as String? ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark))),
                        ]),
                      ),
                  ]),
                ),
              ],
            ]),
    );
  }
}
