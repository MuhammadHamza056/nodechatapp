import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/constant/file_upload_service.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/utils/chat_status.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService extends ChangeNotifier {
  late io.Socket socket;
  //final String _serverUrl = 'http://192.168.0.187:3000';
  final String _serverUrl = 'http://172.17.2.20:3000';
  //final String _serverUrl = 'https://node-1-i9yt.onrender.com';

  String? targetUserId;
  String? fileUrl;

  // Connection state variables
  bool isConnected = false;
  static const int _maxReconnectionAttempts = 5;

  // Message state variables
  final List<Map<String, dynamic>> _messages = [];
  bool _isOtherUserTyping = false;
  final Map<String, String> _latestMessages = {};
  final Set<String> _onlineUsers = {};
  final Map<String, int> _unreadMessageCount = {};
  bool isOtherUserOnline = false;
  DateTime? lastSeen;
  final player = AudioPlayer();

  // Getters
  List<Map<String, dynamic>> get messages => _messages;
  bool get isOtherUserTyping => _isOtherUserTyping;
  String? getLatestMessage(String userId) => _latestMessages[userId];
  bool isUserOnline(String userId) => _onlineUsers.contains(userId);
  int getUnreadMessageCount(String userId) => _unreadMessageCount[userId] ?? 0;

  isConected(bool status) {
    isConnected = status;
    notifyListeners();
  }

  saveTergetUserid(String id) {
    targetUserId = id;
    notifyListeners();
  }

  void playTypingSound() async {
    player.stop();
    if (ChatState.isChatScreenActive) {
      player.play(AssetSource('typing_sound.wav'));
    }
  }

  Future<void> playMessageSound() async {
    try {
      // Only play sound if NOT in chat screen
      if (!ChatState.isChatScreenActive) {
        await player.stop();
        await player.setVolume(1.0);

        // Load and play the sound
        await player.setSourceAsset('message.mp3');
        await player.play(AssetSource('message.mp3'));
        await player.onPlayerComplete.first;
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  imageUrl(imageUrl) {
    fileUrl = imageUrl;
    notifyListeners();
  }

  //FUNCTION TO UPLOAD THE FILE TO SERVER
  uploadFile() async {
    EasyLoading.show(status: 'Uploading File...');
    try {
      FileUploadService.sendFile(
        targetUserId.toString(),
        HiveService.getTokken(),
      );
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
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

      socket.connect();
    } catch (e) {
      EasyLoading.showError('Socket init error');
      debugPrint('Socket initialization error: $e');

      rethrow;
    }
  }

  // Set up all socket event handlers
  void _setupSocketHandlers() {
    socket.onConnect((_) {
      debugPrint('✅ Connected with ID: ${socket.id}');
      isConected(true);

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
      final currentUserId = HiveService.getTokken();

      if (data['from'] == currentUserId) {
        // Sender receives their own message with status
        addMessages(data); // ✅ Add only once, with correct status
      } else if (data['to'] == currentUserId) {
        // Receiver gets message
        addMessages(data);
        playMessageSound();
      }

      debugPrint('📨 Processed message: $data');
    });

    socket.on('typing', (data) {
      debugPrint('✍️ Typing status: $data');
      if (data['from'] != HiveService.getTokken()) {
        _isOtherUserTyping = data['isTyping'] ?? false;
        playTypingSound();
        notifyListeners();
      }
    });

    socket.on('user_status', (data) {
      final userId = data['userId'];
      final status = data['status'];
      debugPrint('🔔 User status update: $data');

      if (status == 'online') {
        _onlineUsers.add(userId);
      } else {
        _onlineUsers.remove(userId);
      }

      notifyListeners();
    });

    socket.onError((err) {
      debugPrint('❌ Socket error: $err');
      EasyLoading.showError('Connection error');
      isConected(false);
      notifyListeners();
    });
    socket.onReconnect((_) {
      isConected(true);
      notifyListeners();
    });
    socket.on("new_file", (data) {
      fileUrl = data["fileUrl"];
      imageUrl(data["fileUrl"]);
      addMessages(data);
      playMessageSound();
      notifyListeners();
    });

    socket.onDisconnect((data) {
      debugPrint('🔌 Disconnected from socket server: $data');
      isConected(false);
    });
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
    socket.disconnect();
    super.dispose();
  }
}
