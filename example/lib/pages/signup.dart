import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'guardian_setup.dart';
import 'package:http/http.dart' as http; //delete
import 'dart:convert'; //delete

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedGender = 'Female';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // void _onSignUpPressed() {
  //   if (_formKey.currentState!.validate()) {
  //     // Check age and navigate to guardian setup if needed
  //     int age = int.parse(_ageController.text);
  //     if (age < 15) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => GuardianSetupPage(
  //             childAge: _ageController.text,
  //           ),
  //         ),
  //       );
  //     } else {
  //       // TODO: Implement regular sign up logic
  //       print('Email: ${_emailController.text}');
  //       print('Phone: ${_phoneController.text}');
  //       print('Age: ${_ageController.text}');
  //       print('Gender: $_selectedGender');
  //       print('Password: ${_passwordController.text}');
  //     }
  //   }
  // }
  void _onSignUpPressed() async {
    if (_formKey.currentState!.validate()) {
      int age = int.parse(_ageController.text);
      if (age < 15) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuardianSetupPage(
              childAge: _ageController.text,
            ),
          ),
        );
      } else {
        // Prepare the data to be sent
        final Map<String, dynamic> signUpData = {
          "email": _emailController.text,
          "phone_number": _phoneController.text,
          "age": age,
          "gender": _selectedGender,
          "password": _passwordController.text,
          "full_name": "", // Add fields as needed
          "vehicle_number": "",
          "vehicle_color": "",
          "emergency_contacts": [],
          "work_address": "",
          "home_address": "",
        };

        // Convert the data to JSON
        final String jsonData = jsonEncode(signUpData);

        // Send the POST request
        final response = await http.post(
          Uri.parse('https://safeyatra.onrender.com/auth/register'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        // Check the response status
        if (response.statusCode == 200) {
          // Handle successful sign-up
          print('Sign-up successful');
          // Navigate to the next screen or show a success message
        } else {
          // Handle error
          print('Sign-up failed: ${response.body}');
          // Show an error message to the user
        }
      }
    }
  }

//yacha varcha delete
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/safeyatraofficiallogo.png', // Your asset image path
                        width: 50, // Adjust size as needed
                        height: 50,
                      ),
                      const SizedBox(width: 0),
                      Text(
                        'Create Account',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: const Color.fromRGBO(216, 196, 182, 1),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      int? age = int.tryParse(value);
                      if (age == null || age < 13 || age > 120) {
                        return 'Please enter a valid age between 13 and 120';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedGender,
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGender = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _onSignUpPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Sign In',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignment;
  late Animation<Alignment> _bottomAlignment;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));

    _topAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.centerRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.centerRight, end: Alignment.bottomRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.centerLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.centerLeft, end: Alignment.topLeft),
          weight: 1),
    ]).animate(_controller);

    _bottomAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.centerLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.centerLeft, end: Alignment.topLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.centerRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.centerRight, end: Alignment.bottomRight),
          weight: 1)
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: _topAlignment.value,
                    end: _bottomAlignment.value,
                    colors: const [
                  Color.fromRGBO(33, 53, 85, 1),
                  Color.fromRGBO(62, 88, 121, 1),
                ])),
            child: widget.child,
          );
        });
  }
}
