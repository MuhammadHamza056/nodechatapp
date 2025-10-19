import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/chates/provider/provider.dart';
import 'package:flutternode/chates/provider/socket_service.dart';
import 'package:flutternode/constant/baseurl.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/utils/chat_status.dart';
import 'package:flutternode/widget/file_widget.dart';
import 'package:flutternode/widget/image_widget.dart';
import 'package:flutternode/widget/typing_dots.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SocketService>(context, listen: false);
      // prov.loadMessages(widget.userId);
      final user1 = HiveService.getTokken().toString();
      final user2 = widget.userId;
      provider.loadMessages(user1, user2);
      ChatState.isChatScreenActive = true;
    });

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
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.back),
                    onPressed: () {
                      provider.markMessagesAsRead(widget.userId.toString());
                      Navigator.pop(context);
                    },
                  ),
                  Consumer<SocketService>(
                    builder: (context, provider, child) {
                      final isOnline = provider.isUserOnline(
                        widget.userId.toString(),
                      );
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              widget.userName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          if (isOnline)
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
                  Expanded(
                    child: Consumer<SocketService>(
                      builder: (context, provider, child) {
                        final isTyping = provider.isOtherUserTyping == true;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedPadding(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.only(
                                bottom: isTyping ? 4.0 : 0.0,
                              ),
                              child: Consumer<SocketService>(
                                builder: (context, provider, child) {
                                  return Text(
                                    provider.isConnected
                                        ? widget.userName
                                        : 'Connecting...',
                                    style: const TextStyle(
                                      fontSize:
                                          18, // Slightly smaller for app bar
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
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
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                      : const SizedBox(
                                        key: ValueKey("not_typing"),
                                        height:
                                            12, // Maintain consistent height
                                      ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.phone, size: 24),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.video_camera, size: 34),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        body: Column(
          children: [
            // MESSAGES LIST
            Expanded(
              child: Consumer<SocketService>(
                builder: (context, provider, child) {
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.usermessages.length,
                    itemBuilder: (context, index) {
                      final msg =
                          provider.usermessages[provider.usermessages.length -
                              1 -
                              index];

                      final isMe =
                          msg.sender == HiveService.getTokken().toString();

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
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
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg.messageType == 'image' &&
                                  msg.fileUrl?.isNotEmpty == true)
                                ImageMessageWidget(
                                  fileUrl: '$imageUrl${msg.fileUrl}',
                                  context: context,
                                  isMe: isMe,
                                )
                              else if (msg.messageType == 'document' &&
                                  msg.localPath?.isNotEmpty == true)
                                FileMessageWidget(
                                  fileName: msg.messageType!,
                                  fileUrl: msg.fileUrl!,
                                  isMe: isMe,
                                )
                              else if (msg.text!.isNotEmpty)
                                Text(
                                  msg.text!,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    provider.formatTimestamp(msg.timestamp),
                                    style: TextStyle(
                                      color:
                                          isMe
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ), // spacing between timestamp and status
                                  if (isMe) // ✅ Show status only for sender
                                    Consumer<SocketService>(
                                      builder: (context, provider, child) {
                                        return Text(
                                          provider.getMessageStatus(
                                            msg.messageId.toString(),
                                          ), // e.g., 'sent', 'delivered', 'read'
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        );
                                      },
                                    ),
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
                          ).sendMessage(widget.userId, message, Uuid().v4());

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
    );
  }
}
