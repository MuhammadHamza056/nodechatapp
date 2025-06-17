// lib/router/app_router.dart
import 'package:flutternode/chates/pages/home_page.dart';
import 'package:flutternode/chates/pages/login_page.dart';
import 'package:flutternode/chates/pages/sign_up_page.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/dashboard/pages/dashboard.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'login',
      builder: (context, state) {
        return HiveService.getUserLogin() ? DashboardScreen() : LoginPage();
      },
    ),

    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

    GoRoute(path: '/', redirect: (context, state) => '/login'),
  ],
);
