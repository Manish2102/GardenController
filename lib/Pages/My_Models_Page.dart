import 'package:flutter/material.dart';
import 'package:gardenmate/Device_Screens/GC1Screen.dart';
import 'package:gardenmate/Device_Screens/GC3S_Screen.dart';
import 'package:gardenmate/Device_Screens/GC3_Screen.dart';

class MyModelsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Devices'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GC1Page(
                      userName: '',
                    ),
                  ),
                );
                // Handle GC1 button press
              },
              child: Text(
                'GC1',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GC3Page(userName: ''),
                  ),
                );
              },
              child: Text(
                'GC3',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GC3SPage(userName: ''),
                  ),
                );
              },
              child: Text(
                'GC3S',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
