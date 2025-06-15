import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _handController;
  late AnimationController _pulseController;
  late AnimationController _textController;
  late AnimationController _glowController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _handRotationAnimation;
  late Animation<double> _handScaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  // Text animations for each letter
  late List<Animation<double>> _letterAnimations;
  late List<Animation<Offset>> _letterSlideAnimations;
  late List<Animation<double>> _letterScaleAnimations;

  int _currentHandGesture = 0;
  final List<IconData> _handGestures = [
    Icons.sign_language,
    Icons.back_hand,
    Icons.front_hand,
    Icons.waving_hand,
    Icons.sign_language_outlined,
  ];

  final String _appName = "HandLink";
  final List<Color> _letterColors = [
    const Color(0xFF2196F3), // H - Primary Blue
    const Color(0xFF03A9F4), // a - Light Blue
    const Color(0xFF00BCD4), // n - Cyan
    const Color(0xFF2196F3), // d - Primary Blue
    const Color(0xFF03A9F4), // L - Light Blue
    const Color(0xFF00BCD4), // i - Cyan
    const Color(0xFF2196F3), // n - Primary Blue
    const Color(0xFF03A9F4), // k - Light Blue
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _checkLoginState();
  }

  void _initializeAnimations() {
    // Main animation controller for entrance effects
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Hand gesture animation controller
    _handController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Scale animation with bounce effect
    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // Slide animation for subtitle
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    ));

    // Hand rotation animation
    _handRotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _handController,
      curve: Curves.easeInOut,
    ));

    // Hand scale animation
    _handScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _handController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Glow animation
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Initialize letter animations
    _initializeLetterAnimations();
  }

  void _initializeLetterAnimations() {
    _letterAnimations = [];
    _letterSlideAnimations = [];
    _letterScaleAnimations = [];

    for (int i = 0; i < _appName.length; i++) {
      // Stagger each letter animation
      double startTime = i * 0.1;
      double endTime = startTime + 0.3;

      // Fade animation for each letter
      _letterAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(startTime, endTime, curve: Curves.easeOut),
          ),
        ),
      );

      // Slide animation for each letter
      _letterSlideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(startTime, endTime, curve: Curves.bounceOut),
          ),
        ),
      );

      // Scale animation for each letter
      _letterScaleAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(startTime, endTime, curve: Curves.elasticOut),
          ),
        ),
      );
    }
  }

  void _startAnimations() {
    // Start main entrance animation
    _mainController.forward();

    // Start text animation after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _textController.forward();
      }
    });

    // Start glow animation
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _glowController.repeat(reverse: true);
      }
    });

    // Start continuous pulse animation
    _pulseController.repeat(reverse: true);

    // Start hand gesture cycling
    _startHandGestureAnimation();
  }

  void _startHandGestureAnimation() {
    _handController.forward().then((_) {
      _handController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentHandGesture = (_currentHandGesture + 1) % _handGestures.length;
          });
          _startHandGestureAnimation();
        }
      });
    });
  }

  Widget _buildAnimatedLetter(int index) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _letterAnimations[index],
        _letterSlideAnimations[index],
        _letterScaleAnimations[index],
        _glowAnimation,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _letterSlideAnimations[index],
          child: Transform.scale(
            scale: _letterScaleAnimations[index].value,
            child: Opacity(
              opacity: _letterAnimations[index].value,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: _letterColors[index].withOpacity(
                        0.5 * _glowAnimation.value,
                      ),
                      blurRadius: 10 * _glowAnimation.value,
                      spreadRadius: 2 * _glowAnimation.value,
                    ),
                  ],
                ),
                child: Text(
                  _appName[index],
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: _letterColors[index].withOpacity(0.8),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                      Shadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _appName.length,
            (index) => _buildAnimatedLetter(index),
      ),
    );
  }

  Future<void> _checkLoginState() async {
    try {
      await Future.delayed(const Duration(milliseconds: 4000));
      final authService = Get.find<AuthService>();
      final isLoggedIn = await authService.isLoggedIn();
      print('SplashScreen - Login check result: $isLoggedIn');
      final prefs = await SharedPreferences.getInstance();
      final storedLoginState = prefs.getBool('isLoggedIn') ?? false;
      final hasEmail = prefs.getString('login_email') != null;
      final appState = prefs.getString('app_state') ?? '';

      print('SplashScreen - Stored login: $storedLoginState, hasEmail: $hasEmail, appState: $appState');

      if (isLoggedIn && storedLoginState && hasEmail && appState != 'logged_out') {
        print('SplashScreen - Navigating to Model (logged in)');
        Get.offAllNamed('/Model');
      } else {
        print('SplashScreen - Navigating to Welcome (not logged in)');
        await prefs.setString('app_state', 'logged_out');
        await prefs.setBool('isLoggedIn', false);
        Get.offAllNamed('/Welcome');
      }
    } catch (e) {
      print('Error checking login state: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        await prefs.setString('app_state', 'logged_out');
      } catch (e2) {
        print('Error clearing login state: $e2');
      }
      Get.offAllNamed('/Welcome');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _handController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.8),
              colorScheme.secondary.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Hand Gesture Icon
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _scaleAnimation,
                    _handRotationAnimation,
                    _handScaleAnimation,
                    _pulseAnimation,
                    _glowAnimation, // Added glow animation here
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value * _pulseAnimation.value,
                      child: Transform.rotate(
                        angle: _handRotationAnimation.value,
                        child: Transform.scale(
                          scale: _handScaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                                // Fixed: Direct BoxShadow instead of AnimatedBuilder
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(
                                    0.3 * _glowAnimation.value,
                                  ),
                                  blurRadius: 30 * _glowAnimation.value,
                                  spreadRadius: 5 * _glowAnimation.value,
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                _handGestures[_currentHandGesture],
                                key: ValueKey(_currentHandGesture),
                                size: 60,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Animated HandLink Title
                _buildAnimatedTitle(),

                const SizedBox(height: 20),

                // Subtitle with Slide Animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Sign Language Recognition',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(
                                      0.2 * _glowAnimation.value,
                                    ),
                                    blurRadius: 15 * _glowAnimation.value,
                                    spreadRadius: 2 * _glowAnimation.value,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Bridge Communication Barriers',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Animated Loading Indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 3,
                                backgroundColor: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Version Info
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.5,
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
}
