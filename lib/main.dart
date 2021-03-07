import 'package:flutter/material.dart';
import 'package:nautica/SignalKClient.dart';
import 'dart:developer';

import 'package:websocket_manager/websocket_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<int> _future;
  final TextEditingController _urlController =  TextEditingController(text: 'ws://192.168.1.180:3000/');
  final TextEditingController _messageController = TextEditingController();
  WebsocketManager socket;
  String _message = '';
  String _closeMessage = '';


  @override
  void initState() {
    _future = Future.value(DateTime.now().second);

    final signalK = SignalKClient("192.168.1.180",3000);

    print("initx");



    super.initState();
  }


  @override
  Widget build(context) {
    return FutureBuilder<int>(
        future: _future,
        builder: (context, snapshot) {
          //return Text(snapshot.data.toString());
          print("hello!");

          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Websocket Manager Example'),
              ),
              body: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
            ),
            Wrap(
              children: <Widget>[
                RaisedButton(
                  child: Text('CONFIG'),
                  onPressed: () =>
                  socket = WebsocketManager(_urlController.text),
                ),
                RaisedButton(
                  child: Text('CONNECT'),
                  onPressed: () {
                    if (socket != null) {
                      print("connecting");
                      socket.connect();
                    }
                  },
                ),
                RaisedButton(
                  child: Text('CLOSE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.close();
                    }
                  },
                ),
                RaisedButton(
                  child: Text('LISTEN MESSAGE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.onMessage((dynamic message) {
                        print('New message: $message');
                        setState(() {
                          _message = message.toString();
                        });
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('LISTEN DONE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.onClose((dynamic message) {
                        print('Close message: $message');
                        setState(() {
                          _closeMessage = message.toString();
                        });
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('ECHO TEST'),
                  onPressed: () => WebsocketManager.echoTest(),
                ),
              ],
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (socket != null) {
                      socket.send(_messageController.text);
                    }
                  },
                ),
              ),
            ),
            Text('Received message:'),

            Text(_message),
            Text('Close message:'),
            Text(_closeMessage),
          ],
        ),
            ),
          );


        }
    );
  }
}





class _MyAppState2 extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _urlController =  TextEditingController(text: 'ws://192.168.1.180:3000/signalk/v1/api/?subscribe=all');
  final TextEditingController _messageController = TextEditingController();
  WebsocketManager socket;
  String _message = '';
  String _closeMessage = '';







  @override
  Widget build(BuildContext context) {


    final signalK = SignalKClient("192.168.1.180",3000);

    print("initx");


/*
    int messageNum = 0;
// Configure WebSocket url
    ///signalk/v1/api/vessels/self/navigation/courseOverGroundTrue/
    //final socket1 = WebsocketManager('ws:///signalk/v1/stream/vessels/self/navigation/courseOverGroundTrue');
    final socket1 = WebsocketManager('ws://192.168.1.180:3000/signalk/v1/stream/');
// Listen to close message
    socket1.onClose((dynamic message) {
      print('close');
    });
// Listen to server messages
    socket1.onMessage((dynamic message) {
      print('recv: $message');
     // socket1.close();

      if(messageNum == 100) {
      socket1.close();
      } else {
      messageNum += 1;

      }
      });
// Connect to server
    socket1.connect();


    */




    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Websocket Manager Example'),
        ),
        /*body: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
            ),
            Wrap(
              children: <Widget>[
                RaisedButton(
                  child: Text('CONFIG'),
                  onPressed: () =>
                  socket = WebsocketManager(_urlController.text),
                ),
                RaisedButton(
                  child: Text('CONNECT'),
                  onPressed: () {
                    if (socket != null) {
                      print("connecting");
                      socket.connect();
                    }
                  },
                ),
                RaisedButton(
                  child: Text('CLOSE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.close();
                    }
                  },
                ),
                RaisedButton(
                  child: Text('LISTEN MESSAGE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.onMessage((dynamic message) {
                        print('New message: $message');
                        setState(() {
                          _message = message.toString();
                        });
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('LISTEN DONE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.onClose((dynamic message) {
                        print('Close message: $message');
                        setState(() {
                          _closeMessage = message.toString();
                        });
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('ECHO TEST'),
                  onPressed: () => WebsocketManager.echoTest(),
                ),
              ],
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (socket != null) {
                      socket.send(_messageController.text);
                    }
                  },
                ),
              ),
            ),
            Text('Received message:'),

            Text(_message),
            Text('Close message:'),
            Text(_closeMessage),
          ],
        ),*/
      ),
    );
  }
}