import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gardenmate/Bluetooth_Provisions/Provision_Page.dart';
import 'package:gardenmate/Device_Screens/GC1Screen.dart';
import 'package:gardenmate/Device_Screens/GC3S_Screen.dart';
import 'package:gardenmate/Device_Screens/GC3_Screen.dart';
import 'package:gardenmate/Pages/Login_Page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelsPage extends StatefulWidget {
  @override
  _ModelsPageState createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  String qrText = '';
  User? currentUser;
  final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void openBluetoothSettings() async {
    if (Platform.isAndroid) {
      const androidUrl =
          'intent://settings/#Intent;component=com.android.settings/.bluetooth.BluetoothSettings;end';
      try {
        await launchUrl(Uri.parse(androidUrl),
            mode: LaunchMode.externalApplication);
      } catch (e) {
        showError('Could not open Bluetooth settings.');
      }
    } else if (Platform.isIOS) {
      const iosUrl = 'App-Prefs:root=Bluetooth';
      try {
        await launchUrl(Uri.parse(iosUrl));
      } catch (e) {
        showError('Could not open Bluetooth settings.');
      }
    } else {
      showError('Unsupported platform.');
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayName = currentUser?.displayName ?? 'User Name';
    String initial = displayName.isNotEmpty ? displayName.substring(0, 1) : 'U';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        title: Text('Models Page'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'wifi') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              } else if (value == 'bluetooth') {
                openBluetoothSettings();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'wifi',
                  child: Text('WiFi Provision'),
                ),
                PopupMenuItem(
                  value: 'bluetooth',
                  child: Text('Bluetooth Settings'),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green[100]),
              accountName: Text(
                displayName,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                currentUser?.email ?? 'user@example.com',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  initial,
                  style: TextStyle(fontSize: 40.0, color: Colors.black),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Provision'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LogIn()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: connectionStatus,
              builder: (context, isConnected, child) {
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.wifi,
                        color: isConnected ? Colors.green : Colors.red),
                    title: Text(isConnected ? 'Connected' : 'Not Connected'),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.black, width: 2),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GC1Page(userName: displayName)),
                );
              },
              child: Text(
                'GC1',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.black, width: 2),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GC3Page(userName: displayName)),
                );
              },
              child: Text(
                'GC3',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.black, width: 2),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GC3SPage(userName: displayName)),
                );
              },
              child: Text(
                'GC3S',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            if (qrText.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  print('Button pressed: $qrText');
                },
                child: Text(qrText),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openQRScanner,
        backgroundColor: Colors.green[100],
        child: Icon(
          Icons.add,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _openQRScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRViewExample(),
      ),
    );

    setState(() {
      qrText = result ?? '';
    });
  }
}

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  late QRViewController controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Color.fromARGB(255, 60, 167, 41),
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  : Text('Scan a QR code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      String buttonName = RegExp(r'button_name:(.*?)(?:$| )')
              .firstMatch(scanData.code ?? '')
              ?.group(1) ??
          '';

      Navigator.pop(context, buttonName);
    });
  }
}
