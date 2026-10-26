import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/Helpers/LoadTxt.dart';

class TextManager {
  int totalitems = 0;

  TextManager();

  bool isWord(String text) {
    return text.trim().split(" ").length == 1;
  }

  String getRandomText(List<String> dataList) {
    if (dataList.isEmpty) {
      return "No Data Available";
    }
    return dataList[Random().nextInt(dataList.length)];
  }

  Future<void> fetchAndPlayAudio(
      String text, String api_key, String voice_id) async {
    final AudioPlayer audioPlayer = AudioPlayer();

    if (text.isEmpty) return;

    final url =
        Uri.parse("https://api.elevenlabs.io/v1/text-to-speech/$voice_id");
    final response = await http.post(
      url,
      headers: {
        "Accept": "audio/mpeg",
        "Content-Type": "application/json",
        "xi-api-key": api_key,
      },
      body: jsonEncode({
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {"stability": 0.5, "similarity_boost": 0.5}
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/speech.mp3';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Play the local audio file
      await audioPlayer.play(DeviceFileSource(filePath));
    } else {
      print("Error: ${response.statusCode}, ${response.body}");
    }
  }

  Future<String> fetchDefinition(String word) async {
    final response = await http.get(
        Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/$word"));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      print("success==============================================");
      return jsonResponse[0]["meanings"][0]["definitions"][0]["definition"];
    } else {
      return "Definition not found.";
    }
  }

  Future<String> fetchPhonetic(String word) async {
    final response = await http.get(
        Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/$word"));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      // Extracting the first phonetic text from the phonetics list
      String phoneticText = '';
      if (jsonResponse.isNotEmpty &&
          jsonResponse[0]['phonetics'] != null &&
          jsonResponse[0]['phonetics'].isNotEmpty) {
        // Check if there is more than one phonetic entry and select the appropriate one
        if (jsonResponse[0]['phonetics'].length > 1) {
          phoneticText = jsonResponse[0]['phonetics'][1]['text'] ?? '';
        } else {
          phoneticText = jsonResponse[0]['phonetics'][0]['text'] ?? '';
        }
      }

      return phoneticText.isNotEmpty ? phoneticText : "Phonetic not found.";
    } else {
      return "Phonetic not found.";
    }
  }

  Future<List<String>> loadTopicData(String typeOfData) async {
    String path = "assets/Data/Topics/${typeOfData.toLowerCase()}.txt";
    return await TxtLoader.loadTxt(path);
  }

  Future<List<String>> loadPracticeData(
      String userLevel, String typeOfData) async {
    try {
      String path = "assets/Data/$userLevel/${typeOfData.toLowerCase()}.csv";
      String csvString = await rootBundle.loadString(path);
      return csvString.split("\n").map((line) => line.trim()).toList();
    } catch (e) {
      print("Error loading data file: $e");
      return [];
    }
  }

  Future<String> loadULevel() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'Beginner'; // Default to Beginner if not authenticated
    }

    final userId = user.uid;

    // Fetch user level from Firestore
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      return userDoc['level'] ?? 'Beginner';
    } else {
      return 'Beginner';
    }
  }

  Map<String, dynamic> updateFeedback(double score) {
    String message;
    String text;
    Color color;

    if (score >= 70) {
      message = "Success";
      text = "Congratulations! Your score is $score%.";
      color = Colors.green;
    } else {
      text = "but that's okay, let's try again";
      message = "Wrong!";
      color = Colors.red;
    }

    return {"message": message, "color": color, "text": text};
  }

  Map<String, String> colorMistake(
      String currentText, List<String> categories) {
    List<String> words = currentText.split(' '); // Split text into words
    Map<String, String> result = {};

    for (int i = 0; i < words.length; i++) {
      String word = words[i];

      if (i < categories.length) {
        if (categories[i] == "0") {
          result[word] = "green";
        } else if (categories[i] == "1") {
          result[word] = "orange";
        } else if (categories[i] == "2") {
          result[word] = "red";
        }
      } else {
        result[word] = "black"; // Default if no category is provided
      }
    }

    return result;
  }

  Color getColor(String color) {
    switch (color) {
      case "green":
        return Colors.green;
      case "orange":
        return Colors.orange;
      case "red":
        return Colors.red;
      default:
        return AppColors.text;
    }
  }

  Future<List<String>> loadTestData() async {
    List<String> finalData = [];

    List<String> levels = ["Beginner", "Intermediate", "Fluent", "Native"];
    List<int> wordsCount = [5, 5, 5, 5];
    List<int> sentencesCount = [3, 3, 3, 3];
    List<int> paragraphsCount = [2, 2, 2, 2];

    for (int i = 0; i < levels.length; i++) {
      String level = levels[i];

      List<String> words = await _loadCSV('assets/Data/$level/words.csv');
      List<String> sentences =
          await _loadCSV('assets/Data/$level/sentences.csv');
      List<String> paragraphs =
          await _loadCSV('assets/Data/$level/paragraphs.csv');

      finalData.addAll(_getRandomItems(words, wordsCount[i]));
      finalData.addAll(_getRandomItems(sentences, sentencesCount[i]));
      finalData.addAll(_getRandomItems(paragraphs, paragraphsCount[i]));
    }
    totalitems = finalData.length;
    return finalData;
  }

  Future<List<String>> _loadCSV(String path) async {
    try {
      String csvString = await rootBundle.loadString(path);
      print(
          "csvString===================================================:$csvString");
      return csvString.split("\n").map((line) => line.trim()).toList();
    } catch (e) {
      print("Error loading CSV file: $e");
      return [];
    }
  }

  List<String> _getRandomItems(List<String> list, int count) {
    print("List=========================================: $list");
    list.shuffle();
    int safeCount = count > list.length ? list.length : count;
    return list.take(safeCount).toList();
  }
}
