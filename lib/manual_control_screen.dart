import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManualControlScreen extends StatefulWidget {
  const ManualControlScreen({super.key});

  @override
  
  // ignore: library_private_types_in_public_api
  _ManualControlScreenState createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> with TickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("boardStatus");
  bool isCleaningActive = false;
  String currentMovement = "stopped";
  bool isAutoMode = false;
  bool isPaused = false;
  bool handle = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _slideController;
  
  // Animations
  // ignore: unused_field
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkInitialState();
    _setupListeners();
  }

  void _setupAnimations() {
    // Pulse animation for buttons
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate animation for cleaning icon
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * 3.14).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    // Slide animation for controls
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
    if (isCleaningActive && !isPaused) {
      _rotateController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  // ... [Keep existing _checkInitialState and _setupListeners methods] ...

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              _buildAppBar(context),
              Expanded(
                child: _buildMainContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Manual Control",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
  return SlideTransition(
    position: _slideAnimation,
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isAutoMode) _buildAutoModeWarning(),
            const SizedBox(height: 24),
            _buildStatusIcon(),
            const SizedBox(height: 32),
            _buildMainControls(),
            const SizedBox(height: 48),
            _buildMovementStatus(),
            const SizedBox(height: 24),
            _buildDirectionalControls(),
            const SizedBox(height: 32),
            _buildDisableButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildAutoModeWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.2), Colors.yellow.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Please disable Auto Mode to use manual controls",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
  return RotationTransition(
    turns: _rotateAnimation,
    child: Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCleaningActive 
          ? (isPaused ? Colors.orange.shade200 : Colors.green.shade200)
          : Colors.grey.shade300,
        border: Border.all(
          color: isCleaningActive 
            ? (isPaused ? Colors.orange.shade700 : Colors.green.shade700)
            : Colors.grey.shade500,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: isCleaningActive 
              ? (isPaused ? Colors.orange.shade400 : Colors.green.shade400)
              : Colors.grey.withOpacity(0.6),
            blurRadius: 25,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Icon(
        isCleaningActive ? Icons.cleaning_services : Icons.power_settings_new,
        size: 100,
        color: isCleaningActive 
          ? (isPaused ? Colors.orange.shade700 : Colors.green.shade700)
          : Colors.grey.shade700,
      ),
    ),
  );
}


  Widget _buildMainControls() {
    return Container(
      
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        
        gradient: LinearGradient(
          colors: [
            isCleaningActive ? Colors.red : Colors.green,
            isCleaningActive 
              ? Colors.red.withOpacity(0.8) 
              : Colors.green.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isCleaningActive ? Colors.red : Colors.green).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _toggleCleaning,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          isCleaningActive ? "Stop Cleaning" : "Start Cleaning",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMovementStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        "Current Movement: ${currentMovement.toUpperCase()}",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDirectionalControls() {
    return Opacity(
      opacity: (isCleaningActive && !isAutoMode) ? 1.0 : 0.5,
      child: Column(
        children: [
          _buildPauseButton(),
          const SizedBox(height: 25),
          _buildMovementButtons(),
        ],
      ),
    );
  }

  Widget _buildPauseButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            isPaused ? Colors.blue : Colors.orange,
            isPaused 
              ? Colors.blue.withOpacity(0.8) 
              : Colors.orange.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isPaused ? Colors.blue : Colors.orange).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: (isCleaningActive && !isAutoMode) ? _togglePause : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          isPaused ? "Continue" : "Pause",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMovementButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDirectionButton(
          icon: Icons.arrow_back,
          command: "backward",
          isActive: currentMovement == "backward",
        ),
        const SizedBox(width: 48),
        _buildDirectionButton(
          icon: Icons.arrow_forward,
          command: "forward",
          isActive: currentMovement == "forward",
        ),
      ],
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required String command,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            isActive ? Colors.blue : Colors.grey.withOpacity(0.5),
            isActive ? Colors.blue.withOpacity(0.8) : Colors.grey.withOpacity(0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isActive ? Colors.blue : Colors.grey).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        onPressed: (isCleaningActive && !isPaused && !isAutoMode)
          ? () => _sendMovementCommand(command)
          : null,
        icon: Icon(icon),
        iconSize: 48,
        color: Colors.white,
        splashColor: Colors.blue.withOpacity(0.3),
        highlightColor: Colors.blue.withOpacity(0.1),
      ),
    );
  }


  Future<void> _checkInitialState() async {
    try {
      final snapshot = await _database.get();
      if (snapshot.value != null && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          isCleaningActive = data['status'] == 1;
          currentMovement = data['movement_command'] ?? 'stopped';
          isAutoMode = data['auto_mode'] ?? false;
          isPaused = data['signal'] == 0;
          handle = data['handle'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error checking initial state: $e');
    }
  }

  void _setupListeners() {
    _database.onValue.listen((event) {
      if (mounted && event.snapshot.value is Map) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          isCleaningActive = data['status'] == 1;
          currentMovement = data['movement_command'] ?? 'stopped';
          isAutoMode = data['auto_mode'] ?? false;
          isPaused = data['signal'] == 0;
          handle = data['handle'] ?? false;
        });
      }
    });
  }

  void _toggleCleaning() {
    if (isAutoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please disable Auto Mode before manual control'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final newStatus = !isCleaningActive;
    setState(() {
      isCleaningActive = newStatus;
      if (!newStatus) {
        currentMovement = 'stopped';
        isPaused = false;
      }
    });

    if (newStatus) {
      // Starting cleaning
      _database.update({
        "manual_mode": true,
        "auto_mode": false,
        "manual_cleaning": true,
        "status": 1,
        "signal": 1,
        "handle": true,
        "movement_command": "stop",
      });
    } else {
      // Stopping cleaning
      _database.update({
        "manual_mode": false,
        "manual_cleaning": false,
        "status": 0,
        "signal": 0,
        "handle": false,
        "movement_command": "stop",
      });
    }
  }

  void _togglePause() {
    if (!isCleaningActive || isAutoMode) return;

    setState(() {
      isPaused = !isPaused;
    });

    _database.update({
      "signal": isPaused ? 0 : 1,
    });
  }

  void _sendMovementCommand(String command) {
    // Don't send movement commands if auto mode is enabled
    if (!isCleaningActive || isPaused || isAutoMode) return;

    setState(() {
      currentMovement = command;
    });

    _database.update({
      "movement_command": command,
    });
  }

  Widget _buildDisableButton() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        colors: [
          Colors.grey.shade700,
          Colors.grey.shade600,
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade700.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ElevatedButton.icon(
      icon: const Icon(
        Icons.power_settings_new,
        color: Colors.white,
      ),
      label: const Text(
        "Disable Manual Mode",
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: _disableManualMode,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
  );
}

// Add this method to handle disabling manual mode
void _disableManualMode() {
  setState(() {
    isCleaningActive = false;
    currentMovement = 'stopped';
    isPaused = false;
  });

  _database.update({
    "manual_mode": false,
    "manual_cleaning": false,
    "status": 0,
    "signal": 0,
    "handle": false,
    "movement_command": "stop",
  });

  Navigator.pop(context);
}
}