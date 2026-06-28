import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// FR-104 · Wound photo log with the Day-3 dressing lock.
class WoundScreen extends ConsumerStatefulWidget {
  const WoundScreen({super.key});
  @override
  ConsumerState<WoundScreen> createState() => _WoundScreenState();
}

class _WoundScreenState extends ConsumerState<WoundScreen> {
  bool _loading = true, _uploading = false, _locked = false;
  int? _day;
  String _message = '';
  List<Map<String, dynamic>> _photos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(patientRepositoryProvider);
      final s = await repo.woundStatus();
      final p = await repo.woundPhotos();
      if (mounted) setState(() { _day = s.dayPostOp; _locked = s.locked; _message = s.message; _photos = p; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final bytes = await picked.readAsBytes();
      await ref.read(patientRepositoryProvider).uploadWoundPhoto(bytes, picked.name);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo added — your nurse can review it 🤍'), behavior: SnackBarBehavior.floating));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed. Try again.'), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _pickSource() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.camera_alt_rounded, color: AppColors.teal), title: Text('Take a photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), onTap: () { Navigator.pop(context); _add(ImageSource.camera); }),
          ListTile(leading: const Icon(Icons.photo_library_rounded, color: AppColors.teal), title: Text('Choose from gallery', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), onTap: () { Navigator.pop(context); _add(ImageSource.gallery); }),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Wound Log', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : ListView(padding: const EdgeInsets.all(20), children: [
              // Day-3 dressing lock / guidance banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: _locked ? AppColors.warningBg : AppColors.bgTeal, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Icon(_locked ? Icons.lock_clock_rounded : Icons.healing_rounded, color: _locked ? AppColors.warning : AppColors.teal, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_day != null ? 'Day $_day after surgery' : 'Wound care', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(_message, style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textMedium, height: 1.4)),
                  ])),
                ]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _uploading ? null : _pickSource,
                  icon: _uploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white)) : const Icon(Icons.add_a_photo_rounded),
                  label: Text(_uploading ? 'Uploading…' : 'Add wound photo', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(height: 20),
              Text('Your photos', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 10),
              if (_photos.isEmpty)
                Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text('No photos yet. Add one above.', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)))
              else
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.82,
                  children: _photos.map(_photoCard).toList(),
                ),
            ]),
    );
  }

  Widget _photoCard(Map<String, dynamic> p) {
    final b64 = p['image_base64'] as String?;
    final reviewed = p['reviewed'] == true;
    final day = p['day_post_op'];
    return Container(
      decoration: AppDecorations.card,
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: b64 != null
              ? Image.memory(base64Decode(b64), fit: BoxFit.cover)
              : Container(color: AppColors.border, child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textLight)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(child: Text(day != null ? 'Day $day' : 'Logged', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark))),
            Icon(reviewed ? Icons.verified_rounded : Icons.schedule_rounded, size: 14, color: reviewed ? AppColors.success : AppColors.textLight),
            const SizedBox(width: 3),
            Text(reviewed ? 'Reviewed' : 'Pending', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMedium)),
          ]),
        ),
      ]),
    );
  }
}
