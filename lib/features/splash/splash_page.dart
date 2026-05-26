import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.onFinished,
    this.duration = const Duration(milliseconds: 1200),
  });

  static const routeName = '/splash';

  final VoidCallback onFinished;
  final Duration duration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ).drive(Tween<double>(begin: 0.84, end: 1));
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _timer = Timer(widget.duration, widget.onFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const BrightnessAwareOverlay(),
      child: Scaffold(
        backgroundColor: SakuColors.blue100,
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                child: Image.asset(
                  'assets/splashscreen-animation.png',
                  width: 100,
                  height: 87,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BrightnessAwareOverlay extends SystemUiOverlayStyle {
  const BrightnessAwareOverlay()
      : super(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        );
}
