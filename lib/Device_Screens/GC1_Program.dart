import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gardenmate/Pages/Activity_Page.dart';
import 'package:gardenmate/Pages/BottomNav_Bar.dart';
import 'package:gardenmate/Pages/Scheduled_Activity.dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import the intl package

class ProgramSettingsPage extends StatefulWidget {
  @override
  _ProgramSettingsPageState createState() => _ProgramSettingsPageState();
}

class _ProgramSettingsPageState extends State<ProgramSettingsPage> {
  late SharedPreferences _prefs;
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  int _duration = 1;
  List<String> _selectedDays = [];
  List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<ScheduledActivity> _scheduledActivities = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final formattedDateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(formattedDateTime); // 24-hour format
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final dateTime = DateFormat.Hm().parseStrict(timeString);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      final startTimeString = _prefs.getString('selectedStartTime');
      final endTimeString = _prefs.getString('selectedEndTime');
      if (startTimeString != null) {
        _selectedStartTime = _parseTimeOfDay(startTimeString);
      }
      if (endTimeString != null) {
        _selectedEndTime = _parseTimeOfDay(endTimeString);
      }
      _duration = _prefs.getInt('duration') ?? 1;
      _selectedDays = _prefs.getStringList('selectedDays') ?? [];

      final List<String>? scheduledActivityStrings =
          _prefs.getStringList('scheduledActivities');
      if (scheduledActivityStrings != null) {
        _scheduledActivities = scheduledActivityStrings
            .map((jsonString) =>
                ScheduledActivity.fromJson(json.decode(jsonString)))
            .toList();
      }
    });
    _calculateDuration();
  }

  void _calculateDuration() {
    final startDateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, _selectedStartTime.hour, _selectedStartTime.minute);
    final endDateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, _selectedEndTime.hour, _selectedEndTime.minute);

    setState(() {
      _duration = endDateTime.difference(startDateTime).inMinutes;
    });
  }

  Future<void> _sendScheduleToServer(
      String start, String end, List<String> days, int duration) async {
    final url = Uri.parse(
        'http://192.168.1.10:5000/add_schedule?start=$start&end=$end&days=${days.join(',')}&duration=$duration');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schedule added to server successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add schedule to server.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _savePreferences() async {
    // Validate duration
    if (_duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid duration.'),
        ),
      );
      return;
    }

    // Validate selected days
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one day.'),
        ),
      );
      return;
    }

    // If all validations pass, proceed to save preferences
    String formattedStartTime = _formatTimeOfDay(_selectedStartTime);
    String formattedEndTime = _formatTimeOfDay(_selectedEndTime);
    ScheduledActivity newActivity = ScheduledActivity(
      selectedTime: formattedStartTime,
      duration: _duration,
      frequency: 0, // Frequency is not used, set to 0
      selectedDays: _selectedDays,
      channel: 0,
    );

    _scheduledActivities.add(newActivity);

    // Print details to the debug console
    print('Start Time: ${formattedStartTime}');
    print('End Time: ${formattedEndTime}');
    print('Duration: $_duration minutes');
    print('Days: ${_selectedDays.join(', ')}');

    await _prefs.setString('selectedStartTime', formattedStartTime);
    await _prefs.setString('selectedEndTime', formattedEndTime);
    await _prefs.setInt('duration', _duration);
    await _prefs.setStringList('selectedDays', _selectedDays);
    await _prefs.setStringList(
        'scheduledActivities',
        _scheduledActivities
            .map((activity) => json.encode(activity.toJson()))
            .toList());

    // Send schedule to the server
    await _sendScheduleToServer(
        formattedStartTime, formattedEndTime, _selectedDays, _duration);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityPage(
          scheduledActivities: _scheduledActivities,
          onScheduleSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Schedule successful'),
              ),
            );
          },
          selectedTime: '',
        ),
      ),
    );
  }

  void _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _selectedStartTime : _selectedEndTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
        _calculateDuration();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        title: Text('Program Settings'),
      ),
      bottomNavigationBar: buildBottomBar(context, 0, (index) {}),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Time:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
              Container(
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _selectTime(context, true),
                      icon: Icon(Icons.access_time),
                      label: Text(
                        'Select Start Time',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 194, 219, 247)),
                        padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                        elevation: MaterialStateProperty.all(5),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Selected Start Time: ${_formatTimeOfDay(_selectedStartTime)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'End Time:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
              Container(
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _selectTime(context, false),
                      icon: Icon(Icons.access_time),
                      label: Text(
                        'Select End Time',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 194, 219, 247)),
                        padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                        elevation: MaterialStateProperty.all(5),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Selected End Time: ${_formatTimeOfDay(_selectedEndTime)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Duration: $_duration minutes',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 20),
              Text(
                'Select Days:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _daysOfWeek.map((String day) {
                  return FilterChip(
                    label: Text(day),
                    selected: _selectedDays.contains(day),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePreferences,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: Text(
                  'Save Preferences',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
