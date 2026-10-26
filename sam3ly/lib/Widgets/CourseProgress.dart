import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseProgressWidget extends StatefulWidget {
  final List<String> levels = ['Fluent', 'Native'];

  CourseProgressWidget({super.key});

  @override
  State<CourseProgressWidget> createState() => _CourseProgressWidgetState();
}

class _CourseProgressWidgetState extends State<CourseProgressWidget> {
  String userLevel = 'Beginner';
  double courseProgress = 0.0;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        userLevel = userDoc['level'] ?? 'Beginner';
        courseProgress = (userDoc['courseProgress'] ?? 0.0).toDouble();
      });
    }
  }

  bool isLevelUnlocked(String level) {
    final levels = ['Beginner', 'Intermediate', 'Fluent', 'Native'];
    final userLevelIndex = levels.indexOf(userLevel);
    final levelIndex = levels.indexOf(level);
    return levelIndex <= userLevelIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: courseProgress,
              backgroundColor: Colors.grey[300],
              minHeight: 8,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Level indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.levels.map((level) {
            final isUnlocked = isLevelUnlocked(level);

            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUnlocked ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isUnlocked)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.lock, color: Colors.grey, size: 24),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.lock_open, color: Colors.green, size: 24),
                  ),
                const SizedBox(width: 10),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
