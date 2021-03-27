import 'package:flutter/material.dart';
import 'package:nautica/SignalKClient.dart';
import 'package:nautica/widgets/GPS.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'dart:developer';
import 'Configuration.dart';
import 'StreamSubscriber.dart';

import 'package:websocket_manager/websocket_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<int> _future;
  final TextEditingController _urlController =
      TextEditingController(text: 'ws://192.168.1.180:3000/');
  final TextEditingController _messageController = TextEditingController();
  WebsocketManager socket;
  String _message = '';
  String _closeMessage = '';

  bool goForIt = true;
  GPSWidget gps = GPSWidget();
  GPSWidget gps2 = GPSWidget();
  StreamSubscriber stream;

  @override
  void initState() {
    _future = Future.value(DateTime.now().second);

    Authentication loginData = null;
    print("INIT ONCE!");

    if (goForIt) {
      final signalK = SignalKClient("192.168.1.180", 3000, loginData);
      this.stream = StreamSubscriber(signalK);

      gps.setTitle("ciao");
      gps.subscribePosition(this.stream.getStream("nav.position").asBroadcastStream());
      gps2.subscribePosition(this.stream.getStream("nav.position").asBroadcastStream());

      signalK.loadSignalKData().then((x) {
        this.stream.startListening().then((isListening) {
          print("we are listening!");
        }).catchError((Object onError) {
          print('[main] Unable to stream -- on error : $onError');
        });
        //
        //stream.WSConnect().then(
        // subscribe every widget to his data
        // )....

        //
      }).catchError((Object onError) {
        print('[main] Unable to connect -- on error : $onError');
      });
    } else {
      // test functions....

      final signalK = SignalKClient("192.168.1.180", 3000, loginData);
      this.stream = StreamSubscriber(signalK);

      gps.setTitle("ciao");
      gps.subscribePosition(this.stream.getStream("nav.position").asBroadcastStream());
      gps2.subscribePosition(this.stream.getStream("nav.position").asBroadcastStream());


    }

/*

    print("INIT STATE");

    SubscriptionMap.forEach((k,v) => print('${k}: ${v}'));

*/

    super.initState();
  }

  @override
  Widget build(context) {
    return FutureBuilder<int>(
        future: _future,
        builder: (context, snapshot) {
          //return Text(snapshot.data.toString());
          print("hello!");

          return getMaterialApp();
        });
    return FutureBuilder<int>(
        future: _future,
        builder: (context, snapshot) {
          //return Text(snapshot.data.toString());
          print("hello!");

          return getMaterialApp();
        });
  }

  /***********APP DESIGN***********/

  MaterialApp getMaterialApp() {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Websocket Manager Example'),
        ),
        body:

        Column(
          children: <Widget>[
            this.gps.getBuildStream(),
            this.gps2.getBuildStream(),


          ],
        ),



      ),
    );
  }
}
/*

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  // This should actually be a List<MyClass> instead of widgets.
  List<Widget> _list;

  @override
  void initState() {
    super.initState();
    _fetchList();
  }

  Future _fetchList() async {
    List<Widget> singleLineImages = new List();
    List unit;
    for (int i = 0; i <= widget.unitsList.length-1; i++){
      for (int j = 1; j <= int.parse(widget.unitsList[i].quantity); j++){
        print("${widget.unitsList[i].bulletin}, ${widget.unitsList[i].mountType}, ${widget.unitsList[i].disconnect}");
        String fileName = await getfileName(widget.unitsList[i].bulletin, widget.unitsList[i].mountType, widget.unitsList[i].disconnect);
      singleLineImages.add(
          Image.asset("images/SD_Files_2100/$fileName.jpg", height: 400.0, width: 200.0,));
      }
    }

    // call setState here to set the actual list of items and rebuild the widget.
    setState(() {
      _list = singleLineImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the list, or for example a CircularProcessIndicator if it is null.
  }
}

 */
