import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
class QrCodeScreen extends StatefulWidget {
  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;


  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool hasScanned = false ; 

  Color borderColor = Colors.red;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Qr Code Scanner"),
        actions: [
          DropdownButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(
                        width: 8,
                      ),
                      Text("Logout"),
                    ],
                  ),
                ),
                value: "logout",
              )
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(flex: 4, child: _buildQrView(context),),

           if (result != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Le pointage a ete effectuer avec succées', style: TextStyle(color: Colors.green,fontSize: 16,),
                )
              )
          else
                const Text('Scan a code'),

          if(hasScanned) 
            ElevatedButton(onPressed: (){
              controller?.resumeCamera();
              setState(() {
                hasScanned = false;
                result = null;
              });
            }, child: Text("SCANER QR CODE"),
            
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0075BC),) ,
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 10.0),) ,
              textStyle:MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 20,color: Colors.white),) ,
              minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity,50),) ,
            ),
            
            
            ),         
        ]
      ),
    );   
  }
    Widget _buildQrView(BuildContext context) {
   
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // var scanArea = MediaQuery.of(context).size.width * 0.7;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 20,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

   void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      borderColor = Colors.green;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        controller.pauseCamera();
        borderColor = Colors.red;
      });
      if (result!.code == 'GLOBAL_CODE') {
      _handleGlobalCodeScanned();
    }
    });
  }

void _handleGlobalCodeScanned() async {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
  final username = data['username'];
  final role = data['role'];
  final String workOn = data['workOn'].toString();

  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final String formattedDate = formatter.format(DateTime.now());

  final DateFormat hourFormatter = DateFormat("HH:mm");
  final String currentHour = hourFormatter.format(DateTime.now());

  final String scanInfo = 'Username: $username\nRole: $role\nDate: $formattedDate\nlieuDeTravail: $workOn';
  print('lieuDeTravail: $workOn');
  setState(() {
    result = Barcode(scanInfo, BarcodeFormat.qrcode, [1, 1, 1, 1]);
    hasScanned = true;
  });

  DocumentSnapshot scanData = await FirebaseFirestore.instance.collection('users').doc(userId + '_' + formattedDate.split(' ')[0]).get();

  Map<String, dynamic> body;
  var url = Uri.parse('https://script.google.com/macros/s/AKfycbyJtb1VDdecVJiFtfwruvyLqlNqXEu0fLvbyQ53t9lYpRq1EPr4AT-upcc1Zi1McRXvRQ/exec');

  if (!scanData.exists) {
    // Document does not exist, meaning this is the first scan of the day (Entry Scan)
    await FirebaseFirestore.instance.collection('users').doc(userId + '_' + formattedDate.split(' ')[0]).set({
      "enter_hour": currentHour,
    });
    body = {
      'date': formattedDate,
      'employee': username,
      'role': role,
      'lieuDeTravail': workOn,
      'entrer': currentHour,
      'sortie': "",
    };
    print('Sending HTTP POST request with body: $body');
  } else {
    // Document exists, this is the second scan of the day (Exit Scan)
    final Map<String, dynamic> scanDataMap = scanData.data() as Map<String, dynamic>;
    await FirebaseFirestore.instance.collection('users').doc(userId + '_' + formattedDate.split(' ')[0]).update({
      'exit_hour': currentHour,
    });
    body = {
      'date': formattedDate,
      'employee': username,
      'role': role,
      'lieuDeTravail': workOn,
      'entrer': scanDataMap['enter_hour'], // Getting the saved entry hour
      'sortie': currentHour // Current hour as this is the exit scan
    };
  }

  try {
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
      
    );
    print('Sending request with body: ${jsonEncode(body)}');
    if (response.statusCode == 200) {
      print('Data sent to Google Sheets');
      print('Sending body: $body');

    } else {
      print('Error sending data to Google Sheets: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (error) {
    print('Error during HTTP request: $error');
  }
}

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

