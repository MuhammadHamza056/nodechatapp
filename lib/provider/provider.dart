import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/constant/base_client.dart';
import 'package:flutternode/constant/baseurl.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/models/get_user_model.dart';
import 'package:flutternode/models/login_user_model.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ProviderClass extends ChangeNotifier {
  late io.Socket socket;
  bool _isOtherUserTyping = false;
  final List<Map<String, dynamic>> _messages = [];
  final Map<String, String> _latestMessages = {};
  final Map<String, int> _unreadMessageCount = {};
  bool isConnected = true;

  //final String _serverUrl = 'http://192.168.0.187:4000';
  final String _serverUrl = 'http://172.17.2.20:4000';

  List<Map<String, dynamic>> get messages => _messages;

  bool get isOtherUserTyping => _isOtherUserTyping;

  //TEXTEDIT CNOTORLLERS
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController textController = TextEditingController();

  //THESE ARE THE MODEL INSTANCES \
  GetUsersModel? getUsersModel;
  UserLoginModel? loginUser;

  bool obscureText = true;
  bool isOtherUserOnline = false;

  togglePasswordVisibility() {
    obscureText = !obscureText;
    notifyListeners();
  }

  //THIS IS SIGN UP FUNCTION
  Future<bool> signUp() async {
    EasyLoading.show(status: 'Registering...');
    try {
      Map<String, dynamic> payload = {
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      };

      var res = await BaseClients.post(
        baseUrl: baseUrl,
        api: "signup",
        payloadObj: payload,
      );
      res.body;
      return true;
    } catch (e) {
      EasyLoading.showError('Error: $e');
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  //THIS IS THE LOGIN FUNCTION
  Future<bool> login() async {
    EasyLoading.show(status: 'logging in..');
    try {
      var payload = {
        'email': emailController.text..trim(),
        'password': passwordController.text.trim(),
      };

      var res = await BaseClients.post(
        baseUrl: baseUrl,
        api: 'login',
        payloadObj: payload,
      );

      loginUser = userLoginModelFromJson(res.body);

      if (loginUser?.status == 200) {
        HiveService.putTokken(loginUser!.user!.id.toString());
        HiveService.putUserLogin(true);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      EasyLoading.showError(e.toString());
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  //THIS IS LOGOUT FUNCTION
  logOut() async {
    HiveService.deleteHiveData();
    notifyListeners();
  }

  //THIS IS FUNCTION TO GET ALL THE USERS
  getUsers() async {
    EasyLoading.show(status: 'Loading users...');
    try {
      final response = await BaseClients.get(
        baseUrl,
        'getUser?userId=${HiveService.getTokken()}',
      );

      getUsersModel = getUsersModelFromJson(response.body);

      if (getUsersModel?.data?.isEmpty ?? true) {
        throw Exception('No users found');
      }

      EasyLoading.showSuccess('Users loaded successfully');
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
      notifyListeners();
    }
  }

  clearValues() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
  }

  addMessages(data) {
    messages.add(Map<String, dynamic>.from(data));
    final fromUserId = data['from'];
    final messageText = data['message'];

    // Save latest message
    _latestMessages[fromUserId] = messageText;

    if (fromUserId != HiveService.getTokken().toString()) {
      _unreadMessageCount[fromUserId] =
          (_unreadMessageCount[fromUserId] ?? 0) + 1;
    }

    notifyListeners();
  }

  String? getLatestMessage(String userId) => _latestMessages[userId];

  int getUnreadMessageCount(String userId) {
    return _unreadMessageCount[userId] ?? 0;
  }

  void markMessagesAsRead(String userId) {
    _unreadMessageCount[userId] = 0;
    notifyListeners();
  }

  Future<void> initializeSocket() async {
    try {
      socket = io.io(
        _serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _setupSocketHandlers();
      socket.connect();
    } catch (e) {
      EasyLoading.showError('Socket init error');
      debugPrint('Socket initialization error: $e');
      rethrow;
    }
  }

  void _setupSocketHandlers() {
    socket.onConnect((_) {
      debugPrint('✅ Connected with ID: ${socket.id}');

      // Emit authentication after connection
      socket.emit('authenticate', {'userId': HiveService.getTokken()});

      notifyListeners();
    });

    socket.on('authentication-success', (_) {
      debugPrint('🔐 Authentication confirmed by server');
      notifyListeners();
    });

    socket.on('new-message', (data) {
      debugPrint('📨 Received message: $data');
      addMessages(data);
    });

    socket.on('typing', (data) {
      debugPrint('✍️ Typing status: $data');

      if (data['from'] != HiveService.getTokken()) {
        _isOtherUserTyping = data['isTyping'] ?? false;
        notifyListeners();
      }
    });

    socket.on('user-status', (data) {
      debugPrint('🔔 User status update: $data');
      isOtherUserOnline = data['status'] == "online";
      notifyListeners();
    });

    socket.onError((err) {
      EasyLoading.showError('Socket error');
      debugPrint('❌ Socket error: $err');
    });

    socket.onDisconnect((_) {
      debugPrint('🔌 Disconnected from socket server');
      isOtherUserOnline = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final messageData = {
        'to': receiverId,
        'message': message,
        'from': HiveService.getTokken(),
        'timestamp': DateFormat.jm().format(DateTime.now()),
      };

      debugPrint('📤 Sending message: $messageData');
      socket.emit('send-message', messageData);
      // addMessages(messageData);
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      rethrow;
    }
  }

  void sendTypingStatus(String receiverId, bool isTyping) {
    socket.emit('typing', {
      'from': HiveService.getTokken(),
      'to': receiverId,
      'isTyping': isTyping,
    });
  }

  void disconnect() {
    socket.disconnect();
    debugPrint('🔌 Manually disconnected');
    notifyListeners();
  }

  IconData getStatusIcon(String? status) {
    switch (status) {
      case 'sent':
        return Icons.check;
      case 'delivered':
        return Icons.done_all;
      case 'read':
        return Icons.done_all;
      default:
        return Icons.check;
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'read':
        return Colors.lightGreenAccent.shade400; // Green
      default:
        return Colors.white70; // Grey/white for sent/delivered
    }
  }

  // Helper method to safely convert dynamic to String
  String getStringFromDynamic(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map)
      return value['userId']?.toString() ?? ''; // Handle user object case
    return value.toString();
  }

  // Helper method to format timestamp
  String formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return '';
      DateTime date;
      if (timestamp is String) {
        date = DateTime.parse(timestamp).toLocal();
      } else if (timestamp is DateTime) {
        date = timestamp.toLocal();
      } else {
        return '';
      }

      return DateFormat.jm().format(date); // e.g., 4:05 AM
    } catch (e) {
      return '';
    }
  }
}
