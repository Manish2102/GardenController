import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DiscoveredDevicesPage extends StatefulWidget {
  @override
  _DiscoveredDevicesPageState createState() => _DiscoveredDevicesPageState();
}

class _DiscoveredDevicesPageState extends State<DiscoveredDevicesPage> {
  List<BluetoothDevice> devicesList = [];

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  void _startDiscovery() async {
    setState(() {
      devicesList.clear();
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        devicesList.add(r.device);
      });
    }).onDone(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discovered Devices'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _startDiscovery,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devicesList[index].name ?? 'Unknown Device'),
            subtitle: Text(devicesList[index].address.toString()),
            onTap: () {
              Navigator.pop(context, devicesList[index]);
            },
          );
        },
      ),
    );
  }
}
