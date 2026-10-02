import 'package:flutter/foundation.dart';

enum ActivityKind { request, response, waiting, refresh, success, error }

class ActivityEvent {
  final DateTime time;
  final ActivityKind kind;
  final String message;

  const ActivityEvent(this.time, this.kind, this.message);
}

class ActivityLog extends ChangeNotifier {
  final List<ActivityEvent> _events = [];

  List<ActivityEvent> get events => List.unmodifiable(_events);

  int count(ActivityKind kind) => _events.where((e) => e.kind == kind).length;

  void add(ActivityKind kind, String message) {
    _events.add(ActivityEvent(DateTime.now(), kind, message));
    notifyListeners();
  }

  void clear() {
    _events.clear();
    notifyListeners();
  }
}
