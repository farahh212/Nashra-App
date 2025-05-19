import 'package:flutter/material.dart';
import '../utils/theme.dart';

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
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() => _step = i);
    }

    await Future.delayed(const Duration(milliseconds: 300));
    Navigator.pushReplacementNamed(context, '/startup');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(
            _letters[_step - 1],
            key: ValueKey(_letters[_step - 1]),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 6,
            ),
          ),
        ),
      ),
    );
  }
}
