import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  runApp(const BoneSightApp());
}

class BoneSightApp extends StatelessWidget {
  const BoneSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoneSight AI',
      theme: AppTheme.lightTheme,
      home: const SignInPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
