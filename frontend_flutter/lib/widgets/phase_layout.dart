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
    final sidebarWidth = Responsive.value<double>(
      context,
      phone: 100.0,
      fold: 120.0,
      tablet: 148.0,
      large: 180.0,
    );
    final iconSize = Responsive.value<double>(context, phone: 15.0, fold: 17.0, tablet: 19.0);
    final labelSize = Responsive.value<double>(context, phone: 8.5, fold: 9.5, tablet: 10.5);
    final mioSize = Responsive.value<double>(context, phone: 60.0, fold: 72.0, tablet: 88.0);
    final heroFontSize = Responsive.value<double>(context, phone: 13.0, fold: 15.0, tablet: 17.0);
    final isLarge = Responsive.isTablet(context) || Responsive.isFoldable(context);

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
                  Text(title, style: GoogleFonts.inter(fontSize: isLarge ? 18 : 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: isLarge ? 12 : 10, color: AppColors.textMedium)),
                ],
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sidebar ─────────────────────────────────────
          Container(
            width: sidebarWidth,
            color: AppColors.bgCard,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: sideNav.length,
                    itemBuilder: (context, i) {
                      final item = sideNav[i];
                      return InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: isLarge ? 9 : 7, horizontal: 4),
                          child: Column(
                            children: [
                              Text(item.icon, style: TextStyle(fontSize: iconSize)),
                              const SizedBox(height: 2),
                              Text(
                                item.label,
                                style: GoogleFonts.inter(fontSize: labelSize, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Care team CTA
                Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.bgTeal, borderRadius: BorderRadius.circular(8)),
                  child: Column(children: [
                    Text('🎧', style: TextStyle(fontSize: iconSize)),
                    const SizedBox(height: 3),
                    Text('Need\nsomething?', style: GoogleFonts.inter(fontSize: labelSize - 0.5, fontWeight: FontWeight.w600, color: AppColors.textMedium), textAlign: TextAlign.center),
                    Text('Contact\ncare team', style: GoogleFonts.inter(fontSize: labelSize - 0.5, color: AppColors.primary), textAlign: TextAlign.center),
                  ]),
                ),
              ],
            ),
          ),

          // ── Main content ─────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(heroMsg, style: GoogleFonts.inter(fontSize: heroFontSize, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.4)),
                                  if (heroSub != null) ...[
                                    const SizedBox(height: 4),
                                    Text(heroSub!, style: GoogleFonts.inter(fontSize: (heroFontSize - 2), color: AppColors.textMedium, height: 1.5)),
                                  ],
                                  if (mottoMsg != null) ...[
                                    const SizedBox(height: 8),
                                    Text(mottoMsg!, style: GoogleFonts.inter(fontSize: (heroFontSize - 1), fontWeight: FontWeight.w600, color: AppColors.primary)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            MioMascot(variant: mioVariant, size: mioSize),
                            if (focusItems != null) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Today's Focus", style: GoogleFonts.inter(fontSize: isLarge ? 12 : 10, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                    const SizedBox(height: 5),
                                    ...focusItems!.map((f) => Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Row(children: [
                                        Text(f.icon, style: TextStyle(fontSize: isLarge ? 14 : 12)),
                                        const SizedBox(width: 4),
                                        Text(f.label, style: GoogleFonts.inter(fontSize: isLarge ? 11 : 9, color: AppColors.textMedium)),
                                      ]),
                                    )),
                                    const SizedBox(height: 3),
                                    Text("You've got this!", style: GoogleFonts.inter(fontSize: isLarge ? 11 : 9, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                  ],
                                ),
                              ),
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
          ),
        ],
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
          Text(title, style: GoogleFonts.inter(fontSize: 13 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: GoogleFonts.inter(fontSize: 10 * fs, color: AppColors.textMedium)),
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Text(icon, style: TextStyle(fontSize: 16 * fs)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textDark, fontWeight: FontWeight.w500))),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textLight),
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
        decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
        child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal)),
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
          Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMedium), textAlign: TextAlign.center),
          if (sublabel != null) Text(sublabel!, style: GoogleFonts.inter(fontSize: 9, color: AppColors.teal), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
