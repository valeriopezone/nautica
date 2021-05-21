import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:SKDashboard/network/StreamSubscriber.dart';
import 'package:SKDashboard/models/BaseModel.dart';
import 'package:SKDashboard/widgets/monitor/map/LeafLetRealTimeMap.dart';

import 'monitor/graph/DateValueAxisChart.dart';
import 'monitor/indicators/BoatVectorsIndicator.dart';
import 'monitor/indicators/CompassIndicator.dart';

import 'package:SKDashboard/Configuration.dart';

import 'monitor/indicators/SpeedIndicator.dart';
import 'monitor/indicators/TextIndicator.dart';
import 'monitor/indicators/WindIndicator.dart';

class Indicator extends StatefulWidget {
  StreamSubscriber StreamObject;
  String currentVessel = ""; //
  dynamic vesselsDataTable = [];
  bool isEditingMode = false;
  BaseModel model;
  dynamic widgetData;
  int currentPosition;
  int currentWidgetIndex;

  int numCols;
  double baseHeight;

  final Future<void> Function(int cardId, int viewId) onCardStatusChangedCallback;
  final Future<void> Function(int cardId, int viewId) onGoingToEditCallback;
  final Future<void> Function(int cardId, int viewId) onGoingToDeleteCallback;


  Indicator(
      {Key key,
      @required this.model,
      @required this.isEditingMode,
      @required this.currentPosition,
      @required this.currentWidgetIndex,
      @required this.widgetData,
      @required this.StreamObject,
      @required this.currentVessel,
      @required this.onCardStatusChangedCallback,
      @required this.onGoingToEditCallback,
      @required this.onGoingToDeleteCallback,
      @required this.vesselsDataTable,
      @required this.baseHeight,
      @required this.numCols})
      : super(key: key);

  @override
  _IndicatorState createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator> {
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

  int gridNumCols = CONF['configuration']['design']['grid']['numCols']; // 1/4
  double gridBaseHeight = CONF['configuration']['design']['grid']['baseHeight']; // 1/1

  // List<String> widgetTitles = [];
  Map<int, String> widgetTitles = {};

  @override
  void initState() {
    widget.isEditingMode = (widget.isEditingMode == null) ? false : widget.isEditingMode;

    gridNumCols = widget.numCols;
    gridBaseHeight = widget.baseHeight;

    widget.model = BaseModel.instance;
    widget.model.addListener(() {
      if (mounted)
        setState(() {
          currentCardColor = widget.model.cardColor;
        });
    });

    super.initState();

    currentCardColor = widget.model.cardColor;

    initCard();
  }

  @override
  void dispose() {
    super.dispose();
    //should call subwidget?
  }

  void initCard({currentId = null}) {
    if (mounted)
      setState(() {
        isLoadingWidget = true;
      });
    widgetTitles = {};

    //init widget data, indexes, .....
    try {
      //loop
      dynamic w = widget.widgetData;
      var current = (currentId == null) ? w['current'] : currentId; //current index
      dynamic elements = w['elements'];

      currentWidgetWidth = (w['width'] > 0) ? w['width'] + .0 : 1;
      currentWidgetHeight = (w['height'] > 0) ? w['height'] + .0 : 1;
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

        if (mounted)
          setState(() {
            widget.currentWidgetIndex = current;
            errorOccurred = false;
            isLoadingWidget = false;
          });
      }
    } catch (e, s) {
      print("[DraggableCard] error loading widget $e $s");
      if (mounted)
        setState(() {
          errorOccurred = true;
          isLoadingWidget = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double _cardWidth = (currentWidgetWidth != 0) ? (currentWidgetWidth) * (deviceWidth * 0.95) / gridNumCols : (deviceWidth * 0.95) / gridNumCols;

    return GestureDetector(
            child: FutureBuilder(builder: (context, snap) {
        return Container(
          child: SizedBox(
            height: gridBaseHeight * currentWidgetHeight,
            width: _cardWidth,
            child: isLoadingWidget
                ? CupertinoActivityIndicator()
                : errorOccurred
                    ? Text("error")
                    : Container(
                        decoration: BoxDecoration(
                          color: currentCardColor,
                          border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
                        ),
                        child: SimpleCard(widgetTitles[widget.currentWidgetIndex], _cardWidth, [
                          (loadedWidgetData != null)
                              ? Container(height: gridBaseHeight * currentWidgetHeight - 48, child: Center(child: loadWidget(currentClass, currentSubscriptions)))
                              : Center(
                                  child: Text(
                                  "Unable to load widget",
                                  style: TextStyle(color: widget.model.textColor, fontSize: 14, fontFamily: 'Roboto-Bold'),
                                )),
                        ]),
                      ),
          ),
        );
      }),
    );
  }

  void setCurrentWidget(int widget) {
    if (mounted)
      setState(() {
        isLoadingWidget = true;
      });
  }

  Stream<dynamic> _subscribeToStream(String path) {
    return widget.StreamObject.getVesselStream(widget.currentVessel, path, Duration(microseconds: CONF['configuration']['widget']['refreshRate'])).asBroadcastStream();
  }

  Stream<dynamic> _subscribeToDataValueStream(String path) {
    return widget.StreamObject.getTimedVesselStream(widget.currentVessel, path, Duration(microseconds: CONF['configuration']['widget']['refreshRate'])).asBroadcastStream();
  }

  Widget loadWidget(String className, dynamic subscriptions) {
    Widget res = Text("Cannot load " + className.toString());

    try {
      switch (className) {
        case "WindIndicator":
          res = Padding(
            padding: const EdgeInsets.all(8.0),
            child: WindIndicator(
                key: UniqueKey(),
                Angle_Stream: _subscribeToStream(subscriptions['Angle_Stream']),
                Intensity_Stream: _subscribeToStream(subscriptions['Intensity_Stream']),
                model: widget.model,
                widgetGraphics: widgetOptions['graphics']),
          );
          break;

        case "CompassIndicator":
          res = Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                CompassIndicator(key: UniqueKey(), Value_Stream: _subscribeToStream(subscriptions['Value_Stream']), model: widget.model, widgetGraphics: widgetOptions['graphics']),
          );

          break;

        case "SpeedIndicator":
          res = Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                SpeedIndicator(key: UniqueKey(), Speed_Stream: _subscribeToStream(subscriptions['Speed_Stream']), model: widget.model, widgetGraphics: widgetOptions['graphics']),
          );
          break;

        case "BoatVectorsIndicator":
          res = Padding(
            padding: const EdgeInsets.all(8.0),
            child: BoatVectorsIndicator(
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
                model: widget.model),
          );
          break;
        case "DateValueAxisChart":
          res = Padding(
            padding: const EdgeInsets.all(8.0),
            child: DateValueAxisChart(
                key: UniqueKey(),
                DataValue_Stream: _subscribeToDataValueStream(subscriptions['DataValue_Stream']),
                model: widget.model,
                subscriptionPath: subscriptions['DataValue_Stream'].toString(),
                vesselsDataTable: widget.vesselsDataTable,
                currentVessel: widget.currentVessel,
                widgetGraphics: widgetOptions['graphics']),
          );
          break;

        case "TransposedDateValueAxisChart":
          res = Padding(
            padding: const EdgeInsets.all(8.0),
            child: DateValueAxisChart(
                key: UniqueKey(),
                isTransposed: true,
                DataValue_Stream: _subscribeToDataValueStream(subscriptions['DataValue_Stream']),
                model: widget.model,
                subscriptionPath: subscriptions['DataValue_Stream'].toString(),
                vesselsDataTable: widget.vesselsDataTable,
                currentVessel: widget.currentVessel,
                widgetGraphics: widgetOptions['graphics']),
          );
          break;

        case "RealTimeMap":
          res = Padding(
            padding: const EdgeInsets.all(0.0),
            child: new LeafLetMap(key: UniqueKey(), StreamObject: widget.StreamObject, currentVessel: widget.currentVessel),
          );
          break;

        case "TextIndicator":
          res = Padding(
            padding: const EdgeInsets.all(8.0),
            child: new TextIndicator(
                key: UniqueKey(),
                Text_Stream: _subscribeToStream(subscriptions['Text_Stream']),
                subscriptionPath: subscriptions['Text_Stream'].toString(),
                model: widget.model,
                vesselsDataTable: widget.vesselsDataTable,
                currentVessel: widget.currentVessel,
                widgetGraphics: widgetOptions['graphics']),
          );
          break;
      }
    } catch (e) {
      print("[DraggableCard] Cannot load widget in grid - " + e.toString());
    }

    return res;
  }

  Widget SimpleCard(String title, double _cardWidth, List<Widget> children) {
    return Container(
        height: gridBaseHeight * currentWidgetHeight,
        padding: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: currentCardColor,
        ),
        width: _cardWidth,
        child: Container(
          child: Material(
            type: MaterialType.transparency,
            child: Column(children: <Widget>[
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 8, top: 5, bottom: 2),
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: widget.model.paletteColor, fontSize: 14, fontFamily: 'Roboto-Bold'),
                        ),
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
                                    border: Border.all(color: widget.model.cardColor, width: 0),
                                    color: widget.model.cardColor,
                                  ),
                                  child: PopupMenuButton<int>(
                                    icon: Icon(Icons.add, color: widget.model.textColor),
                                    iconSize: 13,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide.none,
                                    ),
                                    tooltip: "Display sub-widgets",
                                    onSelected: (int selectedWidget) {
                                      if (selectedWidget != widget.currentWidgetIndex) {
                                        if (widget.isEditingMode) {
                                          if (mounted)
                                            setState(() {
                                              isLoadingWidget = true;
                                            });
                                          widget.onCardStatusChangedCallback(widget.currentPosition, selectedWidget).then((value) {
                                            isLoadingWidget = false;
                                          });

                                          if (mounted)
                                            setState(() {
                                              widget.currentWidgetIndex = selectedWidget;
                                            });
                                        } else {
                                          if (mounted)
                                            setState(() {
                                              widget.currentWidgetIndex = selectedWidget;
                                            });
                                          initCard(currentId: selectedWidget);
                                        }

                                        //notify parent

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
                              child: widget.isEditingMode
                                  ? SizedBox(
                                      width: 30,
                                      height: 25,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: widget.model.cardColor, width: 0),
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
                                              if (mounted)
                                                setState(() {
                                                  //  widget.currentWidgetIndex = widgetTitles.indexOf(vessel);

                                                  if (option == "edit") {
                                                    widget.onGoingToEditCallback(widget.currentPosition, widget.currentWidgetIndex).then((value) {}); //n
                                                  } else if (option == "delete") {
                                                    AlertDialog alert = AlertDialog(
                                                      title: Text("Are you sure?"),
                                                      content: Text("You cannot undo this operation, if you want to continue press Yes"),
                                                      actions: [
                                                        TextButton(
                                                          child: Text("No"),
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text("Yes"),
                                                          onPressed: () async {
                                                            widget.onGoingToDeleteCallback(widget.currentPosition, widget.currentWidgetIndex).then((value) {}); //n
                                                            Navigator.pop(context);
                                                          },
                                                        )
                                                      ],
                                                    );

                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return alert;
                                                      },
                                                    );
                                                  }
                                                });
                                            },
                                            itemBuilder: (context) => [
                                                  PopupMenuItem<String>(value: "edit", child: Text("Edit widget")),
                                                  PopupMenuItem<String>(value: "delete", child: Text("Delete widget")),
                                                ]),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: widget.model.themeData != null && widget.model.themeData.brightness == Brightness.dark
                    ? const Color.fromRGBO(61, 61, 61, 1)
                    : const Color.fromRGBO(238, 238, 238, 1),
                thickness: 1,
              ),
              Padding(padding: EdgeInsets.only(bottom: 0, top: 0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          color: Colors.transparent,
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: children))),
                ],
              )
            ]),
          ),
        ));
  }
}
