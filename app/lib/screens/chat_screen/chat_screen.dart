import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import 'package:whisper/models/message.dart';
import 'package:whisper/models/chat_info.dart';
import 'package:whisper/services/chat_service.dart';
import 'package:whisper/services/key_service.dart';

@RoutePage()
class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final Box<Message> _messageBox = Hive.box<Message>('messages');
  final Box<ChatInfo> _chatInfoBox = Hive.box<ChatInfo>('chats');
  final KeyService _keyService = KeyService.instance;

  ChatInfo? _chatInfo;

  @override
  void initState() {
    super.initState();
    _loadChatInfo();
  }

  void _loadChatInfo() {
    final info = _chatInfoBox.get(widget.chatId);
    if (mounted) {
      setState(() {
        _chatInfo = info;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isNotEmpty && _chatInfo != null) {
      ChatService.sendMessage(
        text,
        widget.chatId,
        _chatInfo!.participantPublicKey,
      );
      _textController.clear();
    } else if (_chatInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Chat details not loaded.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserPublicKey = _keyService.publicKey;
    final screenWidth = MediaQuery.of(context).size.width;

    const inputDecoration = InputDecoration(
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black54, width: 1.0),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
      hintStyle: TextStyle(color: Colors.black54),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_chatInfo?.name ?? 'Chat',
            style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<Box<Message>>(
                valueListenable: _messageBox.listenable(),
                builder: (context, box, _) {
                  final messages = box.values
                      .where((msg) => msg.chatId == widget.chatId)
                      .toList();
                  messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                  final reversedMessages = messages.reversed.toList();

                  return ListView.builder(
                    reverse: true,
                    // Only apply vertical padding to the list itself
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    itemCount: reversedMessages.length,
                    itemBuilder: (context, index) {
                      final message = reversedMessages[index];
                      final isMe =
                          message.senderPublicKey == currentUserPublicKey;
                      final timestampString =
                          DateFormat('hh:mm a').format(message.timestamp);

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.75,
                          ),
                          child: Container(
                            // Keep horizontal margin on individual messages
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  message.content,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timestampString,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                // Keep padding around the input area
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: inputDecoration.copyWith(
                          hintText: 'Type a message...',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
