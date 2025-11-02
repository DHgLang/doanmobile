import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import 'firebase_options.dart';
import 'config/theme.dart';
import 'screens/verify_email_screen.dart';
import 'screens/main_screen.dart';
import 'screens/introduce_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print("Firebase init error: $e");
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations', // 🔹 thư mục chứa en.json & vi.json
      fallbackLocale: const Locale('vi'),
      child: const MovieApp(),
    ),
  );
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ONEPHIM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: context.localizationDelegates, // ✅ thêm
      supportedLocales: context.supportedLocales,             // ✅ thêm
      locale: context.locale,                                 // ✅ thêm
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            final user = snapshot.data!;
            if (!user.emailVerified) {
              return const VerifyEmailScreen();
            }
            return const MainScreen();
          }

          return const IntroduceScreen();
        },
      ),
    );
  }
}
