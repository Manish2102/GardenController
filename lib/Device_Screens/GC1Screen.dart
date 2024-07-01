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
  String soilMoisture = 'Wet';
  List<String> logs = [];

  final String esp32Url = 'http://192.168.1.10:5000';
  final String motorEndpoint = '/motorStatus';
  final String sensorEndpoint = '/sensor_data';

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
        0, title, body, notificationDetails);
  }

  Future<void> fetchMotorStatus() async {
    try {
      final status = await getMotorStatus();
      setState(() {
        isMainMotorOn = (status == 'on');
      });
      if (isMainMotorOn) {
        showNotification('Motor Status', 'Motor turned on');
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
        isRaining = (data[0] == '1');
        soilMoisture = data[1];
      });
      if (isRaining && soilMoisture == 'Wet') {
        stopMotorAndNotify();
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  Future<List<String>> getSensorData() async {
    final response = await http.get(Uri.parse('$esp32Url$sensorEndpoint'));
    if (response.statusCode == 200) {
      return response.body.split(',');
    } else {
      throw Exception('Failed to fetch sensor data: ${response.reasonPhrase}');
    }
  }

  Future<void> toggleMotor(bool status) async {
    try {
      final response = await http.post(
        Uri.parse('$esp32Url$motorEndpoint'),
        body: {'action': status ? 'on' : 'off'},
      );
      if (response.statusCode == 200) {
        setState(() {
          isMainMotorOn = status;
        });
        print('Motor turned ${status ? 'on' : 'off'}');
        logs.add(
            'Motor ${status ? 'turned on' : 'turned off'} - ${DateTime.now()}');
        showNotification(
            'Motor Status', 'Motor ${status ? 'turned on' : 'turned off'}');
      } else {
        print(
            'Failed to turn motor ${status ? 'on' : 'off'}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error turning motor ${status ? 'on' : 'off'}: $e');
    }
  }

  void showMotorNotification(bool isMotorOn) {
    final snackBar = SnackBar(
      content: Text('Motor ${isMotorOn ? 'started' : 'stopped'}!'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void updateMotorIterationTimings(int iterations, int duration, int gap) {
    DateTime currentTime = DateTime.now();
    DateTime scheduledTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      currentTime.hour,
      currentTime.minute,
    );

    List<DateTime> iterationTimings = [];
    for (int i = 0; i < iterations; i++) {
      DateTime iterationStartTime =
          scheduledTime.add(Duration(minutes: i * (duration + gap)));
      DateTime iterationEndTime =
          iterationStartTime.add(Duration(minutes: duration));
      iterationTimings.add(iterationStartTime);
      iterationTimings.add(iterationEndTime);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Iteration Timings'),
          content: Column(
            children: iterationTimings.map((timing) {
              return Text(
                  '${_formatTime(timing)} - ${_formatTime(timing.add(Duration(minutes: duration)))}');
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void stopMotorAndNotify() {
    if (isMainMotorOn) {
      toggleMotor(false);
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
                        toggleMotor(value);
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
                      ));
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
                            motor1StartTime: motor1StartTime,
                            soilMoisture: soilMoisture,
                            isRaining: isRaining),
                      ));
                },
                icon: Icon(
                  Icons.info,
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
            Divider(
              thickness: 2,
              color: Colors.black,
            ),
            SizedBox(height: 20),
            Text(
              'Logs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(logs[index]),
                  );
                },
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
        TextEditingController iterationsController = TextEditingController();
        TextEditingController durationController = TextEditingController();
        TextEditingController gapController = TextEditingController();
        return AlertDialog(
          title: Text('Program Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: iterationsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Iterations'),
              ),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Duration (minutes)'),
              ),
              TextField(
                controller: gapController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Gap (minutes)'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('SAVE'),
              onPressed: () {
                int iterations = int.parse(iterationsController.text);
                int duration = int.parse(durationController.text);
                int gap = int.parse(gapController.text);
                updateMotorIterationTimings(iterations, duration, gap);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${_formatDigits(dateTime.hour)}:${_formatDigits(dateTime.minute)}';
  }

  String _formatDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
