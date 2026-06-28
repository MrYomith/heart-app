import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/mio_mascot.dart';

// ════════════════════════════════════════════════════════════════════════
// Notifications settings (FR-304)
// ════════════════════════════════════════════════════════════════════════
class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});
  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends ConsumerState<NotificationsSettingsScreen> {
  // (key, label, description) — categories the patient can mute.
  static const _categories = [
    ('reminder', 'Reminders', 'Tasks, medications & appointments'),
    ('education', 'Education', 'New learning content for your stage'),
    ('motivation', 'Motivation', 'Encouragement from Mio'),
    ('social', 'Community', 'Heart Buddy & peer support'),
  ];

  final Set<String> _muted = {};
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ref.read(patientRepositoryProvider).notificationPrefs();
      setState(() {
        _muted
          ..clear()
          ..addAll(((p['muted_categories'] as List?) ?? []).map((e) => e.toString()));
        _quietStart = _parse(p['quiet_hours_start'] as String?) ?? _quietStart;
        _quietEnd = _parse(p['quiet_hours_end'] as String?) ?? _quietEnd;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  TimeOfDay? _parse(String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) return null;
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 22, minute: int.tryParse(parts[1]) ?? 0);
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(patientRepositoryProvider).updateNotificationPrefs(
            mutedCategories: _muted.toList(),
            quietStart: _fmt(_quietStart),
            quietEnd: _fmt(_quietEnd),
          );
      ref.invalidate(notificationPrefsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings saved.')));
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't save. Please try again.")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _bar(context, 'Notifications'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionLabel('What you hear about'),
                Container(
                  decoration: AppDecorations.card,
                  child: Column(
                    children: _categories.map((c) {
                      return SwitchListTile(
                        activeThumbColor: AppColors.teal,
                        title: Text(c.$2, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        subtitle: Text(c.$3, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
                        value: !_muted.contains(c.$1),
                        onChanged: (on) => setState(() => on ? _muted.remove(c.$1) : _muted.add(c.$1)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(children: [
                    const Icon(Icons.shield_outlined, size: 15, color: AppColors.teal),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Safety-critical alerts are always delivered and cannot be muted.',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMedium))),
                  ]),
                ),
                const SizedBox(height: 18),
                const _SectionLabel('Quiet hours'),
                Container(
                  decoration: AppDecorations.card,
                  child: Column(children: [
                    _timeRow('Start', _quietStart, (t) => setState(() => _quietStart = t)),
                    const Divider(height: 1, color: AppColors.border),
                    _timeRow('End', _quietEnd, (t) => setState(() => _quietEnd = t)),
                  ]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: _saving
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Save changes', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _timeRow(String label, TimeOfDay value, ValueChanged<TimeOfDay> onPick) {
    return ListTile(
      title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
        child: Text(_fmt(value), style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.tealDark)),
      ),
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: value);
        if (picked != null) onPick(picked);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Language (FR-300)
// ════════════════════════════════════════════════════════════════════════
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});
  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  late String _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(authControllerProvider).user?.locale ?? 'de';
  }

  Future<void> _pick(String locale) async {
    if (locale == _selected || _saving) return;
    setState(() {
      _selected = locale;
      _saving = true;
    });
    try {
      await ref.read(patientRepositoryProvider).setLocale(locale);
      await ref.read(authControllerProvider.notifier).refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(locale == 'de' ? 'Sprache auf Deutsch eingestellt.' : 'Language set to English.')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't update language.")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _bar(context, 'Language'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: Column(children: [
            const MioMascot(variant: MioVariant.waving, size: 80),
            const SizedBox(height: 8),
            Text('Choose your language', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ])),
          const SizedBox(height: 16),
          Container(
            decoration: AppDecorations.card,
            child: Column(children: [
              _option('de', 'Deutsch', '🇩🇪'),
              const Divider(height: 1, color: AppColors.border),
              _option('en', 'English', '🇬🇧'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _option(String locale, String label, String flag) {
    final selected = _selected == locale;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.teal)
          : const Icon(Icons.radio_button_unchecked, color: AppColors.textLight),
      onTap: () => _pick(locale),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Privacy & Security — GDPR data rights (FR-305)
// ════════════════════════════════════════════════════════════════════════
class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});
  @override
  ConsumerState<PrivacySecurityScreen> createState() => _PrivacySecurityState();
}

class _PrivacySecurityState extends ConsumerState<PrivacySecurityScreen> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final data = await ref.read(patientRepositoryProvider).exportMyData();
      final pretty = const JsonEncoder.withIndent('  ').convert(data);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.bgCard,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.4, expand: false,
          builder: (ctx, scroll) => Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(child: Text('Your data export', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark))),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: pretty));
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Copied to clipboard.')));
                  },
                  icon: const Icon(Icons.copy, size: 16, color: AppColors.teal),
                  label: Text('Copy', style: GoogleFonts.poppins(color: AppColors.teal, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SelectableText(pretty, style: GoogleFonts.robotoMono(fontSize: 11, color: AppColors.textDark)),
              ),
            ),
          ]),
        ),
      );
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't generate export.")));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('Delete your account?', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: AppColors.textDark)),
        content: Text(
          'This permanently removes your profile and recovery data. Records we are legally required to keep (e.g. consent history) are retained in anonymised form. This cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textMedium))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(patientRepositoryProvider).deleteMyAccount();
      await ref.read(authControllerProvider.notifier).logout();
      // AuthGate routes back to login once unauthenticated.
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't delete account. Please contact support.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _bar(context, 'Privacy & Security'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionLabel('Your data, your rights'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.lock_outline, color: AppColors.tealDark),
              const SizedBox(width: 10),
              Expanded(child: Text('Your data is stored securely in the EU and is never sold. You can export or delete it at any time (GDPR).',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.tealDark, height: 1.4))),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: AppDecorations.card,
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.download_outlined, color: AppColors.teal),
                title: Text('Export my data', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                subtitle: Text('Download a copy of everything we hold', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
                trailing: _exporting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))
                    : const Icon(Icons.chevron_right, color: AppColors.textLight),
                onTap: _exporting ? null : _export,
              ),
            ]),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Danger zone'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.primary),
              title: Text('Delete my account', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
              subtitle: Text('Permanently remove your account & data', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
              onTap: _delete,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Help & FAQ
// ════════════════════════════════════════════════════════════════════════
class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  static const _faqs = [
    ('Is my health data private?', 'Yes. Your data is encrypted and stored securely in the EU. Only you and your assigned care team can see it. We never sell your data.'),
    ('How is my daily plan created?', "Mio builds your plan from your surgery type, recovery stage and how you're tracking. Tap “Why these?” on Today's Plan to see the reasoning for each task."),
    ('When can I photograph my wound?', 'Keep your dressing on until Day 3. After that you can photograph and log your wound daily so your nurse can review healing.'),
    ('Can my family follow my progress?', 'Yes — you can invite a carer and choose exactly what they can see (stage, appointments, scores and more) in your carer settings.'),
    ('What do I do in an emergency?', "This app is not for emergencies. If you have chest pain, severe breathlessness or other urgent symptoms, call your local emergency number immediately."),
    ('How do I contact my care team?', 'Use Contact Care Team (secure messaging) from the More menu or Home. For urgent clinical concerns use the Symptoms tracker red-flag report.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _bar(context, 'Help & FAQ'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: Column(children: [
            const MioMascot(variant: MioVariant.happy, size: 80),
            const SizedBox(height: 8),
            Text('How can we help?', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ])),
          const SizedBox(height: 16),
          Container(
            decoration: AppDecorations.card,
            child: Column(
              children: _faqs.map((f) => Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: AppColors.teal,
                      collapsedIconColor: AppColors.textLight,
                      title: Text(f.$1, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(f.$2, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium, height: 1.5)),
                        ),
                      ],
                    ),
                  )).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Text('🚨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(child: Text(
                'In an emergency, call your local emergency number. This app is not monitored for urgent medical issues.',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark, height: 1.4),
              )),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── shared bits ──────────────────────────────────────────────────────────
PreferredSizeWidget _bar(BuildContext context, String title) => AppBar(
      backgroundColor: AppColors.bgCard,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
    );

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMedium)),
      );
}
