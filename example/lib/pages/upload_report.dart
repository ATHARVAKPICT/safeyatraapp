import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class UploadReportPage extends StatefulWidget {
  const UploadReportPage({super.key});

  @override
  State<UploadReportPage> createState() => _UploadReportPageState();
}

class _UploadReportPageState extends State<UploadReportPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationTagController = TextEditingController();
  File? _uploadedImage;

  Future<void> _uploadImage() async {
    try {
      if (Platform.isAndroid) {
        final File selectedImage = await _pickImageFromAndroid();
        if (selectedImage != null) {
          setState(() {
            _uploadedImage = selectedImage;
          });
        }
      }
    } on PlatformException catch (e) {
      print("Error: $e");
    }
  }

  Future<File> _pickImageFromAndroid() async {
    return File('path/to/your/image.jpg');
  }

  void _postReport() {
    final description = _descriptionController.text;
    final locationTag = _locationTagController.text;

    // Modified validation to only check for description and location
    if (description.isEmpty || locationTag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill in both description and location tag')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Post'),
          content: const Text('Are you sure you want to post this report?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report posted successfully!')),
                );

                // Clear inputs after posting
                _descriptionController.clear();
                _locationTagController.clear();
                setState(() {
                  _uploadedImage = null;
                });
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Report an Incident',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: _uploadImage,
                    icon: const Icon(Icons.image, color: Colors.black),
                    label: const Text('Upload Image (Optional)',
                        style: TextStyle(color: Colors.black)),
                  ),
                  if (_uploadedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.file(
                        _uploadedImage!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe the incident...',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationTagController,
                    decoration: const InputDecoration(
                      labelText: 'Location Tag',
                      hintText: 'Enter location tag...',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: _postReport,
                    child: const Text('Post Report',
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: const DockingBar(),
          ),
        ],
      ),
    );
  }
}

// Other classes (DockingBar, AnimatedGradientBackground) remain unchanged

class DockingBar extends StatefulWidget {
  const DockingBar({super.key});

  @override
  State<DockingBar> createState() => _DockingBarState();
}

class _DockingBarState extends State<DockingBar> {
  int activeIndex = 0;

  final List<IconData> icons = [
    Icons.home,
    Icons.search,
    Icons.add_circle_rounded,
    Icons.notifications,
    Icons.person,
  ];

  final List<String> routes = [
    '/basicMap',
    '/search',
    '/upload_report',
    '/community',
    '/profile',
  ];

  Tween<double> tween = Tween<double>(begin: 1.0, end: 1.2);
  bool animationCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        clipBehavior: Clip.none,
        width: MediaQuery.sizeOf(context).width * 0.8 +34,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TweenAnimationBuilder(
          key: ValueKey(activeIndex),
          tween: tween,
          duration: Duration(milliseconds: animationCompleted ? 2000 : 200),
          curve: animationCompleted ? Curves.elasticOut : Curves.easeOut,
          onEnd: () {
            setState(() {
              animationCompleted = true;
              tween = Tween(begin: 1.5, end: 1.0);
            });
          },
          builder: (context, value, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(icons.length, (i) {
                return Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..scale(i == activeIndex ? value : 1.0)
                    ..translate(
                        0.0, i == activeIndex ? 80.0 * (1 - value) : 0.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        animationCompleted = false;
                        tween = Tween(begin: 1.0, end: 1.2);
                        activeIndex = i;
                      });

                      Navigator.pushNamed(context, routes[i]);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icons[i],
                        size: 30,
                        color: const Color.fromARGB(255, 12, 1, 1),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
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
          weight: 1),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _topAlignment.value,
              end: _bottomAlignment.value,
              colors: const [
                Color.fromRGBO(33, 53, 85, 1),
                Color.fromRGBO(62, 88, 121, 1),
              ],
            ),
          ),
        );
      },
    );
  }
}