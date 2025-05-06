// lib/router/app_router.dart
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/pages/home_page.dart';
import 'package:flutternode/pages/login_page.dart';
import 'package:flutternode/pages/sign_up_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        return HiveService.getUserLogin() ? HomePage() : LoginPage();
      },
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

    GoRoute(path: '/', redirect: (context, state) => '/login'),
  ],
);
