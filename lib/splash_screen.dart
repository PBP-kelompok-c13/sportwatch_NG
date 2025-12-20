import 'package:flutter/material.dart';
import 'package:sportwatch_ng/main_page.dart';

class SplashGate extends StatefulWidget {
  const SplashGate({
    super.key,
    this.skipIntro = false,
    this.holdDuration = const Duration(milliseconds: 1400),
  });

  final bool skipIntro;
  final Duration holdDuration;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    if (widget.skipIntro) {
      _showSplash = false;
      return;
    }
    Future.delayed(widget.holdDuration, () {
      if (!mounted) return;
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MainPage(),
        AbsorbPointer(
          absorbing: _showSplash,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _showSplash
                ? const SplashScreen(key: ValueKey('splash'))
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                  Image.asset(
                    'logo_sportwatch.png',
                    width: 92,
                    height: 92,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('SportWatch', style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
