import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PetaBuitenzorgApp());
}

class PetaBuitenzorgApp extends StatelessWidget {
  const PetaBuitenzorgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetaBuitenzorg',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
