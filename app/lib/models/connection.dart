import 'dart:convert'; // Needed for jsonEncode/jsonDecode if used directly

// --- Outgoing Messages (Client -> Server) ---

enum OutgoingMessageType {
  identifyRes,
  pickup,
  send,
}

extension OutgoingMessageTypeValue on OutgoingMessageType {
  String get value {
    switch (this) {
      case OutgoingMessageType.identifyRes:
        return "identify-res";
      case OutgoingMessageType.pickup:
        return "pickup";
      case OutgoingMessageType.send:
        return "send";
    }
  }
}

abstract class OutgoingMessage {
  final OutgoingMessageType type;
  OutgoingMessage(this.type);

  // Abstract method to ensure all subclasses implement toJson
  Map<String, dynamic> toJson();

  // Helper to get the JSON string directly
  String toJsonString() => jsonEncode(toJson());
}

class OutgoingIdentifyResponseMessage extends OutgoingMessage {
  final String signature;
  final String publicKey;

  OutgoingIdentifyResponseMessage({
    required this.signature,
    required this.publicKey,
  }) : super(OutgoingMessageType.identifyRes);

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
        'signature': signature,
        'publicKey': publicKey,
      };
}

class OutgoingPickupMessage extends OutgoingMessage {
  OutgoingPickupMessage() : super(OutgoingMessageType.pickup);

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
      };
}

class OutgoingSendMessage extends OutgoingMessage {
  final String data;
  final String forPublicKey; // Added property

  OutgoingSendMessage({
    required this.data,
    required this.forPublicKey, // Added to constructor
  }) : super(OutgoingMessageType.send);

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
        'data': data,
        'forPublicKey': forPublicKey, // Added to JSON output
      };
}

// --- Incoming Messages (Server -> Client) ---
// (No changes needed here for this request)

enum IncomingMessageType {
  identify,
  pickupRes,
  receive,
}

extension IncomingMessageTypeValue on IncomingMessageType {
  String get value {
    switch (this) {
      case IncomingMessageType.identify:
        return "identify";
      case IncomingMessageType.pickupRes:
        return "pickup-res";
      case IncomingMessageType.receive:
        return "receive";
    }
  }

  // Helper to find enum from string value
  static IncomingMessageType? fromValue(String value) {
    for (var type in IncomingMessageType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }
}

abstract class IncomingMessage {
  final IncomingMessageType type;
  IncomingMessage(this.type);

  // Factory constructor to handle deserialization
  factory IncomingMessage.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String?;
    if (typeString == null) {
      throw ArgumentError('Incoming message JSON must contain a "type" field');
    }

    final type = IncomingMessageTypeValue.fromValue(typeString);

    switch (type) {
      case IncomingMessageType.identify:
        return IncomingIdentifyMessage.fromJson(json);
      case IncomingMessageType.pickupRes:
        return IncomingPickupResponseMessage.fromJson(json);
      case IncomingMessageType.receive:
        return IncomingReceiveMessage.fromJson(json);
      case null:
        throw ArgumentError('Unknown incoming message type: $typeString');
    }
  }

  // Helper to create from JSON string
  static IncomingMessage fromJsonString(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return IncomingMessage.fromJson(decoded);
      } else {
        throw FormatException('Invalid JSON format: Expected a Map');
      }
    } on FormatException catch (e) {
      throw ArgumentError('Could not parse JSON string: $e');
    }
  }
}

class IncomingIdentifyMessage extends IncomingMessage {
  final String nonce;

  IncomingIdentifyMessage({required this.nonce})
      : super(IncomingMessageType.identify);

  factory IncomingIdentifyMessage.fromJson(Map<String, dynamic> json) {
    if (json['type'] != IncomingMessageType.identify.value) {
      throw ArgumentError('Invalid type for IncomingIdentifyMessage');
    }
    final nonce = json['nonce'] as String?;
    if (nonce == null) {
      throw ArgumentError('Missing "nonce" field for identify message');
    }
    return IncomingIdentifyMessage(nonce: nonce);
  }
}

class IncomingPickupResponseMessage extends IncomingMessage {
  final List<String> data;

  IncomingPickupResponseMessage({required this.data})
      : super(IncomingMessageType.pickupRes);

  factory IncomingPickupResponseMessage.fromJson(Map<String, dynamic> json) {
    if (json['type'] != IncomingMessageType.pickupRes.value) {
      throw ArgumentError('Invalid type for IncomingPickupResponseMessage');
    }
    final dataList = json['data'] as List?;
    if (dataList == null) {
      throw ArgumentError('Missing "data" field for pickup-res message');
    }
    // Ensure all elements are strings
    final data = dataList.map((e) => e.toString()).toList();
    return IncomingPickupResponseMessage(data: data);
  }
}

class IncomingReceiveMessage extends IncomingMessage {
  final String data;

  IncomingReceiveMessage({required this.data})
      : super(IncomingMessageType.receive);

  factory IncomingReceiveMessage.fromJson(Map<String, dynamic> json) {
    if (json['type'] != IncomingMessageType.receive.value) {
      throw ArgumentError('Invalid type for IncomingReceiveMessage');
    }
    final data = json['data'] as String?;
    if (data == null) {
      throw ArgumentError('Missing "data" field for receive message');
    }
    return IncomingReceiveMessage(data: data);
  }
}
