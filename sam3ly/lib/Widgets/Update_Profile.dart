import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sam3ly/Helpers/AppColors.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  String? _selectedCountry;
  DateTime? _selectedDateOfBirth;
  bool _isUpdating = false; // Track the update process

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

  void _updateProfile() async {
    setState(() {
      _isUpdating = true; // Change background color
    });
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(_usernameController.text.trim());

        await _firestore.collection("users").doc(user.uid).update({
          'username': _usernameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'gender': _selectedGender,
          'country': _selectedCountry,
          'date_of_birth':
              DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!),
        });
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
          title: 'Success!',
          desc: 'Profile updated successfully!',
          btnOkOnPress: () {},
          btnOkColor: AppColors.primary,
        ).show();
      } catch (e) {
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
          title: 'Error!',
          desc: 'Error updating profile: ${e.toString()}',
          btnOkOnPress: () {},
          btnOkColor: AppColors.primary,
        ).show();
      } finally {
        setState(() {
          _isUpdating = false; // Reset background color
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _usernameController.text = userData['username'];
          _emailController.text = userData['email'];
          _phoneController.text = userData['phone'];
          _selectedGender = userData['gender'];
          _selectedCountry = userData['country'];
          _selectedDateOfBirth =
              DateFormat('yyyy-MM-dd').parse(userData['date_of_birth']);
        });
      }
    }
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
              primary: AppColors.secondary,
              onPrimary: AppColors.text,
              surface: AppColors.background,
              onSurface: AppColors.text,
            ),
            dialogBackgroundColor: AppColors.background,
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: enabled ? AppColors.card : AppColors.card.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: AppColors.secondary),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                hint: Text(label, style: TextStyle(color: AppColors.secondary)),
                items: items
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item,
                              style: TextStyle(color: AppColors.text)),
                        ))
                    .toList(),
                onChanged: onChanged,
                dropdownColor: AppColors.card,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Email Settings', style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Update Your Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(
                  label: 'Username',
                  icon: Icons.person,
                  controller: _usernameController),
              _buildTextField(
                  label: 'Email',
                  icon: Icons.email,
                  controller: _emailController,
                  enabled: false),
              _buildTextField(
                  label: 'Phone Number',
                  icon: Icons.phone,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone),
              _buildDropdown(
                  label: 'Gender',
                  icon: Icons.person_outline,
                  items: ['Male', 'Female'],
                  selectedValue: _selectedGender,
                  onChanged: (value) =>
                      setState(() => _selectedGender = value)),
              _buildDropdown(
                  label: 'Country',
                  icon: Icons.public,
                  items: countries,
                  selectedValue: _selectedCountry,
                  onChanged: (value) =>
                      setState(() => _selectedCountry = value)),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text(
                        _selectedDateOfBirth == null
                            ? 'Date of Birth'
                            : DateFormat('yyyy-MM-dd')
                                .format(_selectedDateOfBirth!),
                        style: TextStyle(
                            color: _selectedDateOfBirth == null
                                ? AppColors.text
                                : AppColors.text),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isUpdating ? Colors.orange : AppColors.primary),
                child: Text('Update',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
