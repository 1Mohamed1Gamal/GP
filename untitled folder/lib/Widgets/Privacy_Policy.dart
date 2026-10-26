import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam3ly/Helpers/AppColors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Privacy & Policy",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            PolicyItem(
              title: "Introduction",
              content:
                  "Sam3ly values your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data.",
            ),
            PolicyItem(
              title: "Information We Collect",
              content:
                  "When using Sam3ly, we may collect your email, username, phone number, country, and gender, along with usage and device data.",
            ),
            PolicyItem(
              title: "How We Use Your Information",
              content:
                  "We use your information to create and manage your account, provide pronunciation feedback, improve app features, and send important updates.",
            ),
            PolicyItem(
              title: "How We Protect Your Data",
              content:
                  "We implement security measures to safeguard your data from unauthorized access, loss, or misuse.",
            ),
            PolicyItem(
              title: "Sharing of Information",
              content:
                  "We do not sell or rent your personal data. However, we may share information with service providers assisting us in app operations or if required by law enforcement.",
            ),
            PolicyItem(
              title: "User Rights",
              content:
                  "You have the right to access, update, or delete your personal information and request data deletion or account deactivation.",
            ),
            PolicyItem(
              title: "Data Retention",
              content:
                  "We retain user data as long as the account is active. Deleted accounts will have their associated data removed permanently after a specific retention period.",
            ),
            PolicyItem(
              title: "Changes to This Privacy Policy",
              content:
                  "We may update this Privacy Policy from time to time. Users will be notified of significant changes.",
            ),
            PolicyItem(
              title: "Contact Us",
              content:
                  "For any questions about our Privacy Policy, contact us at support@sam3ly.com.",
            ),
          ],
        ),
      ),
    );
  }
}

class PolicyItem extends StatelessWidget {
  final String title;
  final String content;

  const PolicyItem({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          backgroundColor: AppColors.card,
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                content,
                style: GoogleFonts.poppins(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
