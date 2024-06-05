import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

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
    await device.connect();
    setState(() {
      _connectedDevice = device;
      connectedESP32Devices.add(device);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connected to ${device.name}')),
    );
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

    final url = 'http://192.168.1.3/wifi'; // Update with the actual IP address
    int retryCount = 3;

    for (int i = 0; i < retryCount; i++) {
      try {
        final response = await http.post(
          Uri.parse(url),
          body: {
            'ssid': widget.ssid,
            'password': _password,
          },
        );

        print('Response: ${response.body}');

        if (response.statusCode == 200) {
          print('Configuration sent successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Configuration sent successfully')),
          );
          widget.connectionStatus.value = true; // Update the connection status
          _showSuccessDialog();
          break;
        } else {
          print('Failed to send configuration: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to send configuration: ${response.body}')),
          );
        }
      } catch (e) {
        if (i == retryCount - 1) {
          print('Error sending configuration: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sending configuration: $e')),
          );
        } else {
          await Future.delayed(Duration(seconds: 2)); // Retry delay
        }
      }
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
