import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:nautica/network/StreamSubscriber.dart';
import 'package:nautica/models/BaseModel.dart';

import 'monitor/graph/BasicGraph.dart';
import 'monitor/indicators/BoatVectorsIndicator.dart';
import 'monitor/indicators/CompassIndicator.dart';

import 'package:nautica/Configuration.dart';

import 'monitor/indicators/SpeedIndicator.dart';
import 'monitor/indicators/WindIndicator.dart';

class DraggableCard extends StatefulWidget {
  StreamSubscriber StreamObject = null;
  String currentVessel = ""; //

  BaseModel model;
  dynamic widgetData;

  final Function(String text, Icon icon) notifyParent;

  DraggableCard(
      {Key key,
      @required this.model,
      @required this.widgetData,
      @required this.StreamObject,
      @required this.currentVessel,
      this.notifyParent})
      : super(key: key);

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  bool isLoadingWidget = true;
  bool errorOccurred = false;

  List<Widget> loadedWidgets = [];
  List<String> widgetTitles = [];
  int currentWidgetIndex;

  void initState() {

    super.initState();

    //init widget data, indexes, .....
    try {
      //loop
      print("LOAD STATE DRAG");

      dynamic w = widget.widgetData;
      print(widget.widgetData.toString());

      String wTitle = w['widgetTitle'];
      String wClass = w['widgetClass'];
      dynamic wSubscriptions = w['widgetSubscriptions'];
      dynamic extraWidgets = w['extraWidgets'];

      if (wTitle != null && wClass != null && wSubscriptions != null) {
        //handle class subscription
        Widget currentWidgetHandle = loadWidget(wClass, wSubscriptions);
        widgetTitles.add(wTitle); //push to widgets
        loadedWidgets.add(currentWidgetHandle); //push to widgets

        //loop others and push to widgets
        try {
          if (extraWidgets != null) {
            print("LOAD SUBS ");
            print(extraWidgets.toString());
            for (dynamic extra in extraWidgets) {
              String eTitle = extra['widgetTitle'];
              String eClass = extra['widgetClass'];
              dynamic eSubscriptions = extra['widgetSubscriptions'];
              if (eTitle != null && eClass != null && eSubscriptions != null) {
                Widget currentExtra = loadWidget(eClass, eSubscriptions);
                widgetTitles.add(eTitle); //push to widgets
                loadedWidgets.add(currentExtra); //push to widgets
              }
            }
          }
        } catch (e) {
          print("error while adding extras - " + e.toString());
        }

        print(widgetTitles.toString());
        print(loadedWidgets.toString());
        setState(() {
          currentWidgetIndex = 0;
          errorOccurred = false;
          isLoadingWidget = false;
        });
      }
    } catch (e) {
      print("error loading widget");
      setState(() {
        errorOccurred = true;
        isLoadingWidget = false;
      });
    }

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _cardWidth = MediaQuery.of(context).size.width / 4;

    return GestureDetector(
      onTap: () {
        // notifyParent(text, icon);
      },
      child: isLoadingWidget
          ? Text("loading")
          : errorOccurred
              ? Text("error")
              : FutureBuilder(builder: (context, snap) {
                  return SizedBox(
                    height: 240,
                    width: _cardWidth,
                    child: Container(
                      decoration: BoxDecoration(
                          color: widget.model.cardColor,
                          border: Border.all(
                              color: const Color.fromRGBO(0, 0, 0, 0.12),
                              width: 1.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12))),
                      child: SimpleCard(
                          widgetTitles[currentWidgetIndex], _cardWidth, [
                        SizedBox(
                          height: 140,
                          child: loadedWidgets[currentWidgetIndex],
                        ),
                        //Text("bubu " + rng.nextInt(200).toString()),
                      ]),
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
    return widget.StreamObject.getVesselStream(
            widget.currentVessel,
            path,
            Duration(
                microseconds: NAUTICA['configuration']['widget']
                    ['refreshRate']))
        .asBroadcastStream();
  }

  Widget loadWidget(String className, dynamic subscriptions) {
    Widget res = Text("Cannot load " + className.toString());

    try {
      switch (className) {
        case "WindIndicator":
          res = WindIndicator(
              Angle_Stream: _subscribeToStream(subscriptions['Angle_Stream']),
              Intensity_Stream:
                  _subscribeToStream(subscriptions['Intensity_Stream']),
              model: widget.model);
          break;

        case "CompassIndicator":
          res = CompassIndicator(
              COG_Stream: _subscribeToStream(subscriptions['COG_Stream']),
              model: widget.model);
          break;

        case "SpeedIndicator":
          res = SpeedIndicator(
              ST_Stream: _subscribeToStream(subscriptions['ST_Stream']),
              model: widget.model);
          break;

        case "BoatVectorsIndicator":
          res = BoatVectorsIndicator(
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
        case "BasicGraph":
          res = BasicGraph(
              DataValue_Stream:
                  _subscribeToStream(subscriptions['DataValue_Stream']),
              model: widget.model);
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
            color: widget.model.cardColor,
            border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        width: _cardWidth,
        child: Column(children: <Widget>[
          Row(
            children: [
              Material(
                child: DropdownButton<String>(
                  value: widgetTitles[currentWidgetIndex],
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 0,
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 0,
                    color: widget.model.splashScreenBackground,
                  ),
                  onChanged: (String vessel) {
                    setState(() {
                      currentWidgetIndex = widgetTitles.indexOf(vessel);
                    });
                  },
                  dropdownColor: Colors.black,
                  items: widgetTitles
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text("Mon #" +
                          (widgetTitles.indexOf(value) + 1).toString()),
                    );
                  }).toList(),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 5, bottom: 2),
                child: Text(
                  title,
                  style: TextStyle(
                      color: widget.model.paletteColor,
                      fontSize: 16,
                      fontFamily: 'Roboto-Bold'),
                ),
              ),
            ],
          ),
          Divider(
            color: widget.model.themeData != null &&
                    widget.model.themeData.brightness == Brightness.dark
                ? const Color.fromRGBO(61, 61, 61, 1)
                : const Color.fromRGBO(238, 238, 238, 1),
            thickness: 1,
          ),
          Padding(padding: EdgeInsets.only(bottom: 0, top: 0)),
          Column(children: children)
        ]));
  }
}
