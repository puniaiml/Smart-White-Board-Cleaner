import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Smart Board Cleaner'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Version
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cleaning_services_rounded,
                      size: 64,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Smart Board Cleaner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Features Section
            _buildSection(
              'Objectives',
              [
                'Fully automated cleaning for busy spaces',
                'Accessible design for users of all abilities',
                'Professional-grade cleaning results',
                'Ergonomic solution for workplace safety',
                'Advanced technology for reliable performance',
                'Perfect for schools, offices & shared spaces',
                'Smart AI pathfinding for thorough cleaning'
              ],
            ),

            _buildSection(
              'Key Features',
              [
                'AI-powered automatic whiteboard cleaning',
                'Real-time monitoring of cleaning status and board conditions',
                'Remote control through mobile & desktop apps',
                'Spotless, streak-free cleaning every time',
                'Live video feed of cleaning progress',
                'Voice commands for hands-free operation',
                'Works with all marker types'
              ],
            ),

            _buildSection(
              'Hardware and Technical Specifications',
              [
                'Raspberry pi and Arduino',
                'MG996R Continuous Servo and Web Camera',
                'Firebase',
                'Flutter',
              ],
            ),

            _buildSection(
              'Support',
              [
                'Email: hod_aiml@jnnce.ac.in',
                'Linked In: JNNCE_AIML',
                'Instagram: jnnce_aiml',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 24),
      ],
    );
  }
}
