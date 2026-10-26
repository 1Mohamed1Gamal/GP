// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:intl/intl.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class ReminderHelper {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static void initialize() {
//     tz.initializeTimeZones();

//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings settings =
//         InitializationSettings(android: androidSettings);

//     _notificationsPlugin.initialize(settings);
//   }

//   /// Updated to allow both date and time selection
//   static Future<DateTime?> setReminder(BuildContext context) async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (pickedDate != null) {
//       TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );

//       if (pickedTime != null) {
//         DateTime reminderTime = DateTime(
//           pickedDate.year,
//           pickedDate.month,
//           pickedDate.day,
//           pickedTime.hour,
//           pickedTime.minute,
//         );

//         if (reminderTime.isBefore(DateTime.now())) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Please select a future time!")),
//           );
//           return null;
//         }

//         await _scheduleNotification(reminderTime);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 "Reminder set for ${DateFormat('MMM d, yyyy h:mm a').format(reminderTime)}"),
//           ),
//         );

//         return reminderTime;
//       }
//     }

//     return null; // If no date or time is selected
//   }

//   static Future<void> _scheduleNotification(DateTime scheduledTime) async {
//     tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       "reminder_channel",
//       "Call Reminders",
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const NotificationDetails details =
//         NotificationDetails(android: androidDetails);

//     await _notificationsPlugin.zonedSchedule(
//       0,
//       "Call Reminder",
//       "It's time to call Hamada!",
//       tzScheduledTime,
//       details,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
// }
