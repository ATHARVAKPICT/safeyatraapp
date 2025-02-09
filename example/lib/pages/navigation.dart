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
  bool _isRecentered = true; // ✅ New variable to track if map is centered
  bool _navigationTripProgressBarEnabled = true;
  bool _trafficEnabled = true;
  bool _speedometerEnabled = true;
  NavigationTravelMode _travelMode = NavigationTravelMode.driving;

  final List<NavigationWaypoint> predefinedWaypoints = [
    NavigationWaypoint.withLatLngTarget(
        title: "Start",
        target: LatLng(latitude: 18.457323, longitude: 73.8508694)),
    NavigationWaypoint.withLatLngTarget(
        title: "Waypoint 1",
        target: LatLng(latitude: 18.4571116, longitude: 73.850638)),
    NavigationWaypoint.withLatLngTarget(
        title: "Waypoint 2",
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

  Future<void> _recenterMap() async {
    if (_navigationViewController == null) return;

    await _navigationViewController!.followMyLocation(CameraPerspective.tilted);
    setState(() => _isRecentered = true); // ✅ Fix: Update UI after recentering
  }


  Future<void> _initializeNavigation() async {
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
      if (mounted) {
        setState(() => _navigatorInitialized = true);
      }
      await _setPredefinedRoute();
    } catch (e) {
      debugPrint("Error initializing navigation: $e");
      showMessage("Failed to initialize navigation.");
    }
  }

  Future<void> _setPredefinedRoute() async {
    if (!_navigatorInitialized) return;

    final Destinations destinations = Destinations(
      waypoints: predefinedWaypoints,
      displayOptions: NavigationDisplayOptions( // ✅ Removed `const`
        showDestinationMarkers: true,
        showStopSigns: true,
        showTrafficLights: true,
      ),
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
    try {
      await GoogleMapsNavigator.startGuidance();
      if (_navigationViewController == null) return;

      await _navigationViewController!.setNavigationUIEnabled(true);
      await _navigationViewController!.followMyLocation(CameraPerspective.tilted);

      if (mounted) {
        setState(() {
          _guidanceRunning = true;
        });
      }

      await _enableNavigationFeatures();
    } catch (e) {
      debugPrint("Error starting guidance: $e");
      showMessage("Failed to start guidance.");
    }
  }

  Future<void> _enableNavigationFeatures() async {
    if (_navigationViewController == null) return;

    await _navigationViewController!.setTrafficIncidentCardsEnabled(_trafficEnabled);
    await _navigationViewController!.setNavigationTripProgressBarEnabled(_navigationTripProgressBarEnabled);
    await _navigationViewController!.setSpeedometerEnabled(_speedometerEnabled);
  }

  void _handleNavigationError(NavigationRouteStatus status) {
    String errorMessage = "Unknown error.";
    if (status == NavigationRouteStatus.routeNotFound) {
      errorMessage = "Route not found.";
    } else if (status == NavigationRouteStatus.networkError) {
      errorMessage = "Check your internet connection.";
    } else if (status == NavigationRouteStatus.apiKeyNotAuthorized) {
      errorMessage = "Invalid API Key.";
    }
    showMessage(errorMessage);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _changeTravelMode(NavigationTravelMode mode) async {
    setState(() {
      _travelMode = mode;
    });
    await _setPredefinedRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: _travelModeSelection(),
            ),
          ),
          Expanded(
            child: _navigatorInitialized
                ? GoogleMapsNavigationView(
              onViewCreated: (controller) {
                setState(() {
                  _navigationViewController = controller;
                });
                _enableNavigationFeatures();
              },
              initialCameraPosition: CameraPosition(
                target: predefinedWaypoints.first.target ?? // ✅ Fixed null issue
                    LatLng(latitude: 0.0, longitude: 0.0), // Default if null
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
            ),
          ),
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
