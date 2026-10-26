import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/Helpers/AudioRecorder.dart';
import 'package:sam3ly/Helpers/Model_Api.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  bool isRecording = false;
  bool isPaused = false;
  int seconds = 0;
  Timer? timer;
  final ModelApi model = const ModelApi();
  String? bytes;
  final AudioRecorderService _audioService = AudioRecorderService();

  void _startRecording() {
    _audioService.startRecording(() {
      setState(() {
        isRecording = true;
      });
    });
  }

  void _stopRecording() {
    _audioService.stopRecording((String? path) {
      setState(() {
        isRecording = false;
      });

      if (path != null) {
        print(_audioService.bytes);
        model.freeSpeech(_audioService.bytes);
      }
    });
  }

  String formatTime(int sec) {
    int min = sec ~/ 60;
    int secRemain = sec % 60;
    return "$min:${secRemain.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRecording) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          formatTime(seconds),
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ],
                    ),
                    SizedBox(height: 10), // مسافة بين التايمر والأزرار
                  ],
                  FloatingActionButton(
                    backgroundColor: AppColors.primary,
                    onPressed: () {
                      if (isRecording) {
                        _stopRecording();
                      } else {
                        _startRecording();
                      }
                    },
                    child: Icon(
                      Icons.mic,
                      size: 36,
                      color: isRecording ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
