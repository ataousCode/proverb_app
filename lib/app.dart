import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';

class ProverbsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proverbs App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: context.read<AuthService>().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return LoginScreen();
            }
            return HomeScreen();
          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
