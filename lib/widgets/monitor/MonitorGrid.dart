/// dart imports
import 'dart:io' show Platform;
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



/// Positioning/aligning the categories as  cards
/// based on the screen width
class MonitorGrid extends StatefulWidget {
  StreamSubscriber StreamObject = null;
  String currentVessel = "";//vessels.urn:mrn:imo:mmsi:503999999

  MonitorGrid({Key key,@required this.StreamObject,@required this.currentVessel}) : super(key: key){

  }

  @override
  _MonitorGridState createState() => _MonitorGridState();
}

class _MonitorGridState extends State<MonitorGrid> {
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

    if (deviceWidth > 1060) {
      padding = deviceWidth * 0.011;
      _cardWidth = (deviceWidth * 0.9) / 3;

      ///setting max cardwidth, spacing between cards in higher resolutions
      if (deviceWidth > 3000) { //three columns
        _cardWidth = 2800 / 3;
        _sidePadding = (deviceWidth - 2740) * 0.5;
        padding = 30;
      }
      final List<Widget> firstColumnWidgets = <Widget>[];
      final List<Widget> secondColumnWidgets = <Widget>[];
      final List<Widget> thirdColumnWidgets = <Widget>[];
      int firstColumnControlCount = 0;
      int secondColumnControlCount = 0;
      organizedCardWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(left: _sidePadding)),
          Column(children: <Widget>[_getCategoryWidget()]),
          Padding(padding: EdgeInsets.only(left: padding)),
          Column(children: <Widget>[Text("bu")]),
          Padding(padding: EdgeInsets.only(left: padding)),
          Column(children: <Widget>[Text("bu")]),
          Padding(
            padding: EdgeInsets.only(left: _sidePadding),
          )
        ],
      );

    } else if (deviceWidth >= 768) { // TABLET


      /**********CURRENTLY WORKING HERE************/



      padding = deviceWidth * 0.011;// 0.018;
      _cardWidth = (deviceWidth * 0.9) / 3;//(deviceWidth * 0.9) / 2;

      organizedCardWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(left: _sidePadding)),
          Column(children: <Widget>[//COLUMN 1
            SimpleCard("Apparent Wind",[Center(child:
            WindIndicator(
                Angle_Stream: _subscribeToStream("environment.wind.angleApparent"),
                Intensity_Stream: _subscribeToStream("environment.wind.speedApparent"),
                model : model
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),



            SimpleCard("COG(m)",[Center(child:
            CompassIndicator(
              model : model,
              COG_Stream: _subscribeToStream("navigation.courseOverGroundMagnetic"),
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),

          ]),
          Padding(padding: EdgeInsets.only(left: padding)),
          Column(children: <Widget>[//COLUMN 2

            SimpleCard("True wind through water",[Center(child:
            WindIndicator(
                Angle_Stream: _subscribeToStream("environment.wind.angleTrueWater"),
                Intensity_Stream: _subscribeToStream("environment.wind.speedTrue"),
                model : model
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),

            SimpleCard("Real time boat",[Center(child:
            BoatVectorsIndicator(
              model:model,
              ATW_Stream: _subscribeToStream("environment.wind.angleTrueWater"),
              ST_Stream: _subscribeToStream("environment.wind.speedTrue"),
              AA_Stream: _subscribeToStream("environment.wind.angleApparent"),
              SA_Stream: _subscribeToStream("environment.wind.speedApparent"),
              HT_Stream: _subscribeToStream("navigation.headingTrue"),
              COG_Stream: _subscribeToStream("navigation.courseOverGroundTrue"),
              SOG_Stream: _subscribeToStream("navigation.speedOverGround"),
            ))]),

            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),

            SimpleCard("Speed Through Water",[Center(child:
            SpeedIndicator(
                ST_Stream: _subscribeToStream("navigation.speedThroughWater"),
                model : model
            ))]),

            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),
            _getCategoryWidget(),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),
            _getCategoryWidget()]
          ),
          Padding(
            padding: EdgeInsets.only(left: padding),
          ),
          Column(children: <Widget>[//COLUMN 3
            SimpleCard("True wind over ground",[Center(child:
            WindIndicator(
                Angle_Stream: _subscribeToStream("environment.wind.angleTrueGround"),
                Intensity_Stream: _subscribeToStream("environment.wind.speedOverGround"),
                model : model
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),


            SimpleCard("COG(t)",[Center(child:
            CompassIndicator(
              model : model,
              COG_Stream: _subscribeToStream("navigation.courseOverGroundTrue"),
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),



            SimpleCard("RPM #1",[Center(child:
            SpeedIndicator(
                ST_Stream: _subscribeToStream("propulsion.engine_1.revolutions"),
                model : model
            ))]),

            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),
            SimpleCard("RPM #2",[Center(child:
            SpeedIndicator(
                ST_Stream: _subscribeToStream("propulsion.engine_2.revolutions"),
                model : model
            ))]),

            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),

            _getCategoryWidget(),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),
            _getCategoryWidget()]
          ),

        ],
      );











    } else { // 1 column
      _cardWidth = deviceWidth * 0.9;
      padding = deviceWidth * 0.035;
      _sidePadding = (deviceWidth * 0.1) / 2;

      organizedCardWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(left: _sidePadding)),
          Column(children: <Widget>[
            //SimpleCard("Speed Through Water",[Center(child:
            //SpeedThroughWaterIndicator(
            //  STW_Stream: this.mainStreamHandle.getStream("navigation.speedThroughWater").asBroadcastStream(),
            //  text: "vel"
            //))]),
            //Padding(padding: EdgeInsets.only(bottom: _sidePadding)),

            SimpleCard("Real time boat",[Center(child:
            BoatVectorsIndicator(
              model: model,
              ATW_Stream: _subscribeToStream("environment.wind.angleTrueWater"),
              ST_Stream: _subscribeToStream("environment.wind.speedTrue"),
              AA_Stream: _subscribeToStream("environment.wind.angleApparent"),
              SA_Stream: _subscribeToStream("environment.wind.speedApparent"),
              HT_Stream: _subscribeToStream("navigation.headingTrue"),
              COG_Stream: _subscribeToStream("navigation.courseOverGroundTrue"),
              SOG_Stream: _subscribeToStream("navigation.speedOverGround"),
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding))

          ]),
          Padding(
            padding: EdgeInsets.only(left: _sidePadding),
          )
        ],
      );

    }




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
                  color: model.backgroundColor,
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
          Column(children: children)
        ]));
  }



  /// get the rounded corner layout for given category
  Widget _getCategoryWidget() {
    return Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: model.cardColor,
            border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        width: _cardWidth,
        child: Column(children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 15, bottom: 2),
            child: Text(
              "bubu",
              style: TextStyle(
                  color: model.backgroundColor,
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
          Column(children: _getControlListView())
        ]));
  }

  /// get the list view of the controls in the specified category
  List<Widget> _getControlListView() {
    final List<Widget> items = <Widget>[];
    for (int i = 0; i<= 1; i++) {
      items.add(Container(
        color: model.cardColor,
        child: Material(
            color: model.cardColor,
            elevation: 0.0,
            child: InkWell(
                splashFactory: InkRipple.splashFactory,
                hoverColor: Colors.grey.withOpacity(0.2),
                onTap: () {
                  //!model.isWebFullView
                  //    ? onTapControlInMobile(context, model, category, i)
                  //    : onTapControlInWeb(context, model, category, i);
                },
                child: Container(
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(
                        12, 2, 0, 6),
                    // leading: Image.asset(control.image, fit: BoxFit.cover),
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(children: [
                            Text(
                              "control",
                              textAlign: TextAlign.left,
                              softWrap: true,
                              textScaleFactor: 1,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                  color: model.textColor,
                                  fontFamily: 'Roboto-Bold'),
                            ),
                            (!model.isWebFullView && Platform.isIOS)
                                ? Container()
                                : Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        3, 3, 3, 2),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Color.fromRGBO(
                                            245, 188, 14, 1)),
                                    child: const Text(
                                      'BETA',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.12,
                                          fontFamily: 'Roboto-Medium',
                                          color: Colors.black),
                                    )))

                          ]),
                          (true == true)
                              ? Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: const Color.fromRGBO(55, 153, 30, 1), //const Color.fromRGBO(                                  246, 117, 0, 1)

                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10))),
                              padding:
                              const EdgeInsets.fromLTRB(6, 2.7, 4, 2.7),
                              child: Text("control status",
                                  style: const TextStyle(
                                      fontFamily: 'Roboto-Medium',
                                      color: Colors.white,
                                      fontSize: 10.5)))
                              : Container()
                        ]),
                    subtitle: Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 7.0, 12.0, 0.0),
                          child: Text(
                            "control desc",
                            textAlign: TextAlign.left,
                            softWrap: true,
                            textScaleFactor: 1,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Color.fromRGBO(128, 128, 128, 1),
                            ),
                          ),
                        )),
                  ),
                ))),
      ));
    }
    return items;
  }
}

