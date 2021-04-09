/// dart imports
import 'dart:io' show Platform;
/// package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';
import 'package:nautica/screens/FirstSetup.dart';
import 'package:nautica/screens/SplashScreen.dart';
import 'package:nautica/screens/DashBoardPage.dart';
import 'package:nautica/screens/SubscriptionsPage.dart';
import 'models/BaseModel.dart';


void main() {

  WidgetsFlutterBinding.ensureInitialized();
  //SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
  //    .then((_) {
  //  SystemChrome.setEnabledSystemUIOverlays([]).then((_) {
  //    runApp(new MyApp());
  //  });
  //});

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}




class _MyAppState extends State<MyApp> {
  BaseModel _sampleListModel;



  @override
  void initState() {
    _sampleListModel = BaseModel.instance;

    _initializeProperties();
    super.initState();

    //maybe connections should be created here

  }

  @override
  Widget build(BuildContext context) {



    ///Avoiding page poping on escape key press
    final Map<LogicalKeySet, Intent> shortcuts =
    Map.of(WidgetsApp.defaultShortcuts)
      ..remove(LogicalKeySet(LogicalKeyboardKey.escape));

    if (_sampleListModel != null && _sampleListModel.isWebFullView) {
      _sampleListModel.currentThemeData = ThemeData.dark();
      _sampleListModel.paletteBorderColors = <Color>[];
      _sampleListModel.changeTheme(_sampleListModel.currentThemeData);
    }

    return  MaterialApp(
      // initialRoute: '/demos',
      //routes: navigationRoutes,
        initialRoute: '/',
        routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          //  '/': (context) => DashBoard(),
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/login': (context) => FirstSetup(),
          '/first_setup': (context) => FirstSetup(),
          '/dashboard': (context) => Builder(builder: (BuildContext context) {
            if(_sampleListModel != null) {
              _sampleListModel.systemTheme = Theme.of(context);
              _sampleListModel.currentThemeData =
              (_sampleListModel.systemTheme.brightness != Brightness.dark
                  ? ThemeData.light()
                  : ThemeData.dark());
              _sampleListModel.changeTheme(_sampleListModel.currentThemeData);
            }
            return DashBoard();


          }),
          '/subscriptions': (context) => Builder(builder: (BuildContext context) {
            if(_sampleListModel != null) {
              _sampleListModel.systemTheme = Theme.of(context);
              _sampleListModel.currentThemeData =
              (_sampleListModel.systemTheme.brightness != Brightness.dark
                  ? ThemeData.light()
                  : ThemeData.dark());
              _sampleListModel.changeTheme(_sampleListModel.currentThemeData);
            }
            return SubscriptionsPage();


          }),
        },

        debugShowCheckedModeBanner: false,
        title: 'Demos & Examples of Syncfusion Flutter Widgets',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: SplashScreen());
  }

  void _initializeProperties() {
    final BaseModel model = BaseModel.instance;
    model.isWebFullView =
        kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    if (kIsWeb) {
      model.isWeb = true;
    } else {
      model.isAndroid = Platform.isAndroid;
      model.isIOS = Platform.isIOS;
      model.isLinux = Platform.isLinux;
      model.isWindows = Platform.isWindows;
      model.isMacOS = Platform.isMacOS;
      model.isDesktop =
          Platform.isLinux || Platform.isMacOS || Platform.isWindows;
      model.isMobile = Platform.isAndroid || Platform.isIOS;
    }
  }
}





























/*



class _MyAppState2 extends State<MyApp> {
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
      gps.subscribePosition(
          this.stream.getStream("nav.position").asBroadcastStream());
      appWind.subscribeApparentWind(
          this.stream.getStream("env.wind.speedApparent").asBroadcastStream());
      appWind.subscribeRealWindSpeed(
          this.stream.getStream("env.wind.speedTrue").asBroadcastStream());

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
      gps.subscribePosition(
          this.stream.getStream("nav.position").asBroadcastStream());
      appWind.subscribeApparentWind(
          this.stream.getStream("env.wind.speedApparent").asBroadcastStream());
      appWind.subscribeRealWindSpeed(
          this.stream.getStream("env.wind.speedTrue").asBroadcastStream());
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
*/
  /***********APP DESIGN***********/
/*
  MaterialApp getMainApplication() {

    return MaterialApp(
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("nautica",style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.headline6)),
            leading: GestureDetector(
              onTap: () {
                /* Write listener code here */
              },
              child: Icon(
                Icons.menu, // add custom icons also
              ),
            ),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.search,
                      size: 26.0,
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.more_vert),
                  )),
            ],
          ),
          body:  Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[


                  Expanded (
                      flex:1,
                      child:
                      Row(
                        children: [
                          Expanded(
                              flex: 5, // 20%
                              child:
                              Card(
                                child: Center(child:
                                PositionIndicator(
                                  Position_Stream: this
                                      .stream
                                      .getStream("nav.position")
                                      .asBroadcastStream(),
                                  text: "vel",
                                )),
                              )
                          ),
                          Expanded(
                              flex: 5, // 20%
                              child:
                              Card(
                                child: Center(child:
                                BoatVectorsIndicator(
                                  ATW_Stream: this
                                      .stream
                                      .getStream("env.wind.angleTrueWater")
                                      .asBroadcastStream(),
                                  ST_Stream: this
                                      .stream
                                      .getStream("env.wind.speedTrue")
                                      .asBroadcastStream(),
                                  AA_Stream: this
                                      .stream
                                      .getStream("env.wind.angleApparent")
                                      .asBroadcastStream(),
                                  SA_Stream: this
                                      .stream
                                      .getStream("env.wind.speedApparent")
                                      .asBroadcastStream(),
                                  HT_Stream: this
                                      .stream
                                      .getStream("nav.headingTrue")
                                      .asBroadcastStream(),
                                  COG_Stream: this
                                      .stream
                                      .getStream("nav.courseOverGroundTrue")
                                      .asBroadcastStream(),
                                  SOG_Stream: this
                                      .stream
                                      .getStream("nav.speedOverGround")
                                      .asBroadcastStream(),
                                  text: "vel",
                                )),
                              )
                            /*PositionIndicator(
                              Position_Stream: this
                                  .stream
                                  .getStream("nav.position")
                                  .asBroadcastStream(),
                              text: "vel",
                            )*/),
                        ],
                      )),
                  //panded (
                  //  flex:1,
                  //  child:
                  //  Row(
                  //    children: [
                  //      Expanded(
                  //          flex: 5, // 20%
                  //          child:
                  //          Card(
                  //            child: Center(child:
                  //            PositionIndicator(
                  //              Position_Stream: this
                  //                  .stream
                  //                  .getStream("nav.position")
                  //                  .asBroadcastStream(),
                  //              text: "vel",
                  //            )),
                  //          )
                  //      ),
                  //      Expanded(
                  //          flex: 5, // 20%
                  //          child:
                  //          Card(
                  //            child: Center(child:
                  //            BoatVectorsIndicator(
                  //              ATW_Stream: this
                  //                  .stream
                  //                  .getStream("env.wind.angleTrueWater")
                  //                  .asBroadcastStream(),
                  //              ST_Stream: this
                  //                  .stream
                  //                  .getStream("env.wind.speedTrue")
                  //                  .asBroadcastStream(),
                  //              AA_Stream: this
                  //                  .stream
                  //                  .getStream("env.wind.angleApparent")
                  //                  .asBroadcastStream(),
                  //              SA_Stream: this
                  //                  .stream
                  //                  .getStream("env.wind.speedApparent")
                  //                  .asBroadcastStream(),
                  //              text: "vel",
                  //            )),
                  //          )
                  //        /*PositionIndicator(
                  //          Position_Stream: this
                  //              .stream
                  //              .getStream("nav.position")
                  //              .asBroadcastStream(),
                  //          text: "vel",
                  //        )*/),
                  //    ],
                  //  )),

                  //Row(
                  //  children: [
                  //    PositionIndicator(
                  //      Position_Stream: this
                  //          .stream
                  //          .getStream("nav.position")
                  //          .asBroadcastStream(),
                  //      text: "vel",
                  //    ),
                  //  ],
                  //),
                  //Row(children: [
                  //  SpeedOverGroundIndicator(
                  //    SOG_Stream: this
                  //        .stream
                  //        .getStream("env.wind.speedTrue")
                  //        .asBroadcastStream(),
                  //    text: "vel",
                  //  ),
                  //]),
                  //Row(
                  //  children: [
                  //    SpeedThroughWaterIndicator(
                  //      STW_Stream: this
                  //          .stream
                  //          .getStream("nav.speedThroughWater")
                  //          .asBroadcastStream(),
                  //      text: "vel",
                  //    )
                  //  ],
                  //)

                ]),
          )),
    );
  }

  MaterialApp getMaterialApp() {
    return MaterialApp(
      home: Scaffold(
        //appBar: AppBar(
        //  title: const Text('Websocket Manager Example'),
        //),
          body: Center(child: LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              return ListView(
                children: <Widget>[
                  this.appWind.buildWidget(),
                  this.gps.getBuildStream(),
                ],
              );
            } else {
              //narrow
              return ListView(
                children: <Widget>[
                  this.gps.getBuildStream(),
                  this.appWind.buildWidget(),
                ],
              );
            }
          }))),
    );
  }
}
*/

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
