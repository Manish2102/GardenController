import 'package:flutter/material.dart';
import 'package:gardenmate/Device_Screens/GC1_Program.dart';
import 'package:gardenmate/Pages/BottomNav_Bar.dart';

class GC3SPage extends StatefulWidget {
  final String userName;

  const GC3SPage({Key? key, required this.userName}) : super(key: key);

  @override
  _GC3SPageState createState() => _GC3SPageState();
}

class _GC3SPageState extends State<GC3SPage> {
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
  String flowmeter = '0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 125, 153, 126),
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

      backgroundColor: Colors.grey[200], // Set background color
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
                      setState(() {
                        mainMotorManual = value;
                      });
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
                setState(() {
                  motor1Manual = value;
                });
              }),
              _buildChannelStatus(
                  'Channel 1', motor1StartTime, motor1Litres, motor1Manual),
              SizedBox(height: 20),
              _buildChannelToggle('Channel 2', motor2Manual, (value) {
                setState(() {
                  motor2Manual = value;
                });
              }),
              _buildChannelStatus(
                  'Channel 2', motor2StartTime, motor2Litres, motor2Manual),
              SizedBox(height: 20),
              _buildChannelToggle('Channel 3', motor3Manual, (value) {
                setState(() {
                  motor3Manual = value;
                });
              }),
              _buildChannelStatus(
                  'Channel 3', motor3StartTime, motor3Litres, motor3Manual),
              SizedBox(height: 20),
              _buildStatusWidget1('Soil Moisture', soilMoisture, Colors.yellow),
              _buildStatusWidget1('Rain Detection',
                  isRaining ? 'Rainy' : 'No Rain', Colors.yellow),
              _buildStatusWidget1('Flow Meter', flowmeter, Colors.yellow)
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
        return AlertDialog(
          title: Text('Settings'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProgramSettingsPage()));
                  },
                  child: Text('Timer Settings'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
