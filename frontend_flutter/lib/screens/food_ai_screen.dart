import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// AI food logging (FR-044 AI layer) — photograph or describe a meal; Claude
/// estimates the nutrition (needs ANTHROPIC_API_KEY set on the backend).
class FoodAiScreen extends ConsumerStatefulWidget {
  const FoodAiScreen({super.key});
  @override
  ConsumerState<FoodAiScreen> createState() => _FoodAiScreenState();
}

class _FoodAiScreenState extends ConsumerState<FoodAiScreen> {
  final _desc = TextEditingController();
  bool _busy = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    final x = await ImagePicker().pickImage(source: source, maxWidth: 1280, imageQuality: 85);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    await _analyze(imageBytes: bytes, filename: x.name);
  }

  Future<void> _analyze({List<int>? imageBytes, String? filename}) async {
    setState(() { _busy = true; _error = null; _result = null; });
    try {
      final r = await ref.read(patientRepositoryProvider).analyzeFood(
        description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        imageBytes: imageBytes, filename: filename,
      );
      setState(() => _result = r);
    } catch (e) {
      setState(() => _error = 'Could not analyse the meal. The AI service may not be configured yet.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        title: Text('Log a Meal', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(child: _btn(Icons.camera_alt_rounded, 'Photo', () => _pick(ImageSource.camera))),
            const SizedBox(width: 10),
            Expanded(child: _btn(Icons.photo_library_rounded, 'Gallery', () => _pick(ImageSource.gallery))),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: _desc,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Or describe your meal, e.g. "grilled salmon, brown rice, broccoli"',
              filled: true, fillColor: AppColors.bgCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _busy ? null : () => _analyze(),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(_busy ? 'Analysing…' : 'Analyse with AI'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
          ),
          const SizedBox(height: 18),
          if (_busy) const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
              child: Text(_error!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark)),
            ),
          if (_result != null) _ResultCard(result: _result!),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap) => ElevatedButton.icon(
        onPressed: _busy ? null : onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.bgCard, foregroundColor: AppColors.textDark, elevation: 0, minimumSize: const Size.fromHeight(48)),
      );
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ResultCard({required this.result});
  @override
  Widget build(BuildContext context) {
    final items = (result['items'] as List?)?.cast<String>() ?? [];
    final heartHealthy = (result['heart_healthy'] as bool?) ?? false;
    Widget stat(String label, String value) => Column(children: [
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.teal)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMedium)),
        ]);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(heartHealthy ? '💚' : '⚠️', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(heartHealthy ? 'Heart-healthy meal' : 'Eat in moderation',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ]),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(items.join(' · '), style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
        ],
        const Divider(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          stat('kcal', '${result['calories_kcal'] ?? 0}'),
          stat('protein', '${result['protein_g'] ?? 0}g'),
          stat('carbs', '${result['carbs_g'] ?? 0}g'),
          stat('fat', '${result['fat_g'] ?? 0}g'),
          stat('sodium', '${result['sodium_mg'] ?? 0}mg'),
        ]),
        if ((result['notes'] as String?)?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(10)),
            child: Text('💡 ${result['notes']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.tealDark)),
          ),
        ],
        const SizedBox(height: 10),
        Text('Logged to your nutrition tracker ✓', style: GoogleFonts.inter(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
