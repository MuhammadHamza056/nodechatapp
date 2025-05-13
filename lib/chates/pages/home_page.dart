import 'package:flutter/material.dart';
import 'package:flutternode/chates/pages/chat_page.dart';
import 'package:flutternode/chates/provider/provider.dart';
import 'package:flutternode/chates/provider/socket_service.dart';
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

              context.go('/login');
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
                          child: Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: Consumer<SocketService>(
                                builder: (context, provider, child) {
                                  final isOnline = provider.isUserOnline(
                                    user.id.toString(),
                                  );
                                  return Stack(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(color: Colors.white),
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
                              trailing: Consumer<SocketService>(
                                builder: (context, provider, child) {
                                  return provider1.getUnreadMessageCount(
                                            user.id.toString(),
                                          ) >
                                          0
                                      ? CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 12,
                                        child: Text(
                                          provider1
                                              .getUnreadMessageCount(
                                                user.id.toString(),
                                              )
                                              .toString(),
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
                              title: Text(user.name ?? 'No name'),
                              subtitle: Consumer<SocketService>(
                                builder: (context, provider, child) {
                                  return Text(
                                    provider.getLatestMessage(
                                          user.id.toString(),
                                        ) ??
                                        user.createdAt?.toIso8601String() ??
                                        'No message yet',
                                  );
                                },
                              ),
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
