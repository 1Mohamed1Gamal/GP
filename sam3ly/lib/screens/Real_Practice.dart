import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/Helpers/AudioRecorder.dart';

import 'package:sam3ly/Helpers/ManageText.dart';
import 'package:sam3ly/Helpers/Model_Api.dart';

class PracticePage extends StatefulWidget {
  final String typeOfData;
  final String typeOfPage;

  const PracticePage(
      {super.key, required this.typeOfData, required this.typeOfPage});

  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  List<String> dataList = [];
  bool showScore = false; // Hide score and feedback initially

  String currentText = "Loading...";
  String? definition;
  Map<String, String> coloredWords = {}; // Store word-color mapping
  List<String> pronunciation_categories = [];

  String? phonetic;
  final AudioPlayer audioPlayer = AudioPlayer();
  TextManager _textManager = TextManager();

  final String elevenLabsApiKey =
      "sk_c37f95ecab1d86e421a9473fa665c0ff7e0f7685c633c753"; // Replace with your API key
  final String voiceId = "pNInz6obpgDQGcFmaJgB";
  bool isLoadingDefinition = false; // Separate loading state for definition
  bool isLoadingPhonetic = false; // Separate loading state for phonetic
  String userLevel = 'Beginner';
  String feedbackMessage = "";
  String feedbackText = "";
  Color feedbackColor = Colors.transparent;
  final record = AudioRecorder();
  bool _isRecording = false;
  String? recordedFilePath;
  final AudioRecorderService _audioService = AudioRecorderService();
  final ModelApi model = const ModelApi();
  double? score = 0.0;
  @override
  void initState() {
    super.initState();
    loadUserLevel(); // Fetch the user's level from Firestore
  }

  Future<void> loadUserLevel() async {
    String level = await _textManager.loadULevel();

    setState(() {
      userLevel = level;
    });

    loadData(); // Call this after fetching the level
  }

  Future<void> loadData() async {
    List<String> data = [];
    if (widget.typeOfPage == "practice") {
      data = await _textManager.loadPracticeData(userLevel, widget.typeOfData);
    } else if (widget.typeOfPage == "topic") {
      data = await _textManager.loadTopicData(widget.typeOfData);
    }

    setState(() {
      dataList = data;
      currentText = _textManager.getRandomText(dataList);
    });
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

  void handleUpload() async {
    Map<String, dynamic>? responseData = await model.uploadAudio(
        currentText, recordedFilePath, _audioService.bytes);
    List<String> categories =
        List<String>.from(responseData?["pronunciation_categories"] ?? []);

    if (responseData != null) {
      double newScore = responseData["pronunciation_accuracy"];

      setState(() {
        score = newScore;
        showScore = true; // Show score only after upload
        pronunciation_categories = categories;

        // Get feedback message & color
        var feedback = _textManager.updateFeedback(newScore);
        feedbackMessage = feedback["message"];
        feedbackColor = feedback["color"];
        feedbackText = feedback["text"];

        coloredWords = _textManager.colorMistake(currentText, categories);
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          color: AppColors.icon,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Dynamic Header
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.typeOfData,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    visible: showScore, // Show score only when needed
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

              // Word/Sentence/Paragraph Display
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

              // Display phonetic for Words
              if (_textManager.isWord(currentText) && phonetic != null)
                Text(
                  phonetic!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.secondary,
                  ),
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
                  FloatingActionButton(
                    backgroundColor: AppColors.secondary,
                    onPressed: () {
                      setState(() {
                        phonetic = null;
                        definition = null;
                        currentText = _textManager.getRandomText(dataList);
                        isLoadingPhonetic = false;
                        _audioService.recordedFilePath = null;

                        showScore = false; // Hide score on refresh
                        score = 0.0;
                        feedbackMessage = "";
                        feedbackText = "";
                        feedbackColor = Colors.transparent;
                        coloredWords = {};
                      });
                    },
                    child: const Icon(Icons.refresh,
                        size: 36, color: AppColors.primary),
                  ),
                ],
              ),

              // Show Definition when Available
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
