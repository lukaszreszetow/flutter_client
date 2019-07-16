import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  String image;
  String sound;
  String pdf;
  SocketIOManager manager;
  SocketIO socket;
  String emited;
  Stopwatch connectionTime;

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
            child: const Text('Send image'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            onPressed: () {
              sendMessage('assets/images/stars.jpg', 'image');
            },
          ),
          RaisedButton(
            child: const Text('Send sound'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            onPressed: () {
              sendMessage('assets/sounds/big_sound.mp3', 'sound');
            },
          ),
          RaisedButton(
            child: const Text('Send pdf'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            onPressed: () {
              sendMessage('assets/medium_pdf_file.PDF', 'pdf');
            },
          ),
          addWidget()
        ],
      )),
    );
  }

  addWidget() {
    if (image == null) {
      return Text("no message");
    } else {
      final bytes = base64Decode(image);
      return Image.memory(bytes);
    }
  }

  _connectToSocket() async {
    manager = SocketIOManager();
    socket = await manager.createInstance(SocketOptions('http://10.0.2.2:1337/'));
    socket.on("image", (data) {
      print('Communication took ${connectionTime.elapsedMilliseconds}');
      setState(() {
        image = data.toString();
        print("Image is the same ${image == emited}");
      });
    });
    socket.on("sound", (data) {
      print('Communication took ${connectionTime.elapsedMilliseconds}');
      setState(() {
        sound = data.toString();
        print("Sound is the same ${sound == emited}");
      });
    });
    socket.on("pdf", (data) {
      print('Communication took ${connectionTime.elapsedMilliseconds}');
      setState(() {
        pdf = data.toString();
        print("Pdf is the same ${pdf == emited}");
      });
    });
    socket.connect();
  }

  disconnect() async {
    await manager.clearInstance(socket);
  }

  sendMessage(String file, String event) async {
    if (socket != null) {
      Stopwatch start = Stopwatch()..start();
      final fileBytes = await rootBundle.load(file);
      final fileCoded = base64Encode(fileBytes.buffer
          .asUint8List(fileBytes.offsetInBytes, fileBytes.lengthInBytes));
      print('Converting took ${start.elapsedMilliseconds}');
      emited = fileCoded;
      connectionTime = Stopwatch()..start();
      socket.emit(event, [fileCoded]);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
