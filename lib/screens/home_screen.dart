import 'package:flutter/material.dart';
import 'package:flutter_access_refresh_token_manager_demo/app_dependencies.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/session_expired_exception.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/token_manager.dart';
import 'package:flutter_access_refresh_token_manager_demo/logging/activity_log.dart';
import 'package:flutter_access_refresh_token_manager_demo/widgets/activity_timeline.dart';
import 'package:flutter_access_refresh_token_manager_demo/widgets/session_card.dart';
import 'package:flutter_access_refresh_token_manager_demo/widgets/stats_row.dart';

class HomeScreen extends StatefulWidget {
  final AppDependencies dependencies;

  const HomeScreen({required this.dependencies, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _parallelRequests = 3;

  bool _restoring = true;
  bool _progress = false;
  bool _loggedIn = false;
  String? _profileName;

  TokenManager get _tokenManager => widget.dependencies.tokenManager;

  ActivityLog get _log => widget.dependencies.activityLog;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _restoring
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Token Manager Demo"),
      actions: [
        if (_loggedIn)
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: _progress ? null : _logout,
          ),
      ],
    );
  }

  Widget _buildContent() {
    return ListenableBuilder(
      listenable: _log,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SessionCard(
              tokenManager: _tokenManager,
              loggedIn: _loggedIn,
              profileName: _profileName,
            ),
            const SizedBox(height: 12),
            _buildAction(),
            if (_loggedIn) ...[
              const SizedBox(height: 12),
              StatsRow(log: _log),
            ],
            const SizedBox(height: 4),
            Expanded(child: ActivityTimeline(log: _log)),
          ],
        ),
      ),
    );
  }

  Widget _buildAction() {
    final bool loggedIn = _loggedIn;
    return Semantics(
      label: loggedIn ? "Simulate token refresh button" : "Login button",
      button: true,
      child: FilledButton.icon(
        onPressed: _progress ? null : (loggedIn ? _simulateRefresh : _login),
        icon: _progress
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(loggedIn ? Icons.bolt : Icons.login),
        label: Text(
          loggedIn
              ? "Expire token and send $_parallelRequests requests"
              : "Login",
        ),
      ),
    );
  }

  Future<void> _restoreSession() async {
    await _tokenManager.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _loggedIn = _tokenManager.hasSession;
      _restoring = false;
    });
  }

  Future<void> _login() async {
    setState(() => _progress = true);
    try {
      await _tokenManager.setToken(await widget.dependencies.authApi.login());
      if (!mounted) {
        return;
      }
      setState(() => _loggedIn = true);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) {
        setState(() => _progress = false);
      }
    }
  }

  Future<void> _simulateRefresh() async {
    setState(() => _progress = true);
    _log.clear();
    _tokenManager.expireAccessToken();
    try {
      final List<Map<String, dynamic>> responses = await Future.wait([
        for (int i = 0; i < _parallelRequests; i++)
          Future.delayed(
            Duration(milliseconds: i * 10),
            widget.dependencies.apiClient.fetchProfile,
          ),
      ]);
      _profileName = responses.first["name"] as String?;
    } on SessionExpiredException {
      _loggedIn = false;
      _profileName = null;
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) {
        setState(() => _progress = false);
      }
    }
  }

  Future<void> _logout() async {
    await _tokenManager.clear();
    _log.clear();
    if (!mounted) {
      return;
    }
    setState(() {
      _loggedIn = false;
      _profileName = null;
    });
  }

  void _showError(Object error) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }
}
