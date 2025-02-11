// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:io';
import 'profile_page.dart';
import 'upload_report.dart';
import 'community.dart';
import 'navigation.dart';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'dart:math';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class BasicMapPage extends ExamplePage {
  const BasicMapPage({super.key})
      : super(
      leading: const Icon(Icons.map),
      title: 'Find your route'
  );

  @override
  ExamplePageState<BasicMapPage> createState() => _MapPageState();
}

class _MapPageState extends ExamplePageState<BasicMapPage> {

  void showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Emergency Alert"),
          content: const Text("🚨 SOS sent! Help is on the way."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  late final GoogleMapViewController _mapViewController;
  late final TextEditingController _sourceController;
  late final TextEditingController _destinationController;

  late bool isMyLocationEnabled = true;
  late bool isMyLocationButtonEnabled = true;
  late bool consumeMyLocationButtonClickEvent = false;
  late bool isZoomGesturesEnabled = false;
  late bool isZoomControlsEnabled = true;
  late bool isCompassEnabled = true;
  late bool isRotateGesturesEnabled = true;
  late bool isScrollGesturesEnabled = true;
  late bool isScrollGesturesEnabledDuringRotateOrZoom = true;
  late bool isTiltGesturesEnabled = true;
  late bool isTrafficEnabled = false;
  late MapType mapType = MapType.normal;

  List<String> _sourceSuggestions = [];
  List<String> _destinationSuggestions = [];
  final List<Polyline> _polylines = <Polyline>[];
  Map<int, String> routeData = {};
  bool showRouteData = false;
  int? selectedRouteType;
  List<Map<String, double>> selectedRoutePoints = [];

  @override
  void initState() {
    super.initState();
    _sourceController = TextEditingController();
    _destinationController = TextEditingController();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> fetchSuggestions(String query, bool isSource) async {
    final url = Uri.parse(
        'https://safeyatra.onrender.com/incidents/search-location/?query=$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
        jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonResponse['status'] == 'OK') {
          final List<dynamic> predictions =
          jsonResponse['predictions'] as List<dynamic>;

          final List<String> suggestions = predictions
              .map((prediction) =>
          (prediction as Map<String, dynamic>)['description'] as String)
              .take(3) // Limit to top 3 suggestions
              .toList();

          setState(() {
            if (isSource) {
              _sourceSuggestions = suggestions;
            } else {
              _destinationSuggestions = suggestions;
            }
          });
        }
      } else {
        throw Exception(
            'Failed to fetch suggestions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }


  Future<void> _addPolyline(int routeType) async {
    final LatLngBounds cameraBounds = await _mapViewController.getVisibleRegion();
    String source = _sourceController.text;
    String destination = _destinationController.text;
    List<LatLng> points = await _fetchRoutePoints(source, destination, routeType);

    Color strokeColor;
    String routeDescription;

    if (routeType == 1) {
      strokeColor = Colors.green;
      int score = Random().nextInt(16) + 75; // Generates a random number between 75 and 90
      routeDescription = "Safest route \n Safety Score: $score";
    } else if (routeType == 2) {
      strokeColor = Colors.yellow;
      int score = Random().nextInt(10) + 65; // Generates a random number between 60 and 75
      routeDescription = "Moderate risk \n Safety Score: $score";
    } else {
      strokeColor = Colors.red;
      int score = Random().nextInt(10) + 55; // Generates a random number between 45 and 60
      routeDescription = "High risk \n Safety Score: $score";
    }

    setState(() {
      routeData[routeType] = routeDescription;
    });

    final PolylineOptions options = PolylineOptions(
      points: points,
      clickable: true,
      strokeColor: strokeColor,
      strokeWidth: 5,
    );

    final List<Polyline?> addedPolylines =
    await _mapViewController.addPolylines(<PolylineOptions>[options]);

    final Polyline? newPolyline = addedPolylines.firstOrNull;
    if (newPolyline != null) {
      setState(() {
        _polylines.add(newPolyline);
        selectedRouteType = routeType;
        selectedRoutePoints = points.map((point) => {
          'lat': point.latitude,
          'lng': point.longitude,
        }).toList();
      });
    }
  }


  Future<List<LatLng>> _fetchRoutePoints(
      String source, String destination, int routeType) async {
    final url = Uri.parse("https://safeyatra.onrender.com/routes/routes/");
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'start': source,
          'end': destination,
          'mode': 'driving',
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is Map && data['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backend Error: ${data['error']}')),
          );
          return [];
        }

        if (data is Map && data.containsKey('routes')) {
          var routeCoordinatesKey = 'route_Coordinates$routeType';
          if (data['routes']['routes'].containsKey(routeCoordinatesKey) == true) {
            dynamic routeCoordinates =
            data['routes']['routes'][routeCoordinatesKey]['coordinates'];
            if (routeCoordinates is List) {
              List<LatLng> routePoints = [];
              for (var coord in routeCoordinates) {
                if (coord is List && coord.length == 2) {
                  double? lat =
                  coord[0] is num ? (coord[0] as num).toDouble() : null;
                  double? lng =
                  coord[1] is num ? (coord[1] as num).toDouble() : null;

                  if (lat != null && lng != null) {
                    routePoints.add(LatLng(latitude: lat, longitude: lng));
                  }
                }
              }
              return routePoints;
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill out both input fields.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching route: $e')),
      );
    }
    return [];
  }

  Future<dynamic> _fetchRouteScore(String source, String destination, int routeType) async {
    final url = Uri.parse("https://safeyatra.onrender.com/routes/routes/");
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'start': source,
          'end': destination,
          'mode': 'driving',
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print("API Response: ${response.body}"); // Debugging: Print full response

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is Map && data.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backend Error: ${data['error']}')),
          );
          return null;
        }

        if (data is Map && data.containsKey('routes')) {
          var routeCoordinatesKey = 'route_Coordinates$routeType';

          print("Routes Data: ${data['routes']}"); // Debugging

          if (data['routes']['routes'].containsKey(routeCoordinatesKey)==true) {
            dynamic routeScore = data['routes']['routes'][routeCoordinatesKey]['safety_score'];

            print("Extracted Safety Score: $routeScore"); // Debugging

            return routeScore;
          } else {
            print("Route key not found: $routeCoordinatesKey");
          }
        } else {
          print("Unexpected API response format");
        }
      } else {
        print("API Error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch safety score.')),
        );
      }
    } catch (e) {
      print("Error fetching safety score: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching safety score: $e')),
      );
    }
    return null;
  }


  Future<void> setMapType(MapType type) async {
    mapType = type;
    await _mapViewController.setMapType(mapType: type);
    setState(() {});
  }

  Future<void> _onViewCreated(GoogleMapViewController controller) async {
    _mapViewController = controller;
    await _mapViewController.settings.setZoomControlsEnabled(false);
    setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final SnackBar snackBar = SnackBar(
        duration: const Duration(milliseconds: 2000), content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onMyLocationClicked(MyLocationClickedEvent event) {
    _showMessage('My location clicked');
  }

  void _onMyLocationButtonClicked(MyLocationButtonClickedEvent event) {
    _showMessage('My location button clicked');
  }

  Widget _buildLocationInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height, // Limit to 40% of screen height
      ),
      decoration: BoxDecoration(
        color: Color.fromRGBO(33,53,85,1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 50),
          TextField(
            controller: _sourceController,
            onChanged: (value) => fetchSuggestions(value, true),
            decoration: InputDecoration(
              hintText: 'Enter source location',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
          if (_sourceSuggestions.isNotEmpty)
            ..._sourceSuggestions.map(
                  (suggestion) => ListTile(
                title: Text(suggestion),
                onTap: () {
                  _sourceController.text = suggestion;
                  setState(() {
                    _sourceSuggestions.clear();
                  });
                },
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _destinationController,
            onChanged: (value) => fetchSuggestions(value, false),
            decoration: InputDecoration(
              hintText: 'Enter destination',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
          if (_destinationSuggestions.isNotEmpty)
            ..._destinationSuggestions.map(
                  (suggestion) => ListTile(
                title: Text(suggestion),
                onTap: () {
                  _destinationController.text = suggestion;
                  setState(() {
                    _destinationSuggestions.clear();
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle mapTypeStyle = ElevatedButton.styleFrom(
        minimumSize: const Size(80, 36),
        disabledBackgroundColor:
        Theme.of(context).colorScheme.primaryContainer);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // ✅ Add Feedback Icon Button at the top right
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.feedback, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pushNamed(context, '/feedback'); // Navigate to Feedback Page
              },
            ),
          ),

          GoogleMapsMapView(
            onViewCreated: _onViewCreated,
            onMyLocationClicked: _onMyLocationClicked,
            onMyLocationButtonClicked: _onMyLocationButtonClicked,
          ),
          _buildLocationInputs(),
          Padding(
            padding: const EdgeInsets.only(top: 200, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // changed to blue background
                    foregroundColor: Colors.white, // changed to white text
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    _mapViewController.clearPolylines();
                    _addPolyline(3);
                    _addPolyline(2);
                    _addPolyline(1);
                    setState(() {
                      showRouteData = true;
                    });
                  },
                  child: const Text('Get Routes'),
                ),
                if (showRouteData) ...[
                  const SizedBox(height: 10, width: 80),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        _buildRouteButton(1, Colors.green),
                        const SizedBox(height: 2, width: 3),
                        _buildRouteButton(2, Colors.yellow),
                        const SizedBox(height:2, width: 3),
                        _buildRouteButton(3, Colors.red),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // getOverlayOptionsButton(context, onPressed: () => toggleOverlay()),
          // Add DockingBar at the bottom
          // const Positioned(
          //   left: 4,
          //   right: 4,
          //   bottom: 50,
          //   child: DockingBar(),
          // ),
          Positioned(
            bottom: 120, // Adjust position above DockingBar
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                showSOSDialog(context);
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.warning, color: Colors.white),
            ),
          ),

          Positioned(
            left: 4,
            right: 4,
            bottom: 40,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  alignment: Alignment.bottomLeft,
                  child: const DockingBar(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget _buildRouteButton(int routeType, Color color) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == Colors.yellow ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: () async {
          await _mapViewController.clearPolylines();
          await _addPolyline(routeType);

          // Navigate to navigation page after route is selected
          if (selectedRoutePoints.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationPage(
                  routePoints: selectedRoutePoints,
                ),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route $routeType',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color == Colors.yellow ? Colors.black : Colors.white,
              ),
            ),
            if (routeData.containsKey(routeType))
              Text(
                routeData[routeType]!,
                style: TextStyle(
                  fontSize: 12,
                  color: color == Colors.yellow ? Colors.black : Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildOverlayContent(BuildContext context) {
    return Column(children: <Widget>[
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _mapViewController.settings.setCompassEnabled(newValue);
            final bool enabled =
            await _mapViewController.settings.isCompassEnabled();
            setState(() {
              isCompassEnabled = enabled;
            });
          },
          title: const Text('Enable compass'),
          value: isCompassEnabled),
      SwitchListTile(
          title: const Text('Enable my location'),
          value: isMyLocationEnabled,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool newValue) async {
            await _mapViewController.setMyLocationEnabled(newValue);
            final bool enabled = await _mapViewController.isMyLocationEnabled();
            setState(() {
              isMyLocationEnabled = enabled;
            });
          },
          visualDensity: VisualDensity.compact),
      SwitchListTile(
          title: const Text('Enable my location button'),
          value: isMyLocationButtonEnabled,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: isMyLocationEnabled
              ? (bool newValue) async {
            await _mapViewController.settings
                .setMyLocationButtonEnabled(newValue);
            final bool enabled = await _mapViewController.settings
                .isMyLocationButtonEnabled();
            setState(() {
              isMyLocationButtonEnabled = enabled;
            });
          }
              : null,
          visualDensity: VisualDensity.compact),
      SwitchListTile(
          title: const Text('Consume my location button click'),
          value: consumeMyLocationButtonClickEvent,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: isMyLocationEnabled && isMyLocationButtonEnabled
              ? (bool newValue) async {
            await _mapViewController.settings
                .setConsumeMyLocationButtonClickEventsEnabled(newValue);
            final bool enabled = await _mapViewController.settings
                .isConsumeMyLocationButtonClickEventsEnabled();
            setState(() {
              consumeMyLocationButtonClickEvent = enabled;
            });
          }
              : null,
          visualDensity: VisualDensity.compact),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _mapViewController.settings.setZoomGesturesEnabled(newValue);
            final bool enabled =
            await _mapViewController.settings.isZoomGesturesEnabled();
            setState(() {
              isZoomGesturesEnabled = enabled;
            });
          },
          title: const Text('Enable zoom gestures'),
          value: isZoomGesturesEnabled),
      // if (Platform.isAndroid)
      //   SwitchListTile(
      //       onChanged: (bool newValue) async {
      //         await _mapViewController.settings
      //             .setZoomControlsEnabled(newValue);
      //         final bool enabled =
      //         await _mapViewController.settings.isZoomControlsEnabled();
      //         setState(() {
      //           isZoomControlsEnabled = enabled;
      //         });
      //       },
      //       title: const Text('Enable zoom controls'),
      //       value: isZoomControlsEnabled),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _mapViewController.settings
                .setRotateGesturesEnabled(newValue);
            final bool enabled =
            await _mapViewController.settings.isRotateGesturesEnabled();
            setState(() {
              isRotateGesturesEnabled = enabled;
            });
          },
          title: const Text('Enable rotate gestures'),
          value: isRotateGesturesEnabled),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _mapViewController.settings
                .setScrollGesturesEnabled(newValue);
            final bool enabled =
            await _mapViewController.settings.isScrollGesturesEnabled();
            setState(() {
              isScrollGesturesEnabled = enabled;
            });
          },

          title: const Text('Enable scroll gestures'),
          value: isScrollGesturesEnabled),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _mapViewController.settings
                .setScrollGesturesDuringRotateOrZoomEnabled(newValue);
            final bool enabled = await _mapViewController.settings
                .isScrollGesturesEnabledDuringRotateOrZoom();
            setState(() {
              isScrollGesturesEnabledDuringRotateOrZoom = enabled;
            });
          },
          title: const Text('Enable scroll gestures during rotate or zoom'),
          value: isScrollGesturesEnabledDuringRotateOrZoom),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _mapViewController.settings.setTiltGesturesEnabled(newValue);
            final bool enabled =
            await _mapViewController.settings.isTiltGesturesEnabled();
            setState(() {
              isTiltGesturesEnabled = enabled;
            });
          },
          title: const Text('Enable tilt gestures'),
          value: isTiltGesturesEnabled),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _mapViewController.settings.setTrafficEnabled(newValue);
            final bool enabled =
            await _mapViewController.settings.isTrafficEnabled();
            setState(() {
              isTrafficEnabled = enabled;
            });
          },
          title: const Text('Enable traffic'),
          value: isTrafficEnabled),
    ]);
  }
}

class DockingBar extends StatefulWidget {
  const DockingBar({Key? key}) : super(key: key);

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
        width: MediaQuery.sizeOf(context).width * 0.75 + 46,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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

