import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sam3ly/screens/Home.dart';
import 'package:sam3ly/Widgets/SignUp.dart';
import 'package:sam3ly/Widgets/forget_password.dart';
import 'package:sam3ly/Widgets/LevelPage.dart';
import 'package:sam3ly/Helpers/AppColors.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isLoginButtonPressed = false;
  bool _isSignUpPressed = false;
  bool _isForgotPasswordPressed = false;
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
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
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
      title: "Error",
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: AppColors.primary,
    ).show();
  }

  void _showSuccessDialog(String message, VoidCallback onOkPress) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
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
      title: "Success",
      desc: message,
      btnOkOnPress: onOkPress,
      btnOkColor: AppColors.primary,
    ).show();
  }

  void _signIn() async {
    setState(() {
      _isLoginButtonPressed = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _isLoginButtonPressed = false;
    });

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showErrorDialog('Please enter both email and password.');
      return;
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user!.emailVerified) {
        String userId = credential.user!.uid;
        DocumentSnapshot userDoc =
            await _firestore.collection("users").doc(userId).get();
        String? level = userDoc.exists ? (userDoc['level'] ?? 'null') : 'null';

        _showSuccessDialog("Login Successful!", () {
          if (level == 'null' || level == "Test Your Level") {
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
        });
      } else {
        _showErrorDialog('Please Verify Your Email');
      }
    } catch (e) {
      _showErrorDialog('Invalid Email OR Password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevents overflow when keyboard appears
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image above title
              Container(
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Soft corners
                  child: Image.asset(
                    "assets/images/welcome.png", // Adjust path accordingly
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              SizedBox(height: 5),
              SizedBox(height: 30),
              SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      icon: Icons.email,
                      hintText: "Email address",
                    ),
                    SizedBox(height: 15),
                    _buildPasswordField(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          backgroundColor: _isLoginButtonPressed
                              ? Colors.orange
                              : AppColors.button,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isForgotPasswordPressed = true;
                        });
                        Future.delayed(Duration(milliseconds: 500), () {
                          setState(() {
                            _isForgotPasswordPressed = false;
                          });
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                            color: _isForgotPasswordPressed
                                ? Colors.orange
                                : AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUpPressed = true;
                        });
                        Future.delayed(Duration(milliseconds: 500), () {
                          setState(() {
                            _isSignUpPressed = false;
                          });
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "New member? ",
                              style: TextStyle(color: AppColors.text),
                            ),
                            TextSpan(
                              text: "Sign up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isSignUpPressed
                                    ? Colors.orange
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          prefixIcon: Icon(icon, color: AppColors.secondary),
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.text.withOpacity(0.6)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          prefixIcon: Icon(Icons.lock, color: AppColors.secondary),
          hintText: "Password",
          hintStyle: TextStyle(color: AppColors.text.withOpacity(0.6)),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.secondary,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }
}
