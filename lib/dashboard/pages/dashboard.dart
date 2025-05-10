import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutternode/chates/pages/home_page.dart';
import 'package:flutternode/dashboard/provider/provider.dart';
import 'package:flutternode/profile/pages/profile.dart';
import 'package:flutternode/setting/pages/setting.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Widget> _screens = [
    const HomePage(),
    const ProfileScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DashboardProvider>(context);
    return Scaffold(
      body: _screens[prov.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: prov.currentIndex,
        onTap: (index) {
          debugPrint(index.toString());
          prov.selectedIndex(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
