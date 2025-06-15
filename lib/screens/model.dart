import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/AiResponse.dart';
import '../models/sign_prediction_model.dart';
import '../widgets/theme_switch_widget.dart';
import '../controllers/prediction_controller.dart';
import '../providers/auth_service.dart';

final logger = Logger();

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
  late Animation<double> _scaleAnimation;
  String _extractedText = '';
  final FlutterTts _flutterTts = FlutterTts();
  final PredictionController _predictionController = Get.find<PredictionController>();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  // Save image to permanent app directory
  Future<String> _saveImagePermanently(String imagePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/prediction_images');

      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imagePath);
      final newFileName = 'prediction_$timestamp$extension';
      final newPath = '${imagesDir.path}/$newFileName';

      // Copy file to permanent location
      final originalFile = File(imagePath);
      await originalFile.copy(newPath);

      logger.d('Image saved permanently to: $newPath');
      return newPath;
    } catch (e) {
      logger.e('Error saving image permanently: $e');
      return imagePath; // Return original path as fallback
    }
  }

  Future<void> _showImageSourceDialog() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: colorScheme.surface,
          title: Text(
            'Select Image Source',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImageSourceOption(
                Icons.photo_library_rounded,
                'Gallery',
                ImageSource.gallery,
                colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _buildImageSourceOption(
                Icons.camera_alt_rounded,
                'Camera',
                ImageSource.camera,
                colorScheme.secondary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption(IconData icon, String label, ImageSource source, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          _pickImage(source);
        },
      ),
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
      logger.e('Error picking image: $e');
      if (mounted) {
        _showErrorSnackBar('Error picking image: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _extractedText = '';
    });
  }

  void _handleModelError() {
    setState(() {
      _isLoading = false;
      _showErrorSnackBar('Error when processing your image, please try again');
    });
  }

  Future<void> _runModel() async {
    if (_image == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final userProfile = await _authService.getUserProfile();
      final email = userProfile.email;

      if (email.isEmpty) {
        _showErrorSnackBar('User email not found. Please login again.');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final permanentImagePath = await _saveImagePermanently(_image!.path);
      final data = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          _image!.path,
          filename: _image!.path.split('/').last,
        ),
      });
      final response = await dio.Dio().post(
        'https://sign-language.runasp.net/api/SignPrediction/predict',
        data: data,
        queryParameters: {'email': email},
        options: dio.Options(headers: {"Content-Type": "multipart/form-data"}),
      );
      logger.d('API Response: ${response.data}');
      if (response.statusCode == 200) {
        final result = AiResponse.fromJson(response.data);

        final prediction = SignPredictionResponse(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate unique ID
          predictedLabel: result.predictedLabel,
          confidence: _parseConfidence(result.confidence), // Parse confidence string to double
          imagePath: permanentImagePath, // Store permanent image path
          timestamp: DateTime.now(),
          userEmail: email,
        );

        setState(() {
          _isLoading = false;
          _extractedText = result.predictedLabel;
        });

        // Add to prediction history
        await _predictionController.addPrediction(prediction);

        // Speak the result
        if (_extractedText.isNotEmpty) {
          await _speakText(_extractedText);
        }

        _showSuccessSnackBar('Image processed successfully! Confidence: ${result.confidence}');

      } else {
        _handleModelError();
      }
    } catch (e) {
      logger.e('Error when processing image: $e');
      _handleModelError();
    }
  }

  double _parseConfidence(String confidenceStr) {
    try {
      final cleanStr = confidenceStr.replaceAll('%', '').trim();
      final percentage = double.parse(cleanStr);
      return percentage / 100.0; // Convert percentage to decimal
    } catch (e) {
      print('Error parsing confidence: $e');
      return 0.0;
    }
  }

  void _showTtsSettingsDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    double pitch = 1.0;
    double rate = 0.5;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: colorScheme.surface,
              title: Text(
                'Text-to-Speech Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pitch', style: theme.textTheme.titleMedium),
                  Slider(
                    value: pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: pitch.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        pitch = value;
                      });
                    },
                  ),
                  Text('Speed', style: theme.textTheme.titleMedium),
                  Slider(
                    value: rate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: rate.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        rate = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _flutterTts.setPitch(pitch);
                      await _flutterTts.setSpeechRate(rate);
                      if (_extractedText.isNotEmpty) {
                        await _flutterTts.speak(_extractedText);
                      } else {
                        await _flutterTts.speak("This is a test of the text to speech settings");
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _flutterTts.setPitch(pitch);
                    await _flutterTts.setSpeechRate(rate);
                    Navigator.of(context).pop();
                    _showSuccessSnackBar('TTS settings updated');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text('Save Settings'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HandLink',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          const ThemeSwitchButton(),
          IconButton(
            icon: Icon(Icons.person_rounded, size: 28, color: colorScheme.primary),
            onPressed: () => Navigator.pushNamed(context, '/UserProfile'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withOpacity(0.05),
            colorScheme.background,
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                _buildLoadingIndicator(context),
              ],
              if (_extractedText.isNotEmpty) ...[
                const SizedBox(height: 30),
                _buildExtractedTextBox(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.sign_language_rounded,
                    size: 30,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'HandLink',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Navigation Menu',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.model_training_rounded,
                  title: 'Model Page',
                  onTap: () => Navigator.pushNamed(context, '/Model'),
                  isSelected: true,
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'Prediction History',
                  onTap: () => Navigator.pushNamed(context, '/PredictionHistory'),
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About Us',
                  onTap: () => Navigator.pushNamed(context, '/AboutUs'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? colorScheme.error
              : isSelected
              ? colorScheme.primary
              : colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDestructive
                ? colorScheme.error
                : isSelected
                ? colorScheme.primary
                : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.camera_enhance_rounded,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'AI-Powered Recognition',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload or capture an image of sign language to convert it into text with our advanced AI model',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadArea(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _showImageSourceDialog,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isHovering
                    ? colorScheme.primary.withOpacity(0.05)
                    : colorScheme.surface,
                border: Border.all(
                  color: _isHovering
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3),
                  width: _isHovering ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _image == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.cloud_upload_rounded,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Upload Image',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click to upload or capture an image',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Supports JPG, PNG formats',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )
                  : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      File(_image!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: _removeImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _image != null ? _runModel : null,
              icon: Icon(
                Icons.psychology_rounded,
                color: _image != null ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.5),
                size: 24,
              ),
              label: Text(
                'Analyze Image',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _image != null ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _image != null ? colorScheme.primary : colorScheme.surfaceVariant,
                foregroundColor: _image != null ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: _image != null ? 4 : 0,
              ),
            ),
          ),
          if (_extractedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _showTtsSettingsDialog(),
              icon: Icon(Icons.settings_voice, color: colorScheme.primary),
              label: Text(
                'Voice Settings',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: colorScheme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Processing Image...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI is analyzing your image',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedTextBox(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.text_fields_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recognition Result',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _speakText(_extractedText),
                  icon: Icon(Icons.volume_up, color: colorScheme.primary),
                  tooltip: 'Speak Text',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _extractedText,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.volume_up_rounded,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Audio pronunciation played',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/PredictionHistory'),
                  child: Text(
                    'View History',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThemeSwitchWidget(showLabel: false);
  }
}
