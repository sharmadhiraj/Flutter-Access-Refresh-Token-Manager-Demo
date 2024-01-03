import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _progress = true;
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
      onPressed: () {},
      child: const Text("Login"),
    );
  }

  Widget _buildTokenRenewWidget() {
    return ElevatedButton(
      onPressed: () {},
      child: const Text("Simulate Token Refresh"),
    );
  }
}
