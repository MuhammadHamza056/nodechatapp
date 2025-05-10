import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
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
          children: [
            // Profile Image Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/1.jpg',
                  ),
                ),
                if (prov.isEditing)
                  FloatingActionButton.small(
                    onPressed: () {
                      // Add image picker functionality here
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
            const SizedBox(height: 20),

            // Email Section (read-only)
            CustomTextField(
              hintText: 'Enter your Email',
              labelText: 'Email',
              enabled: prov.isEditing,
              obscureText: false,
              controller: prov.emailController,
            ),
            const SizedBox(height: 20),

            // Bio Section
            CustomTextField(
              hintText: 'Enter your bio',
              labelText: 'Bio',
              obscureText: false,
              controller: prov.bioController,
              enabled: prov.isEditing,
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            // Save Button (only visible when editing)
            if (prov.isEditing)
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  text: 'Save',
                  onPressed: () {},
                ),
              ),
          ],
        ),
      ),
    );
  }
}
