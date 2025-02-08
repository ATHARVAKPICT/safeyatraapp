import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

enum SimulationState {
  unknown,
  running,
  runningOutdated,
  paused,
  notRunning,
}

class NavigationPage extends StatefulWidget {
  final List<Map<String, double>> routePoints;

  const NavigationPage({
    Key? key,
    required this.routePoints,
  }) : super(key: key);

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  GoogleNavigationViewController? _navigationViewController;
  bool _navigatorInitialized = false;
  bool _guidanceRunning = false;
  NavigationTravelMode _travelMode = NavigationTravelMode.driving; // Default mode

  final List<NavigationWaypoint> predefinedWaypoints = [
    NavigationWaypoint.withLatLngTarget(
        title: "Start",
        target: LatLng(latitude: 18.457323, longitude: 73.8508694)),
    NavigationWaypoint.withLatLngTarget(
        title: "Waypoint 1",
        target: LatLng(latitude: 18.4572755, longitude: 73.8516636)),
    NavigationWaypoint.withLatLngTarget(
        title: "Waypoint 2",
        target: LatLng(latitude: 18.4571116, longitude: 73.850638)),
    NavigationWaypoint.withLatLngTarget(
        title: "Waypoint 3",
        target: LatLng(latitude: 18.4655507, longitude: 73.8546827)),
    NavigationWaypoint.withLatLngTarget(
        title: "Waypoint 4",
        target: LatLng(latitude: 18.4655109, longitude: 73.854751)),
    NavigationWaypoint.withLatLngTarget(
        title: "End",
        target: LatLng(latitude: 18.501996, longitude: 73.863402)),
  ];

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  Future<void> _initializeNavigation() async {
    await GoogleMapsNavigator.initializeNavigationSession();
    setState(() => _navigatorInitialized = true);
    await _setPredefinedRoute();
  }

  Future<void> _setPredefinedRoute() async {
    if (!_navigatorInitialized) return;

    final Destinations destinations = Destinations(
      waypoints: predefinedWaypoints,
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: true),
      routingOptions: RoutingOptions(travelMode: _travelMode),
    );

    final NavigationRouteStatus status =
    await GoogleMapsNavigator.setDestinations(destinations);

    if (status == NavigationRouteStatus.statusOk) {
      await _startGuidance();
    } else {
      _handleNavigationError(status);
    }
  }

  Future<void> _startGuidance() async {
    await GoogleMapsNavigator.startGuidance();
    await _navigationViewController?.setNavigationUIEnabled(true);
    await _navigationViewController?.followMyLocation(CameraPerspective.tilted);

    setState(() => _guidanceRunning = true);
  }

  void _handleNavigationError(NavigationRouteStatus status) {
    String errorMessage = switch (status) {
      NavigationRouteStatus.routeNotFound => "Route not found.",
      NavigationRouteStatus.networkError => "Check your internet connection.",
      NavigationRouteStatus.apiKeyNotAuthorized => "Invalid API Key.",
      _ => "Unknown error.",
    };
    showMessage(errorMessage);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _changeTravelMode(NavigationTravelMode mode) async {
    setState(() {
      _travelMode = mode;
    });
    await _setPredefinedRoute(); // Recalculate the route with the selected mode
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Placing the travel mode selection where the AppBar was
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0), // Adds spacing below the status bar
              child: _travelModeSelection(),
            ),
          ),
          Expanded(
            child: _navigatorInitialized
                ? GoogleMapsNavigationView(
              onViewCreated: (controller) {
                _navigationViewController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: predefinedWaypoints.first.target ??
                    const LatLng(latitude: 18.457323, longitude: 73.8508694),
                zoom: 15,
              ),
              initialNavigationUIEnabledPreference: NavigationUIEnabledPreference.automatic,
            )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  /// UI for selecting travel modes
  Widget _travelModeSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildTravelModeChoice(NavigationTravelMode.driving, Icons.directions_car),
        _buildTravelModeChoice(NavigationTravelMode.cycling, Icons.directions_bike),
        _buildTravelModeChoice(NavigationTravelMode.walking, Icons.directions_walk),
        _buildTravelModeChoice(NavigationTravelMode.taxi, Icons.local_taxi),
        _buildTravelModeChoice(NavigationTravelMode.twoWheeler, Icons.two_wheeler),
      ],
    );
  }

  Widget _buildTravelModeChoice(NavigationTravelMode mode, IconData icon) {
    final bool isSelected = mode == _travelMode;
    return InkWell(
      onTap: () => _changeTravelMode(mode),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(5),
              child: Icon(
                icon,
                size: 30,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
              )),
          if (isSelected)
            Container(
              height: 3,
              color: Theme.of(context).colorScheme.primary,
              width: 40,
            ),
        ],
      ),
    );
  }
}
