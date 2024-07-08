import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gardenmate/Pages/Home.dart';
import 'package:gardenmate/Pages/Login_Page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Request permissions
    requestPermissions().then((_) {
      // Check if the user is logged in
      Timer(Duration(seconds: 5), () {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // User is signed in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ModelsPage()), // Replace with your homepage
          );
        } else {
          // User is not signed in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LogIn()),
          );
        }
      });
    });
  }

  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothConnect,
    ].request();

    if (await Permission.location.isPermanentlyDenied ||
        await Permission.bluetooth.isPermanentlyDenied ||
        await Permission.bluetoothConnect.isPermanentlyDenied) {
      // Open app settings to manually enable permissions
      openAppSettings();
    }
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
