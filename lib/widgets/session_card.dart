import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/token_manager.dart';

class SessionCard extends StatefulWidget {
  final TokenManager tokenManager;
  final bool loggedIn;
  final String? profileName;

  const SessionCard({
    required this.tokenManager,
    required this.loggedIn,
    this.profileName,
    super.key,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.loggedIn ? "Session active" : "Signed out",
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colors),
              if (widget.loggedIn) ...[
                const Divider(height: 24),
                _buildAccessToken(colors),
                const SizedBox(height: 12),
                _buildRefreshToken(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: widget.loggedIn
              ? colors.primaryContainer
              : colors.surfaceContainerHighest,
          child: Icon(widget.loggedIn ? Icons.lock_open : Icons.lock_outline),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.loggedIn ? "Signed in" : "Signed out",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              widget.loggedIn
                  ? widget.profileName ?? "Session restored"
                  : "Log in to get an access and refresh token",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccessToken(ColorScheme colors) {
    final DateTime? expiry = widget.tokenManager.accessTokenExpiry;
    final DateTime? issuedAt = widget.tokenManager.accessTokenIssuedAt;
    final bool expired = widget.tokenManager.isTokenExpired();
    final Duration remaining =
        expiry == null ? Duration.zero : expiry.difference(DateTime.now());
    double? fraction;
    if (expiry != null && issuedAt != null && !expired) {
      fraction = remaining.inSeconds / expiry.difference(issuedAt).inSeconds;
    }
    final Color color = expired ? colors.error : colors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.vpn_key_outlined, size: 18),
            const SizedBox(width: 8),
            const Text("Access token"),
            const Spacer(),
            Chip(
              label: Text(expired ? "Expired" : "Valid"),
              backgroundColor: color.withValues(alpha: 0.12),
              side: BorderSide.none,
              labelStyle: TextStyle(color: color),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: expired ? 0 : fraction?.clamp(0, 1),
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          expired ? "Expires in: now" : "Expires in: ${_format(remaining)}",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildRefreshToken() {
    return Row(
      children: [
        const Icon(Icons.shield_outlined, size: 18),
        const SizedBox(width: 8),
        const Text("Refresh token"),
        const Spacer(),
        Text(
          "Stored securely",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _format(Duration d) {
    if (d.inDays > 0) {
      return "${d.inDays}d ${d.inHours % 24}h";
    }
    if (d.inHours > 0) {
      return "${d.inHours}h ${d.inMinutes % 60}m";
    }
    return "${d.inMinutes}m ${d.inSeconds % 60}s";
  }
}
