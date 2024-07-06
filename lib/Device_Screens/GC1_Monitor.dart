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
    final sensors = ['motor', 'rain', 'soil'];

    try {
      for (var sensor in sensors) {
        final response = await http.get(Uri.parse('$serverIp/$sensor/status'));

        if (response.statusCode == 200) {
          final data = response.body;
          switch (sensor) {
            case 'motor':
              setState(() {
                isMainMotorOn = data == 'on';
              });
              break;
            case 'rain':
              setState(() {
                isRaining = data == 'rainy';
              });
              break;
            case 'soil':
              setState(() {
                soilMoisture = data;
              });
              break;
          }
        } else {
          print('Failed to fetch $sensor status: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Error fetching sensor details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('Monitor'),
        centerTitle: true,
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
