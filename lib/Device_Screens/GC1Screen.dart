import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gardenmate/Device_Screens/GC1_Monitor.dart';
import 'package:gardenmate/Device_Screens/GC1_Program.dart';
import 'package:gardenmate/Pages/BottomNav_Bar.dart';

class GC1Page extends StatefulWidget {
  final String userName;

  const GC1Page({Key? key, required this.userName}) : super(key: key);

  @override
  _GC1PageState createState() => _GC1PageState();
}

class _GC1PageState extends State<GC1Page> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isMainMotorOn = false;
  DateTime? motor1StartTime;
  int motor1Times = 0;
  bool motor1Manual = false;
  bool isRaining = false;
  String soilMoisture = 'Dry'; // Initialize with default value
  List<String> logs = [];

  final String esp32Url = 'http://192.168.1.10:5000'; // Updated base URL
  final String motorEndpoint = '/motor/status'; // Updated endpoints
  final String sensorEndpoint = '/sensor/data'; // Updated endpoints

  @override
  void initState() {
    super.initState();
    fetchMotorStatus();
    fetchSensorData();
    initializeNotifications();
  }

  void initializeNotifications() {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwin = DarwinInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: darwin);
    flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const darwinDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> fetchMotorStatus() async {
    try {
      final status = await getMotorStatus();
      setState(() {
        isMainMotorOn = (status == 'on');
      });
      if (isMainMotorOn) {
        showNotification('Motor Status', 'Motor turned on');
      } else {
        showNotification('Motor Status', 'Motor turned off');
      }
    } catch (e) {
      print('Error fetching motor status: $e');
    }
  }

  Future<String> getMotorStatus() async {
    final response = await http.get(Uri.parse('$esp32Url$motorEndpoint'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch motor status: ${response.reasonPhrase}');
    }
  }

  Future<void> fetchSensorData() async {
    try {
      final data = await getSensorData();
      setState(() {
        isRaining = (data['isRaining'] ?? false);
        soilMoisture = data['soilMoisture'] ?? 'Dry';
      });
      if (isRaining && soilMoisture == 'Wet') {
        stopMotorAndNotify();
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  Future<Map<String, dynamic>> getSensorData() async {
    final response = await http.get(Uri.parse('$esp32Url$sensorEndpoint'));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch sensor data: ${response.reasonPhrase}');
    }
  }

  Future<void> controlMotor(String action) async {
    String url = '$esp32Url/motor/$action';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Successfully controlled the motor
        print('Motor $action successful');
        // Update motor status immediately after controlling
        setState(() {
          isMainMotorOn = (action == 'on');
        });
        // Show notification
        showNotification(
            'Motor Status', 'Motor turned ${action == 'on' ? 'on' : 'off'}');
      } else {
        // Handle error
        print('Failed to $action motor: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      print('Failed to $action motor: $e');
    }
  }

  void stopMotorAndNotify() {
    if (isMainMotorOn) {
      controlMotor('off');
    }
    if (!motor1Manual) {
      final snackBar = SnackBar(
        content:
            Text('It is raining and soil moisture is high! Motor stopped.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('GC1'),
        actions: [
          IconButton(
            onPressed: () {
              _showSettingsDialog(context);
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomBar(context, 0, (index) {}),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Main Motor',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: isMainMotorOn,
                      onChanged: (value) {
                        controlMotor(value ? 'on' : 'off');
                      },
                      activeTrackColor: Colors.green,
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProgramSettingsPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                label: Text(
                  'Configuration',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 182, 197, 213)),
                  padding: MaterialStateProperty.all(EdgeInsets.all(16)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  elevation: MaterialStateProperty.all(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonitorPage(
                        isMainMotorOn: isMainMotorOn,
                        soilMoisture: soilMoisture,
                        isRaining: isRaining,
                        logs: logs,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.monitor,
                  color: Colors.black,
                ),
                label: Text(
                  'Monitor',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 182, 197, 213)),
                  padding: MaterialStateProperty.all(EdgeInsets.all(16)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  elevation: MaterialStateProperty.all(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You can configure your settings here.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
