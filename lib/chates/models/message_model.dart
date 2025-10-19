import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel {
  @HiveField(0)
  final String? sender;

  @HiveField(1)
  final String? text;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? messageType;

  @HiveField(4)
  final String? fileUrl;

  @HiveField(5)
  final String? localPath;

  @HiveField(6)
  final String? receiver;

  @HiveField(7)
  final String? status;

  @HiveField(8)
  final String? messageId;

  MessageModel({
    required this.sender,
    required this.receiver,
    required this.text,
    required this.timestamp,
    required this.messageType,
    required this.status,
    required this.messageId,
    this.fileUrl,
    this.localPath,
  });

  /// ✅ Create a new copy with updated fields
  MessageModel copyWith({
    String? sender,
    String? receiver,
    String? text,
    DateTime? timestamp,
    String? messageType,
    String? fileUrl,
    String? localPath,
    String? status,
    String? messageId,
  }) {
    return MessageModel(
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      messageId: messageId ?? this.messageId,
    );
  }

  /// ✅ Convert to JSON (for storing to Hive as map)
  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'receiver': receiver,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType,
      'fileUrl': fileUrl,
      'localPath': localPath,
      'status': status,
      'messageId': messageId,
    };
  }

  /// ✅ Convert from JSON (if loading from map)
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      sender: json['sender'],
      receiver: json['receiver'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
      messageType: json['messageType'],
      fileUrl: json['fileUrl'],
      localPath: json['localPath'],
      status: json['status'],
      messageId: json['messageId'],
    );
  }

  @override
  String toString() {
    return 'From: $sender, To: $receiver, Text: $text, Type: $messageType, Status: $status, Time: $timestamp';
  }
}
