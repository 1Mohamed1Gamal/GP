import 'package:flutter/material.dart';
import 'package:email_auth/email_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/Home.dart';
import 'LevelPage.dart';

class OTPPage extends StatefulWidget {
  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController _otpController = TextEditingController();
  late EmailAuth emailAuth;
  String? userEmail;
  bool isOtpSent = false;

  @override
  void initState() {
    super.initState();
    emailAuth = EmailAuth(sessionName: "OTP Verification");
    _fetchUserEmail();
  }

  // Fetch user email from Firestore
  Future<void> _fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userEmail = userDoc["email"];
        });
      }
    }
  }

  // Send OTP
  void _sendOTP() async {
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Email not found")),
      );
      return;
    }

    bool res = await emailAuth.sendOtp(
      recipientMail: userEmail!,
      otpLength: 6,
    );

    if (res) {
      setState(() {
        isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Sent to $userEmail")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send OTP")),
      );
    }
  }

  // Verify OTP
  void _verifyOTP() async {
    if (userEmail == null) return;

    bool isValid = emailAuth.validateOtp(
      recipientMail: userEmail!,
      userOtp: _otpController.text.trim(),
    );

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verified!")),
      );

      _navigateBasedOnLevel();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP! Try again.")),
      );
    }
  }

  // Navigate based on user level
  Future<void> _navigateBasedOnLevel() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();

    String? level = userDoc.exists ? (userDoc['level'] ?? 'null') : 'null';

    if (level == 'null') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LevelPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Verification"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the OTP sent to your email",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: "Enter OTP",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isOtpSent ? _verifyOTP : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Verify OTP", style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _sendOTP,
              child: Text("Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
