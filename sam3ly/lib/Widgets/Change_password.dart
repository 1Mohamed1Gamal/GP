import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isButtonPressed = false; // Track button press

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool isPasswordValid(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  Future<void> _changePassword() async {
    // Explicitly return Future<void>
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String email = user.email!;
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: _oldPasswordController.text.trim(),
        );

        await user.reauthenticateWithCredential(credential);

        String newPassword = _newPasswordController.text.trim();
        String confirmPassword = _confirmPasswordController.text.trim();

        if (newPassword != confirmPassword) {
          _showDialog(
              DialogType.warning, "Warning!", "New passwords do not match!");
          return;
        }

        if (!isPasswordValid(newPassword)) {
          _showDialog(DialogType.warning, "Weak Password",
              "Your password must be at least 8 characters long and include an uppercase letter, lowercase letter, number, and special character.");
          return;
        }

        await user.updatePassword(newPassword);
        _showDialog(
            DialogType.success, "Success!", "Password changed successfully!",
            popOnOk: true);
      } catch (e) {
        _showDialog(
            DialogType.error, "Error!", "Current Password is incorrect!");
      }
    }
  }

  void _showDialog(DialogType type, String title, String desc,
      {bool popOnOk = false}) {
    AwesomeDialog(
      context: context,
      dialogType: type, // ✅ Now correctly assigned
      animType: AnimType.scale,
      dialogBackgroundColor: AppColors.background,
      titleTextStyle: TextStyle(
          color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold),
      descTextStyle: TextStyle(color: AppColors.secondary, fontSize: 18),
      title: title,
      desc: desc,
      btnOkOnPress: popOnOk ? () => Navigator.pop(context) : () {},
      btnOkColor: AppColors.primary,
    ).show();
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback toggleVisibility,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: !isVisible,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: AppColors.secondary, fontSize: 14),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.icon,
              ),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Change Password',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPasswordField(
              label: 'Current Password',
              controller: _oldPasswordController,
              isVisible: _isOldPasswordVisible,
              toggleVisibility: () {
                setState(() {
                  _isOldPasswordVisible = !_isOldPasswordVisible;
                });
              },
            ),
            SizedBox(height: 12),
            _buildPasswordField(
              label: 'New Password',
              controller: _newPasswordController,
              isVisible: _isNewPasswordVisible,
              toggleVisibility: () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              },
            ),
            SizedBox(height: 12),
            _buildPasswordField(
              label: 'Confirm New Password',
              controller: _confirmPasswordController,
              isVisible: _isConfirmPasswordVisible,
              toggleVisibility: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            SizedBox(height: 18),
            GestureDetector(
              onTap: _isButtonPressed
                  ? null
                  : () async {
                      setState(() {
                        _isButtonPressed =
                            true; // Change button color when clicked
                      });

                      await _changePassword(); // ✅ Now properly awaited

                      setState(() {
                        _isButtonPressed =
                            false; // Reset button color after operation
                      });
                    },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                decoration: BoxDecoration(
                  color: _isButtonPressed
                      ? Colors.orange
                      : AppColors.primary, // Dynamic color
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Update Password',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
