import 'package:flutter/material.dart';
import 'package:flutter_access_refresh_token_manager_demo/app_dependencies.dart';
import 'package:flutter_access_refresh_token_manager_demo/screens/home_screen.dart';

class TokenManagerDemoApp extends StatelessWidget {
  final AppDependencies dependencies;

  const TokenManagerDemoApp({required this.dependencies, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Token Manager Demo",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(dependencies: dependencies),
    );
  }
}
