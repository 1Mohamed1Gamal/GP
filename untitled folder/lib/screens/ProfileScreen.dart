import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/Widgets/Account.dart';
import 'package:sam3ly/Widgets/Change_password.dart';
import 'package:sam3ly/Widgets/FAQ_Screen.dart';
import 'package:sam3ly/Widgets/Privacy_Policy.dart';
import 'package:sam3ly/Widgets/Update_Profile.dart';
import 'package:sam3ly/providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    }
    return null;
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!;
            String username = userData['username'] ?? "Unknown";
            String email = userData['email'] ?? "No email";

            return Column(
              children: [
                // Profile Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/sleep.png'),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Settings List
                Expanded(
                  child: ListView(
                    children: [
                      buildListTile("Account", context, AccountScreen()),
                      buildListTile(
                          "Email Settings", context, UpdateProfileScreen()),
                      buildListTile(
                          "Change Password", context, ChangePasswordScreen()),
                      buildListTile("FAQs", context, const FAQScreen()),
                      buildListTile("Privacy & Policy", context,
                          const PrivacyPolicyScreen()),

                      // Dark Mode Toggle inside the same page
                      SwitchListTile(
                        title: const Text(
                          'Dark Mode',
                          style: TextStyle(color: AppColors.text),
                        ),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        secondary: Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: themeProvider.isDarkMode
                              ? Colors.yellow
                              : AppColors.secondary,
                        ),
                        activeColor: AppColors.secondary,
                        inactiveTrackColor:
                            AppColors.secondary.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTapDown: (_) => _onButtonPress(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.button,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildListTile(String title, BuildContext context, Widget page) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: AppColors.text),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.icon),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  void _onButtonPress(BuildContext context) {
    _logout(context);
  }
}
