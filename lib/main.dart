// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:proverbs/firebase_options.dart';
// import 'package:provider/provider.dart';
// import 'app.dart';
// import 'services/auth_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(
//     Provider<AuthService>(create: (_) => AuthService(), child: ProverbsApp()),
//   );
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proverbs/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<AuthService>(create: (_) => AuthService())],
      child: MaterialApp(
        title: 'Proverbs App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<bool>(
          future: _checkFirstLaunch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSplashScreen();
            }

            bool isFirstLaunch = snapshot.data ?? true;
            if (isFirstLaunch) {
              return OnboardingScreen();
            } else {
              return AuthWrapper();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.format_quote, size: 80, color: Colors.blue);
              },
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    return !onboardingCompleted;
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          }
          return HomeScreen();
        }

        // Show loading indicator while checking auth state
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
