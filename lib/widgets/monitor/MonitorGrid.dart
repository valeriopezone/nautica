/// dart imports
import 'dart:io' show Platform;
/// package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter/cupertino.dart';

import 'package:nautica/widgets/monitor/BoatVectorsIndicator.dart';

import 'package:nautica/widgets/monitor/SpeedOverGroundIndicator.dart';
import 'package:nautica/widgets/monitor/SpeedThroughWaterIndicator.dart';
import 'package:nautica/widgets/monitor/SpeedTrueIndicator.dart';


import '../../StreamSubscriber.dart';

import '../../models/BaseModel.dart';
import '../../models/Helper.dart';
import 'TrueWindThroughWaterIndicator.dart';

/// Positioning/aligning the categories as  cards
/// based on the screen width
class MonitorGrid extends StatefulWidget {
  StreamSubscriber mainStreamHandle = null;

  MonitorGrid({Key key,@required this.mainStreamHandle}) : super(key: key){

  }

  @override
  _MonitorGridState createState() => _MonitorGridState(mainStreamHandle);
}

class _MonitorGridState extends State<MonitorGrid> {
  BaseModel model = BaseModel.instance;
  double _cardWidth;
  StreamSubscriber mainStreamHandle = null;

  _MonitorGridState(StreamSubscriber this.mainStreamHandle){
    print("LOADED STREAM ----> ${mainStreamHandle}");
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _getMonitorGrid());
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
            TrueWindThroughWaterIndicator(
              ATW_Stream: this.mainStreamHandle.getStream("nav.speedThroughWater").asBroadcastStream(),
              ST_Stream: this.mainStreamHandle.getStream("nav.speedTrue").asBroadcastStream(),
              text: "vel",
                model : model
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),



            SimpleCard("SOG",[Center(child:
            SpeedOverGroundIndicator(
              SOG_Stream: this.mainStreamHandle.getStream("nav.speedOverGround").asBroadcastStream(),
              text: "vel",
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),

          ]),
          Padding(padding: EdgeInsets.only(left: padding)),
          Column(children: <Widget>[//COLUMN 2

            SimpleCard("True wind through water",[Center(child:
            TrueWindThroughWaterIndicator(
                ATW_Stream: this.mainStreamHandle.getStream("nav.speedThroughWater").asBroadcastStream(),
                ST_Stream: this.mainStreamHandle.getStream("nav.speedTrue").asBroadcastStream(),
                text: "vel",
                model : model
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),

            SimpleCard("Real time boat",[Center(child:
            BoatVectorsIndicator(
              model:model,
              ATW_Stream: this.mainStreamHandle.getStream("env.wind.angleTrueWater").asBroadcastStream(),
              ST_Stream: this.mainStreamHandle.getStream("env.wind.speedTrue").asBroadcastStream(),
              AA_Stream: this.mainStreamHandle.getStream("env.wind.angleApparent").asBroadcastStream(),
              SA_Stream: this.mainStreamHandle.getStream("env.wind.speedApparent").asBroadcastStream(),
              HT_Stream: this.mainStreamHandle.getStream("nav.headingTrue").asBroadcastStream(),
              COG_Stream: this.mainStreamHandle.getStream("nav.courseOverGroundTrue").asBroadcastStream(),
              SOG_Stream: this.mainStreamHandle.getStream("nav.speedOverGround").asBroadcastStream(),
            ))]),

            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),

            SimpleCard("Speed True",[Center(child:
            SpeedTrueIndicator(
                ST_Stream: this.mainStreamHandle.getStream("env.wind.speedTrue").asBroadcastStream(),
                text: "vel",
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

            SimpleCard("True wind through ground",[Center(child:
            TrueWindThroughWaterIndicator(
                ATW_Stream: this.mainStreamHandle.getStream("nav.speedThroughWater").asBroadcastStream(),
                ST_Stream: this.mainStreamHandle.getStream("nav.speedTrue").asBroadcastStream(),
                text: "vel",
                model : model
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),
            SimpleCard("SOG",[Center(child:
            SpeedOverGroundIndicator(
              SOG_Stream: this.mainStreamHandle.getStream("nav.speedOverGround").asBroadcastStream(),
              text: "vel",
            ))]),

            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),

            SimpleCard("Speed True",[Center(child:
            SpeedTrueIndicator(
                ST_Stream: this.mainStreamHandle.getStream("env.wind.speedTrue").asBroadcastStream(),
                text: "vel",
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
            SimpleCard("Speed Through Water",[Center(child:
            SpeedThroughWaterIndicator(
              STW_Stream: this.mainStreamHandle.getStream("nav.speedThroughWater").asBroadcastStream(),
              text: "vel"
            ))]),
            Padding(padding: EdgeInsets.only(bottom: _sidePadding)),

            SimpleCard("Real time boat",[Center(child:
            BoatVectorsIndicator(
              model: model,
              ATW_Stream: this.mainStreamHandle.getStream("env.wind.angleTrueWater").asBroadcastStream(),
              ST_Stream: this.mainStreamHandle.getStream("env.wind.speedTrue").asBroadcastStream(),
              AA_Stream: this.mainStreamHandle.getStream("env.wind.angleApparent").asBroadcastStream(),
              SA_Stream: this.mainStreamHandle.getStream("env.wind.speedApparent").asBroadcastStream(),
              HT_Stream: this.mainStreamHandle.getStream("nav.headingTrue").asBroadcastStream(),
              COG_Stream: this.mainStreamHandle.getStream("nav.courseOverGroundTrue").asBroadcastStream(),
              SOG_Stream: this.mainStreamHandle.getStream("nav.speedOverGround").asBroadcastStream(),
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

