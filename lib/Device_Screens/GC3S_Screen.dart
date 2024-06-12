import 'package:flutter/material.dart';
import 'package:gardenmate/Device_Screens/GC1_Program.dart';
import 'package:gardenmate/Device_Screens/GC3_Program.dart';
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
              Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Main Motor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _getMotorStatus(mainMotorManual),
                            style: TextStyle(
                              color: _getStatusColor(mainMotorManual),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Control:',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Channels',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildChannelToggle(
                        'Channel 1',
                        motor1Manual,
                        (value) {
                          setState(() {
                            motor1Manual = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      _buildChannelToggle(
                        'Channel 2',
                        motor2Manual,
                        (value) {
                          setState(() {
                            motor2Manual = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      _buildChannelToggle(
                        'Channel 3',
                        motor3Manual,
                        (value) {
                          setState(() {
                            motor3Manual = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GC3ProgramPage()),
                      );
                    },
                    icon: Icon(Icons.settings),
                    label: Text('Configuration'),
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
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.monitor),
                    label: Text('Monitor'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelToggle(
    String channelName,
    bool isManual,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          channelName,
          style: TextStyle(fontSize: 16),
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

  String _getMotorStatus(bool isManual) {
    return isManual ? 'ON' : 'OFF';
  }

  Color _getStatusColor(bool isManual) {
    return isManual ? Colors.green : Colors.red;
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
                        builder: (_) => ProgramSettingsPage(),
                      ),
                    );
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
