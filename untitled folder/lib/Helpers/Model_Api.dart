import 'dart:convert';

import 'package:sam3ly/Helpers/IP_manager.dart';
import 'package:http/http.dart' as http;

class ModelApi {
  const ModelApi();

  Future<Map<String, dynamic>?> uploadAudio(
      String text, String? filepath, String? bytes) async {
    IPManager ipManager = IPManager();
    String ip =
        await ipManager.getDeviceIP(); // Await the IP address resolution

    try {
      var url = Uri.parse(
          "http://${ip}:8000/upload"); // No query params, use JSON body

      var response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json", // ✅ Required for JSON request
        },
        body: jsonEncode({
          // ✅ Sending JSON payload
          "file_name": filepath,
          "real_text": text,
          "bytes": bytes,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("Response: ${response.body}");
        return jsonResponse; // ✅ Return full JSON response
      } else {
        print(
            "Failed with status: ${response.statusCode}, body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> freeSpeech(String? bytes) async {
    IPManager ipManager = IPManager();
    String ip =
        await ipManager.getDeviceIP(); // Await the IP address resolution

    try {
      var url = Uri.parse(
          "http://${ip}:8000/freeSpeech"); // No query params, use JSON body

      var response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json", // ✅ Required for JSON request
        },
        body: jsonEncode({
          // ✅ Sending JSON payload
          "bytes": bytes,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("Response: ${response.body}");
        return jsonResponse; // ✅ Return full JSON response
      } else {
        print(
            "Failed with status: ${response.statusCode}, body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
