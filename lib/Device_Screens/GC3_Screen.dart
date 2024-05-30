import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gardenmate/Device_Screens/GC3_Program.dart';
import 'package:gardenmate/Pages/BottomNav_Bar.dart';
import 'package:http/http.dart' as http;

class GC3Page extends StatefulWidget {
  final String userName;

  const GC3Page({Key? key, required this.userName}) : super(key: key);

  @override
  _GC3PageState createState() => _GC3PageState();
}

class _GC3PageState extends State<GC3Page> {
  // Variables to store settings values for each motor
  DateTime? motor1StartTime;
  int motor1Times = 0;
  int motor1Litres = 0;

  DateTime? motor2StartTime;
  int motor2Times = 0;
  int motor2Litres = 0;

  DateTime? motor3StartTime;
  int motor3Times = 0;
  int motor3Litres = 0;

  // Variables to store manual settings
  bool mainMotorManual = false;
  bool motor1Manual = false;
  bool motor2Manual = false;
  bool motor3Manual = false;

  // Variables to store sensor data
  bool isRaining = false;
  String soilMoisture = 'Dry';

  final String esp32Url =
      'http://192.168.4.100'; // Replace with your ESP32 IP address

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Fetch initial sensor data when the widget initializes
    _fetchSensorData();
    // Start the session end timer
    _startSessionTimer();
  }

  @override
  void dispose() {
    // Cancel the session end timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('GC3'),
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
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
                    value: mainMotorManual,
                    onChanged: (value) {
                      _toggleMotor('mainmotor', value);
                    },
                    activeTrackColor: Colors.green,
                    activeColor: Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildStatusWidget1(
                  'Main Motor Status',
                  _getMotorStatus(mainMotorManual),
                  _getStatusColor(mainMotorManual)),
              SizedBox(height: 20),
              _buildChannelToggle('Channel 1', motor1Manual, (value) {
                _toggleMotor('channel1', value);
              }),
              _buildChannelStatus(
                  'Channel 1', motor1StartTime, motor1Litres, motor1Manual),
              SizedBox(height: 20),
              _buildChannelToggle('Channel 2', motor2Manual, (value) {
                _toggleMotor('channel2', value);
              }),
              _buildChannelStatus(
                  'Channel 2', motor2StartTime, motor2Litres, motor2Manual),
              SizedBox(height: 20),
              _buildChannelToggle('Channel 3', motor3Manual, (value) {
                _toggleMotor('channel3', value);
              }),
              _buildChannelStatus(
                  'Channel 3', motor3StartTime, motor3Litres, motor3Manual),
              SizedBox(height: 20),
              _buildStatusWidget1('Soil Moisture', soilMoisture, Colors.yellow),
              _buildStatusWidget1('Rain Detection',
                  isRaining ? 'Rainy' : 'No Rain', Colors.yellow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelToggle(
      String channelName, bool isManual, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          channelName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Switch(
          value: isManual,
          onChanged: onChanged,
          activeTrackColor: Colors.green,
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildChannelStatus(
      String channelName, DateTime? startTime, int liters, bool isManual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusWidget1(
            '$channelName Last Run Time', _formatTime(startTime), Colors.blue),
        _buildStatusWidget1(
            '$channelName Litres Dripped', liters.toString(), Colors.orange),
        _buildStatusWidget1('$channelName Status', isManual ? 'ON' : 'OFF',
            isManual ? Colors.green : Colors.red),
      ],
    );
  }

  Widget _buildStatusWidget1(String title, String value, Color color) {
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

  String _getMotorStatus(bool isManual) {
    if (isManual) {
      return 'ON';
    } else {
      return 'OFF';
    }
  }

  Color _getStatusColor(bool isManual) {
    if (isManual) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String _formatTime(DateTime? time) {
    if (time != null) {
      return '${time.hour}:${time.minute}';
    } else {
      return 'N/A';
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GC3ProgramPage();
      },
    );
  }

  Future<void> _toggleMotor(String motor, bool status) async {
    try {
      final response = await http.post(
        Uri.parse('$esp32Url/motor'),
        body: {'motor': motor, 'action': status ? 'on' : 'off'},
      );
      if (response.statusCode == 200) {
        if (response.body.contains('Motor turned ${status ? 'on' : 'off'}')) {
          print('Motor $motor turned ${status ? 'on' : 'off'}');
          // Update local motor status
          setState(() {
            switch (motor) {
              case 'main':
                mainMotorManual = status;
                break;
              case 'motor1':
                motor1Manual = status;
                break;
              case 'motor2':
                motor2Manual = status;
                break;
              case 'motor3':
                motor3Manual = status;
                break;
            }
          });
          // Fetch updated sensor data after motor status change
          _fetchSensorData();
        } else {
          print('Failed to update motor $motor status: ${response.body}');
        }
      } else {
        print('Failed to toggle motor $motor: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error toggling motor $motor: $e');
    }
  }

  Future<void> _fetchSensorData() async {
    try {
      final response = await http.get(Uri.parse('$esp32Url/sensor'));
      if (response.statusCode == 200) {
        final data = response.body;
        // Parse and update sensor data here
        // Example: if data contains soil moisture and rain status,
        // update soilMoisture and isRaining variables accordingly
        setState(() {
          // Update sensor data based on received response
        });
      } else {
        print('Failed to fetch sensor data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  void _startSessionTimer() {
    _timer = Timer(Duration(seconds: 10), () {
      // Perform session end request here
      print('Session ended');
    });
  }
}
