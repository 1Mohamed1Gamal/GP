import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/Widgets/Update_Profile.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? userData;
  Color _editButtonColor = AppColors.primary; // Default button color
  Stream<DocumentSnapshot>? userStream;

  @override
  void initState() {
    super.initState();
    listenToUserData();
  }

  /// Listens for real-time updates from Firestore
  void listenToUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();

      userStream!.listen((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          setState(() {
            userData = snapshot.data() as Map<String, dynamic>;
          });
        }
      });
    }
  }

  void _onEditButtonPress(BuildContext context) {
    setState(() {
      _editButtonColor = Colors.orange; // Change color to orange
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _editButtonColor = AppColors.primary; // Reset color after delay
      });

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              UpdateProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: userData == null
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.person,
                              size: 50, color: AppColors.text),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(),
                      const SizedBox(height: 20),

                      // Edit Profile Button
                      Center(
                        child: GestureDetector(
                          onTap: () => _onEditButtonPress(context),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            decoration: BoxDecoration(
                              color: _editButtonColor, // Dynamic button color
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.edit, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.background,
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.person, "Username", userData!["username"]),
          _infoRow(Icons.email, "Email", userData!["email"]),
          _infoRow(Icons.phone, "Phone", userData!["phone"]),
          _infoRow(Icons.cake, "Date of Birth", userData!["date_of_birth"]),
          _infoRow(Icons.person, "Gender", userData!["gender"]),
          _infoRow(Icons.emoji_flags, "Country", userData!["country"]),
          _infoRow(Icons.star, "Level", userData!["level"]),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Text("$title: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.text)),
          Expanded(
              child: Text(value, style: TextStyle(color: AppColors.secondary))),
        ],
      ),
    );
  }
}
