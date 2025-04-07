import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whisper/models/connection.dart';
import 'package:whisper/services/chat_service.dart';

void pickupResHandler(
    WebSocketChannel _channel, IncomingPickupResponseMessage message) async {
  final encryptedMessages = message.data;

  for (final encryptedMessage in encryptedMessages) {
    ChatService.receiveMessage(encryptedMessage);
  }
}
