import 'dart:async';
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
  String soilMoisture = 'Dry';
  List<String> logs = [];

  final String esp32Url = 'http://192.168.1.10:5000';
  final String motorEndpoint = '/motor/status';
  final String sensorEndpoint = '/rain/status';
  final String sensorEndpoint1 = '/soil/status';
  final String logsEndpoint = '/logs';

  Timer? periodicTimer;

  @override
  void initState() {
    super.initState();
    fetchMotorStatus(); // Fetch initial motor status from server
    fetchSensorData(); // Fetch initial sensor data
    fetchSensorData1(); // Fetch initial sensor data
    fetchLogs(); // Fetch initial logs data
    initializeNotifications();

    // Start periodic checks
    startPeriodicCheck();
  }

  @override
  void dispose() {
    periodicTimer?.cancel();
    super.dispose();
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
        logs.add(
            'Motor ${status == 'on' ? 'turned on' : 'turned off'} at ${DateTime.now()}');
      });
    } catch (e) {
      print('Error fetching motor status: $e');
    }
  }

  Future<String> getMotorStatus() async {
    final response = await http.get(Uri.parse('$esp32Url$motorEndpoint'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['status'];
    } else {
      throw Exception('Failed to fetch motor status: ${response.reasonPhrase}');
    }
  }

  Future<void> fetchSensorData() async {
    try {
      final data = await getSensorData();
      setState(() {
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

  Future<void> fetchSensorData1() async {
    try {
      final data = await getSensorData1();
      setState(() {
        isRaining = (data['isRaining'] ?? false);
      });
      if (isRaining && soilMoisture == 'Wet') {
        stopMotorAndNotify();
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  Future<Map<String, dynamic>> getSensorData1() async {
    final response = await http.get(Uri.parse('$esp32Url$sensorEndpoint1'));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch sensor data: ${response.reasonPhrase}');
    }
  }

  Future<void> fetchLogs() async {
    try {
      final logData = await getLogs();
      setState(() {
        logs = List<String>.from(logData['logs']);
      });
    } catch (e) {
      print('Error fetching logs: $e');
    }
  }

  Future<Map<String, dynamic>> getLogs() async {
    final response = await http.get(Uri.parse('$esp32Url$logsEndpoint'));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch logs: ${response.reasonPhrase}');
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
          logs.add(
              'Motor turned ${action == 'on' ? 'on' : 'off'} manually at ${DateTime.now()}');
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

  // Function to start periodic motor status check
  void startPeriodicCheck() {
    const Duration checkInterval = Duration(seconds: 30); // Adjust as needed

    // Timer for periodic check
    periodicTimer = Timer.periodic(checkInterval, (Timer timer) {
      fetchMotorStatus(); // Fetch motor status periodically
      fetchLogs(); // Fetch logs periodically
    });
  }

  void clearLogs() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Logs'),
          content: Text('Are you sure you want to delete all logs?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  logs.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
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
              color: Colors.green[50],
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
                      onChanged: (value) async {
                        await controlMotor(value ? 'on' : 'off');
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
                      builder: (context) => MonitorPage(),
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
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: clearLogs,
                  child: Text(
                    'Clear',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: 200, // Fixed height for the container
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: logs.map((log) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        log,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    );
                  }).toList(),
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
