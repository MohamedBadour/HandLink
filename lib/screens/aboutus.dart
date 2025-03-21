import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  AboutUsPageState createState() => AboutUsPageState();
}

class AboutUsPageState extends State<AboutUsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.person, size: 28), onPressed: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
      drawer: _buildAnimatedDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.primary.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildIntroduction(context),
              const SizedBox(height: 32),
              _buildAnimatedSections(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.teal)),
                  SizedBox(height: 10),
                  Text('Navigation', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _buildDrawerItem(icon: Icons.model_training, title: 'Model Page', onTap: () => Navigator.pushNamed(context, '/Model')),
            _buildDrawerItem(icon: Icons.info_outline, title: 'About Us', onTap: () => Navigator.pushNamed(context, '/AboutUs')),
            _buildDrawerItem(icon: Icons.exit_to_app, title: 'Sign Out', onTap: () => Navigator.pushReplacementNamed(context, '/Login')),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 3))]),
        child: Center(
          child: Text(
            "Welcome to our 'Sign Language to Text Recognition' project!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 3))]),
        child: Text(
          "This project uses cutting-edge technology to convert images of hand gestures from the American Finger Spelling alphabet into readable text. It is designed to provide an easy and efficient way for individuals to translate sign language into text, promoting better communication for the hearing impaired.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
      ),
    );
  }

  Widget _buildAnimatedSections(BuildContext context) {
    final sections = [
      {
        'title': "Our Mission",
        'content': "Our mission is to create a tool that facilitates communication between individuals who use sign language and those who don't. This system will help users easily understand and translate sign language gestures, making conversations smoother and more inclusive.",
        'icon': Icons.flag,
        'color': Colors.teal,
      },
      {
        'title': "Why This Project?",
        'content': "The ability to understand sign language is a crucial skill for inclusivity, but it's often limited by accessibility and tools available for real-time translation. Our project aims to provide a solution that is both simple to use and effective in converting sign language gestures to text, making it accessible for everyone, anywhere, at any time.",
        'icon': Icons.question_answer,
        'color': Colors.blue,
      },
      {
        'title': "How It Works",
        'content': "The project uses image recognition techniques powered by machine learning. When a user uploads or capture an image of sign language gestures, our system processes the image, identifies the hand shapes, and converts them into corresponding text.",
        'icon': Icons.settings,
        'color': Colors.orange,
      },
      {
        'title': "Get Involved",
        'content': "If you're passionate about accessibility and sign language recognition, we invite you to contribute to this project. Whether you're a developer, designer, or someone with a strong interest in improving communication tools for the hearing impaired, your involvement can make a real difference.",
        'icon': Icons.group,
        'color': Colors.purple,
      },
    ];

    return Column(
      children: List.generate(
        sections.length,
            (index) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500 + (500 * index)),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _buildSection(
                    context,
                    title: sections[index]['title'] as String,
                    content: sections[index]['content'] as String,
                    icon: sections[index]['icon'] as IconData,
                    color: sections[index]['color'] as Color,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content, required IconData icon, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 8),
                  Text(content, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}