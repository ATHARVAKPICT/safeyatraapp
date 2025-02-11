import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GuardianSetupPage extends StatefulWidget {
  final String childAge;

  const GuardianSetupPage({super.key, required this.childAge});

  @override
  _GuardianSetupPageState createState() => _GuardianSetupPageState();
}

class _GuardianSetupPageState extends State<GuardianSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _onCompleteSetup() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement guardian setup completion logic
      print('Guardian Name: ${_nameController.text}');
      print('Guardian Phone: ${_phoneController.text}');
      print('Guardian Email: ${_emailController.text}');
      print('Guardian Address: ${_addressController.text}');
      print('Child Age: ${widget.childAge}');

      // Navigate back to sign in page after completion
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Setup'),
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(), // Animated gradient background
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top-left asset image
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/safeyatraofficiallogo.png',
                          width: 80, // Adjust width as needed
                          height: 80, // Adjust height as needed
                        ),
                      ),
                    ),
                    Text(
                      'Guardian Information',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Since the user is under 15 (Age: ${widget.childAge}), we need guardian information.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Guardian's Name",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter guardian's name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Guardian's Phone Number",
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
                          return "Please enter guardian's phone number";
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Guardian's Email",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter guardian's email";
                        }
                        if (!isValidEmail(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: "Guardian's Home Address",
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter guardian's address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _onCompleteSetup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Complete Guardian Setup!',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key});

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
          );
        });
  }
}
