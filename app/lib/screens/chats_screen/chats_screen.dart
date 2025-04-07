import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whisper/app/router.dart';
import 'package:whisper/models/chat_info.dart';

@RoutePage()
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<ChatInfo> chatInfoBox = Hive.box<ChatInfo>('chats');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ValueListenableBuilder<Box<ChatInfo>>(
        // Keep body simple
        valueListenable: chatInfoBox.listenable(),
        builder: (context, box, _) {
          final chats = box.values.toList();

          chats.sort((a, b) {
            final tsA = a.lastMessageTimestamp;
            final tsB = b.lastMessageTimestamp;
            if (tsA == null && tsB == null) return 0;
            if (tsA == null) return 1;
            if (tsB == null) return -1;
            return tsB.compareTo(tsA);
          });

          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'No chats yet. Start a new conversation!',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatInfo = chats[index];
              return ListTile(
                title: Text(chatInfo.name,
                    style: const TextStyle(color: Colors.black)),
                subtitle: Text(
                  chatInfo.lastMessage ?? 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54),
                ),
                onTap: () {
                  AutoRouter.of(context).push(ChatRoute(
                    chatId: chatInfo.chatId,
                  ));
                },
              );
            },
          );
        },
      ),
      // Use floatingActionButton for placement, but customize the button
      floatingActionButton: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black, // Black background
          foregroundColor: Colors.white, // White icon
          shape: RoundedRectangleBorder(
            // Rectangular shape
            borderRadius:
                BorderRadius.circular(4), // Small radius for slight curve
            // Or use BorderRadius.zero for sharp corners
          ),
          padding: const EdgeInsets.all(16), // Adjust padding for desired size
          minimumSize: Size.zero, // Allow button to shrink to padding size
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap area
          elevation: 0, // No shadow
        ),
        onPressed: () {
          // Navigate to NewChatScreen
          AutoRouter.of(context).push(const NewChatRoute());
        },
        child: const Icon(Icons.message_outlined), // Or Icons.add_comment
      ),
    );
  }
}
