import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFE8614D);
  static const Color primaryDark = Color(0xFFC94F3B);
  static const Color primaryLight = Color(0xFFFFE8E4);
  static const Color teal = Color(0xFF4A7C79);
  static const Color tealDark = Color(0xFF3A6360);
  static const Color tealMid = Color(0xFF5BA5A0);
  static const Color tealLight = Color(0xFFE8F5F4);
  static const Color bg = Color(0xFFFAF7F2);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgBanner = Color(0xFFFFF5F0);
  static const Color bgTeal = Color(0xFFF0F8F7);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textMedium = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color success = Color(0xFF48BB78);
  static const Color successBg = Color(0xFFF0FFF4);
  static const Color warning = Color(0xFFED8936);
  static const Color warningBg = Color(0xFFFFFAF0);
  static const Color border = Color(0xFFEDE8E0);
  static const Color shadow = Color(0x0F000000);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.bg,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgCard,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 1,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

// Reusable style helpers
class AppTextStyles {
  static TextStyle heading1 = GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark);
  static TextStyle heading2 = GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark);
  static TextStyle heading3 = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static TextStyle body = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textMedium);
  static TextStyle bodyBold = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark);
  static TextStyle caption = GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textMedium);
  static TextStyle captionBold = GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMedium);
  static TextStyle label = GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMedium);
  static TextStyle primary = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary);
  static TextStyle teal = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal);
}

// Reusable decoration helpers
class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.bgCard,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
  );
  static BoxDecoration banner = BoxDecoration(
    color: AppColors.bgBanner,
    borderRadius: BorderRadius.circular(16),
  );
  static BoxDecoration tealBanner = BoxDecoration(
    color: AppColors.bgTeal,
    borderRadius: BorderRadius.circular(16),
  );
}
