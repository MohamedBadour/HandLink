import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import '../controllers/prediction_controller.dart';
import '../models/sign_prediction_model.dart';
import '../widgets/theme_switch_widget.dart';

class PredictionHistoryScreen extends StatefulWidget {
  const PredictionHistoryScreen({super.key});

  @override
  State<PredictionHistoryScreen> createState() => _PredictionHistoryScreenState();
}

class _PredictionHistoryScreenState extends State<PredictionHistoryScreen> {
  final PredictionController _controller = Get.find<PredictionController>();
  final TextEditingController _searchController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  List<SignPredictionResponse> _filteredPredictions = [];
  String _currentPlayingId = '';

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadHistory();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _currentPlayingId = '';
      });
    });
  }

  Future<void> _loadHistory() async {
    await _controller.loadPredictionHistory();
    setState(() {
      _filteredPredictions = _controller.predictions;
    });
  }

  Future<void> _speakText(String text, String predictionId) async {
    if (_currentPlayingId == predictionId) {
      await _flutterTts.stop();
      setState(() {
        _currentPlayingId = '';
      });
    } else {
      await _flutterTts.stop();
      setState(() {
        _currentPlayingId = predictionId;
      });
      await _flutterTts.speak(text);
    }
  }

  void _filterPredictions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPredictions = _controller.predictions;
      } else {
        _filteredPredictions = _controller.searchPredictions(query);
      }
    });
  }

  // Full screen image viewer
  void _showFullScreenImage(String imagePath) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildFullScreenImageWidget(imagePath),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenImageWidget(String imagePath) {
    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFullScreenImagePlaceholder();
        },
      );
    } else if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFullScreenImagePlaceholder();
        },
      );
    } else {
      return _buildFullScreenImagePlaceholder();
    }
  }

  Widget _buildFullScreenImagePlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
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

  @override
  void dispose() {
    _flutterTts.stop();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prediction History',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          const ThemeSwitchWidget(showLabel: false),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearConfirmationDialog();
              } else if (value == 'refresh') {
                _loadHistory();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('Refresh'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: colorScheme.error),
                    const SizedBox(width: 8),
                    const Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildStatsCard(context),
          Expanded(
            child: Obx(() => _buildPredictionsList(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterPredictions,
        decoration: InputDecoration(
          hintText: 'Search predictions...',
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: colorScheme.onSurface),
            onPressed: () {
              _searchController.clear();
              _filterPredictions('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.secondaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.history,
            label: 'Total Predictions',
            value: '${_controller.predictions.length}',
            color: colorScheme.primary,
          ),
          Container(
            height: 40,
            width: 1,
            color: colorScheme.outline.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.today,
            label: 'Today',
            value: _getTodayCount().toString(),
            color: colorScheme.secondary,
          ),
          Container(
            height: 40,
            width: 1,
            color: colorScheme.outline.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.volume_up,
            label: 'With Audio',
            value: '${_controller.predictions.length}',
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPredictionsList(BuildContext context) {
    if (_controller.isLoading.value) {
      return _buildLoadingState(context);
    }

    if (_filteredPredictions.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPredictions.length,
        itemBuilder: (context, index) {
          final prediction = _filteredPredictions[index];
          return _buildSimplifiedPredictionCard(context, prediction, index);
        },
      ),
    );
  }

  Widget _buildSimplifiedPredictionCard(BuildContext context, SignPredictionResponse prediction, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPlaying = _currentPlayingId == prediction.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.surface.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and confidence
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.sign_language,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(prediction.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat('hh:mm a').format(prediction.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildConfidenceChip(context, prediction.confidence),
              ],
            ),

            const SizedBox(height: 20),

            // Main prediction text (removed AI Recognition text)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withOpacity(0.3),
                    colorScheme.secondaryContainer.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Text(
                prediction.predictedLabel,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Simplified action button (only play audio)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _speakText(prediction.predictedLabel, prediction.id),
                icon: Icon(
                  isPlaying ? Icons.stop : Icons.play_arrow,
                  size: 20,
                ),
                label: Text(
                  isPlaying ? 'Stop Audio' : 'Play Audio',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlaying
                      ? colorScheme.error
                      : colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),

            // Clickable image section
            if (prediction.imagePath.isNotEmpty) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showFullScreenImage(prediction.imagePath),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImageWidget(prediction.imagePath),
                      ),
                      // Overlay to indicate it's clickable
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    final colorScheme = Theme.of(context).colorScheme;

    // Check if file exists
    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    } else if (imagePath.startsWith('http')) {
      // Handle network images
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildConfidenceChip(BuildContext context, double confidence) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color chipColor;
    String confidenceText;
    IconData confidenceIcon;

    if (confidence >= 0.8) {
      chipColor = Colors.green;
      confidenceText = 'High';
      confidenceIcon = Icons.check_circle;
    } else if (confidence >= 0.6) {
      chipColor = Colors.orange;
      confidenceText = 'Medium';
      confidenceIcon = Icons.warning;
    } else {
      chipColor = Colors.red;
      confidenceText = 'Low';
      confidenceIcon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            chipColor.withOpacity(0.2),
            chipColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confidenceIcon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${(confidence * 100).toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to view',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading predictions...',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.history_outlined,
              size: 64,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Predictions Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start using the sign language recognition\nto see your prediction history here',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/Model'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Start Predicting'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  int _getTodayCount() {
    final today = DateTime.now();
    return _controller.predictions.where((prediction) {
      return prediction.timestamp.year == today.year &&
          prediction.timestamp.month == today.month &&
          prediction.timestamp.day == today.day;
    }).length;
  }

  void _showClearConfirmationDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.surface,
        title: Text(
          'Clear All Predictions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all prediction history? This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.clearAllPredictions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
