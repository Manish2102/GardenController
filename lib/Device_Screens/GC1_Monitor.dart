import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MonitorPage extends StatefulWidget {
  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  bool isMainMotorOn = false;
  String soilMoisture = 'Unknown';
  bool isRaining = false;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    // Call the function to update status once the widget is initialized
    updateStatus();
  }

  // Function to fetch sensor details and motor status from the server
  Future<void> updateStatus() async {
    final serverIp =
        'http://192.168.1.10:5000'; // Replace with your actual server IP

    try {
      // Fetch motor status
      final motorResponse = await http.get(Uri.parse('$serverIp/motor/status'));
      if (motorResponse.statusCode == 200) {
        final motorData = json.decode(motorResponse.body);
        setState(() {
          isMainMotorOn = motorData['status'] == 'ON';
        });
      } else {
        print('Failed to fetch motor status: ${motorResponse.statusCode}');
      }

      // Fetch rain status
      final rainResponse = await http.get(Uri.parse('$serverIp/rain/status'));
      if (rainResponse.statusCode == 200) {
        final rainData = json.decode(rainResponse.body);
        setState(() {
          isRaining = rainData['status'] == 'Raining';
        });
      } else {
        print('Failed to fetch rain status: ${rainResponse.statusCode}');
      }

      // Fetch soil moisture
      final soilResponse = await http.get(Uri.parse('$serverIp/soil/status'));
      if (soilResponse.statusCode == 200) {
        final soilData = json.decode(soilResponse.body);
        setState(() {
          soilMoisture = soilData['status'];
        });
      } else {
        print('Failed to fetch soil moisture: ${soilResponse.statusCode}');
      }
    } catch (error) {
      print('Error fetching sensor details: $error');
    }
  }

  // Function to handle refresh button pressed
  Future<void> _handleRefresh() async {
    await updateStatus();
    // Optionally show a SnackBar or any UI indication of refresh completion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('Monitor'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildStatusWidget(
              'Main Motor Status',
              isMainMotorOn ? 'On' : 'Off',
              isMainMotorOn ? Colors.green : Colors.red,
            ),
            _buildStatusWidget(
              'Soil Moisture',
              soilMoisture,
              Colors.blue,
            ),
            _buildStatusWidget(
              'Rain Detection',
              isRaining ? 'Rainy' : 'No Rain',
              Colors.yellow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10),
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
}
