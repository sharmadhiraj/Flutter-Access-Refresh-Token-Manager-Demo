import 'package:flutter/material.dart';
import 'package:flutter_access_refresh_token_manager_demo/home_screen.dart';

void main() {
  runApp(const TokenManagerDemoApp());
}

class TokenManagerDemoApp extends StatelessWidget {
  const TokenManagerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Token Manager Demo",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
