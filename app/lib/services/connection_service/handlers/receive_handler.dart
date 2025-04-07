import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whisper/models/connection.dart';
import 'package:whisper/services/chat_service.dart';

void receiveHandler(
    WebSocketChannel _channel, IncomingReceiveMessage message) async {
  ChatService.receiveMessage(message.data);
}
