import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
        leading: Icon(Icons.notifications),
      ),
      body: Center(
        child: Text('Notification Page Content'),
      ),
    );
  }
}
