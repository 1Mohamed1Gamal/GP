import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sam3ly/Helpers/AppColors.dart';
import 'package:sam3ly/Helpers/AudioRecorder.dart';
import 'package:sam3ly/Helpers/Model_Api.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with TickerProviderStateMixin {
  bool isRecording = false;
  int seconds = 0;
  Timer? timer;
  final ModelApi model = const ModelApi();
  final AudioRecorderService _audioService = AudioRecorderService();
  String? responseText;
  String supportiveMessage = "🎤 Let's begin! Say something when you're ready.";

  @override
  void initState() {
    super.initState();
    responseText = null;
  }

  void _startRecording() {
    _audioService.startRecording(() {
      setState(() {
        isRecording = true;
        seconds = 0;
        responseText = null;
        supportiveMessage = "";
      });

      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          seconds++;
        });
      });
    });
  }

  void _stopRecording() {
    timer?.cancel();

    setState(() {
      isRecording = false;
      responseText = "⏳ Processing...";
    });

    _audioService.stopRecording((String? path) async {
      if (path != null) {
        final result = await model.freeSpeech(_audioService.bytes);
        setState(() {
          if (result != null && result['text'] != null) {
            responseText = result['text'];
          } else {
            responseText = "❌ No response received.";
          }
        });
      } else {
        setState(() {
          responseText = "⚠️ Recording failed or cancelled.";
        });
      }
    });
  }

  void _cancelRecording() async {
    timer?.cancel();
    await _audioService
        .cancelRecording(); // Add this method in AudioRecorderService
    setState(() {
      isRecording = false;
      seconds = 0;
      responseText = null;
      supportiveMessage = "🗑️ Recording cancelled. Tap the mic to try again.";
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
      body: SafeArea(
        child: Stack(
          children: [
            // Center response/support text
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (supportiveMessage.isNotEmpty)
                        Text(
                          supportiveMessage,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (responseText != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            responseText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom mic/timer/delete
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
                          const Icon(Icons.timer, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            formatTime(seconds),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🗑️ Cancel Button
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            iconSize: 32,
                            onPressed: _cancelRecording,
                          ),
                          const SizedBox(width: 30),
                          // ⏹️ Stop Button
                          FloatingActionButton(
                            backgroundColor: AppColors.primary,
                            onPressed: _stopRecording,
                            child: const Icon(Icons.stop,
                                size: 36, color: Colors.white),
                          ),
                        ],
                      ),
                    ] else ...[
                      // 🎤 Mic Button when idle
                      FloatingActionButton(
                        backgroundColor: AppColors.primary,
                        onPressed: _startRecording,
                        child: const Icon(Icons.mic,
                            size: 36, color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
