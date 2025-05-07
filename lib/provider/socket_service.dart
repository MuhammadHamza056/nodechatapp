import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/utils/life_cycle.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService extends ChangeNotifier {
  late io.Socket socket;
  final String _serverUrl = 'https://node-1-i9yt.onrender.com';

  // Connection state variables
  bool isConnected = false;
  int _reconnectionAttempts = 0;
  static const int _maxReconnectionAttempts = 5;
  DateTime? _lastConnectionAttempt;

  // Message state variables
  final List<Map<String, dynamic>> _messages = [];
  bool _isOtherUserTyping = false;
  final Map<String, String> _latestMessages = {};
  final Map<String, int> _unreadMessageCount = {};
  bool isOtherUserOnline = false;
  DateTime? lastSeen;

  // Getters
  List<Map<String, dynamic>> get messages => _messages;
  bool get isOtherUserTyping => _isOtherUserTyping;
  String? getLatestMessage(String userId) => _latestMessages[userId];
  int getUnreadMessageCount(String userId) => _unreadMessageCount[userId] ?? 0;

  isConected(bool status) {
    isConnected = status;
    notifyListeners();
  }

  // Initialize socket connection
  Future<void> initializeSocket() async {
    try {
      socket = io.io(
        _serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setReconnectionAttempts(_maxReconnectionAttempts)
            .setReconnectionDelay(5000)
            .build(),
      );

      _setupSocketHandlers();
      _setupAppLifecycleListeners();
      _lastConnectionAttempt = DateTime.now();
      socket.connect();
    } catch (e) {
      EasyLoading.showError('Socket init error');
      debugPrint('Socket initialization error: $e');
      _attemptReconnection();
      rethrow;
    }
  }

  // Set up all socket event handlers
  void _setupSocketHandlers() {
    socket.onConnect((_) {
      debugPrint('✅ Connected with ID: ${socket.id}');
      isConected(true);
      _reconnectionAttempts = 0;

      // Authenticate with server
      socket.emit('authenticate', {
        'userId': HiveService.getTokken(),
        'lastSeen': DateTime.now().toIso8601String(),
      });

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
      userStatus(data);
    });

    socket.onError((err) {
      debugPrint('❌ Socket error: $err');
      EasyLoading.showError('Connection error');
      isConected(false);

      _attemptReconnection();
    });
    socket.on('reconnect_attempt', (attempt) {
      debugPrint('🔄 Reconnect attempt #$attempt');
      isConected(true);
    });

    socket.onReconnect((_) {
      isConected(true);
    });

    socket.onDisconnect((data) {
      debugPrint('🔌 Disconnected from socket server: $data');
      isConected(false);
      userStatus({'status': 'offline'});
      _attemptReconnection();
    });

    // Ping-pong for connection health
    socket.on('ping', (_) => socket.emit('pong'));
    socket.on('pong', (_) => debugPrint('🏓 Pong received'));
  }

  // Handle app lifecycle changes
  _setupAppLifecycleListeners() {
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async {
          debugPrint('App resumed - updating status to online');
          if (!socket.connected) {
            debugPrint('Socket not connected on resume, reconnecting...');
            socket.connect();
          }
          socket.emit('update-status', {
            'userId': HiveService.getTokken(),
            'status': 'online',
          });
        },
        suspendingCallBack: () async {
          debugPrint('App suspended - updating status to away');
          socket.emit('update-status', {
            'userId': HiveService.getTokken(),
            'status': 'away',
            'lastSeen': DateTime.now().toIso8601String(),
          });
        },
      ),
    );
  }

  // Reconnection logic
  void _attemptReconnection() {
    if (_reconnectionAttempts < _maxReconnectionAttempts) {
      final now = DateTime.now();
      final lastAttempt = _lastConnectionAttempt ?? now;

      // Don't attempt too frequently
      if (now.difference(lastAttempt).inSeconds > 5) {
        _reconnectionAttempts++;
        _lastConnectionAttempt = now;
        debugPrint(
          '♻️ Attempting reconnection (attempt $_reconnectionAttempts)',
        );
        socket.connect();
      }
    } else {
      debugPrint('❌ Max reconnection attempts reached');
      EasyLoading.showInfo('Connection lost. Please check your network.');
    }
    notifyListeners();
  }

  // Message handling
  void addMessages(data) {
    messages.add(Map<String, dynamic>.from(data));
    final fromUserId = data['from'];
    final messageText = data['message'];

    // Save latest message
    _latestMessages[fromUserId] = messageText;

    // Update unread count if message is from another user
    if (fromUserId != HiveService.getTokken().toString()) {
      _unreadMessageCount[fromUserId] =
          (_unreadMessageCount[fromUserId] ?? 0) + 1;
    }

    notifyListeners();
  }

  // User status handling
  void userStatus(data) {
    final newStatus = data['status'];
    if (newStatus == 'online') {
      isOtherUserOnline = true;
      lastSeen = null;
    } else if (newStatus == 'offline') {
      isOtherUserOnline = false;
      lastSeen =
          data['lastSeen'] != null
              ? DateTime.parse(data['lastSeen'])
              : DateTime.now();
    } else if (newStatus == 'away') {
      isOtherUserOnline = false;
      lastSeen =
          data['lastSeen'] != null
              ? DateTime.parse(data['lastSeen'])
              : DateTime.now();
    }
    notifyListeners();
  }

  // Message sending
  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final messageData = {
        'to': receiverId,
        'message': message,
        'from': HiveService.getTokken(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      debugPrint('📤 Sending message: $messageData');
      socket.emit('send-message', messageData);
      addMessages(messageData);
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      EasyLoading.showError('Failed to send message');
      rethrow;
    }
  }

  // Typing indicator
  void sendTypingStatus(String receiverId, bool isTyping) {
    socket.emit('typing', {
      'from': HiveService.getTokken(),
      'to': receiverId,
      'isTyping': isTyping,
    });
  }

  // Message status indicators
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
        return Colors.lightGreenAccent.shade400;
      default:
        return Colors.white70;
    }
  }

  // Mark messages as read
  void markMessagesAsRead(String userId) {
    _unreadMessageCount[userId] = 0;
    notifyListeners();
  }

  // Clean disconnect
  Future<void> disconnectSocket() async {
    try {
      socket.emit('manual-disconnect', {
        'userId': HiveService.getTokken(),
        'lastSeen': DateTime.now().toIso8601String(),
      });
      socket.clearListeners();
      socket.disconnect();
      _reconnectionAttempts = 0;
    } catch (e) {
      debugPrint('Disconnection error: $e');
    }
  }

  // Helper methods
  String getStringFromDynamic(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) return value['userId']?.toString() ?? '';
    return value.toString();
  }

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
      return DateFormat.jm().format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    disconnectSocket();
    WidgetsBinding.instance.removeObserver(
      LifecycleEventHandler(
        resumeCallBack: () {
          return EasyLoading.showSuccess('resume');
        },
        suspendingCallBack: () {
          return EasyLoading.showSuccess('suspend');
        },
      ),
    );
    super.dispose();
  }
}
