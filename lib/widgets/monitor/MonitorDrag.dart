/// dart imports
import 'dart:io' show Platform;
import 'dart:math';

/// package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

import 'package:nautica/widgets/monitor/indicators/BoatVectorsIndicator.dart';
import 'package:nautica/widgets/monitor/indicators/CompassIndicator.dart';
import 'package:nautica/widgets/monitor/indicators/SpeedIndicator.dart';
import 'package:nautica/widgets/monitor/indicators/WindIndicator.dart';

import 'package:nautica/network/StreamSubscriber.dart';
import 'package:nautica/models/BaseModel.dart';

import 'package:nautica/Configuration.dart';
import 'package:nautica/widgets/reorderable/reorderable_wrap.dart';
import 'dart:convert' as convert;

import '../DraggableCard.dart';
import 'graph/BasicGraph.dart';

/// Positioning/aligning the categories as  cards
/// based on the screen width
class MonitorDrag extends StatefulWidget {
  StreamSubscriber StreamObject = null;
  String currentVessel = ""; //vessels.urn:mrn:imo:mmsi:503999999
  int once = 0;

  MonitorDrag(
      {Key key, @required this.StreamObject, @required this.currentVessel})
      : super(key: key) {}

  @override
  _MonitorDragState createState() => _MonitorDragState();
}

class _MonitorDragState extends State<MonitorDrag> {
  BaseModel model = BaseModel.instance;
  double _cardWidth;
  StreamSubscriber mainStreamHandle;
  String vessel;

  bool isMainGridReady = false;
  bool haveErrorLoadingGrid = false;

  List<IconData> elements = <IconData>[
    Icons.traffic,
    Icons.nature,
    Icons.eco,
    Icons.train,
    Icons.motorcycle,
    Icons.flight,
    Icons.ac_unit,
    Icons.dangerous,
  ];

  List<Widget> mainWidgetList = [];

  @override
  void dispose() {
    super.dispose();
  }

  void initState() {
    super.initState();
    vessel = widget.currentVessel;
    //});
    getMainGrid();
  }

  Stream<dynamic> _subscribeToStream(String path) {
    return widget.StreamObject.getVesselStream(
            vessel,
            path,
            Duration(
                microseconds: NAUTICA['configuration']['widget']
                    ['refreshRate']))
        .asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width / 4;

    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder(builder: (context, snapshot) {
          return !isMainGridReady
              ? (haveErrorLoadingGrid ? Text("error") : Text("loading"))
              : (ReorderableWrap(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      mainWidgetList.insert(
                          newIndex, mainWidgetList.removeAt(oldIndex));
                    });
                  },
                  children: mainWidgetList.map((icon) {
                    var rng = new Random();
                    return ReorderableWrapItem(
                        key: ValueKey(icon), child: icon);
                  }).toList(),
                ));
        }),
      ),
    );
  }

  Widget SimpleCard(String title, List<Widget> children) {
    return Container(
        padding: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
            color: model.cardColor,
            border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        width: _cardWidth,
        child: Column(children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 5, bottom: 2),
            child: Text(
              title,
              style: TextStyle(
                  color: model.paletteColor,
                  fontSize: 16,
                  fontFamily: 'Roboto-Bold'),
            ),
          ),
          Divider(
            color: model.themeData != null &&
                    model.themeData.brightness == Brightness.dark
                ? const Color.fromRGBO(61, 61, 61, 1)
                : const Color.fromRGBO(238, 238, 238, 1),
            thickness: 1,
          ),
          Padding(padding: EdgeInsets.only(bottom: 0, top: 0)),
          Column(children: children)
        ]));
  }

  void getMainGrid() {
    setState(() {
      isMainGridReady = false;
      haveErrorLoadingGrid = false;
    });

    try {
      dynamic mainGridTheme = convert.jsonDecode(mainJSONGridTheme);

      try {
        print("gegrid");
        print(mainGridTheme.toString());

        for (dynamic widgets in mainGridTheme['widgets']) {
          //0..n widgets

          mainWidgetList.add(DraggableCard(
              model: model,
              widgetData: widgets,
              StreamObject: widget.StreamObject,
              currentVessel: widget.currentVessel));
        }
        setState(() {
          isMainGridReady = true;
        });
        //insert into ---> mainWidgetList

      } catch (e) {
        print("err : " + e.toString());
      }
    } catch (e) {
      print("unable to decode json " + e.toString());
    }
  }

/*
  BaseModel model = BaseModel.instance;
  double _cardWidth;
  StreamSubscriber mainStreamHandle;
  String vessel;

  void initState(){
    print("MONITOR CURRENT VESSEL " + widget.currentVessel);
    super.initState();
    vessel = widget.currentVessel;
    //});
  }

  _MonitorGridState(){

  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _getMonitorGrid());
  }

  Stream<dynamic> _subscribeToStream(String path){
    return widget.StreamObject.getVesselStream(vessel,path,Duration(microseconds: NAUTICA['configuration']['widget']['refreshRate'])).asBroadcastStream();
  }



  Widget _getMonitorGrid() {
    final double deviceWidth = MediaQuery.of(context).size.width;

    double padding;
    double _sidePadding = deviceWidth > 1060
        ? deviceWidth * 0.038
        : deviceWidth >= 768
        ? deviceWidth * 0.041
        : deviceWidth * 0.05;

    Widget organizedCardWidget;


    padding = deviceWidth * 0.011;// 0.018;
    _cardWidth = (deviceWidth * 0.9) / 4;//(deviceWidth * 0.9) / 2;
    _sidePadding = (deviceWidth * 0.1) / 8;

    organizedCardWidget = Row(children: [

      Text("ciao")],);


    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.only(top: deviceWidth > 1060 ? 15 : 10),
            child: organizedCardWidget));
  }

  Widget SimpleCard(String title, List<Widget> children) {


    return Container(
        padding: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
            color: model.cardColor,
            border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        width: _cardWidth,
        child: Column(children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 5, bottom: 2),
            child: Text(
              title,
              style: TextStyle(
                  color: model.paletteColor,
                  fontSize: 16,
                  fontFamily: 'Roboto-Bold'),
            ),
          ),
          Divider(
            color: model.themeData!= null && model.themeData.brightness == Brightness.dark
                ? const Color.fromRGBO(61, 61, 61, 1)
                : const Color.fromRGBO(238, 238, 238, 1),
            thickness: 1,
          ),
          Padding(padding: EdgeInsets.only(bottom: 0, top:0)),

          Column(children: children)
        ]));
  }

*/
}
