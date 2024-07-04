import 'package:flutter/material.dart';
import 'package:gardenmate/Device_Screens/GC1Screen.dart';
//import 'package:gardenmate/Device_Screens/GC1_Monitor.dart';
import 'package:gardenmate/Device_Screens/GC1_Program.dart';
import 'package:gardenmate/Device_Screens/GC3S_Screen.dart';
import 'package:gardenmate/Device_Screens/GC3_Program.dart';
import 'package:gardenmate/Device_Screens/GC3_Screen.dart';
//import 'package:gardenmate/Pages/Activity_Page.dart';
import 'package:gardenmate/Pages/ForgotPassword.dart';
import 'package:gardenmate/Pages/Home.dart';
import 'package:gardenmate/Pages/Login_Page.dart';
import 'package:gardenmate/Pages/Notification_Page.dart';
import 'package:gardenmate/Pages/SignUP_Page.dart';
import 'package:gardenmate/Pages/Splash_Page.dart';
import 'package:gardenmate/Values/App_Routes.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('failed to initialize firebase: $e');
  }
  runApp(GardenControllerApp());
}

class GardenControllerApp extends StatelessWidget {
  const GardenControllerApp({Key? key});

  get name => null;

  get email => null;

  @override
  Widget build(BuildContext context) {
    /*var isMainMotorOn;
    var soilMoisture;
    var isRaining;*/
    return MaterialApp(
      title: 'Garden Controller',
      theme: ThemeData(useMaterial3: true),
      initialRoute: AppRoutes.splashpage,
      routes: {
        AppRoutes.splashpage: (context) => SplashScreen(),
        AppRoutes.homepage: (context) => ModelsPage(),
        AppRoutes.forgotpassword: (context) => ForgotPassword(),
        AppRoutes.loginpage: (context) => LogIn(),
        AppRoutes.signuppage: (context) => SignUp(),
        //AppRoutes.activitypage: (context) => ActivityPage(selectedTime: '', duration: '',),
        AppRoutes.notificationpage: (context) => NotificationPage(),
        AppRoutes.gc1screen: (context) => GC1Page(
              userName: '',
            ),
        AppRoutes.gc1program: (context) => ProgramSettingsPage(),
        /*AppRoutes.gc1monitor: (context) => MonitorPage(
              isMainMotorOn: isMainMotorOn,
              soilMoisture: soilMoisture,
              isRaining: isRaining,
              logs: [],
            ),*/
        AppRoutes.gc3page: (context) => GC3Page(userName: ''),
        AppRoutes.gc3program: (context) => GC3ProgramPage(),
        AppRoutes.gc3s: (context) => GC3SPage(userName: ''),
      },
    );
  }
}
