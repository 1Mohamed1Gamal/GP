import 'package:flutter/services.dart' show rootBundle;

class TxtLoader {
  static Future<List<String>> loadTxt(String filePath) async {
    try {
      // Load the file content from assets
      String fileContent = await rootBundle.loadString(filePath);

      // Split into lines and remove duplicates
      List<String> words = fileContent
          .split('\n') // Split by newline
          .map((word) => word.trim()) // Remove any extra spaces
          .where((word) => word.isNotEmpty) // Remove empty lines
          .toSet() // Remove duplicate words
          .toList();

      return words;
    } catch (e) {
      print("Error reading file: $e");
      return [];
    }
  }
}
