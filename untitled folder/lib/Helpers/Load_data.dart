import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseDataLoader {
  final String userId;
  List<Map<String, dynamic>> courses = [];

  CourseDataLoader({required this.userId});

  Future<void> loadUserCourses() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists && userDoc.data() != null) {
      courses = List<Map<String, dynamic>>.from(userDoc['courses']);
    }
  }

  Future<List<String>> loadCourseData(String courseTitle) async {
    var course = courses.firstWhere((course) => course['title'] == courseTitle,
        orElse: () => {});
    if (course.isEmpty) return [];

    int totalLessons = course['lessons'] ?? 30;
    int wordsCount = (totalLessons * 0.7).round();
    int sentencesCount = (totalLessons * 0.2).round();
    int paragraphsCount = (totalLessons * 0.1).round();

    List<String> words = await _loadCSV('assets/Data/$courseTitle/words.csv');
    List<String> sentences =
        await _loadCSV('assets/Data/$courseTitle/sentences.csv');
    List<String> paragraphs =
        await _loadCSV('assets/Data/$courseTitle/paragraphs.csv');

    return [
      ..._getRandomItems(words, wordsCount),
      ..._getRandomItems(sentences, sentencesCount),
      ..._getRandomItems(paragraphs, paragraphsCount),
    ];
  }

  Future<List<String>> _loadCSV(String path) async {
    try {
      final rawData = await rootBundle.loadString(path);
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(rawData);
      return csvTable.map((row) => row.join(',')).toList();
    } catch (e) {
      print("Error loading CSV from $path: $e");
      return [];
    }
  }

  List<String> _getRandomItems(List<String> list, int count) {
    if (list.length <= count) return list;
    list.shuffle(Random());
    return list.sublist(0, count);
  }
}
