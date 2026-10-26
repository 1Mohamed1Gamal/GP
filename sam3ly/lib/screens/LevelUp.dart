import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:record/record.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/Helpers/AudioRecorder.dart';
import 'package:sam3ly/Helpers/IP_manager.dart';
import 'package:sam3ly/Helpers/Load_data.dart';
import 'package:sam3ly/Helpers/ManageText.dart';
import 'package:sam3ly/Helpers/Model_Api.dart';

class LevelUpPage extends StatefulWidget {
  final String levelTitle;
  final int levelIndex;

  const LevelUpPage(
      {super.key, required this.levelTitle, required this.levelIndex});

  @override
  _LevelUpPageState createState() => _LevelUpPageState();
}

class _LevelUpPageState extends State<LevelUpPage> {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  String userLevel = "Beginner";
  double score = 0.0;
  List<dynamic> courseData = [];
  Map<String, String> coloredWords = {}; // Store word-color mapping

  List<String> pronunciation_categories = [];
  String currentText = "Loading...";
  String? definition;
  bool showScore = false; // Hide score and feedback initially

  String feedbackMessage = "";
  String feedbackText = "";
  Color feedbackColor = Colors.transparent;
  final String elevenLabsApiKey =
      "sk_c37f95ecab1d86e421a9473fa665c0ff7e0f7685c633c753"; // Replace with your API key
  final String voiceId =
      "XB0fDUnXU5powFXDhCwa"; // Choose a voice from ElevenLabs
  final AudioPlayer audioPlayer = AudioPlayer();
  String? phonetic;
  bool isLoadingDefinition = false;
  bool isLoadingPhonetic = false;
  TextManager _textManager = TextManager();

  final List<String> levels = ['Beginner', 'Intermediate', 'Fluent', 'Native'];
  double progress = 0.0; // Course progress value
  int totalLessons = 0; // Total lessons in the course
  int completedLessons = 0; // Number of completed lessons
  final record = AudioRecorder();
  bool _isRecording = false;
  String? recordedFilePath;
  IPManager ipmanager = IPManager();
  final AudioRecorderService _audioService = AudioRecorderService();
  final ModelApi model = const ModelApi();
  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _startRecording() {
    _audioService.startRecording(() {
      setState(() {
        _isRecording = true;
        recordedFilePath = _audioService.recordedFilePath;
      });
    });
  }

  // Function to change the word
  void changeWord(double scoree) {
    if (scoree >= 70) {
      // Show the score and feedback for a moment before changing the word
      setState(() {
        showScore = true;
        score = scoree.toDouble();
        feedbackMessage = "Great job!";
        feedbackText = "You got it right!";
        feedbackColor = Colors.green;
      });

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          phonetic = null;
          definition = null;
          currentText = getRandomCourseData();
          isLoadingPhonetic = false;
          _audioService.recordedFilePath = null;
          showScore = false; // Hide score when changing the word
          score = 0.0;
          feedbackMessage = "";
          feedbackText = "";
          feedbackColor = Colors.transparent;
          coloredWords = {};
        });
      });
    } else {
      setState(() {
        phonetic = null;
        definition = null;
        currentText = getRandomCourseData();
        isLoadingPhonetic = false;
        showScore = false; // Hide score when changing the word
        score = 0.0;
        feedbackMessage = "";
        feedbackText = "";
        feedbackColor = Colors.transparent;
        coloredWords = {};
      });
    }
  }

  void handleUpload() async {
    Map<String, dynamic>? responseData = await model.uploadAudio(
        currentText, recordedFilePath, _audioService.bytes);
    List<String> categories =
        List<String>.from(responseData?["pronunciation_categories"] ?? []);

    if (responseData != null) {
      double newScore = responseData["pronunciation_accuracy"];

      setState(() {
        if (newScore > 0) {
          score = newScore;
        }
        showScore = true; // Show score only after upload
        pronunciation_categories = categories;

        // Get feedback message & color
        var feedback = _textManager.updateFeedback(newScore);
        feedbackMessage = feedback["message"];
        feedbackColor = feedback["color"];
        feedbackText = feedback["text"];

        coloredWords = _textManager.colorMistake(currentText, categories);
        if (newScore >= 70) {
          updateProgress();
          changeWord(score);
        }
      });
    } else {
      print("Failed to get response.");
    }
  }

  void updateProgress() async {
    if (userId.isEmpty) return;

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;
      double newProgress = 0.0;

      List<dynamic> courses = userDoc['courses'] ?? [];
      var course = courses.firstWhere(
          (course) => course['title'] == widget.levelTitle,
          orElse: () => null);

      if (course != null) {
        int completedCourses = (course['completedCourses'] is int)
            ? course['completedCourses']
            : 0;
        int totalLessons = (course['lessons'] is int) ? course['lessons'] : 30;
        if (completedCourses < 30) {
          completedCourses++;
          newProgress = completedCourses / totalLessons;
        }

        transaction.update(userRef, {
          'courses': courses.map((c) {
            if (c['title'] == widget.levelTitle) {
              return {
                ...c,
                'completedCourses': completedCourses,
                'progress': newProgress,
              };
            }
            return c;
          }).toList()
        });

        // **Update UI Progress Bar**
        setState(() {
          completedLessons = completedCourses;
          progress = newProgress;
        });

        if (completedCourses >= 30) {
          int currentLevelIndex = levels.indexOf(widget.levelTitle);
          if (currentLevelIndex < levels.length - 1) {
            String newLevel = levels[currentLevelIndex + 1];
            transaction.update(userRef, {'level': newLevel});

            setState(() {
              userLevel = newLevel;
            });
          }
        }
      }
    });
  }

  void _stopRecording() {
    _audioService.stopRecording((String? path) {
      setState(() {
        _isRecording = false;
        recordedFilePath = path;
      });

      if (path != null) {
        handleUpload();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    if (userId.isEmpty) return;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      setState(() {
        userLevel = userDoc['level'] ?? 'null';
        courseData = userDoc['courses'] ?? [];
      });
    }

    var course = courseData.firstWhere(
        (course) => course['title'] == widget.levelTitle,
        orElse: () => null);

    if (course != null) {
      setState(() {
        totalLessons = (course['lessons'] is int)
            ? course['lessons']
            : 30; // ✅ Ensure totalLessons is an int
        completedLessons = (course['completedCourses'] is int)
            ? course['completedCourses']
            : 0; // ✅ Ensure completedLessons is an int

        // ✅ Prevent division by zero
        progress = totalLessons > 0 ? (completedLessons / totalLessons) : 0.0;
      });
    }

    CourseDataLoader dataLoader = CourseDataLoader(userId: userId);
    await dataLoader.loadUserCourses();
    List<String> loadedData =
        await dataLoader.loadCourseData(widget.levelTitle);

    setState(() {
      courseData = loadedData;
      currentText = getRandomCourseData();
    });
  }

  String getRandomCourseData() {
    if (courseData.isEmpty) return "No Data";
    return courseData[Random().nextInt(courseData.length)];
  }

  Future<void> fetchDef() async {
    setState(() {
      isLoadingDefinition = true;
    });

    definition = await _textManager.fetchDefinition(currentText);

    setState(() {
      isLoadingDefinition = false;
    });
  }

  Future<void> fetchPhonetic() async {
    setState(() {
      isLoadingPhonetic = true;
    });

    phonetic = await _textManager.fetchPhonetic(currentText);

    setState(() {
      isLoadingPhonetic = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int userLevelIndex =
        ['Beginner', 'Intermediate', 'Fluent', 'Native'].indexOf(userLevel);
    // bool isUnlocked = widget.levelIndex <= userLevelIndex;

    // Determine next level
    int nextLevelIndex = widget.levelIndex + 1;
    bool hasNextLevel = nextLevelIndex < levels.length;
    String nextLevelTitle = hasNextLevel ? levels[nextLevelIndex] : "";
    bool isNextLevelUnlocked = hasNextLevel && nextLevelIndex <= userLevelIndex;

    // Progress Bar from current course to next course
    double progressBarValue = 0.0;
    if (totalLessons > 0) {
      progressBarValue = completedLessons / totalLessons; // Calculate progress
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          color: AppColors.text,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(10),
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.secondary,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  right: 40), // Add padding to prevent overflow
              child: Stack(
                // alignment: Alignment.topLeft,
                clipBehavior: Clip.none,
                children: [
                  // Next Level
                  if (hasNextLevel)
                    Positioned(
                      right: -40, // Adjust position relative to current level
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        width: 200, // Reduced width
                        height: 50,
                        decoration: BoxDecoration(
                          color: isNextLevelUnlocked
                              ? AppColors.secondary
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                nextLevelTitle,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 16, // Slightly smaller font
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Icon(
                              isNextLevelUnlocked
                                  ? Icons.lock_open
                                  : Icons.lock,
                              color: isNextLevelUnlocked
                                  ? AppColors.primary
                                  : AppColors.text.withOpacity(0.5),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Current Level
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.levelTitle,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: 10),
                Visibility(
                  visible: showScore, // Show score only when needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Score:$score",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        feedbackMessage,
                        style: TextStyle(
                          color: feedbackColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        feedbackText.isNotEmpty ? feedbackText : "",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Display text dynamically
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: currentText.split(' ').map((word) {
                  return TextSpan(
                    text: "$word ", // Ensure spacing between words
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: coloredWords[word] != null
                          ? _textManager.getColor(coloredWords[word]!)
                          : AppColors.text,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Display phonetic if word
            if (_textManager.isWord(currentText) && phonetic != null)
              Text(
                phonetic!,
                style:
                    const TextStyle(fontSize: 18, color: AppColors.secondary),
              ),

            const SizedBox(height: 20),

            // Action Buttons (Speaker, Snail, Info)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  color: AppColors.icon,
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    _textManager.fetchAndPlayAudio(
                        currentText, elevenLabsApiKey, voiceId);
                  },
                ),
                IconButton(
                  color: AppColors.icon,
                  icon: const Icon(Icons.play_arrow), // Play Recording Icon
                  onPressed: () async {
                    await _audioService
                        .playRecording(); // Play the recorded audio
                  },
                ),
                if (_textManager.isWord(currentText))
                  IconButton(
                    color: AppColors.icon,
                    icon: const Icon(Icons.info_outline), // Info Icon
                    onPressed: isLoadingDefinition ? null : fetchDef,
                  ),
                IconButton(
                  color: AppColors.icon,
                  icon: const Icon(Icons.phonelink_ring), // Phonetic Icon
                  onPressed: isLoadingPhonetic ? null : fetchPhonetic,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Display Definition if available
            if (definition != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Definition: $definition",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                if (_isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
              child: Icon(
                Icons.mic,
                size: 36,
                color: _isRecording ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
