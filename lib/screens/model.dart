import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../providers/gemini_chat_service.dart'; // Import the chat service

class ModelPage extends StatefulWidget {
  const ModelPage({super.key});

  @override
  ModelPageState createState() => ModelPageState();
}

class ModelPageState extends State<ModelPage> with SingleTickerProviderStateMixin {
  XFile? _image;
  bool _isHovering = false;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _extractedText = '';
  final GeminiChatService _chatService = GeminiChatService();
  String _chatResponse = '';

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

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.photo_library, color: Colors.white)),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.camera_alt, color: Colors.white)),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null && mounted) {
        setState(() {
          _image = image;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error picking image: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
  }

  void _runModel() {
    if (_image == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // Simulate a delay for model processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _extractedText = 'Extracted text from the image';
      });
    });
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _extractedText = '';
    });
  }

  void _openChat() async {
    String userMessage = "Hello, how can I help you?"; // Example message
    try {
      String response = await _chatService.sendMessage(userMessage);
      setState(() {
        _chatResponse = response; // Store the response
      });
      _showChatDialog(response);
    } catch (e) {
      _showErrorSnackBar('Chat error: $e');
    }
  }

  void _showChatDialog(String response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chatbot Response'),
          content: Text(response),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Page', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.person, size: 28), onPressed: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
      drawer: _buildDrawer(context),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(context),
                const SizedBox(height: 30),
                _buildImageUploadArea(context),
                const SizedBox(height: 30),
                _buildActionButtons(context),
                if (_isLoading) ...[
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(),
                ],
                if (_extractedText.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  _buildExtractedTextBox(context),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openChat,
        child: const Icon(Icons.chat),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
      child: Column(
        children: [
          Text(
            'Sign Language to Text Recognition',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Upload or capture an image of sign language to convert it into text',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadArea(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _showImageSourceDialog,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _isHovering ? Colors.grey[100] : Colors.white,
              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: _image == null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Click to upload or capture an image',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                ),
              ],
            )
                : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.file(File(_image!.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.red[700], size: 30),
                    onPressed: _removeImage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ElevatedButton.icon(
        onPressed: _runModel,
        icon: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
        label: const Text('Run Model', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildExtractedTextBox(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extracted Text:',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _extractedText,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

