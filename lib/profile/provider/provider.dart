import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  bool isEditing = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  
  isEdite() {
    isEditing = !isEditing;
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }
}
