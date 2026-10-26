import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sam3ly/Helpers/AppColors.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  List<List<bool>> _monthProgress =
      List.generate(4, (index) => List.filled(7, false));
  bool isLoading = true;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _listenToProgressUpdates();
  }

  void _listenToProgressUpdates() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((userDoc) {
      if (userDoc.exists) {
        DateTime lastLogin = (userDoc['lastLoginDate'] as Timestamp).toDate();
        int streakCount = userDoc['streakCount'] as int;

        // Reset progress data
        List<List<bool>> newProgress =
            List.generate(4, (index) => List.filled(7, false));

        // Fill in progress data
        DateTime currentDate = DateTime.now();
        for (int i = 0; i < streakCount; i++) {
          DateTime checkDate = lastLogin.subtract(Duration(days: i));
          if (currentDate.difference(checkDate).inDays <= 28) {
            int week = currentDate.difference(checkDate).inDays ~/ 7;
            int dayOfWeek = checkDate.weekday - 1; // 0 = Monday, 6 = Sunday
            if (week < 4) {
              newProgress[week][dayOfWeek] = true;
            }
          }
        }

        setState(() {
          _monthProgress = newProgress;
          isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error fetching progress data: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'Your Progress',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Column(
            children: [
              // Days of week header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                      .map((day) => SizedBox(
                            width: 35,
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              // Progress grid
              for (int week = 0; week < _monthProgress.length; week++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (day) {
                      bool isCompleted = _monthProgress[week][day];
                      return Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.2),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
