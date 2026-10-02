import 'package:flutter/material.dart';
import 'package:flutter_access_refresh_token_manager_demo/logging/activity_log.dart';

class ActivityTimeline extends StatelessWidget {
  final ActivityLog log;

  const ActivityTimeline({required this.log, super.key});

  @override
  Widget build(BuildContext context) {
    final List<ActivityEvent> events = log.events.reversed.toList();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Text(
                  "Activity",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  tooltip: "Clear activity",
                  icon: const Icon(Icons.delete_outline),
                  onPressed: events.isEmpty ? null : log.clear,
                ),
              ],
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text("No activity yet"))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (_, i) => _buildTile(context, events[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, ActivityEvent event) {
    final (IconData icon, Color color) = _style(event.kind);
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, size: 16, color: color),
      ),
      title: Text(event.message),
      trailing: Text(
        _time(event.time),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  (IconData, Color) _style(ActivityKind kind) {
    return switch (kind) {
      ActivityKind.request => (Icons.north_east, Colors.blue),
      ActivityKind.response => (Icons.check, Colors.green),
      ActivityKind.waiting => (Icons.hourglass_top, Colors.orange),
      ActivityKind.refresh => (Icons.autorenew, Colors.deepPurple),
      ActivityKind.success => (Icons.verified, Colors.teal),
      ActivityKind.error => (Icons.error_outline, Colors.red),
    };
  }

  String _time(DateTime t) {
    String two(int n) => n.toString().padLeft(2, "0");
    return "${two(t.hour)}:${two(t.minute)}:${two(t.second)}."
        "${t.millisecond.toString().padLeft(3, "0")}";
  }
}
