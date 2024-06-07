import 'package:flutter/material.dart';
import 'package:gardenmate/Device_Screens/GC1_Program.dart';

class ActivityPage extends StatelessWidget {
  final String selectedTime;
  final int duration;
  final int frequency;
  final List<String> selectedDays;
  final VoidCallback onScheduleSuccess;

  // Constructor to receive data from ProgramSettingsPage
  ActivityPage({
    required this.selectedTime,
    required this.duration,
    required this.frequency,
    required this.selectedDays,
    required this.onScheduleSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('Activity Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Program Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Start Time', selectedTime),
                      _buildInfoRow('Duration', '$duration minutes'),
                      _buildInfoRow(
                          'Frequency',
                          Frequency.values[frequency]
                              .toString()
                              .split('.')
                              .last),
                      if (frequency == Frequency.SelectDays.index)
                        _buildInfoRow('Selected Days', selectedDays.join(', ')),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Perform delete action here
                              // Call the callback to show success message
                              onScheduleSuccess();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
