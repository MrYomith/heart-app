import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/main_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MioHartApp());
}

class MioHartApp extends StatelessWidget {
  const MioHartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MioHart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainScaffold(),
    );
  }
}
