import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/constant/camera_dailog.dart';
import 'package:flutternode/profile/provider/provider.dart';
import 'package:flutternode/widget/custom_Elevated_Button.dart';
import 'package:flutternode/widget/custom_textifeld.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: const Text('Profile'),
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  provider.isEdite();
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 20,
          children: [
            // Profile Image Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Consumer<ProfileProvider>(
                  builder: (context, prov, child) {
                    return GestureDetector(
                      onLongPress: () {
                        prov.clearImage();
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            prov.selectedImage != null
                                ? FileImage(prov.selectedImage!)
                                : AssetImage('person.png') as ImageProvider,
                      ),
                    );
                  },
                ),
                if (prov.isEditing)
                  FloatingActionButton.small(
                    backgroundColor: Colors.white,

                    onPressed: () {
                      CameraDailog().showImageSourceDialog(context);
                    },
                    child: const Icon(
                      CupertinoIcons.camera,
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Username Section
            CustomTextField(
              hintText: 'Enter your User name',
              labelText: 'User Name',
              controller: prov.usernameController,
              enabled: prov.isEditing,
              obscureText: false,
            ),

            // Email Section (read-only)
            CustomTextField(
              hintText: 'Enter your Email',
              labelText: 'Email',
              enabled: prov.isEditing,
              obscureText: false,
              controller: prov.emailController,
            ),

            // Bio Section
            CustomTextField(
              hintText: 'Enter your bio',
              labelText: 'Bio',
              obscureText: false,
              controller: prov.bioController,
              enabled: prov.isEditing,
              maxLines: 3,
            ),

            // Save Button (only visible when editing)
            if (prov.isEditing)
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  text: 'Save',
                  onPressed: () {
                    if (prov.usernameController.text.isNotEmpty ||
                        prov.emailController.text.isNotEmpty ||
                        prov.bioController.text.isNotEmpty) {
                      
                    } else {
                      EasyLoading.showError('please fill the data');
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
