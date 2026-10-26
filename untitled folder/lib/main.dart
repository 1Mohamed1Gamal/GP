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
// ✅ Added Dynamic History
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
            home: (FirebaseAuth.instance.currentUser != null &&
                    FirebaseAuth.instance.currentUser!.emailVerified)
                ? Home()
                : SplashScreen(),
            routes: {
              '/login': (context) => SignInScreen(),
              '/signup': (context) => SignUpScreen(),
              '/home': (context) => const Home(),
            });
      },
    );
  }
}
