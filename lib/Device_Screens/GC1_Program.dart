import 'package:flutter/material.dart';
import 'package:gardenmate/Pages/BottomNav_Bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Frequency { Daily, AlternativeDays, Weekly, SelectDays }

class ProgramSettingsPage extends StatefulWidget {
  @override
  _ProgramSettingsPageState createState() => _ProgramSettingsPageState();
}

class _ProgramSettingsPageState extends State<ProgramSettingsPage> {
  late SharedPreferences _prefs;
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _duration = 1;
  Frequency _frequency = Frequency.Daily; // Default frequency
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

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTime = TimeOfDay.fromDateTime(DateTime.parse(
          _prefs.getString('selectedTime') ?? DateTime.now().toString()));
      _duration = _prefs.getInt('duration') ?? 1;
      _frequency = Frequency.values[_prefs.getInt('frequency') ?? 0];
      _selectedDays = _prefs.getStringList('selectedDays') ?? [];
    });
  }

  Future<void> _savePreferences() async {
    await _prefs.setString('selectedTime', _selectedTime.toString());
    await _prefs.setInt('duration', _duration);
    await _prefs.setInt('frequency', _frequency.index);
    await _prefs.setStringList('selectedDays', _selectedDays);
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
                    _duration = int.tryParse(value) ?? 1;
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
              DropdownButton<Frequency>(
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
              ElevatedButton(
                onPressed: () async {
                  await _savePreferences();
                  Navigator.pop(context);
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 194, 219, 247)),
                  padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  elevation: MaterialStateProperty.all(5),
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
