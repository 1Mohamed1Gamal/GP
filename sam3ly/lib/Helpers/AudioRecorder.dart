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

  /// Starts recording audio and calls [onRecordingStarted] when ready
  Future<void> startRecording(VoidCallback onRecordingStarted) async {
    try {
      if (await record.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final savePath = "${directory.path}/recordings";

        final newDirectory = Directory(savePath);
        if (!newDirectory.existsSync()) {
          newDirectory.createSync(recursive: true);
        }

        String filePath = "$savePath/new.ogg";

        await record.start(
          const RecordConfig(encoder: AudioEncoder.opus),
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

  /// Stops recording and returns the path and base64 content
  Future<void> stopRecording(Function(String?) onRecordingStopped) async {
    try {
      final path = await record.stop();
      _isRecording = false;

      if (path != null && File(path).existsSync()) {
        final fileBytes = await File(path).readAsBytes();
        bytes = base64Encode(fileBytes);

        print(
            "Base64 Encoded Audio: ${bytes.substring(0, 30)}..."); // partial log
        print("Recording saved at: $path");

        onRecordingStopped(path);
      } else {
        print("Recording failed to save.");
        onRecordingStopped(null);
      }
    } catch (e) {
      print("Error stopping recording: $e");
      onRecordingStopped(null);
    }
  }

  /// Cancels the recording and deletes any temp file
  Future<void> cancelRecording() async {
    try {
      if (_isRecording && await record.isRecording()) {
        await record.stop();
        print("Recording cancelled by user.");
      }

      if (recordedFilePath != null) {
        final file = File(recordedFilePath!);
        if (file.existsSync()) {
          await file.delete();
          print("Temporary file deleted: $recordedFilePath");
        }
      }

      _isRecording = false;
      recordedFilePath = null;
      bytes = '';
    } catch (e) {
      print("Error cancelling recording: $e");
    }
  }

  /// Plays the last recorded audio file
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

  /// Dispose audio resources
  void dispose() {
    record.dispose();
    audioPlayer.dispose();
  }
}
