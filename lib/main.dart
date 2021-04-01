import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nautica/SignalKClient.dart';
import 'package:nautica/widgets/ApparentWind.dart';
import 'package:nautica/widgets/GPS.dart';
import 'package:nautica/widgets/PositionIndicator.dart';
import 'package:nautica/widgets/SpeedOverGroundIndicator.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'dart:developer';
import 'Configuration.dart';
import 'StreamSubscriber.dart';
import 'package:flutter/services.dart';
import 'package:websocket_manager/websocket_manager.dart';
import 'package:google_fonts/google_fonts.dart';



void main() {

WidgetsFlutterBinding.ensureInitialized();
SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
    .then((_) {

  SystemChrome.setEnabledSystemUIOverlays([]).then((_) {
    runApp(new MyApp());

  });


});


// runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<int> _future;


  WebsocketManager socket;
  String _message = '';
  String _closeMessage = '';

  bool goForIt = true;
  GPSWidget gps = GPSWidget();
  ApparentWindIndicator appWind = ApparentWindIndicator();
  StreamSubscriber stream;

  @override
  void initState() {
    _future = Future.value(DateTime.now().second);

    Authentication loginData = null;
    print("INIT ONCE!");

    if (goForIt) {
      final signalK = SignalKClient("192.168.1.179", 3000, loginData);
      this.stream = StreamSubscriber(signalK);

      gps.setTitle("ciao");
      gps.subscribePosition(this.stream.getStream("nav.position").asBroadcastStream());
      appWind.subscribeApparentWind(this.stream.getStream("env.wind.speedApparent").asBroadcastStream());
      appWind.subscribeRealWindSpeed(this.stream.getStream("env.wind.speedTrue").asBroadcastStream());

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

      final signalK = SignalKClient("192.168.1.179", 3000, loginData);
      this.stream = StreamSubscriber(signalK);

      gps.setTitle("ciao");
      gps.subscribePosition(this.stream.getStream("nav.position").asBroadcastStream());
      appWind.subscribeApparentWind(this.stream.getStream("env.wind.speedApparent").asBroadcastStream());
      appWind.subscribeRealWindSpeed(this.stream.getStream("env.wind.speedTrue").asBroadcastStream());

    }

/*

    print("INIT STATE");

    SubscriptionMap.forEach((k,v) => print('${k}: ${v}'));

*/

    super.initState();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();


  }

  @override
  Widget build(context) {

    //SystemChrome.setPreferredOrientations([
    //  DeviceOrientation.landscapeLeft,
    //  DeviceOrientation.landscapeRight,
    //]);


    return FutureBuilder<int>(
        future: _future,
        builder: (context, snapshot) {
          //return Text(snapshot.data.toString());
          print("hello!");
        return getMainApplication();
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


  MaterialApp getMainApplication(){
    return MaterialApp(
      home: Scaffold(
        //appBar: AppBar(
        //  title: const Text('Websocket Manager Example'),
        //),
          body:
          Center(
           child: Container(
             child: Column(
               children : [
                 SpeedOverGroundIndicator(
                   SOG_Stream: this.stream.getStream("env.wind.speedTrue").asBroadcastStream(),
                   text : "vel",
                 ),
                 PositionIndicator(
                   Position_Stream: this.stream.getStream("nav.position").asBroadcastStream(),
                   text : "vel",
                 ),
                 SpeedOverGroundIndicator(
                   SOG_Stream: this.stream.getStream("env.wind.speedTrue").asBroadcastStream(),
                   text : "vel",
                 ),
               ]
             )
           )
          )


      ),
    );

  }


  MaterialApp getMaterialApp() {



    return MaterialApp(
      home: Scaffold(
       //appBar: AppBar(
       //  title: const Text('Websocket Manager Example'),
       //),
        body:
Center(
    child : LayoutBuilder(
      builder : (context,constraints){
        if(constraints.maxWidth > 500){
          return     ListView(
            children: <Widget>[
              this.appWind.buildWidget(),
              this.gps.getBuildStream(),

            ],
          );

      }else{
          //narrow
          return     ListView(
            children: <Widget>[
              this.gps.getBuildStream(),
              this.appWind.buildWidget(),

            ],
          );
        }
      }
    )
)


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
