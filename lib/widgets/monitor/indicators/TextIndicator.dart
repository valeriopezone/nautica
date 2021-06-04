import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SKDashboard/models/BaseModel.dart';
import 'package:SKDashboard/models/Helper.dart';
import 'package:SKDashboard/utils/HexColor.dart';

class TextIndicator extends StatefulWidget {
  String subscriptionPath = "";
  dynamic Text_Value = "";
  Stream<dynamic> Text_Stream = null;
  BaseModel model;
  dynamic widgetGraphics;
  dynamic vesselsDataTable = [];
  String currentVessel = ""; //

  TextIndicator(
      {Key key,
      @required this.subscriptionPath,
      @required this.vesselsDataTable,
        @required this.currentVessel,

        @required this.Text_Stream,
      @required this.model,
      @required this.widgetGraphics
      })
      : super(key: key);

  @override
  _TextIndicatorState createState() => _TextIndicatorState();
}

class _TextIndicatorState extends State<TextIndicator> with DisposableWidget {
  Map graphics = new Map();
  String currentTheme = "light";

  @override
  void initState() {
    widget.model.addListener(() {
      _loadWidgetGraphics();
    });

    graphics['labelFontSize'] = 32.0;
    graphics['labelFontColor'] = HexColor("#FF333333");
    graphics['unitFontSize'] = 12.0;
    graphics['unitFontColor'] = HexColor("#FF333333");



    _loadWidgetGraphics();

    super.initState();
    if (widget.Text_Stream != null) {
      widget.Text_Stream.listen((data) {
        widget.Text_Value = (data == null) ? "" : data;
      }).canceledBy(this);
    }
  }

  void _loadWidgetGraphics() {
    currentTheme = widget.model.isDark ? "darkTheme" : "lightTheme";

    if (widget.widgetGraphics != null) {
      try {
        graphics['labelFontSize'] = (widget.widgetGraphics[currentTheme]['labelFontSize'] is double)
            ? widget.widgetGraphics[currentTheme]['labelFontSize']
            : double.parse(widget.widgetGraphics[currentTheme]['labelFontSize'].toString());
        graphics['labelFontColor'] = HexColor(widget.widgetGraphics[currentTheme]['labelFontColor']);

        graphics['unitFontSize'] = (widget.widgetGraphics[currentTheme]['unitFontSize'] is double)
            ? widget.widgetGraphics[currentTheme]['unitFontSize']
            : double.parse(widget.widgetGraphics[currentTheme]['unitFontSize'].toString());
        graphics['unitFontColor'] = HexColor(widget.widgetGraphics[currentTheme]['unitFontColor']);
      } catch (e,s) {
        print("TextIndicator error while loading graphics -> $e $s");
      }
    }
  }

  @override
  void dispose() {
    print("[TextIndicator] DISPOSING...");

    cancelSubscriptions();
    super.dispose();
  }

  String _getUnit(){
    String unit = (widget.subscriptionPath == "navigation.position") ? "'" : " ";

      try{
      unit = widget.vesselsDataTable[widget.currentVessel][widget.subscriptionPath]['units'];
      unit = (unit != null && unit.isNotEmpty) ? unit.toString() : " ";
    }catch (e) {
      //print("[TextIndicator] error while decoding unit -> $e");
    }
    return unit;
  }

  String _formatValue(dynamic data) {

    if (widget.subscriptionPath == "navigation.position") {
      if (data != null && data is Map) {
        try {
          if (data["latitude"] != null && data["longitude"] != null) {
            var lat = (data["latitude"] != 0) ? data["latitude"] : 0.0;
            var lng = (data["longitude"] != 0) ? data["longitude"] : 0.0;
            String res = "Lat : ${lat.toStringAsFixed(5)}\nLon : ${lng.toStringAsFixed(5)}";
            return res;
          }
        } catch (e,s) {
          print("[TextIndicator] error while decoding value -> $e $s");
        }
      }
    }

    if (data is double || data is int) {
      return data.toStringAsFixed(2);
    }

    return data.toString();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
          stream: widget.Text_Stream,
          builder: (context, snap) {
            return Stack(

              children: [
                Padding(
                  padding: const EdgeInsets.only(top : 5.0),
                  child:  Center(child: Text(_formatValue(widget.Text_Value), style: GoogleFonts.orbitron(textStyle: TextStyle(color: graphics['labelFontColor'], fontSize: graphics['labelFontSize'],)))),
                ),
               Padding(
                 padding: const EdgeInsets.only(right : 8),
                 child: Align(alignment: Alignment.bottomRight, child: Text(_getUnit(), style: GoogleFonts.orbitron(textStyle: TextStyle(color: graphics['unitFontColor'], fontSize: graphics['unitFontSize'],)))),
               ),
              ],
            );
          });
  }
}
