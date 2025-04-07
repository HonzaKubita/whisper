import 'package:hive/hive.dart';

part 'chat_info.g.dart';

@HiveType(typeId: 1)
class ChatInfo extends HiveObject {
  @HiveField(0)
  late String chatId; // The unique ID for the chat

  @HiveField(1)
  late String name; // Display name for the chat

  @HiveField(2)
  late String participantPublicKey; // Public key of the second chat participant

  @HiveField(3)
  String? description; // Optional description

  @HiveField(4)
  String? lastMessage; // Optional last message preview

  @HiveField(5)
  DateTime? lastMessageTimestamp; // Optional timestamp for the last message

  ChatInfo({
    required this.chatId,
    required this.name,
    required this.participantPublicKey,
    this.description,
    this.lastMessage,
    DateTime? lastMessageTimestamp,
  });
}
