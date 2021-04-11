import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class WindIndicator extends StatefulWidget {
  double Angle_Value = 0.0;
  double Intensity_Value = 0.0;
  Stream<dynamic> Angle_Stream = null;
  Stream<dynamic> Intensity_Stream = null;

  BaseModel model;
  bool haveData = false;
  final Function(String text, Icon icon) notifyParent;

  WindIndicator(
      {Key key,
      @required this.Angle_Stream,
      @required this.Intensity_Stream,
      @required this.model,
      this.notifyParent})
      : super(key: key);

  @override
  _WindIndicatorState createState() => _WindIndicatorState();
}

class _WindIndicatorState extends State<WindIndicator> with DisposableWidget {
  @override
  double speedLabelFontSize;
  double angleLabelFontSize;


  void initState() {
    super.initState();
    if (widget.Angle_Stream != null) {
      widget.Angle_Stream.listen((data) {
        widget.haveData = (data == null) ? false : true;
        widget.Angle_Value =
            (data == null || data == 0) ? 0.0 : (data * 180 / pi);
      }).canceledBy(this);
    }

    if (widget.Intensity_Stream != null) {
      widget.Intensity_Stream.listen((data) {
        widget.Intensity_Value = (data == null || data == 0) ? 0.0 : data;
      }).canceledBy(this);
    }
  }

  @override
  void dispose() {
    print("CANCEL WIND SUBSCRIPTION");
    cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    angleLabelFontSize = widget.model.isWebFullView ? 25.0 : 17.0;
    speedLabelFontSize = widget.model.isWebFullView ? 18.0 : 12.0;




    return GestureDetector(
      onTap: () {
        // notifyParent(text, icon);
      },
      child: StreamBuilder(
          stream: widget.Angle_Stream,
          builder: (context, snap) {
            // if (!snap.hasData || Angle_Value == null) {
            //   //append no data img
            //   haveData = false;
            // }

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
                    radiusFactor: 0.9,
                    axisLabelStyle: GaugeTextStyle(
                        color: widget.model.textColor,
                        fontWeight: FontWeight.bold),
                    majorTickStyle: MajorTickStyle(
                        length: 0.1,
                        lengthUnit: GaugeSizeUnit.factor,
                        thickness: 1.5),
                    minorTicksPerInterval: 4,
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          widget: Container(
                              child: Text(
                                  ((widget.haveData)
                                      ? widget.Angle_Value.toStringAsFixed(2) +
                                          "°"
                                      : "No data"),
                                  style: TextStyle(
                                      color: widget.model.textColor,
                                      fontSize: angleLabelFontSize,
                                      fontWeight: FontWeight.bold))),
                          angle: 90,
                          positionFactor: 0.2),
                      GaugeAnnotation(
                          widget: Container(
                              child: Text(
                                  ((widget.haveData)
                                      ? widget.Intensity_Value.toStringAsFixed(
                                              2) +
                                          " m/s"
                                      : "No data"),
                                  style: TextStyle(
                                      color: widget.model.textColor,
                                      fontSize: speedLabelFontSize,
                                      fontWeight: FontWeight.bold))),
                          angle: 90,
                          positionFactor: 0.4)
                    ],
                    pointers: <GaugePointer>[





                      NeedlePointer(
                          value: widget.Angle_Value,
                          needleStartWidth: 0,
                          needleColor: widget.model.paletteColor,
                          // model.isWebFullView ? null : const Color(0xFFD481FF),
                          lengthUnit: GaugeSizeUnit.factor,
                          needleLength: 0.9,
                          enableAnimation: true,
                          animationDuration: 2000,
                          animationType: AnimationType.elasticOut,
                          needleEndWidth: 5,
                          knobStyle: KnobStyle(
                              knobRadius: 0, sizeUnit: GaugeSizeUnit.factor)),
                    ],

                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: 0,
                        endValue: widget.Angle_Value,
                        rangeOffset: 0.1,
                        sizeUnit: GaugeSizeUnit.factor,
                        startWidth: 0.10,
                        endWidth: 0.10,
                        color: widget.Angle_Value >= 0 ? widget.model.positiveWind : widget.model.negativeWind,

                        //gradient: const SweepGradient(
                        //    colors: <Color>[Color(0xFFD481FF), Color(0xFF06F0E0)],
                        //    stops: <double>[0.25, 0.75]),
                      ),
                    ],
                    minorTickStyle: MinorTickStyle(
                        length: 0.04,
                        lengthUnit: GaugeSizeUnit.factor,
                        thickness: 1.5),
                    axisLineStyle: AxisLineStyle(color: Colors.transparent))
              ],
            );
          }),
    );
  }

  void _handleAxisLabelCreated(AxisLabelCreatedArgs args) {
    if (args.text == '-180') {
      args.text = '';
    }
    //args.labelStyle = GaugeTextStyle(
    //    color: model.paletteColor,
    //    fontSize: model.isCardView ? 12 : _labelFontSize);
    //}
  }
}
