import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:SKDashboard/models/BaseModel.dart';
import 'package:SKDashboard/models/Helper.dart';
import 'package:SKDashboard/utils/HexColor.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


class SpeedIndicator extends StatefulWidget {
  dynamic Speed_Value = 0.0;
  Stream<dynamic> Speed_Stream = null;
  BaseModel model;
  dynamic widgetGraphics;

  SpeedIndicator(
      {Key key, @required this.Speed_Stream, @required this.model,@required this.widgetGraphics})
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
      _loadWidgetGraphics();
    });

    graphics['minValue'] = 0.0;
    graphics['maxValue'] = 100.0;
    graphics['gaugeFontColor'] = HexColor("#FF000000");
    graphics['gaugeFontSize'] = 17.0;
    graphics['axisLabelFontSize'] = 12.0;
    graphics['radiusFactor'] = 1.0;
    graphics['majorTickLength'] = 0.04;
    graphics['majorTickThickness'] = 1.5;
    graphics['minorTickLength'] = 0.04;
    graphics['minorTickThickness'] = 1.5;
    graphics['labelOffset']  = 15.0;
    graphics['rangeOffset']  = 0.08;
    graphics['gradientFrom']  = HexColor("#FF4CAF50");
    graphics['gradientTo']  = HexColor("#FFF44336");
    graphics['textColor'] = widget.model.textColor;
    graphics['needleColor'] = widget.model.textColor;
    graphics['knobColor'] = widget.model.textColor;
    graphics['needleStartWidth']  = 1.0;
    graphics['needleEndWidth']  = 5.0;
    graphics['needleLength']  = 0.7;
    graphics['knobRadius']  = 0.08;



    _loadWidgetGraphics();




    super.initState();
    if(widget.Speed_Stream != null) {
      widget.Speed_Stream.listen((data) {
        widget.Speed_Value =  (data == null || data == 0) ? 0.0 : data.toDouble() + .0;
      }).canceledBy(this);
    }
  }



  void _loadWidgetGraphics(){
    currentTheme = widget.model.isDark ? "darkTheme" : "lightTheme";

    if (widget.widgetGraphics != null) {
      try {

        graphics['minValue'] = (widget.widgetGraphics[currentTheme]['minValue'] is double)
            ? widget.widgetGraphics[currentTheme]['minValue']
            : double.parse(widget.widgetGraphics[currentTheme]['minValue'].toString());
        graphics['maxValue'] = (widget.widgetGraphics[currentTheme]['maxValue'] is double)
            ? widget.widgetGraphics[currentTheme]['maxValue']
            : double.parse(widget.widgetGraphics[currentTheme]['maxValue'].toString());


        graphics['gaugeFontColor'] = HexColor(widget.widgetGraphics[currentTheme]['gaugeFontColor']);
        graphics['gaugeFontSize'] = (widget.widgetGraphics[currentTheme]['gaugeFontSize'] is double)
            ? widget.widgetGraphics[currentTheme]['gaugeFontSize']
            : double.parse(widget.widgetGraphics[currentTheme]['gaugeFontSize'].toString());
        graphics['radiusFactor'] = (widget.widgetGraphics[currentTheme]['radiusFactor'] is double) ? widget.widgetGraphics[currentTheme]['radiusFactor'] : double.parse(widget.widgetGraphics[currentTheme]['radiusFactor'].toString());
        graphics['majorTickLength'] = (widget.widgetGraphics[currentTheme]['majorTickLength'] is double) ? widget.widgetGraphics[currentTheme]['majorTickLength'] : double.parse(widget.widgetGraphics[currentTheme]['majorTickLength'].toString());
        graphics['majorTickThickness'] = (widget.widgetGraphics[currentTheme]['majorTickThickness'] is double) ? widget.widgetGraphics[currentTheme]['majorTickThickness'] : double.parse(widget.widgetGraphics[currentTheme]['majorTickThickness'].toString());
        graphics['minorTickLength'] = (widget.widgetGraphics[currentTheme]['minorTickLength'] is double) ? widget.widgetGraphics[currentTheme]['minorTickLength'] : double.parse(widget.widgetGraphics[currentTheme]['minorTickLength'].toString());
        graphics['minorTickThickness'] = (widget.widgetGraphics[currentTheme]['minorTickThickness'] is double) ? widget.widgetGraphics[currentTheme]['minorTickThickness'] : double.parse(widget.widgetGraphics[currentTheme]['minorTickThickness'].toString());
        graphics['labelOffset'] = (widget.widgetGraphics[currentTheme]['labelOffset'] is double) ? widget.widgetGraphics[currentTheme]['labelOffset'] : double.parse(widget.widgetGraphics[currentTheme]['labelOffset'].toString());
        graphics['gradientFrom'] =  HexColor(widget.widgetGraphics[currentTheme]['gradientFrom']);
        graphics['gradientTo'] =  HexColor(widget.widgetGraphics[currentTheme]['gradientTo']);
        graphics['textColor'] =  HexColor(widget.widgetGraphics[currentTheme]['textColor']);
        graphics['rangeOffset'] = (widget.widgetGraphics[currentTheme]['rangeOffset'] is double) ? widget.widgetGraphics[currentTheme]['rangeOffset'] : double.parse(widget.widgetGraphics[currentTheme]['rangeOffset'].toString());
        graphics['needleColor'] =  HexColor(widget.widgetGraphics[currentTheme]['needleColor']);
        graphics['knobColor'] =  HexColor(widget.widgetGraphics[currentTheme]['knobColor']);

        graphics['needleStartWidth'] = (widget.widgetGraphics[currentTheme]['needleStartWidth'] is double) ? widget.widgetGraphics[currentTheme]['needleStartWidth'] : double.parse(widget.widgetGraphics[currentTheme]['needleStartWidth'].toString());
        graphics['needleEndWidth'] = (widget.widgetGraphics[currentTheme]['needleEndWidth'] is double) ? widget.widgetGraphics[currentTheme]['needleEndWidth'] : double.parse(widget.widgetGraphics[currentTheme]['needleEndWidth'].toString());
        graphics['needleLength'] = (widget.widgetGraphics[currentTheme]['needleLength'] is double) ? widget.widgetGraphics[currentTheme]['needleLength'] : double.parse(widget.widgetGraphics[currentTheme]['needleLength'].toString());
        graphics['knobRadius'] = (widget.widgetGraphics[currentTheme]['knobRadius'] is double) ? widget.widgetGraphics[currentTheme]['knobRadius'] : double.parse(widget.widgetGraphics[currentTheme]['knobRadius'].toString());
        graphics['axisLabelFontSize'] = (widget.widgetGraphics[currentTheme]['axisLabelFontSize'] is double) ? widget.widgetGraphics[currentTheme]['axisLabelFontSize'] : double.parse(widget.widgetGraphics[currentTheme]['axisLabelFontSize'].toString());



      } catch (e) {
        print("[SpeedIndicator] error while loading graphics -> " + e.toString());
      }
    }
  }


  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder(
          stream: widget.Speed_Stream,
          builder: (context, snap) {

            return  SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                    showAxisLine: false,
                    minimum: graphics['minValue'],
                    maximum: graphics['maxValue'],
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
                    axisLabelStyle: GaugeTextStyle(fontSize: graphics['axisLabelFontSize']),
                    useRangeColorForAxis: true,
                    pointers: <GaugePointer>[
                      NeedlePointer(

                        needleColor: graphics['needleColor'],
                          needleStartWidth: graphics['needleStartWidth'],
                          enableAnimation: true,
                          value: widget.Speed_Value,

                          needleEndWidth: graphics['needleEndWidth'],
                          needleLength: graphics['needleLength'],
                          lengthUnit: GaugeSizeUnit.factor,
                          knobStyle: KnobStyle(
                            color: graphics['knobColor'],
                            knobRadius: graphics['knobRadius'],
                            sizeUnit: GaugeSizeUnit.factor,
                          ))
                    ],
                    ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: graphics['minValue'],
                          endValue:  graphics['maxValue'],
                          startWidth: 0.05,
                          gradient:  SweepGradient(
                              colors: <Color>[graphics['gradientFrom'], graphics['gradientTo']],
                              stops: <double>[0.25, 0.75]),
                          color: graphics['textColor'],
                          rangeOffset: graphics['rangeOffset'],
                          endWidth: 0.1,
                          sizeUnit: GaugeSizeUnit.factor)
                    ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0.8,
                        widget: Text(
                          widget.Speed_Value.toStringAsFixed(2) + " Hz",
                          style: TextStyle(color: graphics['gaugeFontColor'], fontWeight: FontWeight.bold, fontSize: graphics['gaugeFontSize']),
                        ))
                  ]
                ),
              ],
            );
          });
  }

}