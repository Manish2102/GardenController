import 'package:flutter/material.dart';

class GC3SMonitor extends StatelessWidget {
  final String channel1Status;
  final String channel2Status;
  final String channel3Status;
  final String soilMoisture;
  final bool isRaining;
  final String flowmeter;

  const GC3SMonitor({
    Key? key,
    required this.channel1Status,
    required this.channel2Status,
    required this.channel3Status,
    required this.soilMoisture,
    required this.isRaining,
    required this.flowmeter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GC3S Monitor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildStatusWidget('Channel 1 Status', channel1Status),
            _buildStatusWidget('Channel 2 Status', channel2Status),
            _buildStatusWidget('Channel 3 Status', channel3Status),
            _buildStatusWidget('Soil Moisture', soilMoisture),
            _buildStatusWidget(
                'Rain Detection', isRaining ? 'Rainy' : 'No Rain'),
            _buildStatusWidget('Flow Meter', flowmeter),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(String title, String value) {
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
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
