import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sam3ly/providers/call_history_provider.dart';
import '../Helpers/AppColors.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Call History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        backgroundColor: AppColors.background, // جعل الـ AppBar نفس لون الخلفية
        elevation: 0, // إزالة الظل
        iconTheme: const IconThemeData(color: Colors.white), // جعل السهم أبيض
      ),
      backgroundColor: AppColors.background,
      body: Consumer<CallHistoryProvider>(
        builder: (context, historyProvider, child) {
          final callHistory = historyProvider.callHistory;

          return callHistory.isEmpty
              ? const Center(
                  child: Text(
                    "No history yet",
                    style: TextStyle(color: AppColors.text, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: callHistory.length,
                  itemBuilder: (context, index) {
                    final entry = callHistory[index];
                    final entryType = entry['type'];
                    final Color typeColor = entryType == "Call"
                        ? AppColors.primary
                        : AppColors.secondary;

                    return Card(
                      color: AppColors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          entryType == "Call"
                              ? Icons.phone
                              : Icons.notifications,
                          color: typeColor, // لون الأيقونة حسب نوع المكالمة
                        ),
                        title: Text(
                          "${entryType} - ${entry['date']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        subtitle: Text(
                          "Time: ${entry['time']}" +
                              (entryType == "Reminder"
                                  ? "\nScheduled: ${entry['scheduled_time']}"
                                  : ''),
                          style:
                              TextStyle(color: AppColors.text.withOpacity(0.7)),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
