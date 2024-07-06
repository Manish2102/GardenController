import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gardenmate/Pages/Scheduled_Activity.dart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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
    _fetchSchedulesFromServer();
  }

  Future<void> _fetchSchedulesFromServer() async {
    final url = Uri.parse('http://192.168.1.10:5000/get_schedules');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _scheduledActivities = (data['schedules'] as List)
              .map((schedule) => ScheduledActivity(
                    selectedTime: schedule['start'],
                    duration:
                        _calculateDuration(schedule['start'], schedule['end']),
                    frequency: 0,
                    selectedDays: List<String>.from(schedule['days']),
                    channel: 0,
                  ))
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch schedules from server.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  int _calculateDuration(String start, String end) {
    final startTime = TimeOfDay(
      hour: int.parse(start.split(":")[0]),
      minute: int.parse(start.split(":")[1]),
    );
    final endTime = TimeOfDay(
      hour: int.parse(end.split(":")[0]),
      minute: int.parse(end.split(":")[1]),
    );

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    return endMinutes - startMinutes;
  }

  Future<void> _deleteActivityFromServer(ScheduledActivity activity) async {
    final url = Uri.parse(
        'http://192.168.1.10:5000/remove_schedule?start=startTime&end=endTime&days=${activity.selectedDays.join(',')}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schedule deleted from server successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete schedule from server.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _deleteActivity(int index) async {
    ScheduledActivity activity = _scheduledActivities[index];

    setState(() {
      _scheduledActivities.removeAt(index);
    });

    // Delete activity from the server
    await _deleteActivityFromServer(activity);

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

  Future<void> _refreshSchedules() async {
    await _fetchSchedulesFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('Activity Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshSchedules,
          ),
        ],
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
              child: RefreshIndicator(
                onRefresh: _refreshSchedules,
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
    // Extracting start and end times as TimeOfDay
    TimeOfDay startTime = TimeOfDay(
      hour: int.parse(activity.selectedTime.split(":")[0]),
      minute: int.parse(activity.selectedTime.split(":")[1]),
    );

    int endHour = startTime.hour;
    int endMinute = startTime.minute + activity.duration;
    while (endMinute >= 60) {
      endHour += 1;
      endMinute -= 60;
    }

    TimeOfDay endTime = TimeOfDay(hour: endHour, minute: endMinute);

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
              'Start Time: ${startTime.format(context)}', // Use TimeOfDay format
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'End Time: ${endTime.format(context)}', // Use TimeOfDay format
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'Duration: ${activity.duration} minutes',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'Days Selected: ${activity.selectedDays.join(', ')}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
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
