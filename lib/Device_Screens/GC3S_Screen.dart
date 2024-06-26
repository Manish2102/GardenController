import 'package:flutter/material.dart';
import 'package:gardenmate/Device_Screens/GC3SMonitor.dart';
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
    final double buttonWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('GC3S'),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Main Motor',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
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
                      SizedBox(height: 10),
                      _buildStatusWidget1(
                          'Main Motor Status',
                          _getMotorStatus(mainMotorManual),
                          _getStatusColor(mainMotorManual)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      _buildChannelToggle('Channel 1', motor1Manual, (value) {
                        setState(() {
                          motor1Manual = value;
                        });
                      }),
                      SizedBox(height: 10),
                      _buildChannelToggle('Channel 2', motor2Manual, (value) {
                        setState(() {
                          motor2Manual = value;
                        });
                      }),
                      SizedBox(height: 10),
                      _buildChannelToggle('Channel 3', motor3Manual, (value) {
                        setState(() {
                          motor3Manual = value;
                        });
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  SizedBox(
                    width: buttonWidth,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GC3ProgramPage()),
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
                  SizedBox(height: 10),
                  SizedBox(
                    width: buttonWidth,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GC3SMonitor(
                                    channel1Status:
                                        _getMotorStatus(motor1Manual),
                                    channel2Status:
                                        _getMotorStatus(motor2Manual),
                                    channel3Status:
                                        _getMotorStatus(motor3Manual),
                                    soilMoisture: soilMoisture,
                                    isRaining: isRaining,
                                    flowmeter: flowmeter,
                                  )),
                        );
                      },
                      icon: Icon(
                        Icons.monitor,
                        color: Colors.black,
                      ),
                      label: Text(
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
    return isManual ? 'ON' : 'OFF';
  }

  Color _getStatusColor(bool isManual) {
    return isManual ? Colors.green : Colors.red;
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GC3ProgramPage();
      },
    );
  }
}
