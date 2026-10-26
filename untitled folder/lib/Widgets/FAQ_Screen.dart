import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam3ly/Helpers/AppColors.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("FAQs",
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            FAQItem(
                question: "What is Sam3ly?",
                answer:
                    "Sam3ly is a pronunciation improvement application that helps users practice speaking by analyzing their pronunciation of words, sentences, and paragraphs."),
            FAQItem(
                question: "How does Sam3ly work?",
                answer:
                    "Users can either select their level manually or take a test to determine their level automatically. The app provides pronunciation exercises, conversation practice with a bot (Hamada), and a challenge mode where users speak freely and receive feedback."),
            FAQItem(
                question: "How do I sign up?",
                answer:
                    "To create an account, you need to provide your email, password, username, phone number, country, and gender. You must verify your email before logging in."),
            FAQItem(
                question: "How does the pronunciation analysis work?",
                answer:
                    "When you pronounce a word, sentence, or paragraph, the app records your speech and analyzes it for correctness. It highlights mistakes, whether they are in specific letters or whole words."),
            FAQItem(
                question: "What is the bot conversation feature?",
                answer:
                    "The app includes a chatbot named Hamada that engages in conversations on various topics. After the conversation, it provides feedback on pronunciation mistakes."),
            FAQItem(
                question: "What is Challenge Mode?",
                answer:
                    "Challenge Mode allows users to speak freely while the app listens and provides feedback on pronunciation errors."),
            FAQItem(
                question: "Does the app have a streak system?",
                answer:
                    "Yes! Sam3ly includes a streak system similar to Snapchat to encourage consistent practice."),
            FAQItem(
                question: "Can I manage my profile?",
                answer:
                    "Yes, users can update their information and change their passwords from the profile settings."),
            FAQItem(
                question: "Can I delete or deactivate my account?",
                answer:
                    "Yes, users can choose to either delete or deactivate their account through the account settings."),
            FAQItem(
                question: "Is Sam3ly free to use?",
                answer:
                    "Sam3ly offers a free version with essential features. Additional features may be available through in-app purchases or a premium subscription."),
          ],
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          backgroundColor: AppColors.card,
          title: Text(
            question,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                answer,
                style: GoogleFonts.poppins(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
