// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// You may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'pages/circles.dart';
import 'pages/pages.dart';
import 'pages/signin.dart';
import 'widgets/widgets.dart';
import 'pages/signup.dart';
import 'pages/guardian_setup.dart';
import 'pages/map.dart';
import 'pages/community.dart';
import 'pages/profile_page.dart';
import 'pages/upload_report.dart';
import 'pages/feedback.dart';

void main() {
  runApp(const NavigationApp());
}

class NavigationApp extends StatelessWidget {
  const NavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Navigation Flutter',
      theme: ThemeData.light().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(minimumSize: const Size(160, 36)),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(minimumSize: const Size(160, 36)),
        ),
      ),
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SignInPage(),
        '/navigation': (context) {
          // This is a fallback that redirects to home if someone tries to access
          // navigation directly without coordinates
          Navigator.pushReplacementNamed(context, '/');  // or your home route
          return Container(); // placeholder return
        },
        '/basicMap': (context) => const BasicMapPage(),
        '/camera': (context) => const CameraPage(),
        '/markers': (context) => const MarkersPage(),
        '/polygons': (context) => const PolygonsPage(),
        '/polylines': (context) => const PolylinesPage(),
        '/circles': (context) => const CirclesPage(),
        '/turnByTurn': (context) => const TurnByTurnPage(),
        '/widgetInit': (context) => const WidgetInitializationPage(),
        '/navWithoutMap': (context) => const NavigationWithoutMapPage(),
        '/multipleMaps': (context) => const MultipleMapViewsPage(),
        '/signup': (context) => const SignUpPage(),
        '/guardian_setup': (context) => const GuardianSetupPage(
          childAge: '15',
        ),
        '/profile': (context) => const ProfilePage(),
        '/upload_report': (context) => const UploadReportPage(),
        '/community': (context) => const CommunityPage(),
        '/feedback': (context) => const FeedbackPage(),
      },
    );
  }
}
