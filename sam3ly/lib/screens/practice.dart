import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sam3ly/screens/Real_Practice.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String selectedButton = ""; // Track which button is clicked

  void _onButtonClick(String title, BuildContext context) {
    setState(() {
      selectedButton = title; // Change button color
    });

    // Delay for 1 second before navigating
    Future.delayed(const Duration(microseconds: 500), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PracticePage(
              typeOfData: title,
              typeOfPage: "practice",
            ),
          ),
        ).then((_) {
          // Reset button color when returning
          if (mounted) {
            setState(() {
              selectedButton = "";
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),

            // Animated Title with Glow Effect
            FadeInDown(
              child: Text(
                "Use it or lose it!",
                style: GoogleFonts.lobster(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.greenAccent,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sections with animations
            buildSection(context, "Words", "assets/images/wordss.png"),
            buildSection(context, "Sentences", "assets/images/sentences.png"),
            buildSection(context, "Paragraphs", "assets/images/paragraphs.png"),
          ],
        ),
      ),
    );
  }

  Widget buildSection(BuildContext context, String title, String imagePath) {
    return FadeInLeft(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.card, Colors.black45],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔥 Wrap Column inside Expanded
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Animated Button
                  Bounce(
                    child: ElevatedButton(
                      onPressed: () => _onButtonClick(title, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedButton == title
                            ? Colors.orange // Change when clicked
                            : AppColors.primary, // Default color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Start",
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🛠 Wrap Image.asset in Flexible to prevent overflow
            Flexible(
              child: Image.asset(
                imagePath,
                height: 120,
                width: 120,
                fit: BoxFit.contain, // Ensures image scales correctly
              ),
            ),
          ],
        ),
      ),
    );
  }
}
