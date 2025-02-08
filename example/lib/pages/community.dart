// import 'package:flutter/material.dart';
//
// class CommunityPage extends StatefulWidget {
//   const CommunityPage({super.key});
//
//   @override
//   State<CommunityPage> createState() => _CommunityPageState();
// }
//
// class _CommunityPageState extends State<CommunityPage> {
//   // Sample data for incidents
//   final List<Map<String, dynamic>> _incidents = [
//     {
//       'description': 'Incident at Main Street: Suspicious activity reported.',
//       'location': 'Main Street',
//       'image': 'lib/assets/snoweyyy.jpeg',
//       'upvotes': 0,
//       'downvotes': 0,
//     },
//     {
//       'description': 'Power outage near Pine Street reported.',
//       'location': 'Pine Street',
//       'image': null,
//       'upvotes': 0,
//       'downvotes': 0,
//     },
//     {
//       'description': 'Road accident at Elm Avenue. Caution advised.',
//       'location': 'Elm Avenue',
//       'image': null,
//       'upvotes': 0,
//       'downvotes': 0,
//     },
//   ];
//
//   void _upvotePost(int index) {
//     setState(() {
//       _incidents[index]['upvotes'] += 1;
//     });
//   }
//
//   void _downvotePost(int index) {
//     setState(() {
//       _incidents[index]['downvotes'] += 1;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedGradientBackground(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Stack(
//           children: [
//             ListView.builder(
//               padding: const EdgeInsets.only(
//                   bottom: 100), // Add padding for the bottom navigation
//               itemCount: _incidents.length,
//               itemBuilder: (context, index) {
//                 final incident = _incidents[index];
//                 return Card(
//                   margin: const EdgeInsets.all(8.0),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: const BorderSide(
//                         color: Colors.black, width: 1), // Add black border
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (incident['image'] != null)
//                           Image.asset(
//                             incident['image'],
//                             height: 200,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                           ),
//                         Text(
//                           incident['description'],
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Location: ${incident['location']}',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 IconButton(
//                                   onPressed: () => _upvotePost(index),
//                                   icon: const Icon(Icons.thumb_up),
//                                 ),
//                                 Text('${incident['upvotes']}'),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 IconButton(
//                                   onPressed: () => _downvotePost(index),
//                                   icon: const Icon(Icons.thumb_down),
//                                 ),
//                                 Text('${incident['downvotes']}'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const Positioned(
//               bottom: 20,
//               left: 0,
//               right: 0,
//               child: DockingBar(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DockingBar extends StatefulWidget {
//   const DockingBar({super.key});
//
//   @override
//   State<DockingBar> createState() => _DockingBarState();
// }
//
// class _DockingBarState extends State<DockingBar> {
//   int activeIndex = 0;
//
//   final List<IconData> icons = [
//     Icons.home,
//     Icons.search,
//     Icons.add_circle_rounded,
//     Icons.notifications,
//     Icons.person,
//   ];
//
//   final List<String> routes = [
//     '/maps',
//     '/search',
//     '/upload_report',
//     '/community',
//     '/profile',
//   ];
//
//   Tween<double> tween = Tween<double>(begin: 1.0, end: 1.2);
//   bool animationCompleted = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         clipBehavior: Clip.none,
//         width: MediaQuery.sizeOf(context).width * 0.8,
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: TweenAnimationBuilder(
//           key: ValueKey(activeIndex),
//           tween: tween,
//           duration: Duration(milliseconds: animationCompleted ? 2000 : 200),
//           curve: animationCompleted ? Curves.elasticOut : Curves.easeOut,
//           onEnd: () {
//             setState(() {
//               animationCompleted = true;
//               tween = Tween(begin: 1.5, end: 1.0);
//             });
//           },
//           builder: (context, value, child) {
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(icons.length, (i) {
//                 return Transform(
//                   alignment: Alignment.bottomCenter,
//                   transform: Matrix4.identity()
//                     ..scale(i == activeIndex ? value : 1.0)
//                     ..translate(
//                         0.0, i == activeIndex ? 80.0 * (1 - value) : 0.0),
//                   child: InkWell(
//                     onTap: () {
//                       setState(() {
//                         animationCompleted = false;
//                         tween = Tween(begin: 1.0, end: 1.2);
//                         activeIndex = i;
//                       });
//                       Navigator.pushNamed(context, routes[i]);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         icons[i],
//                         size: 30,
//                         color: const Color.fromARGB(255, 12, 1, 1),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class AnimatedGradientBackground extends StatefulWidget {
//   final Widget child;
//
//   const AnimatedGradientBackground({super.key, required this.child});
//
//   @override
//   State<AnimatedGradientBackground> createState() =>
//       _AnimatedGradientBackgroundState();
// }
//
// class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Alignment> _topAlignment;
//   late Animation<Alignment> _bottomAlignment;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 4));
//
//     _topAlignment = TweenSequence<Alignment>([
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.topLeft, end: Alignment.topRight),
//           weight: 1),
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.topRight, end: Alignment.centerRight),
//           weight: 1),
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.centerRight, end: Alignment.bottomRight),
//           weight: 1),
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.bottomRight, end: Alignment.bottomLeft),
//           weight: 1),
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.bottomLeft, end: Alignment.centerLeft),
//           weight: 1),
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.centerLeft, end: Alignment.topLeft),
//           weight: 1),
//     ]).animate(_controller);
//
//     _bottomAlignment = TweenSequence<Alignment>([
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.bottomRight, end: Alignment.bottomLeft),
//           weight: 1),
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.bottomLeft, end: Alignment.centerLeft),
//           weight: 1),
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.centerLeft, end: Alignment.topLeft),
//           weight: 1),
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.topLeft, end: Alignment.topRight),
//           weight: 1),
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.topRight, end: Alignment.centerRight),
//           weight: 1),
//       TweenSequenceItem(
//           tween: Tween<Alignment>(
//               begin: Alignment.centerRight, end: Alignment.bottomRight),
//           weight: 1)
//     ]).animate(_controller);
//
//     _controller.repeat();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//         animation: _controller,
//         builder: (context, _) {
//           return Container(
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: _topAlignment.value,
//                     end: _bottomAlignment.value,
//                     colors: const [
//                       Color.fromRGBO(33, 53, 85, 1),
//                       Color.fromRGBO(62, 88, 121, 1),
//                     ])),
//             child: widget.child,
//           );
//         });
//   }
// }
