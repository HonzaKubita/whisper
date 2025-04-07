import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:whisper/screens/welcome_screen/welcome_screen.dart';
import 'package:whisper/screens/chat_screen/chat_screen.dart';
import 'package:whisper/screens/chats_screen/chats_screen.dart';
import 'package:whisper/screens/new_chat_screen/new_chat_screen.dart';
import 'package:whisper/screens/qr_scanner_screen/qr_scanner_screen.dart';
import 'package:whisper/screens/my_qr_code_screen/my_qr_code_screen.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType =>
      RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: WelcomeRoute.page),
        AutoRoute(page: ChatsRoute.page, initial: true),
        AutoRoute(page: ChatRoute.page),
        AutoRoute(page: NewChatRoute.page),
        AutoRoute(page: QRScannerRoute.page),
        AutoRoute(page: MyQRCodeRoute.page),
      ];

  @override
  List<AutoRouteGuard> get guards => [
        // optionally add root guards here
      ];
}
