import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'dart:convert';
import 'package:adhara_socket_io/adhara_socket_io.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, @required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message;
  SocketIOManager manager;
  SocketIO socket;

  @override
  void initState() {
    super.initState();
    manager = SocketIOManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: const Text('Connect to socket'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            onPressed: () {
              _connectToSocket();
            },
          ),
          RaisedButton(
            child: const Text('Send to socket'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            onPressed: () {
              sendMessage();
            },
          ),
          addWidget()
        ],
      )),
    );
  }

  addWidget() {
    if(message == null) {
      return Text("no message");
    } else {
      final bytes = base64Decode(message);
      print("bytes = $bytes");
      return Image.memory(bytes);
    }

  }

  _connectToSocket() async {
    manager = SocketIOManager();
    socket = await manager.createInstance('http://10.0.2.2:1337/');
    socket.on("message", (data) {
      print("new message arrived");
      print("message = $data");
      setState(() {
        message = data.toString();
      });
    });
    socket.connect();
  }

  disconnect() async {
    await manager.clearInstance(socket);
  }

  sendMessage() async {
    if (socket != null) {
      print("sending message");
      //socket.emit("message", [myController.text]);
      final imageBytes = await rootBundle.load('assets/images/dog.jpeg');
      print("imageBytes = $imageBytes");
      final image = base64Encode(imageBytes.buffer.asUint8List(imageBytes.offsetInBytes, imageBytes.lengthInBytes));
      print("image = $image");
      socket.emit("message", [image]);
      print("Message emitted...");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
