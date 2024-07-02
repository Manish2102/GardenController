import 'package:flutter/material.dart';
import 'package:gardenmate/Pages/BottomNav_Bar.dart';

class MonitorPage extends StatelessWidget {
  final bool isMainMotorOn;
  final DateTime? motor1StartTime;
  final String soilMoisture;
  final bool isRaining;

  const MonitorPage({
    Key? key,
    required this.isMainMotorOn,
    required this.motor1StartTime,
    required this.soilMoisture,
    required this.isRaining, required List<String> logs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('Monitor'),
        centerTitle: true,
      ),
      bottomNavigationBar: buildBottomBar(context, 0, (index) {}),
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
              'Motor 1 Last Run Time',
              _formatTime(motor1StartTime),
              Colors.blue,
            ),
            _buildStatusWidget(
              'Soil Moisture',
              soilMoisture,
              Colors.yellow,
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

  String _formatTime(DateTime? time) {
    if (time != null) {
      return '${time.hour}:${time.minute}';
    } else {
      return 'N/A';
    }
  }
}
