import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Load the theme from Firestore
  _loadTheme() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String mode = userDoc['Mode'] ?? 'light';
        _isDarkMode = (mode == 'dark');
        notifyListeners();
      }
    }
  }

  // Toggle theme and save it to Firestore
  toggleTheme() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newMode = _isDarkMode ? 'light' : 'dark';
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({'Mode': newMode});

      _isDarkMode = !_isDarkMode;
      notifyListeners();
    }
  }
}
