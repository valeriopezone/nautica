import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:SKDashboard/models/BaseModel.dart';
import 'package:SKDashboard/models/Helper.dart';
import 'package:SKDashboard/utils/HexColor.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class WindIndicator extends StatefulWidget {
  double Angle_Value = 0.0;
  double Intensity_Value = 0.0;
  Stream<dynamic> Angle_Stream = null;
  Stream<dynamic> Intensity_Stream = null;
  dynamic widgetGraphics;

  BaseModel model;
  bool haveData = false;

  WindIndicator({Key key, @required this.Angle_Stream, @required this.Intensity_Stream, @required this.model, @required this.widgetGraphics}) : super(key: key);

  void changeTheme(String themeType) {}

  @override
  _WindIndicatorState createState() => _WindIndicatorState();
}

class _WindIndicatorState extends State<WindIndicator> with DisposableWidget {
  @override
  Map graphics = new Map();
  String currentTheme = "light";

  void initState() {
    super.initState();

    widget.model.addListener((){
      _loadWidgetGraphics();
    });


    graphics['intensityUnit'] = "m/s";
    graphics['angleUnit'] = "°";

    graphics['radiusFactor'] = 1.05;
    graphics['radialLabelFontColor'] = widget.model.textColor;
    graphics['majorTickSize'] = 1.5;
    graphics['majorTickLength'] = 0.1;
    graphics['angleLabelFontSize'] = widget.model.isWebFullView ? 25.0 : 17.0;
    graphics['angleLabelFontColor'] = widget.model.textColor;
    graphics['intensityLabelFontSize'] = widget.model.isWebFullView ? 18.0 : 12.0;
    graphics['intensityLabelFontColor'] = widget.model.textColor;
    graphics['needlePointerColor'] = widget.model.paletteColor;
    graphics['gaugePositiveColor'] = widget.model.positiveWind;
    graphics['gaugeNegativeColor'] = widget.model.negativeWind;
    graphics['minorTickSize'] = 1.5;
    graphics['minorTickLength'] = 0.04;

    _loadWidgetGraphics();

    if (widget.Angle_Stream != null) {
      widget.Angle_Stream.listen((data) {
        widget.haveData = (data == null) ? false : true;
        widget.Angle_Value = (data == null || data == 0) ? 0.0 : (data.toDouble() * 180 / pi);
      }).canceledBy(this);
    }

    if (widget.Intensity_Stream != null) {
      widget.Intensity_Stream.listen((data) {
        widget.Intensity_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }
  }

  void _loadWidgetGraphics(){
    currentTheme = widget.model.isDark ? "darkTheme" : "lightTheme";

    if (widget.widgetGraphics != null) {
      try {
        graphics['radiusFactor'] = (widget.widgetGraphics[currentTheme]['radiusFactor'] is double) ? widget.widgetGraphics[currentTheme]['radiusFactor'] : double.parse(widget.widgetGraphics[currentTheme]['radiusFactor'].toString());
        graphics['radialLabelFontColor'] = HexColor(widget.widgetGraphics[currentTheme]['radialLabelFontColor']);
        graphics['majorTickSize'] = (widget.widgetGraphics[currentTheme]['majorTickSize'] is double) ? widget.widgetGraphics[currentTheme]['majorTickSize'] : double.parse(widget.widgetGraphics[currentTheme]['majorTickSize'].toString());
        graphics['majorTickLength'] = (widget.widgetGraphics[currentTheme]['majorTickLength'] is double) ? widget.widgetGraphics[currentTheme]['majorTickLength'] : double.parse(widget.widgetGraphics[currentTheme]['majorTickLength'].toString());
        graphics['angleLabelFontSize'] = (widget.widgetGraphics[currentTheme]['angleLabelFontSize'] is double) ? widget.widgetGraphics[currentTheme]['angleLabelFontSize'] : double.parse(widget.widgetGraphics[currentTheme]['angleLabelFontSize'].toString());
        graphics['angleLabelFontColor'] = HexColor(widget.widgetGraphics[currentTheme]['angleLabelFontColor']);
        graphics['intensityLabelFontSize'] = (widget.widgetGraphics[currentTheme]['intensityLabelFontSize'] is double) ? widget.widgetGraphics[currentTheme]['intensityLabelFontSize'] : double.parse(widget.widgetGraphics[currentTheme]['intensityLabelFontSize'].toString());
        graphics['intensityLabelFontColor'] = HexColor(widget.widgetGraphics[currentTheme]['intensityLabelFontColor']);
        graphics['needlePointerColor'] = HexColor(widget.widgetGraphics[currentTheme]['needlePointerColor']);
        graphics['gaugePositiveColor'] = HexColor(widget.widgetGraphics[currentTheme]['gaugePositiveColor']);
        graphics['gaugeNegativeColor'] = HexColor(widget.widgetGraphics[currentTheme]['gaugeNegativeColor']);
        graphics['minorTickSize'] = (widget.widgetGraphics[currentTheme]['minorTickSize'] is double) ? widget.widgetGraphics[currentTheme]['minorTickSize'] : double.parse(widget.widgetGraphics[currentTheme]['minorTickSize'].toString());
        graphics['minorTickLength'] = (widget.widgetGraphics[currentTheme]['minorTickLength'] is double) ? widget.widgetGraphics[currentTheme]['minorTickLength'] : double.parse(widget.widgetGraphics[currentTheme]['minorTickLength'].toString());
      } catch (e) {
        print("[WindIndicator] error while loading graphics -> " + e.toString());
      }
    }
  }

  void reInitState() {}

  @override
  void dispose() {
    print("[WindIndicator] DISPOSING...");
    cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
          stream: widget.Angle_Stream,
          builder: (context, snap) {

            return SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                    startAngle: 90,
                    //90,
                    endAngle: 450,
                    minimum: -180,
                    maximum: 180,
                    onLabelCreated: _handleAxisLabelCreated,
                    showAxisLine: true,
                    canScaleToFit: true,
                    interval: 45,
                    //22.5,
                    showLabels: true,
                    radiusFactor: graphics['radiusFactor'],
                    axisLabelStyle: GaugeTextStyle(color: graphics['radialLabelFontColor'], fontWeight: FontWeight.bold),
                    majorTickStyle: MajorTickStyle(length: graphics['majorTickLength'], lengthUnit: GaugeSizeUnit.factor, thickness: graphics['majorTickSize']),
                    minorTicksPerInterval: 4,
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          widget: Container(
                              child: Text((widget.Angle_Value.toStringAsFixed(2) + " " + graphics['angleUnit'].toString()),
                                  style: TextStyle(color: graphics['angleLabelFontColor'], fontSize: graphics['angleLabelFontSize'], fontWeight: FontWeight.bold))),
                          angle: 90,
                          positionFactor: 0.2),
                      GaugeAnnotation(
                          widget: Container(
                              child: Text((widget.Intensity_Value.toStringAsFixed(2) + " " + graphics['intensityUnit'].toString()),
                                  style: TextStyle(color: graphics['intensityLabelFontColor'], fontSize: graphics['intensityLabelFontSize'], fontWeight: FontWeight.bold))),
                          angle: 90,
                          positionFactor: 0.4)
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                          value: widget.Angle_Value,
                          needleStartWidth: 0,
                          needleColor: graphics['needlePointerColor'],
                          // model.isWebFullView ? null : const Color(0xFFD481FF),
                          lengthUnit: GaugeSizeUnit.factor,
                          needleLength: 0.9,
                          enableAnimation: true,
                          animationDuration: 2000,
                          animationType: AnimationType.elasticOut,
                          needleEndWidth: 5,
                          knobStyle: KnobStyle(knobRadius: 0, sizeUnit: GaugeSizeUnit.factor)),
                    ],
                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: 0,
                        endValue: widget.Angle_Value,
                        rangeOffset: 0.1,
                        sizeUnit: GaugeSizeUnit.factor,
                        startWidth: 0.10,
                        endWidth: 0.10,
                        color: widget.Angle_Value >= 0 ? graphics['gaugePositiveColor'] : graphics['gaugeNegativeColor'],
                      ),
                    ],
                    minorTickStyle: MinorTickStyle(length: graphics['minorTickLength'], lengthUnit: GaugeSizeUnit.factor, thickness: graphics['minorTickSize']),
                    axisLineStyle: AxisLineStyle(color: Colors.transparent))
              ],
            );
          });
  }

  void _handleAxisLabelCreated(AxisLabelCreatedArgs args) {
    if (args.text == '-180') {
      args.text = '';
    }
  }
}
