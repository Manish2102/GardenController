import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gardenmate/Pages/My_Models_Page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:gardenmate/Pages/Login_Page.dart';
import 'package:gardenmate/Pages/BottomNav_Bar.dart';

class ModelsPage extends StatefulWidget {
  @override
  _ModelsPageState createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  String qrText = '';
  User? currentUser;

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

  @override
  Widget build(BuildContext context) {
    String displayName = currentUser?.displayName ?? 'User Name';
    String initial = displayName.isNotEmpty ? displayName.substring(0, 1) : 'U';

    return Scaffold(
      appBar: AppBar(
        title: Text('Models Page'),
      ),
      bottomNavigationBar: buildBottomBar(context, 0, (index) {}),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(displayName),
              accountEmail: Text(currentUser?.email ?? 'user@example.com'),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  initial,
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                // Navigate to MyModelsPage when button is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyModelsPage()),
                );
              },
              child: Text(
                'My Devices',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            if (qrText.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  // Handle button press
                  print('Button pressed: $qrText');
                },
                child: Text(qrText),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openQRScanner,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _openQRScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRViewExample(),
      ),
    );

    // Update qrText when QR code is scanned
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
                  cutOutSize: 300),
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

      // Pass button name back to ModelsPage
      Navigator.pop(context, buttonName);
    });
  }
}
