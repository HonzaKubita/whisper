// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatInfoAdapter extends TypeAdapter<ChatInfo> {
  @override
  final int typeId = 1;

  @override
  ChatInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatInfo(
      chatId: fields[0] as String,
      name: fields[1] as String,
      participantPublicKey: fields[2] as String,
      description: fields[3] as String?,
      lastMessage: fields[4] as String?,
      lastMessageTimestamp: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.chatId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.participantPublicKey)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.lastMessage)
      ..writeByte(5)
      ..write(obj.lastMessageTimestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
