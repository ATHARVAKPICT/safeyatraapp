import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signup.dart'; // Import the signup page
import 'map.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignInPressed() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('https://safeyatra.onrender.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": _emailController.text,
          "phone_number": "",
          "age": 0,
          "gender": "",
          "password": _passwordController.text,
          "full_name": "",
          "vehicle_number": "",
          "vehicle_color": "",
          "emergency_contacts": [],
          "work_address": "",
          "home_address": ""
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, '/basicMap');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: Image.asset(
                  'assets/safeyatraofficiallogo.png',
                  height: 60,
                  width: 60,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign In',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: const Color.fromRGBO(216, 196, 182, 1)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(Icons.email, color: Colors.white),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _onSignInPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Sign In', style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?", style: TextStyle(color: Color.fromRGBO(216, 196, 182, 1))),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpPage()),
                              );
                            },
                            child: const Text('Create Account', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedGradientBackground extends StatelessWidget {
  final Widget child;
  const AnimatedGradientBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(33, 53, 85, 1),
            Color.fromRGBO(62, 88, 121, 1),
          ],
        ),
      ),
      child: child,
    );
  }
}
