import 'package:flutter/material.dart';

class GC3MonitorPage extends StatelessWidget {
  final DateTime? motor1StartTime;
  final int motor1Litres;
  final bool motor1Manual;

  final DateTime? motor2StartTime;
  final int motor2Litres;
  final bool motor2Manual;

  final DateTime? motor3StartTime;
  final int motor3Litres;
  final bool motor3Manual;

  final String soilMoisture;
  final bool isRaining;

  GC3MonitorPage({
    required this.motor1StartTime,
    required this.motor1Litres,
    required this.motor1Manual,
    required this.motor2StartTime,
    required this.motor2Litres,
    required this.motor2Manual,
    required this.motor3StartTime,
    required this.motor3Litres,
    required this.motor3Manual,
    required this.soilMoisture,
    required this.isRaining,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitor'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChannelStatus(
              'Channel 1',
              motor1StartTime,
              motor1Litres,
              motor1Manual,
            ),
            SizedBox(height: 20),
            _buildChannelStatus(
              'Channel 2',
              motor2StartTime,
              motor2Litres,
              motor2Manual,
            ),
            SizedBox(height: 20),
            _buildChannelStatus(
              'Channel 3',
              motor3StartTime,
              motor3Litres,
              motor3Manual,
            ),
            SizedBox(height: 20),
            _buildStatusWidget1('Soil Moisture', soilMoisture, Colors.yellow),
            _buildStatusWidget1('Rain Detection',
                isRaining ? 'Rainy' : 'No Rain', Colors.yellow),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelStatus(
      String channelName, DateTime? startTime, int liters, bool isManual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusWidget1(
          '$channelName Last Run Time',
          _formatTime(startTime),
          Colors.blue,
        ),
        _buildStatusWidget1(
          '$channelName Litres Dripped',
          liters.toString(),
          Colors.orange,
        ),
        _buildStatusWidget1(
          '$channelName Status',
          isManual ? 'ON' : 'OFF',
          isManual ? Colors.green : Colors.red,
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

  String _formatTime(DateTime? time) {
    if (time != null) {
      return '${time.hour}:${time.minute}';
    } else {
      return 'N/A';
    }
  }
}
