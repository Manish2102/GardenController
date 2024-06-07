import 'package:flutter/material.dart';
import 'package:gardenmate/Pages/Activity_Page.dart';
import 'package:gardenmate/Pages/Home.dart';
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
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ModelsPage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ActivityPage(
                          selectedTime: '',
                          duration: 0,
                          frequency: 0,
                          selectedDays: [],
                          onScheduleSuccess: () {},
                        )),
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
