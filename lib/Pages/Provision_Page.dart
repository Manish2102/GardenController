import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WiFiScanPage(),
    );
  }
}

class WiFiScanPage extends StatefulWidget {
  @override
  _WiFiScanPageState createState() => _WiFiScanPageState();
}

class _WiFiScanPageState extends State<WiFiScanPage> {
  List<WifiNetwork> _wifiNetworks = [];
  List<String> _espNetworks = [];

  @override
  void initState() {
    super.initState();
    _scanWiFiNetworks();
    _fetchESPNetworks();
  }

  void _scanWiFiNetworks() async {
    List<WifiNetwork> networks = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      _wifiNetworks = networks;
    });
  }

  void _fetchESPNetworks() async {
    final url = 'http://192.168.4.1/wifi?';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> networks = json.decode(response.body);
      setState(() {
        _espNetworks =
            networks.map((network) => network['ssid'] as String).toList();
      });
    } else {
      print('Failed to fetch ESP networks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan WiFi Networks'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(),
          Text('ESP8266 Networks'),
          Expanded(
            child: ListView.builder(
              itemCount: _espNetworks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_espNetworks[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WiFiCredentialsPage(
                          ssid: _espNetworks[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WiFiCredentialsPage extends StatefulWidget {
  final String ssid;

  WiFiCredentialsPage({required this.ssid});

  @override
  _WiFiCredentialsPageState createState() => _WiFiCredentialsPageState();
}

class _WiFiCredentialsPageState extends State<WiFiCredentialsPage> {
  String _password = '';

  void _sendCredentials() async {
    final url = 'http://192.168.4.1/wifisave';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'ssid': widget.ssid,
        'password': _password,
      },
    );

    if (response.statusCode == 200) {
      print('Configuration sent successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configuration sent successfully')),
      );
    } else {
      print('Failed to send configuration');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send configuration')),
      );
    }
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
              onPressed: _sendCredentials,
              child: Text('Send Credentials'),
            ),
          ],
        ),
      ),
    );
  }
}
