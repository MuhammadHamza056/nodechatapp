import 'package:flutter/material.dart';
import 'package:flutternode/pages/chat_page.dart';
import 'package:flutternode/provider/provider.dart';
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
    final provider = Provider.of<ProviderClass>(context, listen: false);
    provider.getUsers();
    provider.initializeSocket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderClass>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        surfaceTintColor: Colors.white,
        title: Text("Home", style: TextStyle(color: Colors.white)),
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

              if (users.isEmpty) {
                return const Text(
                  'No users available',
                  style: TextStyle(color: Colors.grey),
                );
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return GestureDetector(
                    onTap: () {
                      provider.markMessagesAsRead(user.id.toString());
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
                    },
                    child: Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(color: Colors.white),
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
                                      color:
                                          Colors.white, // To give a clean edge
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing:
                            provider.getUnreadMessageCount(user.id.toString()) >
                                    0
                                ? CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 12,
                                  child: Text(
                                    provider
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
                                : const SizedBox.shrink(),
                        title: Text(user.name ?? 'No name'),
                        subtitle: Text(
                          provider.getLatestMessage(user.id.toString()) ??
                              user.createdAt?.toIso8601String() ??
                              'No message yet',
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
