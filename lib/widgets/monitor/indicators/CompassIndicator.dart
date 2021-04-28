import 'dart:math';

/// Flutter package imports
import 'package:flutter/material.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';
import 'package:nautica/utils/HexColor.dart';

/// Gauge imports

import 'package:syncfusion_flutter_gauges/gauges.dart';

/// Locals imports

/// Renders the gauge compass sample.
class CompassIndicator extends StatefulWidget {
  //should rename
  /// Creates the gauge compass sample.
  BaseModel model;
  double COG_Value = 0;
  Stream<dynamic> Value_Stream = null;
  dynamic widgetGraphics;

  final Function(String text, Icon icon) notifyParent;

  CompassIndicator({Key key, @required this.model, @required this.Value_Stream, @required this.widgetGraphics, this.notifyParent}) : super(key: key);

  @override
  _CompassIndicatorState createState() => _CompassIndicatorState();
}

class _CompassIndicatorState extends State<CompassIndicator> with DisposableWidget {
  _CompassIndicatorState();

  Map graphics = new Map();
  String currentTheme = "light";

  @override
  void initState() {
    super.initState();

    widget.model.addListener(() {
      print("THEME WIND CHANGE");
      _loadWidgetGraphics();
    });

   //graphics['intensityUnit'] = "m/s";
   //graphics['angleUnit'] = "°";

    graphics['axisRadiusFactor'] = 1.3;
    graphics['axisLabelFontColor'] = Color(0xFF949494);
    graphics['axisLabelFontSize'] = 11.0;
    graphics['minorTickColor'] = Color(0xFF616161);
    graphics['minorTickThickness'] = 1.0;
    graphics['minorTickLength'] = 0.058;
    graphics['majorTickColor'] = Color(0xFF949494);
    graphics['majorTickThickness'] = 2.3;
    graphics['majorTickLength'] = 0.087;
    graphics['markerOffset'] = 0.69;
    graphics['markerHeight'] = 5.0;
    graphics['markerWidth'] =  10.0;
    graphics['gaugeFontColor'] = Color(0xFFDF5F2D);
    graphics['gaugeFontSize'] =  16.0;
    _loadWidgetGraphics();

    if (widget.Value_Stream != null) {
      widget.Value_Stream.listen((data) {
        widget.COG_Value = (data == null || data == 0) ? 0.0 : data.toDouble() * (180 / pi);
      }).canceledBy(this);
    }
  }

  void _loadWidgetGraphics() {
    currentTheme = widget.model.isDark ? "darkTheme" : "lightTheme";

    if (widget.widgetGraphics != null) {
      try {
        graphics['axisRadiusFactor'] = (widget.widgetGraphics[currentTheme]['axisRadiusFactor'] is double)
            ? widget.widgetGraphics[currentTheme]['axisRadiusFactor']
            : double.parse(widget.widgetGraphics[currentTheme]['axisRadiusFactor'].toString());
        graphics['axisLabelFontColor'] = HexColor(widget.widgetGraphics[currentTheme]['axisLabelFontColor']);
        graphics['axisLabelFontSize'] = (widget.widgetGraphics[currentTheme]['axisLabelFontSize'] is double)
            ? widget.widgetGraphics[currentTheme]['axisLabelFontSize']
            : double.parse(widget.widgetGraphics[currentTheme]['axisLabelFontSize'].toString());
        graphics['minorTickColor'] = HexColor(widget.widgetGraphics[currentTheme]['minorTickColor']);
        graphics['minorTickThickness'] = (widget.widgetGraphics[currentTheme]['minorTickThickness'] is double)
            ? widget.widgetGraphics[currentTheme]['minorTickThickness']
            : double.parse(widget.widgetGraphics[currentTheme]['minorTickThickness'].toString());
        graphics['minorTickLength'] = (widget.widgetGraphics[currentTheme]['minorTickLength'] is double)
            ? widget.widgetGraphics[currentTheme]['minorTickLength']
            : double.parse(widget.widgetGraphics[currentTheme]['minorTickLength'].toString());
        graphics['majorTickColor'] = HexColor(widget.widgetGraphics[currentTheme]['majorTickColor']);
        graphics['majorTickThickness'] = (widget.widgetGraphics[currentTheme]['majorTickThickness'] is double)
            ? widget.widgetGraphics[currentTheme]['majorTickThickness']
            : double.parse(widget.widgetGraphics[currentTheme]['majorTickThickness'].toString());
        graphics['majorTickLength'] = (widget.widgetGraphics[currentTheme]['majorTickLength'] is double)
            ? widget.widgetGraphics[currentTheme]['majorTickLength']
            : double.parse(widget.widgetGraphics[currentTheme]['majorTickLength'].toString());
        graphics['markerOffset'] = (widget.widgetGraphics[currentTheme]['markerOffset'] is double)
            ? widget.widgetGraphics[currentTheme]['markerOffset']
            : double.parse(widget.widgetGraphics[currentTheme]['markerOffset'].toString());
        graphics['markerHeight'] = (widget.widgetGraphics[currentTheme]['markerHeight'] is double)
            ? widget.widgetGraphics[currentTheme]['markerHeight']
            : double.parse(widget.widgetGraphics[currentTheme]['markerHeight'].toString());
        graphics['markerWidth'] = (widget.widgetGraphics[currentTheme]['markerWidth'] is double)
            ? widget.widgetGraphics[currentTheme]['markerWidth']
            : double.parse(widget.widgetGraphics[currentTheme]['markerWidth'].toString());
        graphics['gaugeFontColor'] = HexColor(widget.widgetGraphics[currentTheme]['gaugeFontColor']);
        graphics['gaugeFontSize'] = (widget.widgetGraphics[currentTheme]['gaugeFontSize'] is double)
            ? widget.widgetGraphics[currentTheme]['gaugeFontSize']
            : double.parse(widget.widgetGraphics[currentTheme]['gaugeFontSize'].toString());
      } catch (e,s) {
        print("CompassIndicator error while loading graphics -> $e $s");
      }
    }
  }

  @override
  void dispose() {
    // print("CANCEL COMPASS SUBSCRIPTION");
    cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget _widget = GestureDetector(
        onTap: () {
          //notifyParent(text, icon);
        },
        child: StreamBuilder(
            stream: widget.Value_Stream,
            builder: (context, snap) {
              //if (!snap.hasData) {
              //return CircularProgressIndicator();
              //}
              double rotationAngle = (270 + widget.COG_Value) % 360;
              return SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                      showAxisLine: false,
                      radiusFactor: graphics['axisRadiusFactor'],
                      canRotateLabels: true,
                      tickOffset: 0.32,
                      offsetUnit: GaugeSizeUnit.factor,
                      onLabelCreated: _handleAxisLabelCreated,
                      startAngle: rotationAngle,
                      endAngle: rotationAngle,
                      labelOffset: 0.05,
                      maximum: 360,
                      minimum: 0,
                      interval: 30,
                      minorTicksPerInterval: 4,
                      axisLabelStyle: GaugeTextStyle(
                        color: graphics['axisLabelFontColor'],
                        fontSize: graphics['axisLabelFontSize'],
                        fontWeight: FontWeight.bold,
                      ),
                      minorTickStyle: MinorTickStyle(
                          color: graphics['minorTickColor'], thickness: graphics['minorTickThickness'], length: graphics['minorTickLength'], lengthUnit: GaugeSizeUnit.factor),
                      majorTickStyle: MajorTickStyle(
                          color: const Color(0xFF949494), thickness: graphics['majorTickThickness'], length: graphics['majorTickLength'], lengthUnit: GaugeSizeUnit.factor),
                      //backgroundImage: const AssetImage('assets/dark_theme_gauge.png'),
                      pointers: <GaugePointer>[
                        MarkerPointer(
                            value: 0,
                            //widget.COG_Value,
                            color: graphics['majorTickColor'],
                            enableAnimation: true,
                            animationDuration: 1200,
                            markerOffset: graphics['markerOffset'],
                            offsetUnit: GaugeSizeUnit.factor,
                            markerType: MarkerType.triangle,
                            markerHeight: graphics['markerHeight'],
                            markerWidth: graphics['markerWidth'])
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            angle: 270,
                            positionFactor: _positionFactor,
                            widget: Text(
                              widget.COG_Value.toStringAsFixed(2) + "°",
                              style: TextStyle(color: graphics['gaugeFontColor'], fontWeight: FontWeight.bold, fontSize: graphics['gaugeFontSize']),
                            ))
                      ])
                ],
              );
            }));
    if (widget.model.isWebFullView) {
      return Padding(
        padding: const EdgeInsets.all(35),
        child: _widget,
      );
    } else {
      return _widget;
    }
  }

  /// Handled callback for change numeric value to compass directional letter.
  void _handleAxisLabelCreated(AxisLabelCreatedArgs args) {
    if (args.text == '90') {
      args.text = 'E';
    } else if (args.text == '360') {
      args.text = '';
    } else {
      if (args.text == '0') {
        args.text = 'N';
        args.labelStyle = GaugeTextStyle(color: widget.model.paletteColor, fontSize: widget.model.isWebFullView ? 10 : _labelFontSize);
      } else if (args.text == '180') {
        args.text = 'S';
      } else if (args.text == '270') {
        args.text = 'W';
      }

      args.labelStyle = GaugeTextStyle(color: widget.model.paletteColor, fontSize: widget.model.isWebFullView ? 12 : _labelFontSize);
    }
  }

  double _annotationTextSize = 22;
  double _positionFactor = 0.025;
  double _markerHeight = 10;
  double _markerWidth = 15;
  double _markerOffset = 0.71;
  double _labelFontSize = 10;
}
