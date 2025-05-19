import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _step = 1;
  final List<String> _letters = ['N', 'NA', 'NAS', 'NASH', 'NASHR', 'NASHRA'];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 1; i <= _letters.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _step = i);
    }

    await Future.delayed(const Duration(milliseconds: 300));
    Navigator.pushReplacementNamed(context, '/startup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Color(0xFF1976D2),
                Color(0xFF2196F3),
                Color(0xFF64B5F6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              _letters[_step - 1],
              key: ValueKey(_letters[_step - 1]),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
