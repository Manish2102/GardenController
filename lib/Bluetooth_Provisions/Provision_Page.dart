import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:android_intent/android_intent.dart';
import 'package:android_intent/flag.dart';
import 'package:gardenmate/Bluetooth_Provisions/Paired_device.dart';

class BluetoothProvision extends StatefulWidget {
  @override
  _BluetoothProvisionState createState() => _BluetoothProvisionState();
}

class _BluetoothProvisionState extends State<BluetoothProvision> {
  bool isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      setState(() {
        isBluetoothOn = state == BluetoothState.STATE_ON;
      });
    });
  }

  void _checkBluetoothStatus() async {
    bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
    setState(() {
      isBluetoothOn = isEnabled ?? false;
    });
  }

  void _toggleBluetooth(bool value) async {
    if (value) {
      await FlutterBluetoothSerial.instance.requestEnable();
    } else {
      await FlutterBluetoothSerial.instance.requestDisable();
    }
    await Future.delayed(
        Duration(seconds: 1)); // Delay to ensure the state is updated
    _checkBluetoothStatus();
  }

  void _openBluetoothSettings() {
    final AndroidIntent intent = AndroidIntent(
      action: 'android.settings.BLUETOOTH_SETTINGS',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }

  void _navigateToPairedDevices() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PairedDevicesPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Provision'),
        backgroundColor: Colors.green[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable Bluetooth',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: isBluetoothOn,
                  onChanged: (value) {
                    _toggleBluetooth(value);
                  },
                  activeTrackColor: Colors.green,
                  activeColor: Colors.green[100],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bluetooth Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  isBluetoothOn ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 18,
                    color: isBluetoothOn ? Colors.green : Colors.red,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: _openBluetoothSettings,
                ),
              ],
            ),
            Divider(), // Divider line added
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToPairedDevices,
              child: Text('Connect to paired devices'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Sharp borders
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
