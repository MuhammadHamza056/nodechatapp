import 'package:flutter/material.dart';
import 'package:flutternode/chates/pages/chat_page.dart';
import 'package:flutternode/chates/provider/provider.dart';
import 'package:flutternode/chates/provider/socket_service.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/widget/date_formater.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    final provider1 = Provider.of<SocketService>(context, listen: false);
    final provider = Provider.of<ProviderClass>(context, listen: false);
    provider.getUsers();
    provider1.loadLastMessage(
      HiveService.getTokken(),
      provider1.targetUserId.toString(),
    );
    provider1.initializeSocket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider1 = Provider.of<SocketService>(context, listen: false);
    final provider = Provider.of<ProviderClass>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        surfaceTintColor: Colors.white,
        title: Row(
          children: [Text("Chats", style: TextStyle(color: Colors.white))],
        ),

        actions: [
          GestureDetector(
            onTap: () async {
              await provider.logOut();

              GoRouter.of(context).pushReplacement('/');
            },
            child: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.getUsers();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ProviderClass>(
            builder: (context, provider, child) {
              final users = provider.getUsersModel?.data ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<SocketService>(
                    builder: (context, provider, child) {
                      return Row(
                        children: [
                          Text(
                            'Server Status: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          provider.isConnected
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return GestureDetector(
                          onTap: () {
                            provider1.markMessagesAsRead(user.id.toString());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatPage(
                                      userName: user.name.toString(),
                                      userId: user.id.toString(),
                                    ),
                              ),
                            );
                            provider1.saveTergetUserid(user.id.toString());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 👤 Avatar with online dot
                                Consumer<SocketService>(
                                  builder: (context, provider, child) {
                                    final isOnline = provider.isUserOnline(
                                      user.id.toString(),
                                    );
                                    return Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.blue,
                                          radius: 22,
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
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

                                // 📋 User Info and Message
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Name and createdAt in one line with space between
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              user.name ?? 'No name',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormatter.shortDateFormat(
                                              user.createdAt!,
                                            ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      // Latest message
                                      Consumer<SocketService>(
                                        builder: (context, provider, child) {
                                          return Text(
                                            provider.latestMessages[user.id
                                                    .toString()] ??
                                                '',
                                            style:  TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600]
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // 🟢 Unread Message Count
                                Consumer<SocketService>(
                                  builder: (context, provider1, child) {
                                    final count = provider1
                                        .getUnreadMessageCount(
                                          user.id.toString(),
                                        );
                                    return count > 0
                                        ? CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 12,
                                          child: Text(
                                            count.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                        : const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
