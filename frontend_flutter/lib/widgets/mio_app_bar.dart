import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Shared top-bar actions — the notification bell (with badge) and the profile
/// avatar — matching the mockups' top-right on every screen. Use as
/// `AppBar(... actions: mioActions(context))` so all screens feel like Home.
List<Widget> mioActions(BuildContext context) => [
      Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Stack(clipBehavior: Clip.none, children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 26, color: AppColors.textDark),
          ),
          Positioned(
            right: 6, top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
              child: const Text('3', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
            ),
          ),
        ]),
      ),
      const Padding(
        padding: EdgeInsets.only(right: 14),
        child: CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.tealLight,
          child: Icon(Icons.person_rounded, size: 19, color: AppColors.teal),
        ),
      ),
    ];

/// A branded title (icon + title + subtitle) for an AppBar, matching the
/// mockups' per-screen headers.
Widget mioTitle(String title, {String? subtitle, String? emoji, double fs = 1.0}) {
  return Row(
    children: [
      if (emoji != null) ...[
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            if (subtitle != null)
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textMedium)),
          ],
        ),
      ),
    ],
  );
}
