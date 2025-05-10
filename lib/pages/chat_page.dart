import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/constant/baseurl.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/provider/provider.dart';
import 'package:flutternode/provider/socket_service.dart';
import 'package:flutternode/utils/chat_status.dart';
import 'package:flutternode/widget/file_widget.dart';
import 'package:flutternode/widget/image_widget.dart';
import 'package:flutternode/widget/typing_dots.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String userId;
  const ChatPage({super.key, required this.userName, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    ChatState.isChatScreenActive = true;
    super.initState();
  }

  @override
  void dispose() {
    ChatState.isChatScreenActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SocketService>(context, listen: false);

    Timer? typingTimer;

    void onTextChanged(String text) {
      provider.sendTypingStatus(widget.userId, true);

      typingTimer?.cancel();
      typingTimer = Timer(const Duration(seconds: 1), () {
        provider.sendTypingStatus(widget.userId, false);
      });
    }

    void onBackPressed() {
      final provider = Provider.of<SocketService>(context, listen: false);
      provider.markMessagesAsRead(widget.userId);
      Navigator.of(context).pop();
    }

    return WillPopScope(
      onWillPop: () async {
        onBackPressed();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[100],

          body: Column(
            children: [
              //USER INFO AND CONNECTION STATUS
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    GestureDetector(
                      onTap: () {
                        onBackPressed();
                      },
                      child: Icon(CupertinoIcons.back),
                    ),
                    Consumer<SocketService>(
                      builder: (context, provider, child) {
                        return Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                widget.userName[0].toUpperCase(),
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
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(width: 12),

                    Consumer<SocketService>(
                      builder: (context, provider, child) {
                        final isTyping = provider.isOtherUserTyping == true;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedPadding(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.only(
                                bottom: isTyping ? 4.0 : 0.0,
                              ),
                              child: Text(
                                provider.isConnected
                                    ? widget.userName
                                    : 'Connecting...',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child:
                                  isTyping
                                      ? const Text(
                                        "typing...",
                                        key: ValueKey("typing"),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                      : const SizedBox(
                                        key: ValueKey("not_typing"),
                                      ),
                            ),
                          ],
                        );
                      },
                    ),

                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        spacing: 15,
                        children: [
                          Icon(CupertinoIcons.phone, size: 30),
                          Icon(CupertinoIcons.video_camera, size: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // MESSAGES LIST
              Expanded(
                child: Consumer<SocketService>(
                  builder: (context, provider, child) {
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.messages.length,
                      itemBuilder: (context, index) {
                        final msg =
                            provider.messages[provider.messages.length -
                                1 -
                                index];
                        final from = provider.getStringFromDynamic(msg['from']);
                        final fileName = provider.getStringFromDynamic(
                          msg['fileName'],
                        );
                        final fileType = provider.getStringFromDynamic(
                          msg['fileType'],
                        );
                        final fileUrl = provider.getStringFromDynamic(
                          msg['fileUrl'],
                        );
                        final messageText = provider.getStringFromDynamic(
                          msg['message'],
                        );

                        final isMe = from == HiveService.getTokken().toString();

                        return Align(
                          alignment:
                              isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[500] : Colors.grey[200],
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
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // File message display
                                if (fileType == 'image' && fileUrl.isNotEmpty)
                                  ImageMessageWidget(
                                    fileUrl: '$imageUrl$fileUrl',
                                    context: context,
                                    isMe: isMe,
                                  )
                                else if (fileType == 'document' &&
                                    fileName.isNotEmpty)
                                  FileMessageWidget(
                                    fileName: fileName,
                                    fileUrl: fileUrl,
                                    isMe: isMe,
                                  )
                                else
                                  Text(
                                    messageText,
                                    style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black87,
                                    ),
                                  ),

                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      provider.formatTimestamp(
                                        msg['timestamp'],
                                      ),
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
              // WIDGET FOR USER TYPING INDICATOR
              Consumer<SocketService>(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  final provider = Provider.of<SocketService>(
                                    context,
                                    listen: false,
                                  );
                                  provider.uploadFile();
                                },
                                child: Icon(Icons.add, color: Colors.blue),
                              ),
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
                            Provider.of<SocketService>(
                              context,
                              listen: false,
                            ).sendMessage(widget.userId, message);
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
        ),
      ),
    );
  }
}
