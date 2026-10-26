import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/screens/Assessment.dart';
import 'package:sam3ly/screens/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LevelPage extends StatelessWidget {
  const LevelPage({Key? key}) : super(key: key);

  void _saveUserLevel(String level) async {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const ChatMessageWidget(),
                  const SizedBox(height: 20),
                  MyComponent(saveUserLevel: _saveUserLevel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/man.png',
            width: 87,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'How much English do you know?',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontFamily: 'Baloo Chettan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyComponent extends StatelessWidget {
  final Function(String) saveUserLevel;

  const MyComponent({Key? key, required this.saveUserLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LevelCardAnimated(
          imagePath: 'assets/images/beginner.png',
          title: 'Beginner',
          destination: Home(),
          saveUserLevel: saveUserLevel,
        ),
        LevelCardAnimated(
          imagePath: 'assets/images/intermediate.png',
          title: 'Intermediate',
          destination: Home(),
          saveUserLevel: saveUserLevel,
        ),
        LevelCardAnimated(
          imagePath: 'assets/images/fluent.png',
          title: 'Fluent',
          destination: Home(),
          saveUserLevel: saveUserLevel,
        ),
        LevelCardAnimated(
          imagePath: 'assets/images/native.png',
          title: 'Native',
          destination: Home(),
          saveUserLevel: saveUserLevel,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Center(
            child: Text(
              'OR',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
                color: AppColors.text,
              ),
            ),
          ),
        ),
        LevelCardAnimated(
          imagePath: 'assets/images/test.png',
          title: 'Test Your Level',
          destination: AssessmentPage(),
          saveUserLevel: saveUserLevel,
        ),
      ],
    );
  }
}

class LevelCardAnimated extends StatefulWidget {
  final String imagePath;
  final String title;
  final Widget destination;
  final Function(String) saveUserLevel;

  const LevelCardAnimated({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.destination,
    required this.saveUserLevel,
  }) : super(key: key);

  @override
  _LevelCardAnimatedState createState() => _LevelCardAnimatedState();
}

class _LevelCardAnimatedState extends State<LevelCardAnimated> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: () {
        widget.saveUserLevel(widget.title);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => widget.destination),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              _isTapped ? AppColors.primary.withOpacity(0.8) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isTapped ? Colors.black26 : Colors.black54,
              blurRadius: _isTapped ? 2 : 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              widget.imagePath,
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 12),
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
