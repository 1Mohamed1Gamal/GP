import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sam3ly/Helpers/AppColors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isButtonPressed = false; // Track button press state

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _resetPassword() async {
    setState(() => _isButtonPressed = true); // Change color when clicked

    if (_emailController.text.trim().isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
        AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.scale,
                dialogBackgroundColor: AppColors.background,
                titleTextStyle: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                descTextStyle: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 18,
                ),
                title: "Success",
                desc: "Password reset email has been sent!",
                btnOkOnPress: () {},
                btnOkColor: AppColors.primary)
            .show();
      } catch (e) {
        if (!isValidEmail(_emailController.text.trim())) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.leftSlide,
            dialogBackgroundColor: AppColors.background,
            titleTextStyle: TextStyle(
              color: AppColors.text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            descTextStyle: TextStyle(
              color: AppColors.secondary,
              fontSize: 18,
            ),
            title: "Invalid Email",
            desc: "Please enter a valid email format (example@mail.com).",
            btnOkOnPress: () {},
            btnOkColor: AppColors.primary,
          ).show();
          return;
        }
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.leftSlide,
          dialogBackgroundColor: AppColors.background,
          titleTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          descTextStyle: TextStyle(
            color: AppColors.secondary,
            fontSize: 18,
          ),
          title: 'ERROR 404',
          desc: "Something Wrong!",
          btnOkOnPress: () {},
          btnOkColor: AppColors.primary,
        ).show();
      }
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.leftSlide,
        dialogBackgroundColor: AppColors.background,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        descTextStyle: TextStyle(
          color: AppColors.secondary,
          fontSize: 18,
        ),
        title: "Incomplete Information",
        desc: "Please enter your email address to continue.",
        btnOkOnPress: () {},
        btnOkColor: AppColors.primary,
      ).show();
      return;
    }
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() => _isButtonPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Enter your email address",
                  style: TextStyle(
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: AppColors.secondary),
                      hintText: "Email address",
                      hintStyle:
                          TextStyle(color: AppColors.text.withOpacity(0.6)),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      backgroundColor:
                          _isButtonPressed ? Colors.orange : AppColors.button,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
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
}
