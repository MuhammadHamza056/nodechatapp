import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/chates/models/message_model.dart';
import 'package:flutternode/constant/file_upload_service.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/utils/chat_status.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService extends ChangeNotifier {
  late io.Socket socket;
  final String _serverUrl = 'http://172.17.2.90:3000';

  String? targetUserId;
  String? fileUrl;
  List<MessageModel> usermessages = [];

  bool isConnected = false;
  static const int _maxReconnectionAttempts = 5;

  bool _isOtherUserTyping = false;
  final Map<String, String> latestMessages = {};
  final Set<String> _onlineUsers = {};
  final Map<String, int> _unreadMessageCount = {};
  final Map<String, String> _messageStatuses = {}; // messageId → status

  final player = AudioPlayer();
  DateTime? lastSeen;

  // Getters
  bool get isOtherUserTyping => _isOtherUserTyping;
  int getUnreadMessageCount(String userId) => _unreadMessageCount[userId] ?? 0;
  bool isUserOnline(String userId) => _onlineUsers.contains(userId);
  String getMessageStatus(String messageId) =>
      _messageStatuses[messageId] ?? 'sent';
  String? getLatestMessage(String userId) => latestMessages[userId];

  void isConected(bool status) {
    isConnected = status;
    notifyListeners();
  }

  void saveTergetUserid(String id) {
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
      if (!ChatState.isChatScreenActive) {
        await player.stop();
        await player.setVolume(1.0);
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

  Future<void> uploadFile() async {
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

  Future<void> initializeSocket() async {
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
  }

  void _setupSocketHandlers() {
    socket.onConnect((_) {
      isConected(true);
      notifyListeners();
      socket.emit('authenticate', {
        'userId': HiveService.getTokken(),
        'lastSeen': DateTime.now().toIso8601String(),
      });
    });

    socket.on('authentication-success', (_) {
      debugPrint('🔐 Authenticated by server');
    });

    socket.on('new-message', (data) {
      addMessages(data);
      playMessageSound();

      debugPrint('📨 Message received: $data');
    });

    socket.on('message-status', (data) {
      final mid = data['messageId'];
      final status = data['status'];
      final fromUserId = data['from'];
      final toUserId = data['to'];

      if (mid != null &&
          status != null &&
          fromUserId != null &&
          toUserId != null) {
        _messageStatuses[mid] = status;

        notifyListeners();
        debugPrint(
          '✅ Message $mid from $fromUserId to $toUserId marked $status',
        );
      }
    });

    socket.on('typing', (data) {
      if (data['from'] != HiveService.getTokken()) {
        _isOtherUserTyping = data['isTyping'] ?? false;
        if (_isOtherUserTyping) playTypingSound();
        notifyListeners();
      }
    });

    socket.on('user_status', (data) {
      final userId = data['userId'];
      final status = data['status'];
      if (status == 'online')
        _onlineUsers.add(userId);
      else
        _onlineUsers.remove(userId);
      notifyListeners();
    });

    socket.on("new_file", (data) {
      fileUrl = data["fileUrl"];
      imageUrl(data["fileUrl"]);
      addMessages(data);
      playMessageSound();
    });

    socket.onDisconnect((_) {
      isConected(false);
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
  }

  void loadLastMessage(String u1, String u2) {
    final m = HiveService.getLastMessage(u1, u2);
    if (m != null) {
      latestMessages[u1] = m.text.toString();
      notifyListeners();
    }
  }

  void addMessages(Map<String, dynamic> data) {
    final from = data['from'];
    final to = data['to'];
    final messageId = data['messageId'];
    final text = data['message'] ?? '';
    final ts = DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now();
    final messageType = data['messageType'] ?? 'text';
    final fUrl = data['fileUrl'];
    final lPath = data['localPath'];
    final status = data['status'] ?? 'sent';
    final currentUser = HiveService.getTokken();

    latestMessages[from] = text;

    final msg = MessageModel(
      sender: from,
      receiver: to,
      text: text,
      messageId: messageId,
      timestamp: ts,
      messageType: messageType,
      status: status,
      fileUrl: fUrl,
      localPath: lPath,
    );

    HiveService.saveMessage(from, to, msg);
    debugPrint('✅ Saved message: $msg');

    loadLastMessage(from, to);
    loadMessages(from, to);

    if (from != currentUser) {
      _unreadMessageCount[from] = (_unreadMessageCount[from] ?? 0) + 1;
    }

    notifyListeners();
  }

  void loadMessages(String u1, String u2) {
    usermessages = HiveService.getMessages(u1, u2);
    notifyListeners();
  }

  Future<void> sendMessage(
    String receiverId,
    String message,
    String messageId,
  ) async {
    final data = {
      'to': receiverId,
      'message': message,
      'messageId': messageId,
      'from': HiveService.getTokken(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    socket.emit('send-message', data);
    _messageStatuses[messageId] = 'sent';
    notifyListeners();
  }

  void sendTypingStatus(String rid, bool isTyping) {
    socket.emit('typing', {
      'from': HiveService.getTokken(),
      'to': rid,
      'isTyping': isTyping,
    });
  }

  void markMessagesAsRead(String userId) {
    _unreadMessageCount[userId] = 0;
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
    return status == 'read' ? Colors.lightGreenAccent.shade400 : Colors.white70;
  }

  String formatTimestamp(dynamic ts) {
    try {
      final date =
          (ts is String ? DateTime.parse(ts) : ts as DateTime).toLocal();
      return DateFormat.jm().format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
