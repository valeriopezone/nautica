/// dart imports
import 'dart:io' show Platform;


import 'package:nautica/Configuration.dart';

/// package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nautica/widgets/AnimateOpacityWidget.dart';
import 'package:nautica/widgets/monitor/MonitorDrag.dart';
import 'package:nautica/widgets/monitor/MonitorGrid.dart';
import 'package:nautica/widgets/monitor/SubscriptionsGrid.dart';
import 'package:nautica/widgets/monitor/map/RealTimeMap.dart';
import 'package:websocket_manager/websocket_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nautica/network/SignalKClient.dart';
import 'package:nautica/network/StreamSubscriber.dart';


import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';


/// Home page of the sample browser for both mobile and web
class DashBoard extends StatefulWidget {
  /// creates the home page layout
  const DashBoard();

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {


  BaseModel sampleListModel;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController controller = ScrollController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();


  SignalKClient signalK = null;
  WebsocketManager socket;
  StreamSubscriber SKFlow;
  Authentication loginData = null;

  String signalKServerAddress;
  int signalKServerPort;

  String currentViewState = "monitors";
  String currentVessel;

  List<String> vesselsList;
  Map vesselsDataTable;


  bool sectionLoaded = false;
  void _setViewState(String state) {
    setState(() {
      currentViewState = state;
    });
  }


  void _setCurrentVessel(String vessel) {
    setState(() {
      currentVessel = vessel;
     // currentViewState = "monitors";
    });
  }


  Widget _getCurrentView(){
    switch(currentViewState){


      case "real_time_map" :
        return new MapSample(key: UniqueKey(),
            StreamObject : this.SKFlow,
            currentVessel : currentVessel);
        break;

      case "subscriptions" :
        return new SubscriptionsGrid(
            key: UniqueKey(),
            StreamObject : this.SKFlow,
            currentVessel : currentVessel,
            vesselsDataTable : vesselsDataTable);
        break;

      case "monitors" :
      default :

      return new MonitorDrag(key: UniqueKey(),
          StreamObject : this.SKFlow,
          currentVessel : currentVessel);

      return new MonitorGrid(key: UniqueKey(),
          StreamObject : this.SKFlow,
          currentVessel : currentVessel);
        break;
    }
  }

  @override
  void initState() {
    sampleListModel = BaseModel.instance;
    sampleListModel.addListener(_handleChange);
    //sampleListModel.paletteBorderColors[4] = sampleListModel.paletteColors[4];
    //sampleListModel.currentPaletteColor = sampleListModel.paletteColors[4];
    //sampleListModel.currentPrimaryColor = sampleListModel.darkPaletteColors[4];
   // sampleListModel.changeTheme(ThemeData.dark());

    super.initState();


    _prefs.then((SharedPreferences prefs) {
      signalKServerAddress =
          prefs.getString('signalKServerAddress') ?? NAUTICA['signalK']['connection']['address'];
      signalKServerPort = prefs.getInt('signalKServerPort') ?? NAUTICA['signalK']['connection']['port'];

      print("INIT ONCE!");

      signalK = SignalKClient(signalKServerAddress, signalKServerPort, loginData);
      //signalK = SignalKClient("192.168.1.179", 3000, loginData);
      SKFlow = StreamSubscriber(signalK);

      signalK.loadSignalKData().then((x) {
        SKFlow.startListening().then((isListening) {
          print("we are listening!");
          vesselsList = signalK.getVessels();
          vesselsDataTable = signalK.getPaths();


          setState(() {
            // The listenable's state was changed already.
            currentVessel = (vesselsList[0] != null) ? vesselsList[0] : null;
            sectionLoaded = true;

          });

        }).catchError((Object onError) {
          print('[main] Unable to stream -- on error : $onError');
          cleanPrefsAndGoToSetup().then((value) => goToSetup());
        });
      }).catchError((Object onError) {
        print('[main] Unable to connect -- on error : $onError');
        cleanPrefsAndGoToSetup().then((value) => goToSetup());

      });



    });



  }

  Future<void> cleanPrefsAndGoToSetup() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool("firstSetupDone", false).then((bool success) {
      return Future.value(true);
    });

  }

  void goToSetup(){
    Navigator.pop(context);
    Navigator.pushNamed(context, '/');
  }

  @override
  void dispose(){
    if(signalK != null) signalK.WSdisconnect();
    sectionLoaded = false;
    super.dispose();
  }

  ///Notify the framework by calling this method
  void _handleChange() {
    if (mounted) {
      setState(() {
        // The listenable's state was changed already.
      });
    }
  }

  @override
  Widget build(BuildContext context) {

   // print("START BUILDING DASHBOARD");
    ///Checking the download button is currently hovered
    bool isHoveringDownloadButton = false;

    ///Checking the get packages is currently hovered
    bool isHoveringPubDevButton = false;
    final bool isMaxxSize = MediaQuery.of(context).size.width >= 1000;
    final BaseModel model = sampleListModel;
    model.isMobileResolution = (MediaQuery.of(context).size.width) < 768;
    //return Container();
    return !sectionLoaded ? getSpinnerPage(model) : FutureBuilder(
      builder: (context, snapshot) {
        return Container(
          child: SafeArea(
              child:
              //model.isMobileResolution
              //    ?
              //Scaffold(
              //    resizeToAvoidBottomInset: false,
              //    drawer: (!model.isWebFullView && Platform.isIOS)
              //        ? null //Avoiding drawer in iOS platform
              //        : null,
              //    key: scaffoldKey,
              //    backgroundColor: model.webBackgroundColor,
              //    endDrawer:
              //    !model.isWebFullView ? null : showWebThemeSettings(model),
              //    appBar: PreferredSize(
              //        preferredSize: const Size.fromHeight(46.0),
              //        child: AppBar(
              //          leading: (!model.isWebFullView && Platform.isIOS)
              //              ? Container()
              //              : null,
              //          elevation: 0.0,
              //          backgroundColor: model.paletteColor,
              //          title: AnimateOpacityWidget(
              //              controller: controller,
              //              opacity: 0,
              //              child: const Text('Nautica',
              //                  style: TextStyle(
              //                      fontSize: 18, fontFamily: 'HeeboMedium'))),
              //          actions: <Widget>[
              //            Container(
              //              height: 40,
              //              width: 40,
              //              child: IconButton(
              //                icon: const Icon(Icons.settings,
              //                    color: Colors.white),
              //                onPressed: () {
//
              //                  //Navigator.pushNamed(context, '/login');
//
              //                  model.isWebFullView
              //                      ? scaffoldKey.currentState.openEndDrawer()
              //                      : showBottomSettingsPanel(model, context);
              //                },
              //              ),
              //            ),
              //          ],
              //        )),
              //    body: Container(
              //        transform: Matrix4.translationValues(0, -1, 0),
              //        child: _getScrollableWidget(model)))
              //    :

              Scaffold(
                // bottomNavigationBar: getFooter(context, model),
                  key: scaffoldKey,
                  backgroundColor: model.webBackgroundColor,
                  endDrawer: showWebThemeSettings(model),
                  resizeToAvoidBottomInset: false,
                  appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(75.0),
                      child: AppBar(
                        leading: Container(),
                        elevation: 0.0,
                        backgroundColor: model.paletteColor,
                        flexibleSpace: Container(
                            transform: Matrix4.translationValues(0, 4, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(24, 10, 0, 0),
                                  child: const Text('Nautica ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          letterSpacing: 0.53,
                                          fontFamily: 'Roboto-Bold')),
                                ),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
                                    child: Text('Open Source Marine Electronics',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Roboto-Regular',
                                            letterSpacing: 0.26,
                                            fontWeight: FontWeight.normal))),
                                const Padding(
                                  padding: EdgeInsets.only(top: 15),
                                ),
                               // Container(
                               //     alignment: Alignment.bottomCenter,
                               //     width: double.infinity,
                               //     height: 0,
                               //     decoration: BoxDecoration(
                               //         color: model.webBackgroundColor,
                               //         borderRadius: const BorderRadius.only(
                               //             topLeft: Radius.circular(12.0),
                               //             topRight: Radius.circular(12.0)),
                               //         boxShadow: <BoxShadow>[
                               //           BoxShadow(
                               //             color: model.webBackgroundColor,
                               //             offset: const Offset(0, 2.0),
                               //             blurRadius: 0.25,
                               //           )
                               //         ]))


                              ],
                            )),
                        actions: <Widget>[
                          MediaQuery.of(context).size.width < 500
                              ? Container(height: 0, width: 9)
                              : Container(
                              //child: Container(
                              //  padding:
                              //  const EdgeInsets.only(top: 10, right: 10),
                              //  width: MediaQuery.of(context).size.width >=
                              //      920
                              //      ? 300
                              //      : MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width < 820
                              //      ? 5
                              //      : 4),
                              //  height: MediaQuery.of(context).size.height * 0.0445,
                              //  child: Text("searchbarr"),
                              //)
                          ),

                          ///download option
                          model.isMobileResolution
                              ? Container()
                              : Row(
                            mainAxisSize: MainAxisSize.min,

                            crossAxisAlignment: CrossAxisAlignment.stretch,

                            children: [
                                  Container(

                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(
                                      top: 10, left: isMaxxSize ? 10 : 0),
                                  child: Container(

                                      child: StatefulBuilder(builder:
                                          (BuildContext context,
                                          StateSetter setState) {
                                            return
                                              Row(
                                                children: [


                                                  (currentVessel != null ) ? SizedBox(
                                                      child:  DropdownButton<String>(
                                                        value: currentVessel,
                                                        icon: const Icon(Icons.arrow_downward),
                                                        iconSize: 24,
                                                        elevation: 16,
                                                        style: const TextStyle(color: Colors.white),
                                                        underline: Container(
                                                          height: 0,
                                                          color: model.splashScreenBackground,
                                                        ),
                                                        onChanged: (String vessel) {
                                                          _setCurrentVessel(vessel);
                                                        },
                                                        dropdownColor: Colors.black,
                                                        items: vesselsList
                                                            .map<DropdownMenuItem<String>>((String value) {
                                                          return DropdownMenuItem<String>(
                                                            value: value,
                                                            child: Text("Vessel #" + (vesselsList.indexOf(value) + 1).toString()),
                                                          );
                                                        }).toList(),
                                                      )
                                                  ) : Container(),
                                                  Padding(padding: EdgeInsets.only(left: 25)),
                                                  SizedBox(
                                                    child: MaterialButton(
                                                      onPressed: (){_setViewState("monitors");},//_setViewState("subscriptions"),
                                                      child: Text("MON"),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.only(left: 25)),

                                                  SizedBox(
                                                    child: MaterialButton(
                                                      onPressed: (){_setViewState("subscriptions");},//_setViewState("subscriptions"),
                                                      child: Text("SUB"),
                                                      color: Colors.white,


                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.only(left: 25)),

                                                  SizedBox(
                                                    child: MaterialButton(
                                                      onPressed: (){_setViewState("real_time_map");},//_setViewState("subscriptions"),
                                                      child: Text("MAP"),
                                                      color: Colors.white,


                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.only(left: 25)),

                                                  SizedBox(
                                                    child: MaterialButton(
                                                      onPressed: (){cleanPrefsAndGoToSetup().then((value) => goToSetup());},//_setViewState("subscriptions"),
                                                      child: Text("LOGOUT"),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.only(left: 25)),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,

                                                    children: [
                                                      showThemeSwitcher(sampleListModel),
                                                    ],
                                                  ),
                                                ],
                                              );
                                      }))),
                                ],
                              ),

                          ///Get package from pub.dev option
                   //       model.isMobileResolution
                   //           ? Container()
                   //           : Container(
                   //           alignment: Alignment.center,
                   //           padding: EdgeInsets.only(
                   //               top: 10, left: isMaxxSize ? 25 : 12),
                   //           child: Container(
                   //               width: 118,
                   //               height: 32,
                   //               decoration: BoxDecoration(
                   //                   border:
                   //                   Border.all(color: Colors.white)),
                   //               child: StatefulBuilder(builder:
                   //                   (BuildContext context,
                   //                   StateSetter setState) {
                   //                 return MouseRegion(
                   //                   onHover: (PointerHoverEvent event) {
                   //                     isHoveringPubDevButton = true;
                   //                     setState(() {});
                   //                   },
                   //                   onExit: (PointerExitEvent event) {
                   //                     isHoveringPubDevButton = false;
                   //                     setState(() {});
                   //                   },
                   //                   child: InkWell(
                   //                     hoverColor: Colors.white,
                   //                     onTap: () {
//
                   //                     },
                   //                     child: Padding(
                   //                       padding:
                   //                       const EdgeInsets.fromLTRB(
                   //                           0, 7, 8, 7),
                   //                       child: Row(children: [
                   //                         Image.asset(
                   //                             'assets/boat.png',
                   //                             fit: BoxFit.contain,
                   //                             height: 33,
                   //                             width: 33),
                   //                         Text('Credits',
                   //                             style: TextStyle(
                   //                                 color:
                   //                                 isHoveringPubDevButton
                   //                                     ? model
                   //                                     .paletteColor
                   //                                     : Colors.white,
                   //                                 fontSize: 12,
                   //                                 fontFamily:
                   //                                 'Roboto-Medium'))
                   //                       ]),
                   //                     ),
                   //                   ),
                   //                 );
                   //               }))),
                          Padding(
                              padding:
                              EdgeInsets.only(left: isMaxxSize ? 15 : 0),
                              child: Container(
                                padding: MediaQuery
                                    .of(context)
                                    .size
                                    .width < 500
                                    ? const EdgeInsets.only(top: 20, left: 5)
                                    : EdgeInsets.only(top: 10, right: 15),
                                height: 60,
                                width: 60,
                                child: IconButton(
                                  icon: const Icon(Icons.settings,
                                      color: Colors.white),
                                  onPressed: () {
                                    //Navigator.pushNamed(context, '/login');

                                    scaffoldKey.currentState.openEndDrawer();
                                  },
                                ),
                              )),
                        ],
                      )),
                  body: _getCurrentView())

          ),
        );
      }
    );
  }







Widget getSpinnerPage(BaseModel model){
    return Container(
      child: SafeArea(
        child: Scaffold(
          // bottomNavigationBar: getFooter(context, model),
            key: scaffoldKey,
            backgroundColor: model.webBackgroundColor,
            endDrawer: showWebThemeSettings(model),
            resizeToAvoidBottomInset: false,
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(90.0),
                child: AppBar(
                  leading: Container(),
                  elevation: 0.0,
                  backgroundColor: model.paletteColor,
                  flexibleSpace: Container(
                      transform: Matrix4.translationValues(0, 4, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding:
                            const EdgeInsets.fromLTRB(24, 10, 0, 0),
                            child: const Text('Nautica ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    letterSpacing: 0.53,
                                    fontFamily: 'Roboto-Bold')),
                          ),
                          const Padding(
                              padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
                              child: Text('Open Source Marine Electronics',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Roboto-Regular',
                                      letterSpacing: 0.26,
                                      fontWeight: FontWeight.normal))),
                          const Padding(
                            padding: EdgeInsets.only(top: 15),
                          ),
                          Container(
                              alignment: Alignment.bottomCenter,
                              width: double.infinity,
                              height: kIsWeb ? 16 : 14,
                              decoration: BoxDecoration(
                                  color: model.webBackgroundColor,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: model.webBackgroundColor,
                                      offset: const Offset(0, 2.0),
                                      blurRadius: 0.25,
                                    )
                                  ]))
                        ],
                      )),
                  actions: <Widget>[
                   Container(),
                  ],
                )),
            body:  model.getLoadingPage()),
      ),
    );
}















  /// get scrollable widget to getting stickable view
  Widget _getScrollableWidget(BaseModel model) {

    return Container(
        color: model.paletteColor,
        child: GlowingOverscrollIndicator(
            color: model.paletteColor,
            axisDirection: AxisDirection.down,
            child: CustomScrollView(
              controller: controller,
              physics: const ClampingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text('Nautica',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  letterSpacing: 0.53,
                                  fontFamily: 'HeeboBold',
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 8, 0, 0),
                          child: Text('Fast . Fluid . Flexible',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  letterSpacing: 0.26,
                                  fontFamily: 'HeeboBold',
                                  fontWeight: FontWeight.normal)),
                        )
                      ],
                    )),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PersistentHeaderDelegate(model),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    Container(
                        color: model.webBackgroundColor,
                        child: _getCurrentView()),
                  ]),
                )
              ],
            )));
  }

  /// Add the palette colors



}

/// Search bar, rounded corner
class _PersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PersistentHeaderDelegate(BaseModel sampleModel) {
    _sampleListModel = sampleModel;
  }
  BaseModel _sampleListModel;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 90,
      child: Container(
          color: _sampleListModel.paletteColor,
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                height: 70,
                child: Text("search"),
              ),
              Container(
                  height: 20,
                  decoration: BoxDecoration(
                      color: _sampleListModel.webBackgroundColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: _sampleListModel.webBackgroundColor,
                          offset: const Offset(0, 2.0),
                          blurRadius: 0.25,
                        )
                      ])),
            ],
          )),
    );
  }

  @override
  double get maxExtent => 90;

  @override
  double get minExtent => 90;

  @override
  bool shouldRebuild(_PersistentHeaderDelegate oldDelegate) {
    return true;
  }
}




