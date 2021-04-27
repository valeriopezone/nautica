import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';
import 'package:nautica/utils/HexColor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';



class DateValueAxisChart extends StatefulWidget {


  double Time_Value = 0.0;
  double Intensity_Value = 0.0;
  Stream<dynamic> DataValue_Stream = null;

  BaseModel model;
  bool haveData = false;
  final Function(String text, Icon icon) notifyParent;
  Map<dynamic, dynamic> lastStreamedValue = {'timestamp': null, 'value': 0};

  dynamic widgetGraphics;
  dynamic vesselsDataTable = [];
  String currentVessel = ""; //


  DateValueAxisChart({Key key,
    @required this.DataValue_Stream,
    @required this.model,
    this.notifyParent,
    @required this.vesselsDataTable,
    @required this.currentVessel,
    @required this.widgetGraphics,
  }) : super(key: key);

  @override
  _LiveVerticalState createState() => _LiveVerticalState();
}

/// State class of the realtime line chart.
class _LiveVerticalState extends State<DateValueAxisChart> with DisposableWidget {

  List<_DateValueChartCoords> chartData = <_DateValueChartCoords>[];
  ChartSeriesController _chartSeriesController;




  double minValue = 0.0;
  double maxValue = 30.0;
  int numDatapoints = 30;
  Color chartColor = HexColor("#FFC06C84");

  @override
  void initState() {
    super.initState();
    if (widget.DataValue_Stream != null) {
      widget.DataValue_Stream.listen((data) {

        try {
          var timestamp = data['timestamp'];
          var value = (data['value'] == null)
              ? 0.0
              : (data['value'] is double)
                  ? data['value']
                  : double.parse(data['value']);

          if (timestamp == null || timestamp == widget.lastStreamedValue['timestamp']) return;

          var date = DateTime.parse(timestamp);
          if (date.isUtc) {
            widget.lastStreamedValue['timestamp'] = timestamp;
            widget.lastStreamedValue['value'] = value;
            print("date : $date");

            _updateDataSource(date, value);

          }
        } catch (e) {
          print("[DateValueAxisChart] initState : " + e.toString());
        }
      }).canceledBy(this);
    }
  }

  @override
  void dispose() {
    print("CANCEL DATEVALUEAXISCHART SUBSCRIPTION");
    cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLiveLineChart();
  }

  /// Returns the realtime Cartesian line chart.
  Widget _buildLiveLineChart() {
    //var x = DateTimeAxis();
    //dateTime
    return GestureDetector(
      onTap: () {
        //notifyParent(text, icon);
      },
      child: StreamBuilder(
          stream: null,
          builder: (context, snapshot) {
            return (!true)
                ? Text("in")
                : SfCartesianChart(
                    // isTransposed: true,
                    plotAreaBorderWidth: 0,
                margin: EdgeInsets.all(15),

                    tooltipBehavior: TooltipBehavior(enable: true, header : "", format: 'point.y m/s'),
                    //   primaryXAxis: NumericAxis(majorGridLines: MajorGridLines(width: 0)),
                    primaryXAxis: DateTimeAxis(axisLine: AxisLine(width: 1), dateFormat: DateFormat.Hms(), interval: 20),
//intervalType: DateTimeIntervalType.auto,
                    // series :  <LineSeries<dynamic, dynamic>>[],//<LineSeries<dynamic, dynamic>>[],

                    primaryYAxis: NumericAxis(minimum: minValue, maximum: maxValue, axisLine: AxisLine(width: 1), majorTickLines: MajorTickLines(size: 0)),
                    series: <LineSeries<_DateValueChartCoords, DateTime>>[
                        LineSeries<_DateValueChartCoords, DateTime>(
                          onRendererCreated: (ChartSeriesController controller) {
                            _chartSeriesController = controller;
                          },
                          dataSource: chartData,
                          color: chartColor,
                          xValueMapper: (_DateValueChartCoords sales, _) => sales.x,
                          yValueMapper: (_DateValueChartCoords sales, _) => sales.y,
                          animationDuration: 0,
                          enableTooltip: true,
                        )
                      ]);
          }),
    );
  }

  void _updateDataSource(DateTime newDate, double newValue) {
    if (true) {
      chartData.add(_DateValueChartCoords(newDate, newValue));
      if (chartData.length == numDatapoints) {
        chartData.removeAt(0);
        _chartSeriesController?.updateDataSource(
          addedDataIndexes: <int>[chartData.length - 1],
          removedDataIndexes: <int>[0],
        );
      } else {
        _chartSeriesController?.updateDataSource(
          addedDataIndexes: <int>[chartData.length - 1],
        );
      }
    }
  }
}


class _DateValueChartCoords {
  _DateValueChartCoords(this.x, this.y);

  final dynamic x;
  final double y;
}
