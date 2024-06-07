import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class WiFiScanPage extends StatefulWidget {
  final ValueNotifier<bool> connectionStatus;

  WiFiScanPage({required this.connectionStatus});

  @override
  _WiFiScanPageState createState() => _WiFiScanPageState();
}

class _WiFiScanPageState extends State<WiFiScanPage> {
  List<WifiNetwork> _wifiNetworks = [];
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<ScanResult>>? _subscription;
  List<BluetoothDevice> connectedESP32Devices = [];

  @override
  void initState() {
    super.initState();
    _scanWiFiNetworks();
  }

  void _scanWiFiNetworks() async {
    List<WifiNetwork> networks = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      _wifiNetworks = networks;
    });
  }

  Future<void> _connectToBluetooth() async {
    // Request permissions for Bluetooth
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissions not granted')),
      );
      return;
    }

    // Start scanning for Bluetooth devices
    _flutterBlue.startScan(timeout: Duration(minutes: 2));

    // Listen to scan results
    _subscription = _flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == 'ESP32') {
          // Replace with your ESP32 Bluetooth name
          _flutterBlue.stopScan();
          _subscription?.cancel();
          _connectToDevice(r.device);
          return;
        }
      }
    });

    // Stop scanning after a timeout
    Future.delayed(Duration(minutes: 1), () {
      _flutterBlue.stopScan();
      _subscription?.cancel();
      if (_connectedDevice == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No devices found')),
        );
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        _connectedDevice = device;
        connectedESP32Devices.add(device);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${device.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _connectedDevice?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan WiFi Networks'),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth),
            onPressed: _connectToBluetooth,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _wifiNetworks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_wifiNetworks[index].ssid ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WiFiCredentialsPage(
                    ssid: _wifiNetworks[index].ssid ?? '',
                    connectedDevice: _connectedDevice,
                    connectionStatus: widget.connectionStatus,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

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
}
