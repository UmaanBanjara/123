import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? message;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) return 'Invalid email';
    return null;
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      message = null;
    });

    final email = emailController.text.trim();
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      setState(() {
        isLoading = false;
        if (response.statusCode == 200) {
          message = 'Reset password email sent!';
        } else {
          message = data['error'] ?? 'Failed to send reset email.';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Enter your email'),
                validator: validateEmail,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : submit,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send Reset Email'),
            ),
            const SizedBox(height: 20),
            if (message != null)
              Text(
                message!,
                style: TextStyle(color: message!.startsWith('Error') || message!.contains('Failed') ? Colors.red : Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
