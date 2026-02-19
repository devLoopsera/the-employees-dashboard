import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _obscurePassword = true.obs;

  @override
  Widget build(BuildContext context) {
    // using a white/black/slate palette similar to shadcn
    const labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black, // shadcn label color often implies high contrast
    );

    return Scaffold(
      backgroundColor: Colors.white, // Or a very light gray if desired
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4, // Subtle shadow
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            surfaceTintColor: Colors.white,
            color: Colors.white,
            clipBehavior: Clip.hardEdge,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 350), // "w-full max-w-sm" match
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // Left aligned headers
                children: [
                  // CardHeader
                  const Text(
                    'Login to your account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter your email below to login to your account',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CardContent -> Form
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field
                      const Text('Email', style: labelStyle),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'm@example.com',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6), // smaller radius
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Colors.black, width: 1.5), // focusing effect
                          ),
                        ),
                      ),
                      const SizedBox(height: 24), // gap-6 equivalent

                      // Password Field
                      const Text('Password', style: labelStyle),
                      const SizedBox(height: 8),
                      Obx(() => TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword.value,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Colors.black, width: 1.5),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                              color: Colors.grey.shade500,
                            ),
                            onPressed: () => _obscurePassword.toggle(),
                          ),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 24), // CardFooter gap

                  // Login Button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              authController.login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Primary button color
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        disabledBackgroundColor: Colors.black.withOpacity(0.5),
                      ),
                      child: authController.isLoading.value
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
