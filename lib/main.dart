import 'package:flutter/material.dart';
import 'package:readsms/readsms.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(SmsReaderApp());
}

class SmsReaderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SmsReaderScreen(),
    );
  }
}

class SmsReaderScreen extends StatefulWidget {
  @override
  _SmsReaderScreenState createState() => _SmsReaderScreenState();
}

class _SmsReaderScreenState extends State<SmsReaderScreen> {
  final Readsms _plugin = Readsms();
  List _messages = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.sms.request();
    if (status.isGranted) {
      _startListening();
    } else {
      print("SMS Permission Denied");
    }
  }

  void _startListening() {
    _plugin.read();
    _plugin.smsStream.listen((sms) {
      setState(() {
        _messages.insert(0, sms); // Add new SMS at the top
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SMS Reader"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _messages.isEmpty
          ? Center(
              child: Text("No SMS received yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            )
          : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final sms = _messages[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(Icons.message, color: Colors.blueAccent),
                    title: Text(sms.sender ?? "Unknown Sender",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(sms.body ?? "No content"),
                    trailing: Text(
                      "${sms.timeReceived.hour}:${sms.timeReceived.minute}",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}


