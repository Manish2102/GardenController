import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gardenmate/Device_Screens/GC1_Program.dart';
import 'package:gardenmate/Pages/Scheduled_Activity.dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityPage extends StatefulWidget {
  final List<ScheduledActivity> scheduledActivities;
  final VoidCallback onScheduleSuccess;

  ActivityPage({
    required this.scheduledActivities,
    required this.onScheduleSuccess, required String selectedTime,
  });

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late List<ScheduledActivity> _scheduledActivities;

  @override
  void initState() {
    super.initState();
    _scheduledActivities = widget.scheduledActivities;
  }

  void _deleteActivity(int index) async {
    setState(() {
      _scheduledActivities.removeAt(index);
    });

    // Update SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'scheduledActivities',
      _scheduledActivities.map((activity) => json.encode(activity.toJson())).toList(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Schedule deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('Activity Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scheduled Activities:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _scheduledActivities.length,
                itemBuilder: (context, index) {
                  return ScheduledActivityCard(
                    activity: _scheduledActivities[index],
                    onDelete: () => _deleteActivity(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduledActivityCard extends StatelessWidget {
  final ScheduledActivity activity;
  final VoidCallback onDelete;

  ScheduledActivityCard({
    required this.activity,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${activity.selectedTime}'),
            Text('Duration: ${activity.duration} minutes'),
            Text(
              'Frequency: ${Frequency.values[activity.frequency].toString().split('.').last}',
            ),
            if (activity.frequency == Frequency.SelectDays.index)
              Text('Days: ${activity.selectedDays.join(', ')}'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onDelete,
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
