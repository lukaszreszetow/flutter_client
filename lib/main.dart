import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;

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
      home: StronaGlowna(title: 'Flutter Demo Home Page'),
    );
  }
}

class StronaGlowna extends StatefulWidget {
  final String title;

  StronaGlowna({Key key, @required this.title}) : super(key: key);

  @override
  _StronaGlownaState createState() => _StronaGlownaState();
}

class _StronaGlownaState extends State<StronaGlowna> {
  String image;
  String sound;
  String pdf;
  SocketIOManager manager;
  SocketIO socket;
  String emited;
  Stopwatch connectionTime;
  Stopwatch podlaczanie;
  final myController = TextEditingController();

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
              _podlaczDoSerwera(myController.text);
            },
          ),
          RaisedButton(
            child: const Text('Wyslij obraz'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            onPressed: () {
              sendMessage('assets/images/stars.jpg', 'obraz');
            },
          ),
          RaisedButton(
            child: const Text('Wyslij dzwiek'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            onPressed: () {
              sendMessage('assets/sounds/big_sound.mp3', 'dzwiek');
            },
          ),
          RaisedButton(
            child: const Text('Wyslij pdf'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            onPressed: () {
              sendMessage('assets/medium_pdf_file.PDF', 'pdf');
            },
          ),
          TextField(
            controller: myController..text = "192.168.1.",
            decoration: InputDecoration(border: InputBorder.none),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          )
        ],
      )),
    );
  }

  _podlaczDoSerwera(String ip) async {
    manager = SocketIOManager();

    socket = await manager.createInstance(SocketOptions('http://$ip:1337'));

    socket.on("connect", (data) {
      print('Polaczenie zajelo ${podlaczanie.elapsedMilliseconds}');
    });
    socket.on("obraz", (data) {
      print('Komunikacja zajela ${connectionTime.elapsedMilliseconds}');
      setState(() {
        print("Obraz jest identyczny? ${image == emited}");
      });
    });
    socket.on("dzwiek", (data) {
      print('Komunikacja zajela ${connectionTime.elapsedMilliseconds}');
      setState(() {
        print("Dzwiek jest identyczny? ${sound == emited}");
      });
    });
    socket.on("pdf", (data) {
      print('Komunikacja zajela ${connectionTime.elapsedMilliseconds}');
      setState(() {
        print("Pdf jest identyczny? ${pdf == emited}");
      });
    });
    podlaczanie = Stopwatch()..start();
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
      print('Konwersja zajela ${start.elapsedMilliseconds}');
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
