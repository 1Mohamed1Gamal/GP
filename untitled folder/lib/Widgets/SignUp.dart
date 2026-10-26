import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sam3ly/Widgets/Signin.dart';
import 'package:sam3ly/Helpers/AppColors.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedGender;
  String? _selectedCountry;
  DateTime? _selectedDateOfBirth;
  bool _isPasswordVisible = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> countries = [
    'Egypt',
    'USA',
    'UK',
    'Canada',
    'Germany',
    'France',
    'India',
    'China'
  ];
  final List<Map<String, dynamic>> courses = [
    {
      'level': 0,
      'title': 'Beginner',
      'lessons': 30,
      'progress': 0.0,
      'completedCourses': 0.0,
      'avatar': 'assets/images/beginnerlevel.png',
    },
    {
      'level': 1,
      'title': 'Intermediate',
      'lessons': 30,
      'progress': 0.0,
      'completedCourses': 0.0,
      'avatar': 'assets/images/intermediatelevel.png',
    },
    {
      'level': 2,
      'title': 'Fluent',
      'lessons': 30,
      'progress': 0.0,
      'completedCourses': 0.0,
      'avatar': 'assets/images/fluentlevel.png',
    },
    {
      'level': 3,
      'title': 'Native',
      'lessons': 30,
      'progress': 0.0,
      'completedCourses': 0.0,
      'avatar': 'assets/images/nativelevel.png',
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.secondary, // Header color
              onPrimary: AppColors.text, // Text color on header
              surface: AppColors.background, // Background color of dialog
              onSurface: AppColors.text, // Text color on surface
            ),
            dialogBackgroundColor:
                AppColors.background, // Background color of dialog
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
      });
    }
  }

  void _signUp() async {
    if (_usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedCountry == null ||
        _selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(_usernameController.text.trim());
        await user.sendEmailVerification();

        Map<String, dynamic> userData = {
          'id': user.uid,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'level': 'null',
          'courses': courses,
          'gender': _selectedGender,
          'phone': _phoneController.text.trim(),
          'country': _selectedCountry,
          'date_of_birth':
              DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!),
          'Mode': 'light'
        };

        await _firestore.collection("users").doc(user.uid).set(userData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up successful!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = e.message ?? "Something went wrong.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildInputBox({required Widget child}) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.icon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sign up",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text)),
                    SizedBox(height: 5),
                    Text("Create an account here",
                        style: TextStyle(color: AppColors.secondary)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildInputBox(
              child: TextField(
                controller: _usernameController,
                style:
                    TextStyle(color: AppColors.text), // Text color when typing
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: AppColors.secondary),
                  hintText: "Username",
                  hintStyle: TextStyle(
                      color: AppColors.text.withOpacity(0.6)), // Hint color
                  border: InputBorder.none,
                ),
              ),
            ),
            _buildInputBox(
              child: TextField(
                controller: _emailController,
                style: TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: AppColors.secondary),
                  hintText: "Email address",
                  hintStyle: TextStyle(color: AppColors.text.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
              ),
            ),
            _buildInputBox(
              child: TextField(
                controller: _passwordController,
                style: TextStyle(color: AppColors.text),
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: AppColors.secondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.secondary),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  hintText: "Password",
                  hintStyle: TextStyle(color: AppColors.text.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
              ),
            ),
            _buildInputBox(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: AppColors.secondary),
                  hintText: "Phone Number",
                  hintStyle: TextStyle(color: AppColors.text.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
              ),
            ),
            _buildInputBox(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.person_outline, color: AppColors.secondary),
                  border: InputBorder.none,
                ),
                hint: Text(
                  "Select Gender",
                  style: TextStyle(color: AppColors.text), // Force white color
                ),
                dropdownColor:
                    AppColors.background, // Dropdown background color
                items: ["Male", "Female"]
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(
                            gender,
                            style: TextStyle(
                                color: AppColors
                                    .text), // Dropdown items text color
                          ),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
            ),
            _buildInputBox(
              child: DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.flag, color: AppColors.secondary),
                  border: InputBorder.none,
                ),
                hint: Text(
                  "Select Country",
                  style: TextStyle(color: AppColors.text), // Force white color
                ),
                dropdownColor:
                    AppColors.background, // Set dropdown background color
                items: countries
                    .map((country) => DropdownMenuItem(
                          value: country,
                          child: Text(
                            country,
                            style: TextStyle(
                                color: AppColors.text), // Country text color
                          ),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCountry = value),
              ),
            ),
            _buildInputBox(
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: AppColors.secondary),
                title: Text(
                  _selectedDateOfBirth == null
                      ? "Select Date of Birth"
                      : DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!),
                  style: TextStyle(
                    color: _selectedDateOfBirth == null
                        ? AppColors.text
                        : Colors.white,
                  ),
                ),
                onTap: _pickDate,
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignInScreen())),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: "Already a member? ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.text)),
                      TextSpan(
                          text: "Sign In",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Sign Up",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
