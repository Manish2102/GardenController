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

  void _connectToPairedDevice() async {
    final pairedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Paired Device'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: pairedDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(pairedDevices[index].name ?? 'Unknown Device'),
                  subtitle: Text(pairedDevices[index].address.toString()),
                  onTap: () {
                    setState(() {
                      selectedDevice = pairedDevices[index];
                    });
                    _connectToDevice(selectedDevice!);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _openChat(BluetoothDevice device) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatPage(device: device),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startDiscovery,
              child: Text('Discover Devices'),
            ),
            ElevatedButton(
              onPressed: _connectToPairedDevice,
              child: Text('Connect to paired device to chat'),
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
                      _openChat(selectedDevice!);
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

class ChatPage extends StatefulWidget {
  final BluetoothDevice device;

  ChatPage({required this.device});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  BluetoothConnection? connection;
  List<String> messages = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  void _connectToDevice() async {
    try {
      connection = await BluetoothConnection.toAddress(widget.device.address);
      print('Connected to the device');

      connection!.input!.listen((Uint8List data) {
        setState(() {
          messages.add('Remote: ${ascii.decode(data)}');
        });
        if (ascii.decode(data).contains('!')) {
          connection!.finish();
          print('Disconnecting by local host');
        }
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } catch (exception) {
      print('Cannot connect, exception occurred');
    }
  }

  void _sendMessage(String text) async {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(utf8.encode(text)));
      setState(() {
        messages.add('Local: $text');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live chat with ${widget.device.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_textController.text);
                    _textController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
