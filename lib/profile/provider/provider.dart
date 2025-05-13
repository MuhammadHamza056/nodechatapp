import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/constant/base_client.dart';
import 'package:flutternode/constant/baseurl.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ProfileProvider extends ChangeNotifier {
  bool isEditing = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  File? get selectedImage => _selectedImage;

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

  updateProfile(String profile, String name, String email, String bio) {
    EasyLoading.show(status: "Updating...");
    try {
      var payload = {
        "UserId": HiveService.getTokken(),
        "profile": selectedImage,
        "name": usernameController.text,
        "email": emailController.text,
        "bio": bioController.text,
      };
      BaseClients.post(
        baseUrl: baseUrl,
        api: 'updateprofile',
        payloadObj: payload,
      );
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      final String fileName = path.basename(pickedFile.path);
      print("Selected file name: $fileName"); // <-- Just the file name
      // If you still need the file for upload, keep this:
      _selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      debugPrint('this is the path: ${selectedImage.toString()}');
      notifyListeners();
    }
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }
}
