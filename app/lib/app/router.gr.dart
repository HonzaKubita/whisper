// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [ChatScreen]
class ChatRoute extends PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    Key? key,
    required String chatId,
    List<PageRouteInfo>? children,
  }) : super(
          ChatRoute.name,
          args: ChatRouteArgs(
            key: key,
            chatId: chatId,
          ),
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>();
      return ChatScreen(
        key: args.key,
        chatId: args.chatId,
      );
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({
    this.key,
    required this.chatId,
  });

  final Key? key;

  final String chatId;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, chatId: $chatId}';
  }
}

/// generated route for
/// [ChatsScreen]
class ChatsRoute extends PageRouteInfo<void> {
  const ChatsRoute({List<PageRouteInfo>? children})
      : super(
          ChatsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChatsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatsScreen();
    },
  );
}

/// generated route for
/// [MyQRCodeScreen]
class MyQRCodeRoute extends PageRouteInfo<MyQRCodeRouteArgs> {
  MyQRCodeRoute({
    Key? key,
    required String publicKey,
    List<PageRouteInfo>? children,
  }) : super(
          MyQRCodeRoute.name,
          args: MyQRCodeRouteArgs(
            key: key,
            publicKey: publicKey,
          ),
          initialChildren: children,
        );

  static const String name = 'MyQRCodeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MyQRCodeRouteArgs>();
      return MyQRCodeScreen(
        key: args.key,
        publicKey: args.publicKey,
      );
    },
  );
}

class MyQRCodeRouteArgs {
  const MyQRCodeRouteArgs({
    this.key,
    required this.publicKey,
  });

  final Key? key;

  final String publicKey;

  @override
  String toString() {
    return 'MyQRCodeRouteArgs{key: $key, publicKey: $publicKey}';
  }
}

/// generated route for
/// [NewChatScreen]
class NewChatRoute extends PageRouteInfo<void> {
  const NewChatRoute({List<PageRouteInfo>? children})
      : super(
          NewChatRoute.name,
          initialChildren: children,
        );

  static const String name = 'NewChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NewChatScreen();
    },
  );
}

/// generated route for
/// [QRScannerScreen]
class QRScannerRoute extends PageRouteInfo<void> {
  const QRScannerRoute({List<PageRouteInfo>? children})
      : super(
          QRScannerRoute.name,
          initialChildren: children,
        );

  static const String name = 'QRScannerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const QRScannerScreen();
    },
  );
}

/// generated route for
/// [WelcomeScreen]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
      : super(
          WelcomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomeScreen();
    },
  );
}
