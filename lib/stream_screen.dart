import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AppConfig {
  static const String baseStreamUrl = 'http://192.168.111.191:5000';
  static const String originalFeedPath = '/original_feed';
  static const String binaryFeedPath = '/binary_feed';
}

class StreamScreen extends StatefulWidget {
  const StreamScreen({Key? key}) : super(key: key);

  @override
  _StreamScreenState createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> with TickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("boardStatus");
  double fillPercentage = 0.0;
  bool isLoading = true;
  bool isOffline = false;
  StreamSubscription? _connectivitySubscription;

  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _listenToBoardFillStatus();
    _startLoadingAnimation();
    _monitorConnectivity();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
    _fadeController.forward();
  }

  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isOffline = result == ConnectivityResult.none;
        if (isOffline) {
          isLoading = false;
        }
      });
    });
  }

  void _startLoadingAnimation() {
    _loadingTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && isLoading) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void _listenToBoardFillStatus() {
    try {
      _database.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        setState(() {
          fillPercentage = (data?['fill_percentage'] ?? 0).toDouble();
        });
      }).onError((error) {
        print('Database error: $error');
      });
    } catch (e) {
      print('Error setting up database listener: $e');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    _loadingTimer?.cancel();
    _connectivitySubscription?.cancel();
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
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: isOffline ? _buildOfflineMessage() : _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_wifi_off,
            size: 100,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 20),
          Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              var connectivityResult = await (Connectivity().checkConnectivity());
              setState(() {
                isOffline = connectivityResult == ConnectivityResult.none;
              });
            },
            child: const Text('Retry Connection'),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            tooltip: 'Go back',
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Board Streams",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            tooltip: 'Refresh streams',
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _startLoadingAnimation();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStreamCard(
                "Original Feed",
                '${AppConfig.baseStreamUrl}${AppConfig.originalFeedPath}',
                Icons.videocam,
              ),
              const SizedBox(height: 16),
              _buildStreamCard(
                "Binary Feed",
                '${AppConfig.baseStreamUrl}${AppConfig.binaryFeedPath}',
                Icons.filter,
              ),
              const SizedBox(height: 16),
              _buildFillStatusCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamCard(String title, String streamUrl, IconData icon) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: isLoading
                      ? _buildLoadingIndicator()
                      : Mjpeg(
                          stream: streamUrl,
                          isLive: true,
                          fit: BoxFit.cover,
                          error: (context, error, stackTrace) {
                            return _buildStreamErrorWidget(error);
                          },
                        ),
                ),
                if (!isLoading)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildLiveIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamErrorWidget(dynamic error) {
    return Container(
      color: Colors.black.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const Text(
              'Stream Unavailable',
              style: TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                _startLoadingAnimation();
              },
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.1),
      child: Center(
        child: RotationTransition(
          turns: _rotateAnimation,
          child: Icon(
            Icons.refresh,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fiber_manual_record,
              color: Colors.white,
              size: 12,
            ),
            SizedBox(width: 4),
            Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillStatusCard() {
    final isHighFill = fillPercentage > 80;
    final statusColor = isHighFill ? Colors.red : Theme.of(context).primaryColor;

    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isHighFill ? Icons.warning : Icons.water_drop,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Board Fill Status",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: fillPercentage / 100,
                      backgroundColor: statusColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ScaleTransition(
              scale: _pulseAnimation,
              child: Text(
                "${fillPercentage.toStringAsFixed(1)}% Full",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}