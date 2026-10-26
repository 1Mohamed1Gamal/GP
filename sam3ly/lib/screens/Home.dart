import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/Widgets/Complete_Course.dart';
import 'package:sam3ly/screens/Challenge_Screen.dart';
import 'package:sam3ly/screens/ProfileScreen.dart';
import 'package:sam3ly/Widgets/Progress.dart';
import 'package:sam3ly/Widgets/Speaking_Section.dart';
import 'package:sam3ly/screens/practice.dart';
import 'package:sam3ly/screens/call_screen.dart';

class MyAppp extends StatelessWidget {
  const MyAppp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _LanguageAppState();
}

class _LanguageAppState extends State<Home> {
  int _selectedIndex = 0;
  String username = '';

  final List<Widget> _pages = [
    const PracticeScreen(),
    const ChallengeScreen(),
    const CallScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _checkUserLoginStatus();
  }

  void _checkUserLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentReference userRef =
          FirebaseFirestore.instance.collection("users").doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      DateTime now = DateTime.now();
      int streakCount = 1;

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>? ?? {};
        DateTime? lastLoginDate;

        if (userData.containsKey('lastLoginDate') &&
            userData['lastLoginDate'] != null) {
          lastLoginDate = (userData['lastLoginDate'] as Timestamp).toDate();
        }

        streakCount = userData['streakCount'] ?? 1;

        if (lastLoginDate != null) {
          int differenceInHours = now.difference(lastLoginDate).inHours;
          if (differenceInHours >= 48) {
            streakCount = 1;
          } else if (differenceInHours >= 24 && differenceInHours < 48) {
            streakCount++;
          }
        }

        await userRef.set({
          'lastLoginDate': Timestamp.fromDate(now),
          'streakCount': streakCount,
        }, SetOptions(merge: true));
      } else {
        await userRef.set({
          'lastLoginDate': Timestamp.fromDate(now),
          'streakCount': streakCount,
        });
      }
    }
  }

  Future<void> _fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          username = userData['username'] ?? 'User';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(username: username, userId: userId),
          ..._pages,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.text,
        backgroundColor: AppColors.card,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/home.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/pencil.png')),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/target.png')),
            label: 'Challenge',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/phone.png')),
            label: 'Call',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/user.png')),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String username;
  final String userId;

  const HomePage({super.key, required this.username, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return _buildHeader(username, 0);
                  }
                  var userData =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  int streakCount = userData['streakCount'] ?? 0;

                  return _buildHeader(username, streakCount);
                },
              ),
              const SizedBox(height: 20),
              const SpeakingSection(),
              const SizedBox(height: 30),
              const ProgressView(),
              const SizedBox(height: 16),
              CompleteCourse(userId: userId),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String username, int streakCount) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              children: [
                const TextSpan(text: 'Hello, '),
                TextSpan(
                  text: username.isNotEmpty ? username : 'User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange, // لون مختلف لكلمة Boda
                  ),
                ),
                const TextSpan(text: '! 👋'),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  color: Colors.orange[700], size: 30),
              const SizedBox(width: 4),
              Text(
                '$streakCount',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
