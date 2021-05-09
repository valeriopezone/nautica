import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:SKDashboard/models/BaseModel.dart';
import 'package:SKDashboard/models/Helper.dart';
import 'package:SKDashboard/utils/HexColor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class _DateValueChartCoords {
  _DateValueChartCoords(this.x, this.y);

  final dynamic x;
  final double y;
}

class DateValueAxisChart extends StatefulWidget {
  double Time_Value = 0.0;
  double Intensity_Value = 0.0;
  Stream<dynamic> DataValue_Stream;
  String subscriptionPath = "";
  bool isTransposed = false;
  BaseModel model;
  dynamic widgetGraphics;
  dynamic vesselsDataTable = [];
  String currentVessel = ""; //

  DateValueAxisChart({
    Key key,
    @required this.DataValue_Stream,
    @required this.model,
    @required this.subscriptionPath,
    @required this.vesselsDataTable,
    @required this.currentVessel,
    @required this.widgetGraphics,
    this.isTransposed = false,
  }) : super(key: key);

  @override
  _DateValueAxisChartState createState() => _DateValueAxisChartState();
}

class _DateValueAxisChartState extends State<DateValueAxisChart> with DisposableWidget {
  Map graphics = new Map();
  String currentTheme = "light";

  List<_DateValueChartCoords> chartData = <_DateValueChartCoords>[];
  ChartSeriesController _chartSeriesController;
  Map<dynamic, dynamic> lastStreamedValue = {'timestamp': null, 'value': 0};
  DateTime lastStreamedDate;
  bool haveReceivedData = false;

  @override
  void initState() {
    super.initState();

    graphics['chartMinValue'] = 0.0;
    graphics['chartMaxValue'] = 100.0;
    graphics['chartNumDatapoints'] = 30;
    graphics['chartLineColor'] = HexColor("#FFC06C84");

    widget.model.addListener(() {
      _loadWidgetGraphics();
    });

    _loadWidgetGraphics();

    lastStreamedValue = {'timestamp': null, 'value': 0};

    if (widget.DataValue_Stream != null) {
      widget.DataValue_Stream.listen((data) {
        try {
          var timestamp = data['timestamp'];
          var value = (data['value'] == null)
              ? 0.0
              : (data['value'] is double)
                  ? data['value']
                  : double.parse(data['value']);

          if (timestamp == null || timestamp == lastStreamedValue['timestamp']) return;

          var date = DateTime.parse(timestamp);
          if (date.isUtc) {
            lastStreamedValue['timestamp'] = timestamp;
            lastStreamedValue['value'] = value;
            if(!haveReceivedData){
              if(mounted) setState(() {
                haveReceivedData = true;
                lastStreamedDate = date;
                initializeDataPoints();

              });
            }
            _updateDataSource(date, value);
          }
        } catch (e) {
          print("[DateValueAxisChart] initState : " + e.toString());
        }
      }).canceledBy(this);
    }
  }

  void _loadWidgetGraphics() {
    currentTheme = widget.model.isDark ? "darkTheme" : "lightTheme";

    if (widget.widgetGraphics != null) {
      try {
        graphics['chartMinValue'] = (widget.widgetGraphics[currentTheme]['chartMinValue'] is double)
            ? widget.widgetGraphics[currentTheme]['chartMinValue']
            : double.parse(widget.widgetGraphics[currentTheme]['chartMinValue'].toString());

        graphics['chartMaxValue'] = (widget.widgetGraphics[currentTheme]['chartMaxValue'] is double)
            ? widget.widgetGraphics[currentTheme]['chartMaxValue']
            : double.parse(widget.widgetGraphics[currentTheme]['chartMaxValue'].toString());

        var nDataPoints = widget.widgetGraphics[currentTheme]['chartNumDatapoints'].toString();
        double ndpDouble = double.parse(nDataPoints); //datapoints num is INTEGER but it's stored as double into db
        graphics['chartNumDatapoints'] = ndpDouble.toInt();
        if (graphics['chartNumDatapoints'] <= 8) graphics['chartNumDatapoints'] = 8;
        if (graphics['chartNumDatapoints'] > 100) graphics['chartNumDatapoints'] = 100;

        graphics['chartLineColor'] = HexColor(widget.widgetGraphics[currentTheme]['chartLineColor']);
      } catch (e) {
        print("[DateValueAxisChart] error while loading graphics -> $e");
      }
    }
  }

  void initializeDataPoints() {
    //fill datapoints with 0
   // DateTime now = new DateTime.now().subtract(new Duration(seconds: 1 * graphics['chartNumDatapoints']));
    DateTime now =  lastStreamedDate.subtract(new Duration(seconds: 1 * graphics['chartNumDatapoints']));
    for (int i = 0; i < graphics['chartNumDatapoints'] - 1; i++) {
      chartData.add(_DateValueChartCoords(now, 0.0));
      now = now.add(new Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLiveLineChart();
  }

  String _getUnit() {
    String unit = (widget.subscriptionPath == "navigation.position") ? "'" : " ";
    try {
      unit = widget.vesselsDataTable[widget.currentVessel][widget.subscriptionPath]['units'];
      unit = (unit != null && unit.isNotEmpty) ? unit.toString() : " ";
    } catch (e) {
      //print("[DateValueAxisChart] error while decoding unit -> $e");
    }
    return unit;
  }

  Widget _buildLiveLineChart() {
    return GestureDetector(
      onTap: () {
        //...
      },
      child: StreamBuilder(
          stream: null,
          builder: (context, snapshot) {
            return (!haveReceivedData) ? CupertinoActivityIndicator() : Container(
              child: SfCartesianChart(

                  isTransposed: widget.isTransposed,
                  plotAreaBorderWidth: 0,
                  margin: EdgeInsets.only(left: 5, right: 5),
                  tooltipBehavior: TooltipBehavior(enable: true, header: "", format: 'point.y ' + _getUnit()),
                  primaryXAxis: DateTimeAxis(axisLine: AxisLine(width: 1), dateFormat: DateFormat.Hms(), interval: 20),
                  primaryYAxis:
                      NumericAxis(minimum: graphics['chartMinValue'], maximum: graphics['chartMaxValue'], axisLine: AxisLine(width: 1), majorTickLines: MajorTickLines(size: 0)),
                  series: <LineSeries<_DateValueChartCoords, DateTime>>[
                    LineSeries<_DateValueChartCoords, DateTime>(
                      onRendererCreated: (ChartSeriesController controller) {
                        _chartSeriesController = controller;
                      },
                      dataSource: chartData,
                      color: graphics['chartLineColor'],
                      xValueMapper: (_DateValueChartCoords dp, _) => dp.x,
                      yValueMapper: (_DateValueChartCoords dp, _) => dp.y,
                      animationDuration: 0,
                      enableTooltip: true,
                    )
                  ]),
            );
          }),
    );
  }

  void _updateDataSource(DateTime newDate, double newValue) {
    if (true) {
      chartData.add(_DateValueChartCoords(newDate, newValue));
      if (chartData.length == graphics['chartNumDatapoints']) {
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
