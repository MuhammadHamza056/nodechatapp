// Status model class
class UserStatus {
  final String userId;
  final String status; // 'online' or 'offline'
  final DateTime? lastSeen;

  UserStatus({required this.userId, required this.status, this.lastSeen});
}
