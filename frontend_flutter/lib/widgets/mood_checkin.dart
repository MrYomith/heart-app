import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/patient_providers.dart';

/// Emoji mood picker that PERSISTS the selection as a `mood` vital (1–5) and
/// confirms with a snackbar. Replaces the old display-only pickers that did
/// nothing on tap.
class MoodCheckIn extends ConsumerStatefulWidget {
  const MoodCheckIn({super.key});

  @override
  ConsumerState<MoodCheckIn> createState() => _MoodCheckInState();
}

class _MoodCheckInState extends ConsumerState<MoodCheckIn> {
  static const _moods = ['😢', '😟', '😐', '🙂', '😊'];
  int? _selected;
  bool _busy = false;

  Future<void> _pick(int i) async {
    if (_busy) return;
    setState(() { _selected = i; _busy = true; });
    try {
      await ref.read(patientRepositoryProvider).logVital('mood', (i + 1).toDouble());
      ref.invalidate(latestVitalsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood saved — thank you for checking in 💚'), duration: Duration(seconds: 2)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _selected = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save right now — please try again")),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(_moods.length, (i) {
        final sel = _selected == i;
        return GestureDetector(
          onTap: () => _pick(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: sel ? AppColors.teal.withValues(alpha: 0.18) : AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: sel ? Border.all(color: AppColors.teal, width: 2) : null,
            ),
            child: Center(child: Text(_moods[i], style: const TextStyle(fontSize: 22))),
          ),
        );
      }),
    );
  }
}
