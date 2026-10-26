import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sam3ly/screens/Home.dart';
import 'package:sam3ly/Widgets/SignUp.dart';
import 'package:sam3ly/Widgets/Signin.dart';
import 'package:sam3ly/Widgets/Splash_Screen.dart';
import 'package:sam3ly/firebase_options.dart';
import 'package:sam3ly/providers/call_history_provider.dart';
import 'package:sam3ly/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('your-site-key'),
    androidProvider:
        AndroidProvider.playIntegrity, // Or AndroidProvider.safetyNet
    appleProvider: AppleProvider.deviceCheck,
  );
  // ReminderHelper.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CallHistoryProvider()),
        ChangeNotifierProvider(
            create: (_) => ThemeProvider()), // Add ThemeProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme:
              themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          // If a user is logged in and verified, check for the level field in Firestore
          home: (FirebaseAuth.instance.currentUser != null &&
                  FirebaseAuth.instance.currentUser!.emailVerified)
              ? FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    // While waiting for data, you can show a loading indicator or splash screen
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SplashScreen();
                    }
                    // If an error occurs or no data is available, fallback to the splash screen
                    if (snapshot.hasError || !snapshot.hasData) {
                      return SplashScreen();
                    }
                    // Once data is available, check the "level" field
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    if (userData["level"] != null &&
                        userData["level"] != "Test Your Level") {
                      return Home();
                    } else {
                      // If level is null, you can decide what to do.
                      // For example, you might want to redirect the user to a profile completion screen.
                      return SplashScreen();
                    }
                  },
                )
              : SplashScreen(),
          routes: {
            '/login': (context) => SignInScreen(),
            '/signup': (context) => SignUpScreen(),
            '/home': (context) => const Home(),
          },
        );
      },
    );
  }
}
