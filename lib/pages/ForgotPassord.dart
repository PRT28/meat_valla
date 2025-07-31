import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  final _auth = FirebaseAuth.instance;

  void showSnackBar(String message, {Color bgColor = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showSnackBar("Please enter your email", bgColor: Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      showSnackBar("Password reset link sent to $email", bgColor: Colors.green);
    } on FirebaseAuthException catch (e) {
      showSnackBar(e.message ?? "Failed to send reset email", bgColor: Colors.red);
    } catch (e) {
      showSnackBar("Error: $e", bgColor: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E1F1F),
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF6E1F1F),
          title: const Text(
              "Forgot Password",
            style: TextStyle(color: Colors.white),
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 240, // Increased image height
                width: 240,
                child: Image.asset(
                  'assets/forgot-password.png',
                  fit: BoxFit.cover,
                )
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            const Text(
              "Enter your email and we'll send you a link to reset your password.",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Email address",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : sendResetLink,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}
