import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whisper/models/connection.dart';
import 'package:whisper/services/key_service.dart';

Future<void> identifyHandler(
    WebSocketChannel _channel, IncomingIdentifyMessage message) async {
  final keyService = KeyService.instance;

  final signature = await keyService.signNonce(message.nonce);

  final identifyResponse = OutgoingIdentifyResponseMessage(
      signature: signature!, publicKey: keyService.publicKey);

  _channel.sink.add(jsonEncode(identifyResponse));
}
