import 'package:flutter/material.dart';
import 'package:trackerapp/screens/signup_screen.dart';
import 'package:trackerapp/screens/welcome_screen.dart';
import 'package:trackerapp/screens/home_screen.dart';
import 'package:trackerapp/screens/map_screen.dart';

Map<String, Widget Function(BuildContext)> myRoutes() {
  return {
    const WelcomeScreen().routeName: (context) => const WelcomeScreen(),
    const SignUpScreen().routeName: (context) => const SignUpScreen(),
    const HomeScreen().routeName: (context) => const HomeScreen(),
    const MapScreen().routeName: (context) => const MapScreen(),
  };
}
