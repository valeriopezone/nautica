import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class PositionIndicator extends StatelessWidget {
  dynamic Position_Value;
  Stream<dynamic> Position_Stream = null;

  final String text;
  final Icon icon;
  final Function(String text, Icon icon) notifyParent;

  PositionIndicator({Key key, @required this.Position_Stream,@required this.text, this.icon, this.notifyParent}) : super(key: key){
    Position_Stream.listen((data) {
      Position_Value = data;
    });
  }





  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        notifyParent(text, icon);
      },
      child: StreamBuilder(
          stream: Position_Stream,
          builder: (context, snap) {
            if (!snap.hasData) {
              return CircularProgressIndicator();
            }
            return Column(children: <Widget>[
              Text("Lon : ${_getLongitudeFromSnap(snap.data)}",
                  style: GoogleFonts.lato(
                      textStyle: Theme.of(context).textTheme.headline4)),
              Text("Lat : ${_getLatitudeFromSnap(snap.data)}",
                  style: GoogleFonts.lato(
                      textStyle: Theme.of(context).textTheme.headline4)),
              SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                      radiusFactor: 0.98,
                      startAngle: 90,
                      endAngle: 330,
                      minimum: -8,
                      maximum: 12,
                      showAxisLine: false,
                      majorTickStyle: MajorTickStyle(
                          length: 0.15, lengthUnit: GaugeSizeUnit.factor, thickness: 2),
                      labelOffset: 8,
                      axisLabelStyle: GaugeTextStyle(
                          fontFamily: 'Times',
                          fontSize:  12,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic),
                      minorTicksPerInterval: 9,
                      interval: 2,
                      pointers: <GaugePointer>[
                        NeedlePointer(
                            value: 0,
                            needleStartWidth: 2,
                            needleEndWidth: 2,
                            needleColor: const Color(0xFFF67280),
                            needleLength: 0.8,
                            lengthUnit: GaugeSizeUnit.factor,
                            enableAnimation: true,
                            animationType: AnimationType.bounceOut,
                            animationDuration: 1500,
                            knobStyle: KnobStyle(
                                knobRadius: 8,
                                sizeUnit: GaugeSizeUnit.logicalPixel,
                                color: const Color(0xFFF67280)))
                      ],
                      minorTickStyle: MinorTickStyle(
                          length: 0.08,
                          thickness: 1,
                          lengthUnit: GaugeSizeUnit.factor,
                          color: const Color(0xFFC4C4C4)),
                      axisLineStyle: AxisLineStyle(
                          color: const Color(0xFFDADADA),
                          thicknessUnit: GaugeSizeUnit.factor,
                          thickness: 0.1)),
                ],
              )
            ]);
          }),
    );
  }

  String _getLatitudeFromSnap(snapData) {
    if (snapData == null || snapData == 0) return 0.toStringAsFixed(5);
    if (snapData['latitude'] != null) return snapData['latitude'].toStringAsFixed(5);
    return 0.toStringAsFixed(5);

  }


  String _getLongitudeFromSnap(snapData) {
    if (snapData == null || snapData == 0) return 0.toStringAsFixed(5);
    if (snapData['longitude'] != null) return snapData['longitude'].toStringAsFixed(5);
    return 0.toStringAsFixed(5);
  }


}