import 'package:flutter/material.dart';
import 'dart:ui';

// Data Models
class TeamMember {
  final String name;
  final String usn;
  final String imageUrl;

  const TeamMember({
    required this.name,
    required this.usn,
    required this.imageUrl,
  });
}

class Coordinator {
  final String name;
  final String designation;
  final String imageUrl;

  const Coordinator({
    required this.name,
    required this.designation,
    required this.imageUrl,
  });
}

class Supporter {
  final String name;
  final String department;

  const Supporter({
    required this.name,
    required this.department,
  });
}

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<TeamMember> teamMembers = [
    const TeamMember(
      name: 'Arqam Zakriya',
      usn: '4JN21AI010',
      imageUrl: 'assets/images/Arqam.jpg',
    ),
    const TeamMember(
      name: 'Puneeth A S',
      usn: '4JN21AI038',
      imageUrl: 'assets/images/Puneeth.jpg',
    ),
    const TeamMember(
      name: 'Sathwik P',
      usn: '4JN21AI043',
      imageUrl: 'assets/images/sathwik.png',
    ),
    const TeamMember(
      name: 'Tarun K Hillodi',
      usn: '4JN21AI055',
      imageUrl: 'assets/images/Tarun.jpg',
    ),
  ];

  final List<Coordinator> coordinators = [
    const Coordinator(
      name: 'Dr. Chetan K R',
      designation: 'Head of Department & Project Guide',
      imageUrl: 'assets/images/hodckr.jpg',
    ),
  ];

  final List<Supporter> supporters = [
    const Supporter(
      name: 'Vinod S L',
      department: 'AI&ML',
    ),
    const Supporter(
      name: 'Areeb Ahmed',
      department: 'Mechanical',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
              Colors.blue[900]!,
              Colors.purple[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                sliver: SliverToBoxAdapter(
                  child: _buildTeamSection(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                sliver: SliverToBoxAdapter(
                  child: _buildCoordinatorSection(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                sliver: SliverToBoxAdapter(
                  child: _buildSupporterSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 150,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      // Add these properties to change icon colors
      iconTheme: const IconThemeData(
          color: Colors.amber), // Changes back button/icons color
      actionsIconTheme: const IconThemeData(
          color: Colors.amber), // Changes action icons color
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Our Amazing Team',
          style: TextStyle(
            color: Colors.amber, // Change text color to amber
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection() {
    return Column(
      children: [
        _buildSectionTitle('Team Members', Icons.group),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: teamMembers.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    (1 - _controller.value) * 100 * (index % 2 == 0 ? 1 : -1),
                  ),
                  child: Opacity(
                    opacity: _controller.value,
                    child: child,
                  ),
                );
              },
              child: _buildTeamMemberCard(teamMembers[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCoordinatorSection() {
    return Column(
      children: [
        _buildSectionTitle('Project Coordinators', Icons.star),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: coordinators.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _controller.value,
                  child: Opacity(
                    opacity: _controller.value,
                    child: child,
                  ),
                );
              },
              child: _buildCoordinatorCard(coordinators[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.amber,
            size: 28,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(TeamMember member) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfileImage(member.imageUrl),
                const SizedBox(height: 12),
                Text(
                  member.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    member.usn,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinatorCard(Coordinator coordinator) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildProfileImage(coordinator.imageUrl),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coordinator.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          coordinator.designation,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white.withOpacity(0.1),
        child: ClipOval(
          child: Image(
            image: AssetImage(imageUrl),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                size: 40,
                color: Colors.amber.withOpacity(0.7),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSupporterSection() {
    return Column(
      children: [
        _buildSectionTitle('Project Supporters', Icons.people_outline),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: supporters.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _controller.value,
                  child: Opacity(
                    opacity: _controller.value,
                    child: child,
                  ),
                );
              },
              child: _buildSupporterCard(supporters[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSupporterCard(Supporter supporter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.amber.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 24,
                    color: Colors.amber.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        supporter.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        supporter.department,
                        style: TextStyle(
                          color: Colors.amber.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
