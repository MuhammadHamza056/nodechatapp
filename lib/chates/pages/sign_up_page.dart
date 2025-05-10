import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/chates/provider/provider.dart';
import 'package:flutternode/widget/custom_textifeld.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderClass>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Signup',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // FORM FIELDS AND BUTTON
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const Text(
                    "Create a new account",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Consumer<ProviderClass>(
                    builder: (context, provider, child) {
                      return CustomTextField(
                        borderRadius: 12,
                        borderColor: Colors.grey,
                        controller: provider.nameController,
                        labelText: 'Name',
                        obscureText: false,
                        keyboardType: TextInputType.name,
                        prefixIcon: const Icon(
                          Icons.person_2_outlined,
                          color: Colors.grey,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  Consumer<ProviderClass>(
                    builder: (context, provider, child) {
                      return CustomTextField(
                        borderRadius: 12,
                        borderColor: Colors.grey,
                        controller: provider.emailController,
                        labelText: 'Email',
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.grey,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      );
                    },
                  ),

                  Consumer<ProviderClass>(
                    builder: (context, provider, child) {
                      return CustomTextField(
                        borderRadius: 12,
                        borderColor: Colors.grey,
                        controller: provider.passwordController,
                        labelText: 'Password',
                        isPasswordField: true,
                        obscureText: provider.obscureText,
                        onTap: () => provider.togglePasswordVisibility(),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      );
                    },
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (provider.emailController.text.isNotEmpty &&
                            provider.passwordController.text.isNotEmpty) {
                          bool success = await provider.signUp();
                          if (success) {
                            context.go('/login');
                            provider.clearValues();
                          }
                        } else {
                          EasyLoading.showError('Please fill the fields above');
                        }
                      },
                      child: const Text("Signup"),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          context.go('/login');
                          provider.clearValues();
                        },
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
