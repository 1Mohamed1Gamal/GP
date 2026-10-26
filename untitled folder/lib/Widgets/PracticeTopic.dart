// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:sam3ly/Helpers/AppColors.dart';
// import 'package:sam3ly/Helpers/ManageText.dart';

// class PracticeTopic extends StatefulWidget {
//   final String typeOfData;

//   const PracticeTopic({super.key, required this.typeOfData});

//   @override
//   _PracticePageState createState() => _PracticePageState();
// }

// class _PracticePageState extends State<PracticeTopic> {
//   final TextManager _textManager = TextManager();
//   List<String> dataList = [];
//   String currentText = "Loading...";
//   String? userLevel;
//   String? definition;
//   final String elevenLabsApiKey =
//       "sk_17324cd53c6790e51e208fb333a240fbc3ea8e7f1aa2c8ec"; // Replace with your API key
//   final String voiceId =
//       "pNInz6obpgDQGcFmaJgB"; // Choose a voice from ElevenLabs
//   final AudioPlayer audioPlayer = AudioPlayer();
//   String? phonetic;
//   bool isLoadingDefinition = false; // Separate loading state for definition
//   bool isLoadingPhonetic = false; // Separate loading state for phonetic
//   // String userLevel = 'Beginner';

//   @override
//   void initState() {
//     super.initState();
//     loadUserLevel(); // Fetch the user's level from Firestore
//   }

//   Future<void> loadUserLevel() async {
//     String level = await _textManager.loadULevel();

//     setState(() {
//       userLevel = level;
//     });

//     loadDataTopic(); // Call this after fetching the level
//   }

//   Future<void> loadDataTopic() async {
//     List<String> data = await _textManager.loadTopicData(widget.typeOfData);

//     setState(() {
//       dataList = data;
//       currentText = _textManager.getRandomText(dataList);
//     });
//   }

//   Future<void> fetchDef() async {
//     setState(() {
//       isLoadingDefinition = true;
//     });

//     definition = await _textManager.fetchDefinition(currentText);

//     setState(() {
//       isLoadingDefinition = false;
//     });
//   }

//   Future<void> fetchPhonetic() async {
//     setState(() {
//       isLoadingPhonetic = true;
//     });

//     phonetic = await _textManager.fetchPhonetic(currentText);

//     setState(() {
//       isLoadingPhonetic = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         leading: IconButton(
//           color: AppColors.icon,
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: AppColors.card,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 10),

//               // Dynamic Header
//               Center(
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     widget.typeOfData,
//                     style: const TextStyle(
//                       color: AppColors.text,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Feedback Section
//               Row(
//                 children: [
//                   const CircleAvatar(
//                     radius: 24,
//                     backgroundImage: AssetImage('assets/images/avatar.png'),
//                   ),
//                   const SizedBox(width: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Wrong!",
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         "but that's okay, let's try again",
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // Word/Sentence/Paragraph Display
//               Text(
//                 currentText,
//                 style: const TextStyle(
//                   color: AppColors.text,
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: 10),

//               // Display phonetic for Words
//               if (_textManager.isWord(currentText) && phonetic != null)
//                 Text(
//                   phonetic!,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     color: AppColors.text,
//                   ),
//                 ),

//               const SizedBox(height: 20),

//               // Action Buttons (Speaker, Snail, Info)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     color: AppColors.icon,
//                     icon: const Icon(Icons.volume_up),
//                     onPressed: () {
//                       _textManager.fetchAndPlayAudio(
//                           currentText, elevenLabsApiKey, voiceId);
//                     },
//                   ),
//                   if (_textManager.isWord(currentText))
//                     IconButton(
//                       color: AppColors.icon,
//                       icon: const Icon(Icons.info_outline), // Info Icon
//                       onPressed: isLoadingDefinition ? null : fetchDef,
//                     ),
//                   IconButton(
//                     color: AppColors.icon,
//                     icon: const Icon(Icons.phonelink_ring), // Phonetic Icon
//                     onPressed: isLoadingPhonetic ? null : fetchPhonetic,
//                   ),
//                   FloatingActionButton(
//                     backgroundColor: Colors.blue,
//                     onPressed: () {
//                       setState(() {
//                         phonetic = null;
//                         definition = null;
//                         currentText = _textManager.getRandomText(dataList);
//                         isLoadingPhonetic = false;
//                       });
//                     },
//                     child: const Icon(Icons.refresh,
//                         size: 36, color: Colors.white),
//                   ),
//                 ],
//               ),

//               // Show Definition when Available
//               if (definition != null)
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Text(
//                     "Definition: $definition",
//                     style: const TextStyle(
//                         color: AppColors.text,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),

//               const SizedBox(height: 20),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
