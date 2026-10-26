// import 'package:flutter/services.dart';
// import 'package:csv/csv.dart';

// class CSVLoader {
//   static Future<List<String>> loadCSV(String path) async {
//     final rawData = await rootBundle.loadString(path);
//     List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
//     return csvTable.map((row) => row[0].toString()).toList();
//   }
// }
