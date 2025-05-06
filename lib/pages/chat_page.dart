import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/provider/provider.dart';
import 'package:flutternode/widget/typing_dots.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  final String userName;
  final String userId;
  const ChatPage({super.key, required this.userName, required this.userId});

  @override
  Widget build(BuildContext context) {
    Timer? typingTimer;

    void onTextChanged(String text) {
      final provider = Provider.of<ProviderClass>(context, listen: false);
      provider.sendTypingStatus(userId, true);

      typingTimer?.cancel();
      typingTimer = Timer(const Duration(seconds: 1), () {
        provider.sendTypingStatus(userId, false);
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Consumer<ProviderClass>(
              builder: (context, provider, child) {
                return Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        userName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (provider.isOtherUserOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(width: 12),
            Text(userName),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              spacing: 15,
              children: [
                Icon(Icons.call_outlined),
                Icon(Icons.video_call_outlined),
              ],
            ),
          ),
        ],
        elevation: 1,
      ),
      body: Column(
        children: [
          // MESSAGES LIST
          Expanded(
            child: Consumer<ProviderClass>(
              builder: (context, provider, child) {
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final msg =
                        provider.messages[provider.messages.length - 1 - index];
                    final from = provider.getStringFromDynamic(msg['from']);
                    final messageText = provider.getStringFromDynamic(
                      msg['message'],
                    );
                    final isMe = from == HiveService.getTokken().toString();

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[500] : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft:
                                isMe
                                    ? const Radius.circular(16)
                                    : const Radius.circular(4),
                            bottomRight:
                                isMe
                                    ? const Radius.circular(4)
                                    : const Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              messageText,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  provider.formatTimestamp(msg['timestamp']),
                                  style: TextStyle(
                                    color:
                                        isMe
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    provider.getStatusIcon(msg['status']),
                                    size: 14,
                                    color: provider.getStatusColor(
                                      msg['status'],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          //WIDGET FOR USER TYPING
          Consumer<ProviderClass>(
            builder: (context, provider, child) {
              return provider.isOtherUserTyping
                  ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [const TypingDots()],
                        ),
                      ),
                    ),
                  )
                  : const SizedBox.shrink();
            },
          ),

          // MESSAGE INPUT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Consumer<ProviderClass>(
                    builder: (context, provider, child) {
                      return TextField(
                        onChanged: onTextChanged,
                        controller: provider.textController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        minLines: 1,
                        maxLines: 3,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final message =
                          Provider.of<ProviderClass>(
                            context,
                            listen: false,
                          ).textController.text.trim();
                      if (message.isNotEmpty) {
                        Provider.of<ProviderClass>(
                          context,
                          listen: false,
                        ).sendMessage(userId, message);
                        Provider.of<ProviderClass>(
                          context,
                          listen: false,
                        ).textController.clear();
                      } else {
                        EasyLoading.showError('Please enter your message');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
