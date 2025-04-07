import 'dart:convert';

import 'package:hive/hive.dart';

part 'message.g.dart'; // Make sure this matches your filename

@HiveType(typeId: 0) // Ensure this typeId is unique in your app
class Message extends HiveObject {
  @HiveField(0)
  late String id; // Unique ID for the message itself

  @HiveField(1)
  late String senderPublicKey; // Who sent the message

  @HiveField(2)
  late DateTime timestamp; // When it was sent

  @HiveField(3)
  late String content; // The actual message text

  @HiveField(4) // New field for chat association
  late String chatId; // ID of the chat this message belongs to

  Message({
    required this.id,
    required this.senderPublicKey,
    required this.timestamp,
    required this.content,
    required this.chatId, // Add chatId to constructor
  });
}

class MessageData {
  final String id;
  final String senderPublicKey;
  final DateTime timestamp;
  final String content;

  MessageData({
    required this.id,
    required this.senderPublicKey,
    required this.timestamp,
    required this.content,
  });

  MessageData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        senderPublicKey = json['senderPublicKey'],
        timestamp = DateTime.parse(json['timestamp']),
        content = json['content'];

  String toJsonString() {
    return jsonEncode({
      'id': id,
      'senderPublicKey': senderPublicKey,
      'timestamp': timestamp.toIso8601String(),
      'content': content,
    });
  }
}
