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
    required this.onScheduleSuccess,
    required String selectedTime,
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
      _scheduledActivities
          .map((activity) => json.encode(activity.toJson()))
          .toList(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Schedule deleted'),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Schedule'),
          content: Text('Do you want to delete the schedule?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without deleting
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog and delete the schedule
                _deleteActivity(index);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
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
                    onDelete: () => _confirmDelete(index),
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
            Text(
              'Time: ${activity.selectedTime}',
              style: TextStyle(fontSize: 18),
            ),
            Text('Duration: ${activity.duration} minutes',
                style: TextStyle(fontSize: 18)),
            Text(
                'Frequency: ${Frequency.values[activity.frequency].toString().split('.').last}',
                style: TextStyle(fontSize: 18)),
            if (activity.frequency == Frequency.SelectDays.index)
              Text('Days: ${activity.selectedDays.join(', ')}',
                  style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_sharp,
                    size: 40,
                    color: Colors.black,
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
