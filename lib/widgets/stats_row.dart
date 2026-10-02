import 'package:flutter/material.dart';
import 'package:flutter_access_refresh_token_manager_demo/logging/activity_log.dart';

class StatsRow extends StatelessWidget {
  final ActivityLog log;

  const StatsRow({required this.log, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat(context, Icons.send, "Requests", ActivityKind.request),
        _stat(context, Icons.autorenew, "Refreshes", ActivityKind.refresh),
        _stat(context, Icons.hourglass_top, "Waited", ActivityKind.waiting),
      ],
    );
  }

  Widget _stat(
    BuildContext context,
    IconData icon,
    String label,
    ActivityKind kind,
  ) {
    return Expanded(
      child: Semantics(
        label: "$label: ${log.count(kind)}",
        excludeSemantics: true,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, size: 20),
                const SizedBox(height: 4),
                Text(
                  "${log.count(kind)}",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
