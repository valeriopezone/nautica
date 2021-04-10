import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


class SpeedIndicator extends StatefulWidget {
  dynamic ST_Value;
  Stream<dynamic> ST_Stream = null;
  BaseModel model;
  final Function(String text, Icon icon) notifyParent;

  SpeedIndicator(
      {Key key, @required this.ST_Stream, @required this.model, this.notifyParent})
      : super(key: key);


  @override
  _SpeedIndicatorState createState() => _SpeedIndicatorState();
}


class _SpeedIndicatorState extends State<SpeedIndicator> with DisposableWidget{

  @override
  void initState(){
    super.initState();
    if(widget.ST_Stream != null) {
      widget.ST_Stream.listen((data) {
        widget.ST_Value =  (data == null || data == 0) ? 0.0 : data;
      }).canceledBy(this);
    }
  }

  @override
  void dispose() {
    print("CANCEL SPEED INDICATOR SUBSCRIPTION");
    cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //notifyParent(text, icon);
      },
      child: StreamBuilder(
          stream: widget.ST_Stream,
          builder: (context, snap) {
            if (!snap.hasData) {
              return CircularProgressIndicator();
            }

            return  SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                    showAxisLine: false,
                    minimum: 0,
                    maximum: 100,
                    ticksPosition: ElementsPosition.outside,
                    labelsPosition: ElementsPosition.outside,
                    radiusFactor: 0.9,
                    canRotateLabels: true,
                    majorTickStyle: MajorTickStyle(
                      length: 0.1,
                      thickness: 1.5,
                      lengthUnit: GaugeSizeUnit.factor,
                    ),
                    minorTickStyle: MinorTickStyle(
                      length: 0.04,
                      thickness: 1.5,
                      lengthUnit: GaugeSizeUnit.factor,
                    ),
                    minorTicksPerInterval: 5,
                    interval: 10,
                    labelOffset: 15,
                    axisLabelStyle: GaugeTextStyle(fontSize: 12),
                    useRangeColorForAxis: true,
                    pointers: <GaugePointer>[
                      NeedlePointer(
                          needleStartWidth: 1,
                          enableAnimation: true,
                          value: widget.ST_Value,
                          tailStyle: TailStyle(
                              length: 0.2, width: 5, lengthUnit: GaugeSizeUnit.factor),
                          needleEndWidth: 5,
                          needleLength: 0.7,
                          lengthUnit: GaugeSizeUnit.factor,
                          knobStyle: KnobStyle(
                            knobRadius: 0.08,
                            sizeUnit: GaugeSizeUnit.factor,
                          ))
                    ],
                    ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: 30,
                          endValue: 100,
                          startWidth: widget.model.isWebFullView ? 0.2 : 0.05,
                          gradient: const SweepGradient(
                              colors: <Color>[Color(0xFF289AB1), Color(0xFF43E695)],
                              stops: <double>[0.25, 0.75]),
                          color: const Color(0xFF289AB1),
                          rangeOffset: 0.08,
                          endWidth: 0.2,
                          sizeUnit: GaugeSizeUnit.factor)
                    ]),
              ],
            );
          //return Text(
          //    "Speed true: ${(snap.data.toStringAsFixed(2))}",
          //    style: GoogleFonts.lato(
          //        textStyle: Theme.of(context).textTheme.headline4));
          }),
    );
  }

}