import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'pages/auth/login.dart';
import 'navigation.dart';

void main() {
  runApp(const PythanceApp());
}

class PythanceApp extends StatelessWidget {
  const PythanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightScheme = lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.amberAccent);
        final darkScheme = darkDynamic ?? ColorScheme.fromSeed(seedColor: Colors.amberAccent, brightness: Brightness.dark);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pythance',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            fontFamily: 'Poppins',
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w900),
              displayMedium: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w900),
              displaySmall: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w900),
              headlineLarge: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w900),
              headlineMedium: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w900),
              headlineSmall: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w900),
              titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900),
              bodyLarge: TextStyle(fontFamily: 'Poppins'),
              bodyMedium: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            fontFamily: 'Poppins',
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.bold),
              displayMedium: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.bold),
              displaySmall: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.bold),
              headlineLarge: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.bold),
              headlineMedium: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.bold),
              headlineSmall: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.bold),
              titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              bodyLarge: TextStyle(fontFamily: 'Poppins'),
              bodyMedium: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          themeMode: ThemeMode.system,
          home: const AuthCheck(),
        );
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  final storage = const FlutterSecureStorage();

  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData && snapshot.data == true) {
          return const NavigationBarPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  Future<bool> _isLoggedIn() async {
    return await storage.read(key: 'api_token') != null;
  }
}
