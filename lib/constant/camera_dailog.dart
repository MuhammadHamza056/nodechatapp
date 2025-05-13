import 'package:flutter/material.dart';
import 'package:flutternode/profile/provider/provider.dart';
import 'package:provider/provider.dart';

class CameraDailog {
  void showImageSourceDialog(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Change Profile Picture'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Take Photo'),
                  onTap: () {
                    provider.pickImageFromCamera();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    provider.pickImageFromGallery();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
