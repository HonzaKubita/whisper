import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:whisper/app/router.dart';

@RoutePage()
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whisper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Whisper',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                AutoRouter.of(context).navigate(const ChatsRoute());
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Continue'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
