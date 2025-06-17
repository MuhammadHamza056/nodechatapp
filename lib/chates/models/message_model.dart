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
  final String? messageType; // e.g., 'text', 'image', 'file'

  @HiveField(4)
  final String? fileUrl;

  @HiveField(5)
  final String? localPath;

  @HiveField(6)
  final String? receiver; // ✅ new field

  @HiveField(7)
  final String? status; // ✅ new field: 'sent', 'delivered', 'read'

  MessageModel({
    required this.sender,
    required this.receiver, // ✅
    required this.text,
    required this.timestamp,
    required this.messageType,
    required this.status, // ✅
    this.fileUrl,
    this.localPath,
  });

  @override
  String toString() {
    return 'From: $sender, To: $receiver, Text: $text, Type: $messageType, Status: $status, Time: $timestamp';
  }
}
