import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// Readable, admin-managed educational resources for a stage (the
/// `phase_resource` catalog from /api/content). Each card opens a bottom sheet
/// with the full text so patients can actually read and understand — no media
/// required. Content is editable in the clinician/admin dashboard.
class StageGuides extends ConsumerWidget {
  final String stage;
  const StageGuides({super.key, required this.stage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(contentProvider((category: 'phase_resource', stage: stage)));
    return async.maybeWhen(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            for (final g in items)
              InkWell(
                onTap: () => _open(context, g),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(children: [
                    Text((g['emoji'] as String?) ?? '📖', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(g['title'] as String? ?? '',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark))),
                    const Icon(Icons.chevron_right, size: 16, color: AppColors.textLight),
                  ]),
                ),
              ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  void _open(BuildContext context, Map<String, dynamic> g) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text((g['emoji'] as String?) ?? '📖', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Text(g['title'] as String? ?? '',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark))),
          ]),
          const SizedBox(height: 14),
          Text((g['body'] as String?) ?? 'More information is coming soon.',
              style: GoogleFonts.poppins(fontSize: 14, height: 1.6, color: AppColors.textMedium)),
        ]),
      ),
    );
  }
}
