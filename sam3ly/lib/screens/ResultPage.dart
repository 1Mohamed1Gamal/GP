import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sam3ly/Screens/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResultPage extends StatefulWidget {
  final double totalScore;
  final int totalItems;

  const ResultPage(
      {super.key, required this.totalScore, required this.totalItems});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isVisible = true;
      });
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getLevel() {
    double maxScore = widget.totalItems * 100;
    double percentage = (widget.totalScore / maxScore) * 100;

    if (percentage < 25) {
      return "Beginner";
    } else if (percentage < 50) {
      return "Intermediate";
    } else if (percentage < 75) {
      return "Fluent";
    } else {
      return "Native";
    }
  }

  Future<void> saveUserLevel(String level) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'level': level},
        SetOptions(merge: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String level = getLevel();
    double maxScore = widget.totalItems * 100;
    double percentage = (widget.totalScore / maxScore) * 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZoomIn(
              duration: const Duration(milliseconds: 800),
              child: const Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Text(
                "🎉 Congratulations! 🎉",
                style: GoogleFonts.lobster(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  Text(
                    "Your Final Level Is:",
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    level,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.blue.withOpacity(0.5),
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1000),
              child: Text(
                "Your Score: ${percentage.toStringAsFixed(0)} / 100",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: ElevatedButton(
                onPressed: () async {
                  await saveUserLevel(level);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  "Go to Home",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
