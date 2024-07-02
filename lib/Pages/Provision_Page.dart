import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:android_intent/android_intent.dart';
import 'package:android_intent/flag.dart';
import 'dart:convert';

class BluetoothProvision extends StatefulWidget {
  @override
  _BluetoothProvisionState createState() => _BluetoothProvisionState();
}

class _BluetoothProvisionState extends State<BluetoothProvision> {
  bool isBluetoothOn = false;
  BluetoothConnection? connection;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? selectedDevice;

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

  void _startDiscovery() async {
    devicesList.clear();
    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        devicesList.add(r.device);
      });
    }).onDone(() {
      setState(() {});
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device');

      connection!.input!.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        connection!.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
          connection!.finish(); // Closing connection
          print('Disconnecting by local host');
        }
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } catch (exception) {
      print('Cannot connect, exception occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Provision'),
        backgroundColor: Colors.blue,
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
                  activeTrackColor: Colors.blueAccent,
                  activeColor: Colors.blue,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startDiscovery,
              child: Text('Discover Devices'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: devicesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devicesList[index].name ?? 'Unknown Device'),
                    subtitle: Text(devicesList[index].address.toString()),
                    onTap: () {
                      setState(() {
                        selectedDevice = devicesList[index];
                      });
                      _connectToDevice(selectedDevice!);
                    },
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
