import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LevelCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final Widget destination;
  final String userId; // User ID for Firestore update
  final Function(String) saveUserLevel; // Function to save level

  const LevelCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.destination,
    required this.userId,
    required this.saveUserLevel, // Add this here
  }) : super(key: key);

  Future<void> saveUserLevelToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'level': title, // Save the title of the selected level
      });
    } catch (e) {
      print("Error updating user level: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        saveUserLevel(
            title); // Update the level using the function passed from parent
        saveUserLevelToFirestore(); // Update Firestore level
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(top: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Image.asset(
                imagePath, // Custom image path
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title, // Custom text
                style: const TextStyle(
                  color: Color(0xFF1E1C1C),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Baloo Chettan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
