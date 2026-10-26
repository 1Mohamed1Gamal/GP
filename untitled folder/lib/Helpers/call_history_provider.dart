import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Helpers/AppColors.dart'; // استيراد الألوان

class CallHistoryProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _callHistory = []; // dynamic عشان نضيف اللون

  List<Map<String, dynamic>> get callHistory => _callHistory;

  void addHistory(String type, DateTime? scheduledTime) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('MMM d, yyyy').format(now);
    final String formattedTime = DateFormat('h:mm a').format(now);

    String scheduledTimeFormatted = '';
    if (scheduledTime != null) {
      scheduledTimeFormatted =
          DateFormat('MMM d, yyyy h:mm a').format(scheduledTime);
    }
    Color typeColor = type == "Call" ? AppColors.primary : AppColors.secondary;

    _callHistory.insert(0, {
      "date": formattedDate,
      "time": formattedTime,
      "type": type,
      "scheduled_time": scheduledTimeFormatted,
      "color": typeColor, // إضافة اللون للنوع
    });

    notifyListeners();
  }
}
