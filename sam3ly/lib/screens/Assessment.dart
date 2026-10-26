import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/Helpers/AudioRecorder.dart';
import 'package:sam3ly/Helpers/ManageText.dart';
import 'package:sam3ly/Helpers/Model_Api.dart';
import 'package:sam3ly/screens/ResultPage.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<AssessmentPage> {
  List<String> dataList = [];
  bool showScore = false;
  String currentText = "Loading...";
  String? definition;
  Map<String, String> coloredWords = {};
  List<String> pronunciationCategories = [];
  String? phonetic;
  final AudioPlayer audioPlayer = AudioPlayer();
  TextManager _textManager = TextManager();
  final String elevenLabsApiKey =
      "sk_17324cd53c6790e51e208fb333a240fbc3ea8e7f1aa2c8ec";
  final String voiceId = "pNInz6obpgDQGcFmaJgB";
  bool isLoadingDefinition = false;
  bool isLoadingPhonetic = false;
  String feedbackMessage = "";
  String feedbackText = "";
  Color feedbackColor = Colors.transparent;
  final record = AudioRecorder();
  bool _isRecording = false;
  String? recordedFilePath;
  final AudioRecorderService _audioService = AudioRecorderService();
  final ModelApi model = const ModelApi();
  double? score = 0.0;
  double totalScore = 0.0;
  int currentIndex = 0; // علشان نعرف احنا ف انهي مرحلة
  int totalWords = 0; // عدد الكلمات الكلي

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    List<String> data = await _textManager.loadTestData();
    setState(() {
      dataList = data;
      totalWords = dataList.length;
      currentText = dataList.isNotEmpty ? dataList.first : "";
    });
    print("Loaded Data: $dataList");
    print("Total Words: $totalWords");
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

  double safeDivision(int numerator, int denominator) {
    return denominator == 0 ? 0.0 : numerator / denominator;
  }

  void handleUpload() async {
    Map<String, dynamic>? responseData = await model.uploadAudio(
        currentText, recordedFilePath, _audioService.bytes);
    if (responseData != null) {
      double newScore = responseData["pronunciation_accuracy"] ?? 0.0;
      if (newScore.isNaN) newScore = 0.0;
      List<String> categories =
          List<String>.from(responseData["pronunciation_categories"] ?? []);

      setState(() {
        score = newScore;
        showScore = true;
        totalScore += newScore;
        pronunciationCategories = categories;
        var feedback = _textManager.updateFeedback(newScore);
        feedbackMessage = feedback["message"];
        feedbackColor = feedback["color"];
        feedbackText = feedback["text"];
        coloredWords = _textManager.colorMistake(currentText, categories);
      });
      Future.delayed(const Duration(seconds: 2), () {
        moveToNextWord();
      });
    } else {
      print("Failed to get response.");
    }
  }

  void _stopRecording() {
    _audioService.stopRecording((String? path) {
      setState(() {
        _isRecording = false;
        recordedFilePath = path;
      });

      if (path != null) {
        handleUpload();
        print("Recording saved at: $path");
      }
    });
  }

  void moveToNextWord() {
    if (currentIndex < dataList.length - 1) {
      // Ensure it's within bounds
      setState(() {
        currentIndex++;
        currentText = dataList[currentIndex]; // Remove "+1" to stay in range
        showScore = false;
        score = 0.0;
        pronunciationCategories.clear();
        feedbackMessage = "";
        feedbackText = "";
        _audioService.recordedFilePath = null;
        phonetic = null;
        definition = null;
        feedbackColor = Colors.transparent;
        coloredWords.clear();
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            totalScore: totalScore,
            totalItems: _textManager.totalitems,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          color: AppColors.icon,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeInDown(
                child: Text(
                  "Your Level is Cooking...",
                  style: GoogleFonts.lobster(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.greenAccent,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              // Header
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
              ),

              const SizedBox(height: 20),

              // Feedback Section
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  const SizedBox(width: 10),
                  Visibility(
                    visible: showScore,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Score: $score",
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
              Column(
                children: [
                  LinearProgressIndicator(
                    value: safeDivision(currentIndex, totalWords),
                    backgroundColor: Colors.grey[800],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 10),

                  // Text Showing Progress
                  Text(
                    "Remaining ${currentIndex + 1} / $totalWords",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              // Display Text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: currentText.split(' ').map((word) {
                    return TextSpan(
                      text: "$word ",
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

              const SizedBox(height: 20),

              if (_textManager.isWord(currentText) && phonetic != null)
                Text(
                  phonetic!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.secondary,
                  ),
                ),

              const SizedBox(height: 20),

              // Action Buttons
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
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                      await _audioService.playRecording();
                    },
                  ),
                  if (_textManager.isWord(currentText))
                    IconButton(
                      color: AppColors.icon,
                      icon: const Icon(Icons.info_outline),
                      onPressed: isLoadingDefinition ? null : fetchDef,
                    ),
                  IconButton(
                    color: AppColors.icon,
                    icon: const Icon(Icons.phonelink_ring),
                    onPressed: isLoadingPhonetic ? null : fetchPhonetic,
                  ),
                ],
              ),

              if (definition != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Definition: $definition",
                    style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
