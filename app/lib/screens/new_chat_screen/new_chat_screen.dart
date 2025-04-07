import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:whisper/models/chat_info.dart';
import 'package:whisper/services/key_service.dart';
import 'package:whisper/app/router.dart';

@RoutePage()
class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _nameController = TextEditingController();
  final _publicKeyController = TextEditingController();
  final _chatInfoBox = Hive.box<ChatInfo>('chats');
  final _keyService = KeyService.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _publicKeyController.dispose();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    final result =
        await AutoRouter.of(context).push<String>(const QRScannerRoute());
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _publicKeyController.text = result;
      });
    }
  }

  void _showMyQrCode() {
    final myPublicKey = _keyService.publicKey;
    AutoRouter.of(context).push(MyQRCodeRoute(publicKey: myPublicKey));
  }

  void _createChat() {
    // ... (keep existing _createChat logic)
    if (_formKey.currentState?.validate() ?? false) {
      final chatName = _nameController.text.trim();
      final partnerPublicKey = _publicKeyController.text.trim();
      final currentUserPublicKey = _keyService.publicKey;

      if (partnerPublicKey == currentUserPublicKey) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You cannot start a chat with yourself.'),
              backgroundColor: Colors.black87),
        );
        return;
      }

      final participants = [currentUserPublicKey, partnerPublicKey]..sort();
      final chatId = participants.join('_');

      if (_chatInfoBox.containsKey(chatId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('A chat with this user already exists.'),
              backgroundColor: Colors.black87),
        );
        return;
      }

      final newChatInfo = ChatInfo(
        participantPublicKey: partnerPublicKey,
        chatId: chatId,
        name: chatName,
      );

      _chatInfoBox.put(chatId, newChatInfo);
      AutoRouter.of(context).popAndPush(ChatRoute(chatId: chatId));
    }
  }

  @override
  Widget build(BuildContext context) {
    const inputDecoration = InputDecoration(
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black54, width: 1.0),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
      hintStyle: TextStyle(color: Colors.black54),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Chat', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        // Keep GestureDetector for unfocus
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            // Wrap content in an outer Column
            children: [
              // --- Show My QR Code Button ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon:
                      const Icon(Icons.qr_code_2_outlined, color: Colors.black),
                  label: const Text('Show My Code',
                      style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _showMyQrCode,
                ),
              ),
              const SizedBox(height: 15), // Spacing

              // --- Form takes remaining space ---
              Expanded(
                // Make the Form expand
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Chat Name Field ---
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: inputDecoration.copyWith(
                          hintText: 'Chat Name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name for the chat';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 25),

                      // --- Public Key Field ---
                      TextFormField(
                        controller: _publicKeyController,
                        style: const TextStyle(color: Colors.black),
                        decoration: inputDecoration.copyWith(
                          hintText: 'Partner Public Key',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter or scan the public key';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _createChat(),
                      ),
                      const SizedBox(height: 15),

                      // --- Scan QR Button ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.qr_code_scanner,
                              color: Colors.black),
                          label: const Text('Scan QR Code',
                              style: TextStyle(color: Colors.black)),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _scanQRCode,
                        ),
                      ),
                      const Spacer(), // Pushes the create button to the bottom

                      // --- Create Chat Button ---
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 0,
                          ),
                          onPressed: _createChat,
                          child: const Text('Create Chat'),
                        ),
                      ),
                      // Removed bottom SizedBox, padding handles it
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
