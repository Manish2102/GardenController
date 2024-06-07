import 'package:flutter/material.dart';
import 'package:gardenmate/Pages/Home.dart';
import 'package:gardenmate/Pages/Scheduled_Activity.dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'activity_page.dart';
import 'notification_page.dart';

Padding buildBottomBar(context, int _currentIndex, Function callback) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 9.0, left: 9.0, right: 9.0),
    child: ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20.0),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green[50],
        selectedItemColor: Colors.black,
        selectedFontSize: 15.0,
        iconSize: 30.0,
        onTap: (index) async {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ModelsPage()),
              );
              break;
            case 1:
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              final List<String>? scheduledActivityStrings =
                  prefs.getStringList('scheduledActivities');
              final List<ScheduledActivity> scheduledActivities =
                  scheduledActivityStrings != null
                      ? scheduledActivityStrings
                          .map((jsonString) => ScheduledActivity.fromJson(
                              json.decode(jsonString)))
                          .toList()
                      : [];
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityPage(
                    onScheduleSuccess: () {},
                    selectedTime: '', // Adjust as necessary
                    scheduledActivities: scheduledActivities,
                  ),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
              break;
          }
        },
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: 'Home',
            activeIcon: Icon(
              Icons.home,
              color: Colors.black,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined, color: Colors.black),
            label: 'Activity',
            activeIcon: Icon(
              Icons.assessment,
              color: Colors.black,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Colors.black),
            label: 'Notification',
            activeIcon: Icon(
              Icons.notifications,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}
