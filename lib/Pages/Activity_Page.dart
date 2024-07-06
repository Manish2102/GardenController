import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gardenmate/Pages/Scheduled_Activity.dart.dart';

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
    // Extracting start and end times as hours and minutes
    final startTime =
        TimeOfDay.fromDateTime(DateTime.parse(activity.selectedTime));
    final endTime = TimeOfDay.fromDateTime(DateTime.parse(activity.selectedTime)
        .add(Duration(minutes: activity.duration)));

    return Card(
      elevation: 5,
      color: Colors.white70,
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
              'GC1: ${activity.channel}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'Date: ${DateTime.parse(activity.selectedTime).toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'Start Time: ${startTime.format(context)}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'End Time: ${endTime.format(context)}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text('Duration: ${activity.duration} minutes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Days Selected: ${activity.selectedDays.join(', ')}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_sharp,
                    size: 30,
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
