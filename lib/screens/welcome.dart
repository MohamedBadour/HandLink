import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation, _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.teal, Colors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.teal, Colors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 5, blurRadius: 7, offset: const Offset(0, 3))],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network('https://storage.googleapis.com/a1aa/image/Ag6eOvQZAPeD64POFWEEAthwAlorP_L5VZlO4Gw1MUA.jpg', height: 150, width: 150, fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text('Hello', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text('Welcome to Sign Language Recognition App', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white70)),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _fadeAnimation,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/Login'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), backgroundColor: Colors.tealAccent, shadowColor: Colors.black, elevation: 5),
                child: Text('Login', style: TextStyle(fontSize: 18, color: Colors.teal[900])),
              ),
            ),
            const SizedBox(height: 15),
            FadeTransition(
              opacity: _fadeAnimation,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/Register'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), side: const BorderSide(color: Colors.white), shadowColor: Colors.black, elevation: 5),
                child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            /*
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text('Sign up using', style: TextStyle(fontSize: 14, color: Colors.white70)),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: IconButton(icon: const Icon(Icons.facebook, color: Colors.white), onPressed: () {}),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: IconButton(icon: const Icon(Icons.g_translate, color: Colors.white), onPressed: () {}),
                ),
              ],
            ),
             */
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
