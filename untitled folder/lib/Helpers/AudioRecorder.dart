import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  final record = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  String bytes = '';

  bool _isRecording = false;
  String? recordedFilePath;

  Future<void> startRecording(VoidCallback onRecordingStarted) async {
    try {
      if (await record.hasPermission()) {
        // Get app's documents directory (no need for storage permission)
        final directory = await getApplicationDocumentsDirectory();
        final savePath = "${directory.path}/recordings";

        // Ensure the directory exists
        final newDirectory = Directory(savePath);
        if (!newDirectory.existsSync()) {
          newDirectory.createSync(recursive: true);
        }

        // Define the file path
        String filePath = "$savePath/new.ogg";

        // Start recording
        await record.start(
          const RecordConfig(
            encoder: AudioEncoder.opus, // OGG format
          ),
          path: filePath,
        );

        print("Recording started. Saving at: $filePath");

        _isRecording = true;
        recordedFilePath = filePath;
        onRecordingStarted();
      } else {
        print("Recording permission not granted.");
      }
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> stopRecording(Function(String?) onRecordingStopped) async {
    try {
      final path = await record.stop();
      _isRecording = false;

      if (path != null && File(path).existsSync()) {
        // Read the file as bytes
        final fileBytes = await File(path).readAsBytes();

        // Convert to Base64
        final base64String = base64Encode(fileBytes);
        bytes = base64String;
        print("Base64 Encoded Audio: $base64String");

        // Pass the file path (Python will access this)
        onRecordingStopped(path);
        print("Recording saved at: $path");
      } else {
        print("Recording failed to save.");
        onRecordingStopped(null);
      }
    } catch (e) {
      print("Error stopping recording: $e");
      onRecordingStopped(null);
    }
  }

  Future<void> playRecording() async {
    if (recordedFilePath == null || !File(recordedFilePath!).existsSync()) {
      print("No recording found to play.");
      return;
    }

    try {
      await audioPlayer.play(DeviceFileSource(recordedFilePath!));
      print("Playing audio: $recordedFilePath");
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  void dispose() {
    record.dispose();
    audioPlayer.dispose();
  }
}
