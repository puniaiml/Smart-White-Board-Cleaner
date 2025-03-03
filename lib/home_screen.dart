import 'package:board_cleaner/drawer_screen.dart';
import 'package:board_cleaner/voice_assistant_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:board_cleaner/stream_screen.dart';
import 'package:board_cleaner/manual_control_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref("boardStatus");
  int boardStatus = 0;
  bool isAutoMode = false;
  bool isManualMode = false;
  bool isListening = false;
  late AnimationController _animationController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late stt.SpeechToText _speech;
  Timer? _autoModeTimer;
  // ignore: unused_field
  final bool _isAnimating = false;
  // ignore: unused_field
  double _waveRadius = 0.0;
  late AnimationController _waveAnimationController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _setupAnimations();
    _listenToBoardStatus();
    _initSpeech();
    _initializeAutoMode();
  }

  void _setupAnimations() {
    // Main warning animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Slide animation for cards
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Pulse animation for buttons
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _slideController.forward();
    _pulseController.repeat(reverse: true);

    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {
          _waveRadius = _waveAnimationController.value * 50;
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _speech.cancel();
    _autoModeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Builder(
        // Add this Builder widget
        builder: (BuildContext context) {
          // This context will have access to Scaffold
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context), // Pass this context to _buildAppBar
                  Expanded(
                    child: _buildMainContent(context),
                  ),
                  _buildVoiceControl(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add drawer menu icon
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Smart Board Cleaner",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.6),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildStreamButton(context),
        ],
      ),
    );
  }

  Widget _buildStreamButton(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: const Icon(
            Icons.videocam,
            size: 20,
            color: Colors.white, // Explicitly set icon color
          ),
          label: const Text(
            "Stream",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white, // Explicitly set text color
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StreamScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 24),
            _buildControlButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: boardStatus == 1
                ? [
                    Colors.red.withOpacity(0.1),
                    Colors.orange.withOpacity(0.05),
                  ]
                : [
                    Colors.green.withOpacity(0.1),
                    Colors.blue.withOpacity(0.05),
                  ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            const SizedBox(height: 24),
            _buildStatusText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: boardStatus == 1
              ? Colors.red.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
          boxShadow: [
            BoxShadow(
              color: (boardStatus == 1 ? Colors.red : Colors.green)
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          boardStatus == 1 ? Icons.warning_rounded : Icons.check_circle_rounded,
          color: boardStatus == 1 ? Colors.red : Colors.green,
          size: 80,
        ),
      ),
    );
  }

  Widget _buildStatusText(BuildContext context) {
    return Column(
      children: [
        Text(
          boardStatus == 1 ? "Board is Filled!" : "Board is Empty",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: boardStatus == 1 ? Colors.red : Colors.green,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          boardStatus == 1 ? "Please clean the board" : "Ready for use",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Column(
      children: [
        if (isManualMode) _buildManualModeWarning(),
        const SizedBox(height: 16),
        _buildAutoModeButton(context),
        const SizedBox(height: 16),
        _buildManualControlButton(context),
      ],
    );
  }

  Widget _buildManualModeWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade700.withOpacity(0.15),
            Colors.orange.shade500.withOpacity(0.15)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange[700], size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Please disable Manual Mode first to use Auto-Mode",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoModeButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: isAutoMode
              ? [Colors.green, Colors.teal]
              : [Colors.grey.shade400, Colors.grey.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: (isAutoMode ? Colors.green : Colors.grey).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            isAutoMode ? Icons.auto_mode : Icons.power_settings_new,
            key: ValueKey(isAutoMode),
          ),
        ),
        label: Text(
          isAutoMode ? "Auto Mode ON" : "Auto Mode OFF",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _handleAutoModeToggle(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(250, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  void _handleAutoModeToggle(BuildContext context) {
    if (isManualMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please disable Manual Mode before enabling Auto Mode'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    _toggleAutoMode();
  }

  Widget _buildManualControlButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: const Icon(
          Icons.pan_tool,
          color: Colors.white, // Explicitly set icon color
        ),
        label: const Text(
          "Manual Control",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white, // Explicitly set text color
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManualControlScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(250, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceControl(BuildContext context) {
  return SlideTransition(
    position: _slideAnimation,
    child: Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.9),
            Theme.of(context).colorScheme.secondary.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VoiceAssistantScreen()),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.mic_external_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Voice Assistant",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Tap to start voice commands",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  // ignore: unused_element
  Widget _buildCommandChip(String command) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app,
            color: Colors.white.withOpacity(0.8),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            command,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeAutoMode() async {
    final DataSnapshot snapshot =
        await _database.child("auto_mode_timestamp").get();
    if (snapshot.value != null) {
      int timestamp = snapshot.value as int;
      DateTime turnOffTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      if (DateTime.now().difference(turnOffTime).inMinutes >= 30) {
        setState(() {
          isAutoMode = true;
          isManualMode = false;
        });
        _database.update({
          "auto_mode": true,
          "manual_mode": false,
        });
        _database.child("auto_mode_timestamp").remove();
      } else {
        setState(() {
          isAutoMode = false;
        });
        _database.update({
          "auto_mode": false,
          "manual_mode": true,
        });

        int remainingMinutes =
            30 - DateTime.now().difference(turnOffTime).inMinutes;
        _autoModeTimer = Timer(Duration(minutes: remainingMinutes), () {
          setState(() {
            isAutoMode = true;
            isManualMode = false;
          });
          _database.update({
            "auto_mode": true,
            "manual_mode": false,
          });
          _database.child("auto_mode_timestamp").remove();
        });
      }
    } else {
      setState(() {
        isAutoMode = true;
        isManualMode = false;
      });
      _database.update({
        "auto_mode": true,
        "manual_mode": false,
      });
    }
  }

  void _listenToBoardStatus() {
    _database.child("status").onValue.listen((event) {
      final data = event.snapshot.value;
      setState(() {
        boardStatus = (data is int) ? data : int.tryParse(data.toString()) ?? 0;
        if (boardStatus == 1) {
          _animationController.repeat(reverse: true);
        } else {
          _animationController.stop();
          _animationController.reset();
        }
      });
    });

    _database.child("auto_mode").onValue.listen((event) {
      final data = event.snapshot.value;
      setState(() {
        isAutoMode = (data is bool) ? data : false;
      });
    });

    _database.child("manual_mode").onValue.listen((event) {
      final data = event.snapshot.value;
      setState(() {
        isManualMode = (data is bool) ? data : false;
      });
    });
  }

  void _initSpeech() async {
    try {
      debugPrint("Initializing speech recognition...");
      bool available = await _speech.initialize(
        onError: (error) => debugPrint("Speech recognition error: $error"),
        onStatus: (status) => debugPrint("Speech recognition status: $status"),
      );
      if (available) {
        debugPrint("Speech recognition is available.");
      } else {
        debugPrint("Speech recognition is not available.");
      }
      setState(() {});
    } catch (e) {
      debugPrint("Error initializing speech recognition: $e");
    }
  }

  // ignore: unused_element
  void _toggleVoiceControl() async {
    try {
      if (!await Permission.microphone.isGranted) {
        PermissionStatus status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          debugPrint("Microphone permission denied.");
          return;
        }
      }

      if (!_speech.isAvailable) {
        debugPrint("Speech recognition not available. Initializing...");
        bool initialized = await _speech.initialize(
          onError: (error) => debugPrint("Speech recognition error: $error"),
          onStatus: (status) =>
              debugPrint("Speech recognition status: $status"),
        );

        if (!initialized) {
          debugPrint("Failed to initialize speech recognition.");
          return;
        }
      }

      if (!isListening) {
        debugPrint("Starting speech recognition...");

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Listening for commands..."),
            duration: Duration(seconds: 3),
          ),
        );

        _speech.listen(
          onResult: (result) {
            debugPrint("Recognized words: ${result.recognizedWords}");
            if (result.finalResult) {
              String command = result.recognizedWords.toLowerCase();
              debugPrint("Processing command: $command");
              _processVoiceCommand(command);
            }
          },
          listenMode: stt.ListenMode.confirmation,
          partialResults: true,
          cancelOnError: true,
          pauseFor: const Duration(seconds: 3),
        );

        setState(() {
          isListening = true;
        });
      } else {
        debugPrint("Stopping speech recognition...");
        _speech.stop();

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Stopped listening."),
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          isListening = false;
        });
      }
    } catch (e) {
      debugPrint("Error during voice control: $e");
      setState(() {
        isListening = false;
      });
    }
  }

  void _processVoiceCommand(String command) {
    if (command.contains("start cleaning")) {
      _database.child("status").set(1);
      _database.child("voice_command").set("start");

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Command Detected"),
          content: const Text("Starting the board cleaning process."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else if (command.contains("stop cleaning")) {
      _database.child("status").set(0);
      _database.child("voice_command").set("stop");

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Command Detected"),
          content: const Text("Stopping the board cleaning process."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _toggleAutoMode() {
    setState(() {
      isAutoMode = !isAutoMode;
      // isManualMode = !isAutoMode;
    });

    _database.update({
      "auto_mode": isAutoMode,
      // "manual_mode": !isAutoMode,
    });

    if (!isAutoMode) {
      _database
          .child("auto_mode_timestamp")
          .set(DateTime.now().millisecondsSinceEpoch);

      _autoModeTimer?.cancel();
      _autoModeTimer = Timer(const Duration(minutes: 30), () {
        setState(() {
          isAutoMode = true;
          // isManualMode = false;
        });
        _database.update({
          "auto_mode": true,
          // "manual_mode": false,
        });
        _database.child("auto_mode_timestamp").remove();
      });
    } else {
      _autoModeTimer?.cancel();
      _database.child("auto_mode_timestamp").remove();
    }
  }

  void _checkAutoModeTimer() async {
    if (!isAutoMode) {
      final DataSnapshot snapshot =
          await _database.child("auto_mode_timestamp").get();
      if (snapshot.value != null) {
        int timestamp = snapshot.value as int;
        DateTime turnOffTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(turnOffTime).inMinutes >= 30) {
          setState(() {
            isAutoMode = true;
          });
          _database.child("auto_mode").set(true);
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAutoModeTimer();
  }
}
