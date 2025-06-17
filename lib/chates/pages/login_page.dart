import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/chates/provider/provider.dart';
import 'package:flutternode/widget/custom_textifeld.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderClass>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Login Fields & Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  Text(
                    "Sign in to continue",
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
                        controller: provider.emailController,
                        labelText: 'Email',
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.grey,
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter your email'
                                    : null,
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
                          bool success = await provider.login();
                          if (success) {
                            context.go('/dashboard');
                            provider.emailController.clear();
                            provider.passwordController.clear();
                          }
                        } else {
                          EasyLoading.showError('Please fill the fields above');
                        }
                      },
                      child: const Text("Login"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Create a new account? "),
                      GestureDetector(
                        onTap: () {
                          context.go('/signup');
                          provider.clearValues();
                        },
                        child: const Text(
                          "SIGNUP",
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
