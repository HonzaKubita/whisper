import 'package:flutter/material.dart';
import 'package:whisper/app/router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whisper/models/chat_info.dart';
import 'package:whisper/models/message.dart';
import 'package:whisper/services/key_service.dart';
import 'package:whisper/services/connection_service/connection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Initialize Key Service FIRST ---
  final keyService = KeyService.instance; // Get the singleton instance
  try {
    await keyService.initialize(); // Initialize keys
  } catch (e) {
    // Handle critical initialization error (e.g., show error screen)
    print("FATAL: Key Management Service initialization failed: $e");
    // Potentially exit the app or show an error UI
    return;
  }
  // --- Key Service Initialized ---

  await Hive.initFlutter();

  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(ChatInfoAdapter());

  await Hive.openBox<Message>('messages');
  await Hive.openBox<ChatInfo>('chats');

  ConnectionService.initialize('ws://10.9.8.19:3000');
  ConnectionService.instance.connect();

  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(),
    );
  }
}
