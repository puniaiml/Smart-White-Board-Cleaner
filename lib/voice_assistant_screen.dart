import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VoiceAssistantScreenState createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final DatabaseReference _database = FirebaseDatabase.instance.ref("boardStatus");
  bool isListening = false;
  String lastCommand = "";
  String assistantResponse = "Hi! I'm your board cleaning assistant. How can I help you today?";
  late AnimationController _pulseController;
  late AnimationController _avatarController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _avatarAnimation;
  bool isShowingSuccessOverlay = false;
  Timer? _overlayTimer;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Mic button pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Avatar bounce animation
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _avatarAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );
    _avatarController.repeat(reverse: true);
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize(
      onError: (error) {
        debugPrint("Speech recognition error: $error");
        _showErrorSnackBar("Sorry, I couldn't hear that. Please try again.");
      },
      onStatus: (status) {
        debugPrint("Speech recognition status: $status");
        if (status == 'done') {
          setState(() => isListening = false);
        }
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _toggleSuccessOverlay(bool show) {
    setState(() => isShowingSuccessOverlay = show);
    _overlayTimer?.cancel();
    if (show) {
      _overlayTimer = Timer(const Duration(seconds: 2), () {
        setState(() => isShowingSuccessOverlay = false);
      });
    }
  }

  void _startListening() async {
    if (await _speech.initialize()) {
      setState(() => isListening = true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              lastCommand = result.recognizedWords;
              isListening = false;
            });
            _processCommand(result.recognizedWords);
          }
        },
      );
    }
  }

  void _processCommand(String command) {
    command = command.toLowerCase();
    String response = "";
    bool isSuccessful = true;
    
    if (command.contains("start cleaning")) {
      response = "Starting the cleaning process now. The board will be cleaned automatically.";
      _database.child("status").set(1);
      _database.child("voice_command").set("start");
    } else if (command.contains("stop cleaning")) {
      response = "Stopping the cleaning process. The board cleaner will return to its home position.";
      _database.child("status").set(0);
      _database.child("voice_command").set("stop");
    } else if (command.contains("status")) {
      response = "Let me check the board status for you.";
      _checkBoardStatus();
    } else {
      response = "I'm sorry, I didn't quite understand that command. You can ask me to start cleaning, stop cleaning, or check the status.";
      isSuccessful = false;
    }

    setState(() {
      assistantResponse = response;
    });

    if (isSuccessful) {
      _toggleSuccessOverlay(true);
      _avatarController.forward(from: 0.0);
    }
  }

  Future<void> _checkBoardStatus() async {
    final snapshot = await _database.child("status").get();
    final status = snapshot.value as int?;
    
    setState(() {
      assistantResponse = status == 1 
          ? "The board is currently filled and needs cleaning."
          : "The board is clean and ready for use.";
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _avatarController.dispose();
    _overlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildAssistantInterface(context),
                ),
              ],
            ),
          ),
        ),
        if (isShowingSuccessOverlay)
          AnimatedOpacity(
            opacity: isShowingSuccessOverlay ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.green.withOpacity(0.3),
              child: const Center(
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Voice Assistant",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAssistantInterface(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedBuilder(
            animation: _avatarAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_avatarAnimation.value),
                child: _buildAssistantAvatar(),
              );
            },
          ),
          _buildResponseBubble(),
          _buildMicButton(),
          if (lastCommand.isNotEmpty) _buildLastCommandDisplay(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAssistantAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.smart_toy_rounded,
            size: 60,
            color: Colors.white,
          ),
          if (isListening)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponseBubble() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            assistantResponse,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (isListening)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                "Listening...",
                style: TextStyle(
                  color: Colors.blue.shade300,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _startListening,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isListening ? Colors.red : Colors.blue,
            boxShadow: [
              BoxShadow(
                color: (isListening ? Colors.red : Colors.blue).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildLastCommandDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Last Command',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"$lastCommand"',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}