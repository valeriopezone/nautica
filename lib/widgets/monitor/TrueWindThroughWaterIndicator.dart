import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TrueWindThroughWaterIndicator extends StatelessWidget {
  double ATW_Value = 0.0;
  double ST_Value = 0.0;
  Stream<dynamic> ATW_Stream = null;
  Stream<dynamic> ST_Stream = null;
  BaseModel model;

  final String text;
  final Icon icon;
  final Function(String text, Icon icon) notifyParent;

  /*
  angle: values.angleTrueWater,
      speed: values.speedTrue,

   */

  TrueWindThroughWaterIndicator({Key key, @required this.ATW_Stream,@required this.ST_Stream,@required this.text, @required this.model, this.icon, this.notifyParent}) : super(key: key){
    if(ATW_Stream != null) {
      ATW_Stream.listen((data) {
        ATW_Value = (data == null || data == 0) ? 0.0 : data;
      });
    }

    if(ST_Stream != null) {
      ST_Stream.listen((data) {
        ST_Value = (data == null || data == 0) ? 0.0 : data;
      });
    }


  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
       // notifyParent(text, icon);
      },
      child: StreamBuilder(
          stream: ATW_Stream,
          builder: (context, snap) {
            if (!snap.hasData) {
              return CircularProgressIndicator();
            }

            return Container(
              height: 180,
              padding: const EdgeInsets.only(top: 0, bottom: 0),
              margin: const EdgeInsets.only(top: 0, bottom: 0),
              /*decoration: BoxDecoration(
                color: const Color(0xff7c94b6),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),*/
              child: SfRadialGauge(

                axes: <RadialAxis>[
                  RadialAxis(
                      startAngle: 90,//90,
                      endAngle: 450,
                      minimum: -180,
                      maximum: 180,

                      showAxisLine: true,
                      canScaleToFit: true,
                      interval: 45,//22.5,
                      showLabels: true,
                      radiusFactor: 0.9,
                      axisLabelStyle: GaugeTextStyle(color: model.textColor, fontWeight: FontWeight.bold),

                      majorTickStyle: MajorTickStyle(
                          length: 0.1, lengthUnit: GaugeSizeUnit.factor, thickness: 1.5),
                      minorTicksPerInterval: 4,
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(widget: Container(child:
                        Text(ATW_Value.toStringAsFixed(2),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold))),
                            angle: 90, positionFactor: 0.5
                        )],

                      pointers: <GaugePointer>[
                        /*RangePointer(

                            gradient: const SweepGradient(
                                colors: <Color>[Color(0xFFD481FF), Color(0xFF06F0E0)],
                                stops: <double>[0.25, 0.75]),
                            value: -45,
                            width: 5,
                            animationDuration: 2000,
                            enableAnimation: true,
                            animationType: AnimationType.elasticOut,
                            color: const Color(0xFF00A8B5)),*/
                        NeedlePointer(
                            value: ATW_Value,
                            needleStartWidth: 0,
                            needleColor: model.currentPrimaryColor,// model.isWebFullView ? null : const Color(0xFFD481FF),
                            lengthUnit: GaugeSizeUnit.factor,
                            needleLength: 1,
                            enableAnimation: true,
                            animationDuration: 2000,
                            animationType: AnimationType.elasticOut,
                            needleEndWidth: 5,
                            knobStyle:
                            KnobStyle(knobRadius: 0, sizeUnit: GaugeSizeUnit.factor))
                      ],
                      minorTickStyle: MinorTickStyle(
                          length: 0.04, lengthUnit: GaugeSizeUnit.factor, thickness: 1.5),
                      axisLineStyle: AxisLineStyle(color: Colors.transparent))
                ],
              ),
            );


            return Text(
                "angle true water: ${(ATW_Value.toStringAsFixed(2))}",
                style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.headline4));



          }),
    );
  }

}