import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whisper/models/connection.dart';
import 'package:whisper/services/connection_service/handlers/identify_handler.dart';
import 'package:whisper/services/connection_service/handlers/pickup_res_handler.dart';
import 'package:whisper/services/connection_service/handlers/receive_handler.dart';

class ConnectionService {
  // Private constructor
  ConnectionService._(this._webSocketUrl);

  // Static instance variable
  static ConnectionService? _instance;

  // WebSocket channel
  late WebSocketChannel _channel;
  final String _webSocketUrl;

  // Static method to initialize the singleton
  static void initialize(String webSocketUrl) {
    if (_instance == null) {
      _instance = ConnectionService._(webSocketUrl);
    } else {
      // Optionally handle re-initialization or throw an error
      print("ConnectionService already initialized.");
    }
  }

  // Static getter for the instance
  static ConnectionService get instance {
    if (_instance == null) {
      throw Exception(
        "ConnectionService not initialized. Call ConnectionService.initialize() first.",
      );
    }
    return _instance!;
  }

  Future<void> connect() async {
    if (_instance == null) {
      throw Exception(
        "ConnectionService not initialized. Call ConnectionService.initialize() first.",
      );
    }
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));
      print('WebSocket connected.');

      _channel.stream.listen(
        (message) {
          _handleIncomingMessage(message);
        },
        onDone: () {
          print('WebSocket disconnected.');
          // Handle reconnection logic if needed
        },
        onError: (error) {
          print('WebSocket error: $error');
          // Handle error/reconnection
        },
      );
    } catch (e) {
      print('Failed to connect: $e');
      // Handle connection errors
    }
  }

  void _handleIncomingMessage(dynamic message) {
    try {
      final decodedMessage = jsonDecode(message);
      final incomingMessage = IncomingMessage.fromJson(decodedMessage);

      switch (incomingMessage.type) {
        case IncomingMessageType.identify:
          final identifyMessage =
              IncomingIdentifyMessage.fromJson(decodedMessage);
          identifyHandler(_channel, identifyMessage);
          break;
        case IncomingMessageType.pickupRes:
          final pickupResponseMessage =
              IncomingPickupResponseMessage.fromJson(decodedMessage);
          pickupResHandler(_channel, pickupResponseMessage);
          break;
        case IncomingMessageType.receive:
          final receiveMessage =
              IncomingReceiveMessage.fromJson(decodedMessage);
          receiveHandler(_channel, receiveMessage);
          break;
      }
    } catch (e) {
      print('Failed to process message: $e');
      print('Original message: $message');
    }
  }

  void sendMessage(String message) {
    if (_instance == null) {
      print(
          'Cannot send message: ConnectionService not initialized or connected.');
      return;
    }
    try {
      ;
      _channel.sink.add(message);
      print('Message sent: $message');
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  void dispose() {
    if (_instance == null) {
      print('Cannot dispose: ConnectionService not initialized or connected.');
      return;
    }
    _channel.sink.close();
    print('ConnectionService disposed.');
  }
}
