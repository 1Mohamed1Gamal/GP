import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

class CallHistoryProvider extends ChangeNotifier {
  final List<Map<String, String>> _callHistory = [];

  List<Map<String, String>> get callHistory => _callHistory;

  void addHistory(String type, DateTime? scheduledTime) {
    final DateTime now = DateTime.now();

    // Format the date to "Feb 1, 2025"
    final String formattedDate = DateFormat('MMM d, yyyy').format(now);

    // Format the time to "10:30 AM"
    final String formattedTime = DateFormat('h:mm a').format(now);

    String scheduledTimeFormatted = '';
    if (scheduledTime != null) {
      scheduledTimeFormatted =
          DateFormat('MMM d, yyyy h:mm a').format(scheduledTime);
    }

    _callHistory.insert(0, {
      "date": formattedDate,
      "time": formattedTime,
      "type": type,
      "scheduled_time": scheduledTimeFormatted,
    });

    notifyListeners(); // Notify widgets to rebuild
  }
}
