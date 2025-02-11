import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For asset checking

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<Map<String, dynamic>> _incidents = [
    {
      'description': 'I was walking near a shopping mall in Kalyani Nagar around 6:30 PM when I saw a man trying to lure a little girl away. She looked scared, and he kept insisting she follow him. I knew something was wrong, so I called out to her loudly, and the man immediately backed off and rushed away. I alerted the security guards, and we informed the police, but he was already gone. It was terrifying to think what could have happened if no one had noticed.',
      'location': 'Kalyani Nagar',
      'image': 'assets/shadymall.jpeg',
      'upvotes': 0,
      'downvotes': 0,
    },
    {
      'description': 'Last night, around 9:45 PM, I was walking home in Viman Nagar when I felt someone following me. At first, I thought it was just in my head, but every time I changed direction, he did too. My heart started racing, and I quickly walked into a crowded store nearby. I stayed there for a few minutes, pretending to browse, and when I looked outside, he was gone. I don’t know who he was or what he wanted, but it left me shaken.',
      'location': 'Viman Nagar',
      'image': 'assets/shadyapt.jpeg',
      'upvotes': 0,
      'downvotes': 0,
    },
    {
      'description': 'I was waiting for a cab outside Pune Railway Station at 5:30 PM when a group of men started making comments at me. At first, I ignored them, but they kept getting closer, trying to block my way. I felt trapped and didn’t know what to do. Thankfully, a few people around noticed and stepped in, which made them back off. I managed to leave safely, but I was scared. I later filed a complaint because no one should have to go through this.',
      'location': 'Pune Railway Station',
      'image': 'assets/shadyrail.jpeg',
      'upvotes': 0,
      'downvotes': 0,
    },
  ];

  void _upvotePost(int index) {
    setState(() {
      _incidents[index]['upvotes'] += 1;
    });
  }

  void _downvotePost(int index) {
    setState(() {
      _incidents[index]['downvotes'] += 1;
    });
  }

  Future<bool> _checkAssetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Community', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueGrey[900],
          centerTitle: true,
        ),
        body: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _incidents.length,
              itemBuilder: (context, index) {
                final incident = _incidents[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  color: Colors.blueGrey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (incident['image'] != null)
                          FutureBuilder<bool>(
                            future: _checkAssetExists(incident['image'] as String),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done &&
                                  snapshot.data == true) {
                                return Image.asset(
                                  incident['image'] as String,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Container(); // No image if asset not found
                            },
                          ),
                        Text(
                          incident['description'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Location: ${incident['location']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _upvotePost(index),
                                  icon: const Icon(Icons.thumb_up),
                                  color: Colors.black,
                                ),
                                Text('${incident['upvotes']}',
                                    style: const TextStyle(color: Colors.black)),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _downvotePost(index),
                                  icon: const Icon(Icons.thumb_down),
                                  color: Colors.black,
                                ),
                                Text('${incident['downvotes']}',
                                    style: const TextStyle(color: Colors.black)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: DockingBar(),
            ),
          ],
        ),
      ),
    );
  }
}


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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(icons.length, (i) {
            return InkWell(
              onTap: () {
                setState(() {
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
            );
          }),
        ),
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
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
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color.fromRGBO(33, 53, 85, 1),
                Color.fromRGBO(62, 88, 121, 1),
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}