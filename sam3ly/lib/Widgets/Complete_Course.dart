import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/screens/LevelUp.dart';

class CompleteCourse extends StatefulWidget {
  final String userId; // User ID to fetch courses from Firestore

  const CompleteCourse({super.key, required this.userId});

  @override
  _CompleteCourseState createState() => _CompleteCourseState();
}

class _CompleteCourseState extends State<CompleteCourse> {
  // Mapping levels from string to numeric values
  final Map<String, int> levelMap = {
    'Beginner': 0,
    'Intermediate': 1,
    'Fluent': 2,
    'Native': 3,
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No user data available.'));
        }

        var userDoc = snapshot.data;
        String userLevel = userDoc?['level'] ?? 'Beginner';
        int levelIndex = levelMap[userLevel] ?? 0;

        List<dynamic> coursesData = userDoc?['courses'] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Complete Course',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: coursesData
                    .map((course) =>
                        _buildCourseCard(course, levelIndex, context))
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourseCard(
      Map<String, dynamic> course, int userLevel, BuildContext context) {
    bool isUnlocked = userLevel >= course['level'];

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .snapshots(),
      builder: (context, courseSnapshot) {
        if (courseSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!courseSnapshot.hasData) {
          return const Center(child: Text('No course data available.'));
        }

        int totalLessons = (course['lessons'] ?? 0).toInt();
        int completedLessons = (course['completedCourses'] ?? 0).toInt();
        double progress =
            totalLessons > 0 ? completedLessons / totalLessons : 0.0;
        progress = progress.clamp(0.0, 1.0);
        double progressBarWidth = 150.0;
        double progressWidth = progress * progressBarWidth;

        Widget courseCard = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(course['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isUnlocked
                              ? AppColors.text
                              : AppColors.text.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedLessons / $totalLessons lessons',
                        style: TextStyle(
                          color: AppColors.text.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            width: progressBarWidth,
                            decoration: BoxDecoration(
                              color: AppColors.text.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: 6,
                            width: progressWidth,
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? AppColors.primary
                                  : AppColors.text.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  isUnlocked ? Icons.lock_open : Icons.lock,
                  color: isUnlocked
                      ? AppColors.primary
                      : AppColors.text.withOpacity(0.5),
                ),
              ],
            ),
          ),
        );

        // If the course is locked, return the courseCard without OpenContainer
        if (!isUnlocked) {
          return courseCard;
        }

        // If unlocked, wrap it with OpenContainer
        return OpenContainer(
          closedColor: AppColors.background,
          closedElevation: 0,
          openColor: AppColors.background,
          transitionDuration: const Duration(milliseconds: 500),
          closedBuilder: (context, openContainer) => GestureDetector(
            onTap: openContainer,
            child: courseCard,
          ),
          openBuilder: (context, closeContainer) => LevelUpPage(
            levelTitle: course['title'],
            levelIndex: levelMap[course['title']]!,
          ),
        );
      },
    );
  }
}
