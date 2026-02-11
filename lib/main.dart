import 'package:flutter/material.dart';
import 'package:royal_invoice/screens/invoice_form_screen.dart';
import 'package:royal_invoice/screens/settings_screen.dart';
import 'package:royal_invoice/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

          title: 'Royal Invoice Maker',
          theme: ThemeData(primarySwatch: Colors.deepPurple),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/settings': (context) => const SettingsScreen(),
          },
        );
  }
}

