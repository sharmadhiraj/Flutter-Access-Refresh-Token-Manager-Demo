import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_access_refresh_token_manager_demo/api.dart';
import 'package:flutter_access_refresh_token_manager_demo/token.dart';
import 'package:flutter_access_refresh_token_manager_demo/token_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _progress = false;
  bool _loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: _buildBody()),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Token Manager Demo"),
    );
  }

  Widget _buildBody() {
    if (_progress) {
      return _buildProgressWidget();
    } else if (_loggedIn) {
      return _buildTokenRenewWidget();
    } else {
      return _buildLoginWidget();
    }
  }

  Widget _buildProgressWidget() {
    return const CircularProgressIndicator();
  }

  Widget _buildLoginWidget() {
    return ElevatedButton(
      onPressed: _login,
      child: const Text("Login"),
    );
  }

  Widget _buildTokenRenewWidget() {
    return ElevatedButton(
      onPressed: _renewToken,
      child: const Text("Simulate Token Refresh"),
    );
  }

  Future<void> _login() async {
    setState(() => _progress = true);
    try {
      final Token token = await Api.login();
      TokenManager.instance.setToken(token);
      setState(() => _loggedIn = true);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _progress = false);
    }
  }

  Future<void> _renewToken() async {
    setState(() => _progress = true);
    TokenManager.instance.expireAccessToken();
    List<Map<String, dynamic>> responses = await Future.wait(
      [
        Api.fetchProfile(),
        Future.delayed(
          const Duration(milliseconds: 10),
          Api.fetchProfile,
        )
      ],
    );
    for (var element in responses) {
      debugPrint(jsonEncode(element));
    }
    setState(() => _progress = false);
  }
}
