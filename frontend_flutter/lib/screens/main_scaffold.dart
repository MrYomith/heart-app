import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';
import 'journey_screen.dart';
import 'learn_screen.dart';
import 'more_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    JourneyScreen(),
    LearnScreen(),
    MoreScreen(),
  ];

  static const _destinations = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.route_rounded, Icons.route_outlined, 'Journey'),
    (Icons.menu_book_rounded, Icons.menu_book_outlined, 'Learn'),
    (Icons.grid_view_rounded, Icons.grid_view_outlined, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Responsive.useSideNav(context)
        ? _buildWideLayout(context)
        : _buildPhoneLayout(context);
  }

  // ── Phone layout ─────────────────────────────────────────
  Widget _buildPhoneLayout(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _MioBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }

  // ── Tablet / foldable layout with NavigationRail ──────────
  Widget _buildWideLayout(BuildContext context) {
    final extended = Responsive.isLarge(context);
    final railWidth = extended ? 200.0 : (Responsive.isTablet(context) ? 88.0 : 72.0);

    return Scaffold(
      body: Row(
        children: [
          // Side rail
          Container(
            width: railWidth,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: Border(right: BorderSide(color: AppColors.border)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Logo / Mio branding
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: extended ? 24 : 20),
                    child: Column(
                      children: [
                        Container(
                          width: extended ? 56 : 44,
                          height: extended ? 56 : 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Center(child: Text('🫀', style: TextStyle(fontSize: extended ? 26 : 20))),
                        ),
                        if (extended) ...[
                          const SizedBox(height: 6),
                          Text('MioHart', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  // Nav items
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _destinations.length,
                      itemBuilder: (context, i) {
                        final dest = _destinations[i];
                        final selected = _index == i;
                        return _RailItem(
                          icon: selected ? dest.$1 : dest.$2,
                          label: dest.$3,
                          selected: selected,
                          extended: extended,
                          onTap: () => setState(() => _index = i),
                        );
                      },
                    ),
                  ),
                  // Bottom Mio quote (only extended)
                  if (extended)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '"Small steps today, stronger heart tomorrow. 🤍"',
                          style: GoogleFonts.inter(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.teal, height: 1.4),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: IndexedStack(index: _index, children: _screens),
          ),
        ],
      ),
    );
  }
}

// ── Rail item ─────────────────────────────────────────────
class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textLight;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: extended ? 14 : 0, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: AppColors.primary.withValues(alpha: 0.25)) : null,
        ),
        child: extended
            ? Row(children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(width: 12),
                Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: color)),
              ])
            : Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 3),
                Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: color)),
              ]),
      ),
    );
  }
}

// ── Bottom nav (phone only) ───────────────────────────────
class _MioBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MioBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _NavTab(icon: Icons.home_rounded, label: 'Home', index: 0, active: currentIndex == 0, onTap: onTap, activeColor: AppColors.primary),
          _NavTab(icon: Icons.route_rounded, label: 'Journey', index: 1, active: currentIndex == 1, onTap: onTap),
          _CenterMioButton(onTap: () {}),
          _NavTab(icon: Icons.menu_book_rounded, label: 'Learn', index: 2, active: currentIndex == 2, onTap: onTap),
          _NavTab(icon: Icons.grid_view_rounded, label: 'More', index: 3, active: currentIndex == 3, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool active;
  final ValueChanged<int> onTap;
  final Color activeColor;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.index,
    required this.active,
    required this.onTap,
    this.activeColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: active ? activeColor : AppColors.textLight),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? activeColor : AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _CenterMioButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterMioButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              width: 54, height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: const Center(child: Text('🫀', style: TextStyle(fontSize: 24))),
            ),
            Text('MioHart', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
