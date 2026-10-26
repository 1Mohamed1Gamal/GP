import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sam3ly/Widgets/call_history_screen.dart';
import 'package:sam3ly/Widgets/calling_screen.dart';
import 'package:sam3ly/providers/call_history_provider.dart';

import '../Helpers/AppColors.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final callHistoryProvider =
        Provider.of<CallHistoryProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Call with Hamada",
          style: TextStyle(
            fontWeight: FontWeight.bold, // Makes the text bold
            color: AppColors.text, // Changes text color to white
            fontSize: 20, // Adjust size for better visibility
          ),
        ),
        backgroundColor: AppColors.card,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CallHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background, // Matching Profile Page theme

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/images/man.png'),
            ),
            const SizedBox(height: 20),
            const Text(
              "Hamada",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text),
            ),
            const SizedBox(height: 20),
            // Call Now Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text("Start a 10 min Call Now",
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Add history for "Call" without scheduled time
                callHistoryProvider.addHistory("Call", null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CallingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Set Reminder Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: const Text("Set Reminder",
                  style: TextStyle(color: Colors.white)),
              onPressed: () async {
                // Set a reminder and save it in history with scheduled time
                // DateTime? scheduledTime =
                //     // await ReminderHelper.setReminder(context);

                // if (scheduledTime != null) {
                //   callHistoryProvider.addHistory("Reminder", scheduledTime);
                // }
              },
            ),
          ],
        ),
      ),
    );
  }
}
