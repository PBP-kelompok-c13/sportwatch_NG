import 'package:flutter/material.dart';

class ScoreboardLandingPage extends StatelessWidget {
  const ScoreboardLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
      ),
      body: const Center(
        child: Text(
          'Scoreboard Landing Page',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
