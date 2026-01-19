import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  bool _isLoading = false;

  void _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await http.post(
          Uri.parse(
            'http://localhost:3000/reset-password',
          ), // ⚠️ Replace with your real backend URL
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailCtrl.text.trim(),
            'newPassword': _newPasswordCtrl.text.trim(),
          }),
        );

        setState(() => _isLoading = false);

        final data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'Reset failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Icon(
              Icons.lock_reset,
              size: 100,
              color: Colors.black,
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
            const SizedBox(height: 10),
            const Text(
              'Forgot Password',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ).animate().fadeIn(),
            const SizedBox(height: 10),
            const Text(
              'Enter your email and a new password.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ).animate().fadeIn(),

            const SizedBox(height: 30),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email Field
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email Address', Icons.email),
                    validator:
                        (value) =>
                            value!.isEmpty || !value.contains('@')
                                ? 'Enter a valid email'
                                : null,
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),

                  const SizedBox(height: 20),

                  // New Password Field
                  TextFormField(
                    controller: _newPasswordCtrl,
                    obscureText: true,
                    decoration: _inputDecoration('New Password', Icons.lock),
                    validator:
                        (value) =>
                            value!.length < 6
                                ? 'Enter a new password (min 6 characters)'
                                : null,
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _isLoading
                ? const CircularProgressIndicator().animate().fadeIn()
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendResetLink,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.2),

            const SizedBox(height: 20),

            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              label: const Text(
                'Back to Login',
                style: TextStyle(color: Colors.black),
              ),
            ).animate().fadeIn(),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
