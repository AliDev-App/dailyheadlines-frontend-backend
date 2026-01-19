import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _showPassword = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate() || !_agreeToTerms) return;

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'http://localhost:3000/signup',
    ); // change to your actual backend IP
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'password': _passwordCtrl.text,
        'role': _roleCtrl.text.trim().toLowerCase(), // 'user' or 'domain'
      }),
    );

    setState(() => _isLoading = false);

    final result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Signup successful!')),
      );
      if ((result['message'] ?? '').toLowerCase().contains("success")) {
        Navigator.pop(context); // go to login
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Signup failed')),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
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
              Icons.person_add_alt_1,
              size: 100,
              color: Colors.black,
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
            const SizedBox(height: 10),
            Text(
              'Create Account',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _inputDecoration('Name', Icons.person),
                    validator:
                        (value) => value!.isEmpty ? 'Enter your name' : null,
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _roleCtrl,
                    decoration: _inputDecoration(
                      'Role (user/domain)',
                      Icons.verified_user,
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter role: user/domain' : null,
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailCtrl,
                    decoration: _inputDecoration('Email', Icons.email),
                    validator:
                        (value) =>
                            value!.isEmpty || !value.contains('@')
                                ? 'Enter valid email'
                                : null,
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: !_showPassword,
                    decoration: _inputDecoration('Password', Icons.lock),
                    validator:
                        (value) =>
                            value!.length < 6
                                ? 'Password must be 6+ characters'
                                : null,
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: !_showPassword,
                    decoration: _inputDecoration(
                      'Confirm Password',
                      Icons.lock_outline,
                    ),
                    validator:
                        (value) =>
                            value != _passwordCtrl.text
                                ? 'Passwords do not match'
                                : null,
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(
                        value: _showPassword,
                        onChanged:
                            (value) => setState(() => _showPassword = value!),
                      ),
                      const Text("Show Password"),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged:
                            (value) => setState(() => _agreeToTerms = value!),
                      ),
                      const Expanded(
                        child: Text(
                          "I agree to the Terms & Conditions",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 10),

                  _isLoading
                      ? const CircularProgressIndicator().animate().fadeIn()
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
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
