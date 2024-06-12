import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gardenmate/Pages/Activity_Page.dart';
import 'package:gardenmate/Pages/BottomNav_Bar.dart';
import 'package:gardenmate/Pages/Scheduled_Activity.dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Frequency { None, Daily, AlternativeDays, Weekly, SelectDays }

class ProgramSettingsPage extends StatefulWidget {
  @override
  _ProgramSettingsPageState createState() => _ProgramSettingsPageState();
}

class _ProgramSettingsPageState extends State<ProgramSettingsPage> {
  late SharedPreferences _prefs;
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _duration = 1;
  Frequency _frequency = Frequency.None;
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
    return formattedDateTime.toIso8601String();
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final dateTime = DateTime.parse(timeString);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      final timeString = _prefs.getString('selectedTime');
      if (timeString != null) {
        _selectedTime = _parseTimeOfDay(timeString);
      }
      _duration = _prefs.getInt('duration') ?? 1;
      _frequency = Frequency.values[_prefs.getInt('frequency') ?? 0];
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

    // Validate frequency
    if (_frequency == Frequency.None) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a frequency.'),
        ),
      );
      return;
    }

    // Validate selected days if frequency is SelectDays
    if (_frequency == Frequency.SelectDays && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one day.'),
        ),
      );
      return;
    }

    // If all validations pass, proceed to save preferences
    String formattedTime = _formatTimeOfDay(_selectedTime);
    ScheduledActivity newActivity = ScheduledActivity(
      selectedTime: formattedTime,
      duration: _duration,
      frequency: _frequency.index,
      selectedDays: _selectedDays,
    );

    _scheduledActivities.add(newActivity);

    await _prefs.setString('selectedTime', formattedTime);
    await _prefs.setInt('duration', _duration);
    await _prefs.setInt('frequency', _frequency.index);
    await _prefs.setStringList('selectedDays', _selectedDays);
    await _prefs.setStringList(
        'scheduledActivities',
        _scheduledActivities
            .map((activity) => json.encode(activity.toJson()))
            .toList());

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

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
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
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: Text(
                      'Select Time',
                      style:
                          TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
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
                  SizedBox(width: 10),
                  Text(
                    'Selected Time: ${_selectedTime.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Duration (minutes):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _duration = int.tryParse(value) ?? 0;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter duration',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'How Often:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Frequency>(
                    value: _frequency,
                    onChanged: (Frequency? newValue) {
                      setState(() {
                        _frequency = newValue!;
                      });
                    },
                    items: Frequency.values.map((Frequency frequency) {
                      return DropdownMenuItem<Frequency>(
                        value: frequency,
                        child: Text(frequency.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (_frequency == Frequency.SelectDays) ...[
                SizedBox(height: 20),
                Text(
                  'Select Days:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Wrap(
                  children: _buildDayButtons(),
                ),
              ],
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 200,
                  child: OutlinedButton(
                    onPressed: _savePreferences,
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.black, fontSize: 20),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDayButtons() {
    List<Widget> buttons = [];
    for (String day in _daysOfWeek) {
      buttons.add(
        FilterChip(
          label: Text(day),
          selected: _selectedDays.contains(day),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(day);
              } else {
                _selectedDays.remove(day);
              }
            });
          },
        ),
      );
      buttons.add(SizedBox(width: 10));
    }
    return buttons;
  }
}
