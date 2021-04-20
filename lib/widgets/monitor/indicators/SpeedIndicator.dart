import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';
import 'package:nautica/utils/HexColor.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


class SpeedIndicator extends StatefulWidget {
  dynamic Speed_Value = 0.0;
  Stream<dynamic> Speed_Stream = null;
  BaseModel model;
  final Function(String text, Icon icon) notifyParent;
  dynamic widgetGraphics;

  SpeedIndicator(
      {Key key, @required this.Speed_Stream, @required this.model,@required this.widgetGraphics,this.notifyParent})
      : super(key: key);


  @override
  _SpeedIndicatorState createState() => _SpeedIndicatorState();
}


class _SpeedIndicatorState extends State<SpeedIndicator> with DisposableWidget{
  Map graphics = new Map();
  String currentTheme = "light";
  @override
  void initState(){

    widget.model.addListener((){
      print("THEME WIND CHANGE");
      _loadWidgetGraphics();
    });



    graphics['radiusFactor'] = 1.0;
    graphics['majorTickLength'] = 0.04;
    graphics['majorTickThickness'] = 1.5;
    graphics['minorTickLength'] = 0.04;
    graphics['minorTickThickness'] = 1.5;
    graphics['labelOffset']  = 15;
    graphics['rangeOffset']  = 0.08;
    graphics['gradientFrom']  = HexColor("#FF4CAF50");
    graphics['gradientTo']  = HexColor("#FFF44336");
    graphics['textColor'] = widget.model.textColor;



    _loadWidgetGraphics();




    super.initState();
    if(widget.Speed_Stream != null) {
      widget.Speed_Stream.listen((data) {
        widget.Speed_Value =  (data == null || data == 0) ? 0.0 : data + .0;
      }).canceledBy(this);
    }
  }



  void _loadWidgetGraphics(){
    currentTheme = widget.model.isDark ? "darkTheme" : "lightTheme";

    if (widget.widgetGraphics != null) {
      try {

        graphics['radiusFactor'] = (widget.widgetGraphics[currentTheme]['radiusFactor'] is double) ? widget.widgetGraphics[currentTheme]['radiusFactor'] : double.parse(widget.widgetGraphics[currentTheme]['radiusFactor']);
        graphics['majorTickLength'] = (widget.widgetGraphics[currentTheme]['majorTickLength'] is double) ? widget.widgetGraphics[currentTheme]['majorTickLength'] : double.parse(widget.widgetGraphics[currentTheme]['majorTickLength']);
        graphics['majorTickThickness'] = (widget.widgetGraphics[currentTheme]['majorTickThickness'] is double) ? widget.widgetGraphics[currentTheme]['majorTickThickness'] : double.parse(widget.widgetGraphics[currentTheme]['majorTickThickness']);
        graphics['minorTickLength'] = (widget.widgetGraphics[currentTheme]['minorTickLength'] is double) ? widget.widgetGraphics[currentTheme]['minorTickLength'] : double.parse(widget.widgetGraphics[currentTheme]['minorTickLength']);
        graphics['minorTickThickness'] = (widget.widgetGraphics[currentTheme]['minorTickThickness'] is double) ? widget.widgetGraphics[currentTheme]['minorTickThickness'] : double.parse(widget.widgetGraphics[currentTheme]['minorTickThickness']);
        graphics['labelOffset'] = (widget.widgetGraphics[currentTheme]['labelOffset'] is double) ? widget.widgetGraphics[currentTheme]['labelOffset'] : double.parse(widget.widgetGraphics[currentTheme]['labelOffset']);
        graphics['gradientFrom'] =  HexColor(widget.widgetGraphics[currentTheme]['gradientFrom']);
        graphics['gradientTo'] =  HexColor(widget.widgetGraphics[currentTheme]['gradientTo']);
        graphics['textColor'] =  HexColor(widget.widgetGraphics[currentTheme]['textColor']);
        graphics['rangeOffset'] = (widget.widgetGraphics[currentTheme]['rangeOffset'] is double) ? widget.widgetGraphics[currentTheme]['rangeOffset'] : double.parse(widget.widgetGraphics[currentTheme]['rangeOffset']);




      } catch (e) {
        print("WindIndicator error while loading graphics -> " + e.toString());
      }
    }
  }


  @override
  void dispose() {
 //   print("CANCEL SPEED INDICATOR SUBSCRIPTION");
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
          stream: widget.Speed_Stream,
          builder: (context, snap) {













            return  SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                    showAxisLine: false,
                    minimum: 0,
                    maximum: 100,
                    ticksPosition: ElementsPosition.outside,
                    labelsPosition: ElementsPosition.outside,
                    radiusFactor: graphics['radiusFactor'],
                    canRotateLabels: true,
                    majorTickStyle: MajorTickStyle(
                      length: graphics['majorTickLength'],
                      thickness: graphics['majorTickThickness'],
                      lengthUnit: GaugeSizeUnit.factor,
                    ),
                    minorTickStyle: MinorTickStyle(
                      length: graphics['minorTickLength'],
                      thickness: graphics['minorTickThickness'],
                      lengthUnit: GaugeSizeUnit.factor,
                    ),
                    minorTicksPerInterval: 5,
                    interval: 10,
                    labelOffset: graphics['labelOffset'],
                    axisLabelStyle: GaugeTextStyle(fontSize: 12),
                    useRangeColorForAxis: true,
                    pointers: <GaugePointer>[
                      NeedlePointer(
                          needleStartWidth: 1,
                          enableAnimation: true,
                          value: widget.Speed_Value,

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
                          startValue: 0,
                          endValue: 100,
                          startWidth: 0.05,
                          gradient:  SweepGradient(
                              colors: <Color>[graphics['gradientFrom'], graphics['gradientTo']],
                              stops: <double>[0.25, 0.75]),
                          color: graphics['textColor'],
                          rangeOffset: graphics['rangeOffset'],
                          endWidth: 0.1,
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