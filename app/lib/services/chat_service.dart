import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:whisper/models/chat_info.dart';
import 'package:whisper/models/connection.dart';
import 'package:whisper/models/message.dart';
import 'package:whisper/services/connection_service/connection_service.dart';
import 'package:whisper/services/encryption_service.dart';
import 'package:whisper/services/key_service.dart';

class ChatService {
  static const Uuid _uuid = const Uuid();
  static final KeyService _keyService = KeyService.instance;

  static Future<void> sendMessage(
      String text, String chatId, String recipientPublicKey) async {
    final Box<Message> messageBox = Hive.box<Message>('messages');
    final Box<ChatInfo> chatInfoBox = Hive.box<ChatInfo>('chats');

    final newMessage = Message(
      id: _uuid.v4(),
      // Get public key directly from the service
      senderPublicKey: _keyService.publicKey,
      timestamp: DateTime.now(),
      content: text,
      chatId: chatId,
    );

    // The message to the server
    final messageData = MessageData(
      id: newMessage.id,
      senderPublicKey: newMessage.senderPublicKey,
      content: newMessage.content,
      timestamp: newMessage.timestamp,
    );

    final encryptionService = EncryptionService();

    final encryptedData = await encryptionService.encrypt(
        messageData.toJsonString(), recipientPublicKey);

    if (encryptedData == null) {
      // Handle encryption failure
      print('Failed to encrypt message.');
      return;
    }

    final OutgoingSendMessage outgoingMessage = OutgoingSendMessage(
      forPublicKey: recipientPublicKey,
      data: encryptedData,
    );

    ConnectionService.instance.sendMessage(outgoingMessage.toJsonString());

    // Save the message to the local database
    messageBox.put(newMessage.id, newMessage);

    // Update the chat info
    final chatInfo = chatInfoBox.get(chatId);
    if (chatInfo != null) {
      chatInfo.lastMessage = newMessage.content;
      chatInfo.lastMessageTimestamp = newMessage.timestamp;
      chatInfoBox.put(chatId, chatInfo);
    }
  }

  static Future<void> receiveMessage(String encryptedMessageData) async {
    final encryptionService = EncryptionService();

    final decryptedMessageData =
        await encryptionService.decrypt(encryptedMessageData);

    if (decryptedMessageData == null) {
      print("Decryption failed.");
      return;
    }

    final messageData = MessageData.fromJson(jsonDecode(decryptedMessageData));

    final messageBox = Hive.box<Message>('messages');
    final chatInfoBox = Hive.box<ChatInfo>('chats');

    final chat = chatInfoBox.values.firstWhere(
      (chat) => chat.participantPublicKey == messageData.senderPublicKey,
    );

    // Create a new message object
    final newMessage = Message(
      id: Uuid().v4(),
      senderPublicKey: messageData.senderPublicKey,
      timestamp: DateTime.now(),
      content: messageData.content,
      chatId: chat.chatId,
    );

    messageBox.add(newMessage);

    // Update the chat info
    chat.lastMessage = newMessage.content;
    chat.lastMessageTimestamp = newMessage.timestamp;
    chatInfoBox.put(chat.chatId, chat);
  }
}
