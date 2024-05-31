import 'package:flutter/material.dart';
import 'package:gardenmate/Device_Screens/GC1_Monitor.dart';
import 'package:gardenmate/Device_Screens/GC1_Program.dart';
import 'package:gardenmate/Pages/BottomNav_Bar.dart';
import 'package:http/http.dart' as http;

class GC1Page extends StatefulWidget {
  final String userName;

  const GC1Page({Key? key, required this.userName}) : super(key: key);

  @override
  _GC1PageState createState() => _GC1PageState();
}

class _GC1PageState extends State<GC1Page> {
  bool isMainMotorOn = false;
  DateTime? motor1StartTime;
  int motor1Times = 0;
  bool motor1Manual = false;
  bool isRaining = false;
  String soilMoisture = 'Wet';

  final String esp32Url =
      'http://192.168.1.25:5000'; // Replace with ESP32 IP address
  final String motorEndpoint =
      '/motor_control'; // Endpoint to control the motor
  final String sensorEndpoint = '/sensor_data';
  // Endpoint to fetch sensor data

  @override
  void initState() {
    super.initState();
    fetchMotorStatus(); // Fetch motor status when the page initializes
    fetchSensorData(); // Fetch sensor data when the page initializes
  }

  Future<void> fetchMotorStatus() async {
    try {
      final status = await getMotorStatus();
      setState(() {
        isMainMotorOn = (status == 'on');
      });
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
/*
  void updateMotorIterationTimings(int iterations, int duration, int gap) {
    int totalDuration = (duration + gap) * iterations - gap;
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
  */

  void stopMotorAndNotify() {
    // Stop the motor if it's currently running
    if (isMainMotorOn) {
      toggleMotor(false);
    }
    // Display snack notification
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Main Motor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProgramSettingsPage(),
                    ));
              },
              child: Text(
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
            SizedBox(height: 20),
            OutlinedButton(
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
              child: Text(
                'Monitor',
                style: TextStyle(color: Colors.black, fontSize: 20),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time != null) {
      return '${time.hour}:${time.minute}';
    } else {
      return 'N/A';
    }
  }

  void _showSettingsDialog(BuildContext context) async {
    final Map<String, dynamic>? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProgramSettingsPage();
      },
    );

    if (result != null) {
      TimeOfDay startTime = result['startTime'];
      int duration = result['duration'];
      int iterations = result['iterations'];
      int gap = result['gap'];

      // Calculate the total duration of one cycle
      int totalDuration = duration + gap;

      // Calculate the scheduled start time
      DateTime scheduledStartTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        startTime.hour,
        startTime.minute,
      );

      // Calculate the total duration to the next scheduled start time
      int minutesUntilNextStart =
          scheduledStartTime.difference(DateTime.now()).inMinutes;

      // Delay until the next scheduled start time
      await Future.delayed(Duration(minutes: minutesUntilNextStart));

      // Start the scheduled cycles
      for (int i = 0; i < iterations; i++) {
        // Turn on the motor
        await toggleMotor(true);

        // Delay for the duration of one cycle
        await Future.delayed(Duration(minutes: duration));

        // Turn off the motor
        await toggleMotor(false);

        // Delay for the gap between cycles
        if (i < iterations - 1) {
          await Future.delayed(Duration(minutes: gap));
        }
      }

      DateTime motorStoppingTime =
          scheduledStartTime.add(Duration(minutes: totalDuration * iterations));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Motor stopping time: ${_formatTime(motorStoppingTime)}'),
        ),
      );

      setState(() {
        motor1StartTime = motorStoppingTime;
      });
    }
  }

  DateTime calculateMotorStoppingTime(
      TimeOfDay startTime, int duration, int iterations, int gap) {
    DateTime currentTime = DateTime.now();
    DateTime scheduledTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      startTime.hour,
      startTime.minute,
    );

    int totalDuration = (duration + gap) * iterations - gap;
    DateTime motorStoppingTime =
        scheduledTime.add(Duration(minutes: totalDuration));

    return motorStoppingTime;
  }

  Future<void> deleteProgramSettings() async {
    // Add code to delete program settings here
  }
}
