import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gardenmate/Pages/Login_Page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay navigation to dashboard screen
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogIn()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background image or color goes here
          Center(
            child: Image.asset(
              "assets/Logo.png",
              // Replace 'logo.png' with your app logo file path
              // You can adjust the width and height properties as needed
              width: 300,
              height: 200,
            ),
          ),
          // Loading indicator
          Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          ),
          // Version number at the bottom
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Text(
              'Version 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
