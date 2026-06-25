import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// Wearables (FR-240–243) — connect a provider, view the latest synced metrics,
/// and enter readings manually (the manual-entry fallback, FR-243). Native
/// HealthKit / Health Connect sync posts to the same /api/wearables/readings.
class WearablesScreen extends ConsumerWidget {
  const WearablesScreen({super.key});

  static const _providers = [
    ('apple_health', '', 'Apple Health'),
    ('google_health', '🤖', 'Health Connect'),
    ('fitbit', '⌚', 'Fitbit'),
    ('garmin', '🏃', 'Garmin'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(wearableConnectionsProvider);
    final summary = ref.watch(wearableSummaryProvider);
    final repo = ref.read(patientRepositoryProvider);

    Future<void> connect(String provider) async {
      await repo.connectWearable(provider);
      ref.invalidate(wearableConnectionsProvider);
    }

    Future<void> addReading() async {
      final result = await showModalBottomSheet<({String metric, double value})>(
        context: context, backgroundColor: AppColors.bgCard, isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => const _ManualEntrySheet(),
      );
      if (result != null) {
        await repo.ingestReadings('manual', [{'metric': result.metric, 'value': result.value}]);
        ref.invalidate(wearableSummaryProvider);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reading saved.')));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        title: Text('Wearables & Vitals', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addReading, backgroundColor: AppColors.teal,
        icon: const Icon(Icons.add), label: const Text('Add reading'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Latest readings', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 10),
          summary.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            error: (e, _) => Text('Could not load readings.', style: GoogleFonts.inter(color: AppColors.textMedium)),
            data: (s) => s.isEmpty
                ? _empty('No readings yet — connect a device or add one manually.')
                : GridView.count(
                    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                    children: [
                      for (final e in s.entries) _metricCard(e.key, (e.value as Map?)?['value'], (e.value as Map?)?['unit']),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          Text('Connect a device', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 10),
          connections.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (conns) {
              final connected = {for (final c in conns) c['provider'] as String: c['status'] as String};
              return Column(children: [
                for (final p in _providers)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: AppDecorations.card,
                    child: ListTile(
                      leading: Text(p.$2.isEmpty ? '🍎' : p.$2, style: const TextStyle(fontSize: 22)),
                      title: Text(p.$3, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      trailing: connected[p.$1] == 'connected'
                          ? Text('Connected', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal))
                          : OutlinedButton(onPressed: () => connect(p.$1), child: const Text('Connect')),
                    ),
                  ),
              ]);
            },
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String metric, dynamic value, dynamic unit) {
    final label = {
      'heart_rate': '❤️ Heart rate', 'steps': '🦶 Steps', 'spo2': '🫁 SpO₂',
      'sleep': '😴 Sleep', 'hrv': '📈 HRV', 'active_energy': '🔥 Energy',
    }[metric] ?? metric;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
        const SizedBox(height: 4),
        Text('${(value as num).toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} ${unit ?? ''}',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ]),
    );
  }

  Widget _empty(String msg) => Container(
        padding: const EdgeInsets.all(20), decoration: AppDecorations.card,
        child: Text(msg, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
      );
}

class _ManualEntrySheet extends StatefulWidget {
  const _ManualEntrySheet();
  @override
  State<_ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<_ManualEntrySheet> {
  String _metric = 'heart_rate';
  final _value = TextEditingController();
  static const _metrics = [
    ('heart_rate', 'Heart rate (bpm)'), ('steps', 'Steps'), ('spo2', 'SpO₂ (%)'),
    ('sleep', 'Sleep (hours)'), ('active_energy', 'Active energy (kcal)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Add a reading', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _metric,
          items: [for (final m in _metrics) DropdownMenuItem(value: m.$1, child: Text(m.$2))],
          onChanged: (v) => setState(() => _metric = v!),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(controller: _value, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final v = double.tryParse(_value.text);
            if (v != null) Navigator.pop(context, (metric: _metric, value: v));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(46)),
          child: const Text('Save'),
        ),
      ]),
    );
  }
}
