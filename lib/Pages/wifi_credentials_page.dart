/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

class WiFiCredentialsPage extends StatefulWidget {
  final String ssid;
  final BluetoothDevice? connectedDevice;
  final ValueNotifier<bool> connectionStatus;

  WiFiCredentialsPage({
    required this.ssid,
    this.connectedDevice,
    required this.connectionStatus,
  });

  @override
  _WiFiCredentialsPageState createState() => _WiFiCredentialsPageState();
}

class _WiFiCredentialsPageState extends State<WiFiCredentialsPage> {
  String _password = '';
  bool _isLoading = false;

  void _sendCredentials() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.connectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ESP32 is not connected')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    BluetoothDevice device = widget.connectedDevice!;
    List<BluetoothService> services = await device.discoverServices();
    BluetoothService? wifiService;
    BluetoothCharacteristic? wifiCharacteristic;

    // Replace with your actual service and characteristic UUIDs
    String serviceUUID = "00001800-0000-1000-8000-00805f9b34fb";
    String characteristicUUID = "00002a00-0000-1000-8000-00805f9b34fb";

    for (var service in services) {
      if (service.uuid.toString() == serviceUUID) {
        wifiService = service;
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUUID) {
            wifiCharacteristic = characteristic;
            break;
          }
        }
        break;
      }
    }

    if (wifiService == null || wifiCharacteristic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wi-Fi service or characteristic not found')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      String credentials = widget.ssid + " " + _password;
      await wifiCharacteristic.write(utf8.encode(credentials));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configuration sent successfully')),
      );
      widget.connectionStatus.value = true; // Update the connection status
      _showSuccessDialog();
    } catch (e) {
      print('Error sending configuration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending configuration: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });

    // Navigate back to the previous page
    Navigator.pop(context);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Your credentials are sent successfully'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous page
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter WiFi Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'SSID: ${widget.ssid}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              onChanged: (value) {
                _password = value;
              },
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendCredentials,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Send Credentials'),
            ),
          ],
        ),
      ),
    );
  }
}*/
