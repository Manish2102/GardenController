import 'package:flutter/material.dart';
//import 'package:esp_smartconfig/esp_smartconfig.dart';
//import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;

class ProvisioningScreen extends StatefulWidget {
  const ProvisioningScreen({super.key, required this.title});

  final String title;

  @override
  State<ProvisioningScreen> createState() => _ProvisioningScreenState();
}

class _ProvisioningScreenState extends State<ProvisioningScreen> {
  final passwordController = TextEditingController();
  String? _selectedSSID;
  List<String> _wifiNetworks = [];

  @override
  void initState() {
    super.initState();
    _fetchWiFiNetworks();
  }

  Future<void> _fetchWiFiNetworks() async {
    final String esp32IPAddress = '192.168.4.1'; // ESP32's hotspot IP address
    final String url = 'http://$esp32IPAddress/wifi?';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> networkList = response.body as List<dynamic>;
        setState(() {
          _wifiNetworks = networkList.map((e) => e.toString()).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch Wi-Fi networks')),
        );
      }
    } catch (e) {
      print('Error fetching Wi-Fi networks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching Wi-Fi networks')),
      );
    }
  }

  Future<void> _sendCredentialsToESP32() async {
    final String esp32IPAddress = '192.168.4.1'; // ESP32's hotspot IP address
    final String url = 'http://$esp32IPAddress/configure';

    if (_selectedSSID == null || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter SSID and password')),
      );
      return;
    }

    final response = await http.post(Uri.parse(url), body: {
      'ssid': _selectedSSID!,
      'password': passwordController.text,
    });

    if (response.statusCode == 200) {
      print('Configuration sent successfully');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Configuration sent successfully')));
    } else {
      print('Failed to send configuration');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send configuration')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.cell_tower,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox.fromSize(size: const Size.fromHeight(20)),
              const Text(
                'Connect device to Wi-Fi network using ESP-Touch protocol',
                textAlign: TextAlign.center,
              ),
              SizedBox.fromSize(size: const Size.fromHeight(40)),
              DropdownButton<String>(
                hint: const Text('Select Wi-Fi Network'),
                value: _selectedSSID,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSSID = newValue!;
                  });
                },
                items: _wifiNetworks.map((String network) {
                  return DropdownMenuItem<String>(
                    value: network,
                    child: Text(network),
                  );
                }).toList(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                controller: passwordController,
              ),
              SizedBox.fromSize(size: const Size.fromHeight(40)),
              ElevatedButton(
                onPressed: _sendCredentialsToESP32,
                child: const Text('Send credentials to ESP32'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}
