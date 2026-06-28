import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'mio_mascot.dart';

class FocusItem {
  final String icon;
  final String label;
  const FocusItem(this.icon, this.label);
}

class SideNavItem {
  final String icon;
  final String label;
  const SideNavItem(this.icon, this.label);
}

class PhaseLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconEmoji;
  final Color heroBg;
  final MioVariant mioVariant;
  final String heroMsg;
  final String? heroSub;
  final String? mottoMsg;
  final List<FocusItem>? focusItems;
  final List<SideNavItem> sideNav;
  final Widget sections;

  const PhaseLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.heroBg,
    this.mioVariant = MioVariant.happy,
    required this.heroMsg,
    this.heroSub,
    this.mottoMsg,
    this.focusItems,
    required this.sideNav,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final mioSize = Responsive.value<double>(context, phone: 60.0, fold: 72.0, tablet: 88.0);
    final heroFontSize = Responsive.value<double>(context, phone: 13.0, fold: 15.0, tablet: 17.0);
    final isLarge = Responsive.isTablet(context) || Responsive.isFoldable(context);
    // On wide screens the hero lays the focus card beside the mascot; on a
    // narrow phone it stacks below so nothing overflows.
    final focusBeside = isLarge;

    final focusCard = focusItems == null
        ? null
        : Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Today's Focus", style: GoogleFonts.poppins(fontSize: isLarge ? 12 : 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 5),
                ...focusItems!.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(children: [
                        Text(f.icon, style: TextStyle(fontSize: isLarge ? 14 : 13)),
                        const SizedBox(width: 6),
                        Flexible(child: Text(f.label, style: GoogleFonts.poppins(fontSize: isLarge ? 11 : 10, color: AppColors.textMedium))),
                      ]),
                    )),
                const SizedBox(height: 3),
                Text("You've got this!", style: GoogleFonts.poppins(fontSize: isLarge ? 11 : 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(iconEmoji, style: TextStyle(fontSize: isLarge ? 22 : 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: isLarge ? 18 : 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: isLarge ? 12 : 10, color: AppColors.textMedium)),
                ],
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      // Single centred column on every screen size — no side rail (it used to
      // mirror the section list and looked like everything was doubled).
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero
                Container(
                  color: heroBg,
                  width: double.infinity,
                  padding: EdgeInsets.all(isLarge ? 20 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(heroMsg, style: GoogleFonts.poppins(fontSize: heroFontSize, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.4)),
                                if (heroSub != null) ...[
                                  const SizedBox(height: 4),
                                  Text(heroSub!, style: GoogleFonts.poppins(fontSize: (heroFontSize - 2), color: AppColors.textMedium, height: 1.5)),
                                ],
                                if (mottoMsg != null) ...[
                                  const SizedBox(height: 8),
                                  Text(mottoMsg!, style: GoogleFonts.poppins(fontSize: (heroFontSize - 1), fontWeight: FontWeight.w600, color: AppColors.primary)),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          MioMascot(variant: mioVariant, size: mioSize),
                          if (focusCard != null && focusBeside) ...[
                            const SizedBox(width: 10),
                            SizedBox(width: 150, child: focusCard),
                          ],
                        ],
                      ),
                      // On phones the focus card stacks under the hero row.
                      if (focusCard != null && !focusBeside) ...[
                        const SizedBox(height: 12),
                        focusCard,
                      ],
                    ],
                  ),
                ),
                // Sections
                Padding(padding: EdgeInsets.all(isLarge ? 14 : 10), child: sections),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable phase widgets ───────────────────────────────────────────────────

class PhaseSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Color? background;

  const PhaseSection({super.key, required this.title, this.subtitle, required this.child, this.background});

  @override
  Widget build(BuildContext context) {
    final fs = Responsive.fontScale(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(Responsive.isTablet(context) ? 16 : 12),
      decoration: BoxDecoration(
        color: background ?? AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 13 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: GoogleFonts.poppins(fontSize: 10 * fs, color: AppColors.textMedium)),
          ],
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class PhaseActionRow extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const PhaseActionRow({super.key, required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final fs = Responsive.fontScale(context);
    // Rows without an explicit destination still acknowledge the tap so the
    // app never feels "dead" — these are info/resource items being rolled out.
    final effectiveOnTap = onTap ??
        () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label — coming soon'), duration: const Duration(seconds: 2)),
            );
    return InkWell(
      onTap: effectiveOnTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Text(icon, style: TextStyle(fontSize: 16 * fs)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textDark, fontWeight: FontWeight.w500))),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textLight),
        ]),
      ),
    );
  }
}

/// A tappable checklist row that toggles + persists. [initialDone] seeds the
/// state; [onChanged] is awaited when the user taps (e.g. to hit the backend).
class CheckRow extends StatefulWidget {
  final String label;
  final String? sublabel;
  final bool initialDone;
  final Future<void> Function(bool done)? onChanged;
  const CheckRow({super.key, required this.label, this.sublabel, this.initialDone = false, this.onChanged});

  @override
  State<CheckRow> createState() => _CheckRowState();
}

class _CheckRowState extends State<CheckRow> {
  late bool _done = widget.initialDone;
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    final next = !_done;
    setState(() { _done = next; _busy = true; });
    try {
      await widget.onChanged?.call(next);
    } catch (_) {
      if (mounted) setState(() => _done = !next); // revert on failure
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = Responsive.fontScale(context);
    return InkWell(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Icon(_done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 20, color: _done ? AppColors.success : AppColors.border),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.label, style: GoogleFonts.poppins(fontSize: 12.5 * fs, fontWeight: FontWeight.w500, color: AppColors.textDark, decoration: _done ? TextDecoration.lineThrough : null)),
              if (widget.sublabel != null) Text(widget.sublabel!, style: GoogleFonts.poppins(fontSize: 10 * fs, color: AppColors.textMedium)),
            ]),
          ),
          if (_busy) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal)),
        ]),
      ),
    );
  }
}

class PhaseViewLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const PhaseViewLink({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal)),
      ),
    );
  }
}

class PhaseIconBtn extends StatelessWidget {
  final String icon;
  final String label;
  final String? sublabel;
  final VoidCallback? onTap;

  const PhaseIconBtn({super.key, required this.icon, required this.label, this.sublabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMedium), textAlign: TextAlign.center),
          if (sublabel != null) Text(sublabel!, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.teal), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
