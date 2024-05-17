import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:gardenmate/Pages/Splash_Page.dart';
import 'package:gardenmate/Values/App_Routes.dart';
import 'package:gardenmate/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(GardenControllerApp());
}

class Firebase {
  static initializeApp({required FirebaseOptions options}) {}
}

class GardenControllerApp extends StatelessWidget {
  const GardenControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garden Controller',
      theme: ThemeData(useMaterial3: true),
      initialRoute: AppRoutes.splashpage,
      routes: {
        AppRoutes.splashpage: (context) => SplashScreen(),
      },
    );
  }
}
