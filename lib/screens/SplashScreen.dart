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
      await Future.delayed(const Duration(milliseconds: 2000));
      setState(() => _step = i);
    }

    await Future.delayed(const Duration(milliseconds: 800));
    Navigator.pushReplacementNamed(context, '/startup'); // 👈 Transition to StartUp
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF5),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(
            _letters[_step - 1],
            key: ValueKey(_letters[_step - 1]),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20), // dark government green
              letterSpacing: 6,
            ),
          ),
        ),
      ),
    );
  }
}
