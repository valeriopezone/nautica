import 'dart:math';

/// Flutter package imports
import 'package:flutter/material.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';

/// Gauge imports

import 'package:syncfusion_flutter_gauges/gauges.dart';

/// Locals imports

/// Renders the gauge compass sample.
class CompassIndicator extends StatefulWidget { //should rename
  /// Creates the gauge compass sample.
  BaseModel model;
  double COG_Value = 0;
  Stream<dynamic> Value_Stream = null;
  final Function(String text, Icon icon) notifyParent;


  CompassIndicator({Key key, @required this.model,@required this.Value_Stream,this.notifyParent}) : super(key: key);

  @override
  _CompassIndicatorState createState() => _CompassIndicatorState();
}
class _CompassIndicatorState extends State<CompassIndicator> with DisposableWidget {

  _CompassIndicatorState();


  @override
  void initState(){
    super.initState();
    if(widget.Value_Stream != null) {
      widget.Value_Stream.listen((data) {
        widget.COG_Value =  (data == null || data == 0) ? 0.0 : data*(180/pi);
      }).canceledBy(this);
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



      _annotationTextSize = widget.model.isWebFullView ? 22 : 16;
      _markerOffset = widget.model.isWebFullView ? 0.71 : 0.69;
      _positionFactor = widget.model.isWebFullView ? 0.025 : 0.05;
      _markerHeight = widget.model.isWebFullView ? 10 : 5;
      _markerWidth = widget.model.isWebFullView ? 15 : 10;
      _labelFontSize = widget.model.isWebFullView ? 11 : 10;



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
            radiusFactor: 1.3,
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
                color: const Color(0xFF949494),
                fontSize: widget.model.isWebFullView ? 10 : _labelFontSize,
            fontWeight : FontWeight.bold,
            ),

            minorTickStyle: MinorTickStyle(
                color: const Color(0xFF616161),
                thickness: 1.6,
                length: 0.058,
                lengthUnit: GaugeSizeUnit.factor),
            majorTickStyle: MajorTickStyle(
                color: const Color(0xFF949494),

                thickness: 2.3,
                length: 0.087,
                lengthUnit: GaugeSizeUnit.factor),
            //backgroundImage: const AssetImage('assets/dark_theme_gauge.png'),
            pointers: <GaugePointer>[
              MarkerPointer(
                  value: 0,//widget.COG_Value,
                  color: const Color(0xFFDF5F2D),
                  enableAnimation: true,
                  animationDuration: 1200,
                  markerOffset: widget.model.isWebFullView ? 0.69 : _markerOffset,
                  offsetUnit: GaugeSizeUnit.factor,
                  markerType: MarkerType.triangle,
                  markerHeight: widget.model.isWebFullView ? 8 : _markerHeight,
                  markerWidth: widget.model.isWebFullView ? 8 : _markerWidth)
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  angle: 270,
                  positionFactor: _positionFactor,
                  widget: Text(
                    widget.COG_Value.toStringAsFixed(2),
                    style: TextStyle(
                        color: const Color(0xFFDF5F2D),
                        fontWeight: FontWeight.bold,
                        fontSize: widget.model.isWebFullView ? 16 : _annotationTextSize),
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
        args.labelStyle = GaugeTextStyle(
            color: widget.model.paletteColor,
            fontSize: widget.model.isWebFullView ? 10 : _labelFontSize);

      } else if (args.text == '180') {
        args.text = 'S';
      } else if (args.text == '270') {
        args.text = 'W';
      }

      args.labelStyle = GaugeTextStyle(
          color: widget.model.paletteColor,
          fontSize: widget.model.isWebFullView ? 12 : _labelFontSize);
    }
  }

  double _annotationTextSize = 22;
  double _positionFactor = 0.025;
  double _markerHeight = 10;
  double _markerWidth = 15;
  double _markerOffset = 0.71;
  double _labelFontSize = 10;
}
