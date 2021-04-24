import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:nautica/network/StreamSubscriber.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/widgets/monitor/map/LeafLetRealTimeMap.dart';

import 'monitor/graph/DateValueAxisChart.dart';
import 'monitor/indicators/BoatVectorsIndicator.dart';
import 'monitor/indicators/CompassIndicator.dart';

import 'package:nautica/Configuration.dart';

import 'monitor/indicators/SpeedIndicator.dart';
import 'monitor/indicators/TextIndicator.dart';
import 'monitor/indicators/WindIndicator.dart';
import 'monitor/map/RealTimeMap.dart';

class DraggableCard extends StatefulWidget {
  StreamSubscriber StreamObject;
  String currentVessel = ""; //
  dynamic vesselsDataTable = [];

  BaseModel model;
  dynamic widgetData;
  int currentPosition;
  int currentWidgetIndex;

  final Future<void> Function(int cardId, int viewId) onCardStatusChangedCallback;
  final Future<void> Function(int cardId, int viewId) onGoingToEditCallback;
  final Future<void> Function(int cardId, int viewId) onGoingToDeleteCallback;

  final Function(String text, Icon icon) notifyParent;

  DraggableCard(
      {Key key,
      @required this.model,
      @required this.currentPosition,
      @required this.currentWidgetIndex,
      @required this.widgetData,
      @required this.StreamObject,
      @required this.currentVessel,
      @required this.onCardStatusChangedCallback,
      @required this.onGoingToEditCallback,
      @required this.onGoingToDeleteCallback,
      @required this.vesselsDataTable,
      this.notifyParent})
      : super(key: key);

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  bool isLoadingWidget = true;
  bool errorOccurred = false;
  String currentTitle;
  String currentClass;
  dynamic widgetOptions;
  dynamic loadedWidgetData;
  dynamic currentSubscriptions;

  Color currentCardColor;

  List<Widget> loadedWidgets = [];
  double currentWidgetWidth = 1; // 1/4
  double currentWidgetHeight = 1.0; // 1/1

  // List<String> widgetTitles = [];
  Map<int, String> widgetTitles = {};

  @override
  void initState() {
    widget.model = BaseModel.instance;
    widget.model.addListener(() {
      if (mounted) {
        setState(() {
          currentCardColor = widget.model.cardColor;
        });
      }

      print("CARD COLOR SHOULD CHANGE");
    });

    super.initState();

    currentCardColor = widget.model.cardColor;

    setState(() {
      isLoadingWidget = true;
    });
    widgetTitles = {};

    //init widget data, indexes, .....
    try {
      //loop
      dynamic w = widget.widgetData;
      //print(w['current'].toString());
      var current = w['current']; //current index
      dynamic elements = w['elements'];

      currentWidgetWidth = (w['width'] > 0) ? w['width'] + .0 : 1;
      currentWidgetHeight = (w['height'] > 0) ? w['height'] + .0 : 1;
      print(elements.toString());
      if (current != null && current >= 0 && elements != null) {
        int i = 0;
        for (dynamic single in elements) {
          String eTitle = single['widgetTitle'];
          String eClass = single['widgetClass'];
          dynamic eSubscriptions = single['widgetSubscriptions'];

          if (eTitle != null && eClass != null && eSubscriptions != null) {
            if (i == current) {
              currentTitle = eTitle;
              currentClass = eClass;
              currentSubscriptions = eSubscriptions;
              loadedWidgetData = single;
              widgetOptions = single['widgetOptions'];
            }
            //Widget pack = loadWidget(eClass, eSubscriptions);
            widgetTitles[i] = eTitle; //push to widgets
            //loadedWidgets.add(pack); //push to widgets
            i++;
          }
        }

        setState(() {
          widget.currentWidgetIndex = current;
          print("Hi i'm " + widgetTitles[widget.currentWidgetIndex] + " --- position is " + widget.currentPosition.toString());

          errorOccurred = false;
          isLoadingWidget = false;
        });
      }
    } catch (e, s) {
      print("error loading widget " + e.toString() + s.toString());
      setState(() {
        errorOccurred = true;
        isLoadingWidget = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose draggable");
    //should call subwidget?
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
//    final _cardWidth = MediaQuery.of(context).size.width / 4;

    var padding = (deviceWidth * 0.05) / 4;
    //final double _cardWidth = (deviceWidth* 0.95) / 4; //(deviceWidth * 0.9) / 2;
    final double _cardWidth = (currentWidgetWidth != 0) ? (currentWidgetWidth) * (deviceWidth * 0.95) / 4 : (deviceWidth * 0.95) / 4; //(deviceWidth * 0.9) / 2;

    return GestureDetector(
      onTap: () {
        // notifyParent(text, icon);
      },
      child: FutureBuilder(builder: (context, snap) {
        return Container(
          //  padding: EdgeInsets.only(left: padding, right: 0, top: 5, bottom: 5),
          child: SizedBox(
            height: 110.0 * currentWidgetHeight,
            //width: _cardWidth,
            child: isLoadingWidget
                ? CupertinoActivityIndicator()
                : errorOccurred
                    ? Text("error")
                    : Container(
                        decoration: BoxDecoration(
                          color: currentCardColor,
                          border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
                          //borderRadius: const BorderRadius.all(Radius.circular(0))
                        ),
                        child: SimpleCard(widgetTitles[widget.currentWidgetIndex], _cardWidth, [
                          SizedBox(
                            height: 110.0 * currentWidgetHeight - 50,
                            child: (loadedWidgetData != null) ? loadWidget(currentClass, currentSubscriptions) : Text("error"),
                          ),
                          //Text("bubu " + rng.nextInt(200).toString()),
                        ]),
                      ),
          ),
        );
      }),
    );
  }

  void setCurrentWidget(int widget) {
    setState(() {
      isLoadingWidget = true;
    });
  }

  Stream<dynamic> _subscribeToStream(String path) {
//    print("TRY SUBS TO STREAM WITH $path");
    return widget.StreamObject.getVesselStream(widget.currentVessel, path, Duration(microseconds: NAUTICA['configuration']['widget']['refreshRate'])).asBroadcastStream();
  }

  Stream<dynamic> _subscribeToDataValueStream(String path) {
//    print("TRY SUBS TO STREAM WITH $path");
    return widget.StreamObject.getTimedVesselStream(widget.currentVessel, path, Duration(microseconds: NAUTICA['configuration']['widget']['refreshRate'])).asBroadcastStream();
  }

  Widget loadWidget(String className, dynamic subscriptions) {
    Widget res = Text("Cannot load " + className.toString());

    try {
      switch (className) {
        case "WindIndicator":
          print("REBUILD WIND INDICATOR " + widgetOptions.toString());
          res = WindIndicator(
              key: UniqueKey(),
              Angle_Stream: _subscribeToStream(subscriptions['Angle_Stream']),
              Intensity_Stream: _subscribeToStream(subscriptions['Intensity_Stream']),
              model: widget.model,
              widgetGraphics: widgetOptions['graphics']);
          break;

        case "CompassIndicator":
          res = CompassIndicator(key: UniqueKey(), Value_Stream: _subscribeToStream(subscriptions['Value_Stream']), model: widget.model, widgetGraphics: widgetOptions['graphics']);
          ;
          break;

        case "SpeedIndicator":
          res = SpeedIndicator(key: UniqueKey(), Speed_Stream: _subscribeToStream(subscriptions['Speed_Stream']), model: widget.model, widgetGraphics: widgetOptions['graphics']);
          break;

        case "BoatVectorsIndicator":
          res = BoatVectorsIndicator(
              key: UniqueKey(),
              ATW_Stream: _subscribeToStream(subscriptions['ATW_Stream']),
              ST_Stream: _subscribeToStream(subscriptions['ST_Stream']),
              AA_Stream: _subscribeToStream(subscriptions['AA_Stream']),
              SA_Stream: _subscribeToStream(subscriptions['SA_Stream']),
              HT_Stream: _subscribeToStream(subscriptions['HT_Stream']),
              COG_Stream: _subscribeToStream(subscriptions['COG_Stream']),
              SOG_Stream: _subscribeToStream(subscriptions['SOG_Stream']),
              LatLng_Stream: _subscribeToStream(subscriptions['LatLng_Stream']),
              DBK_Stream: _subscribeToStream(subscriptions['DBK_Stream']),
              DBS_Stream: _subscribeToStream(subscriptions['DBS_Stream']),
              DBT_Stream: _subscribeToStream(subscriptions['DBT_Stream']),
              DBST_Stream: _subscribeToStream(subscriptions['DBST_Stream']),
              model: widget.model);
          break;
        case "DateValueAxisChart":
          res = DateValueAxisChart(key: UniqueKey(), DataValue_Stream: _subscribeToDataValueStream(subscriptions['DataValue_Stream']), model: widget.model);
          break;

        case "RealTimeMap":
          //res = new MapSample(key: UniqueKey(), StreamObject: widget.StreamObject, currentVessel: widget.currentVessel);
          res = new LeafLetMap(key: UniqueKey(), StreamObject: widget.StreamObject, currentVessel: widget.currentVessel);
          break;

        case "TextIndicator":
          res = new TextIndicator(
              key: UniqueKey(),
              Text_Stream: _subscribeToStream(subscriptions['Text_Stream']),
              subscriptionPath: subscriptions['Text_Stream'].toString(),
              model: widget.model,
              vesselsDataTable: widget.vesselsDataTable,
              currentVessel: widget.currentVessel,
              widgetGraphics: widgetOptions['graphics']);
          break;
      }
    } catch (e) {
      print("Cannot load widget in grid - " + e.toString());
    }

    return res;
  }

  Widget SimpleCard(String title, double _cardWidth, List<Widget> children) {
    return Container(
        padding: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: currentCardColor,
          //border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1), borderRadius: const BorderRadius.all(Radius.circular(0))
        ),
        width: _cardWidth,
        child: Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 8, top: 5, bottom: 2),
                child: Text(
                  title,
                  style: TextStyle(color: widget.model.paletteColor, fontSize: 14, fontFamily: 'Roboto-Bold'),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Row(
                    children: [
                      Material(
                        child: SizedBox(
                          width: 30,
                          height: 25,
                          child: Container(
    decoration: BoxDecoration(
     border: Border.all(color:  widget.model.cardColor, width: 0),
    color:widget.model.cardColor,
    ),
                            child: PopupMenuButton<int>(
                              icon: Icon(Icons.add, color : widget.model.textColor),
                              iconSize: 13,
                              shape: RoundedRectangleBorder(
                                side: BorderSide.none,
                              ),
                              tooltip: "Display sub-widgets",
                              onSelected: (int selectedWidget) {
                                if (selectedWidget != widget.currentWidgetIndex) {
                                  setState(() {
                                    isLoadingWidget = true;
                                  });
                                  print("$selectedWidget != ${widget.currentWidgetIndex}");
                                  widget.onCardStatusChangedCallback(widget.currentPosition, selectedWidget).then((value) {
                                    print("Hi i changed state and i'm [${widget.currentPosition}][${selectedWidget}]");
                                    //setState(() {
                                    isLoadingWidget = false;
                                    //});
                                  }); //notify parent
                                  setState(() {
                                    widget.currentWidgetIndex = selectedWidget;
                                  });
                                }
                              },
                              initialValue: widget.currentWidgetIndex,
                              itemBuilder: (BuildContext context) => widgetTitles.entries.map<PopupMenuEntry<int>>((w) {
                                return PopupMenuItem<int>(value: w.key, child: Text(w.value));
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        child: SizedBox(
                          width: 30,
                          height: 25,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color:  widget.model.cardColor, width: 0),
                              color: widget.model.cardColor,
                            ),
                            child: PopupMenuButton<String>(
                                icon: Icon(Icons.menu_sharp, color: widget.model.textColor),
                                iconSize: 13,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide.none,
                                ),
                                tooltip: "Display settings for current widget",
                                onSelected: (String option) {
                                  setState(() {
                                    //  widget.currentWidgetIndex = widgetTitles.indexOf(vessel);

                                    if (option == "edit") {
                                      widget.onGoingToEditCallback(widget.currentPosition, widget.currentWidgetIndex).then((value) {
                                        // print("Hi i changed state and i'm [${widget.currentPosition}][${widget.currentWidgetIndex}]");
                                      }); //n
                                    } else if (option == "delete") {
                                      widget.onGoingToDeleteCallback(widget.currentPosition, widget.currentWidgetIndex).then((value) {
                                        // print("Hi i changed state and i'm [${widget.currentPosition}][${widget.currentWidgetIndex}]");
                                      }); //n
                                    }
                                  });
                                },
                                itemBuilder: (context) => [
                                      PopupMenuItem<String>(value: "edit", child: Text("Edit widget")),
                                      PopupMenuItem<String>(value: "delete", child: Text("Delete widget")),
                                    ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: widget.model.themeData != null && widget.model.themeData.brightness == Brightness.dark
                ? const Color.fromRGBO(61, 61, 61, 1)
                : const Color.fromRGBO(238, 238, 238, 1),
            thickness: 1,
          ),
          Padding(padding: EdgeInsets.only(bottom: 0, top: 0)),
          Column(children: children)
        ]));
  }
}
