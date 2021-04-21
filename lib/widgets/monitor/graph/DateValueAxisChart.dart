import 'dart:async';
/// Dart imports
import 'dart:math';
import 'package:intl/intl.dart';

/// Package import
import 'package:flutter/material.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';

/// Local imports

/// Renders the update data source chart sample.
class DateValueAxisChart extends StatefulWidget {

  /// Creates the update data source chart sample.

  double Time_Value = 0.0;
  double Intensity_Value = 0.0;
  Stream<dynamic> DataValue_Stream = null;

  BaseModel model;
  bool haveData = false;
  final Function(String text, Icon icon) notifyParent;

  DateValueAxisChart(
      {Key key,
        @required this.DataValue_Stream,
        @required this.model,
        this.notifyParent})
      : super(key: key);


  @override
  _LiveVerticalState createState() => _LiveVerticalState();
}

/// State class of the realtime line chart.
class _LiveVerticalState extends State<DateValueAxisChart> with DisposableWidget {
  _LiveVerticalState() {
    timer = Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);
  }


  int numDatapoints = 30;



  Timer timer;
  List<_BasicChartCoords> chartData = <_BasicChartCoords>[
    _BasicChartCoords(0, 42.0),
    _BasicChartCoords(1, 47.0),
    _BasicChartCoords(2, 33.0),
    _BasicChartCoords(3, 49.0),
    _BasicChartCoords(4, 54.0),
    _BasicChartCoords(5, 41.0),
    _BasicChartCoords(6, 58.0),
    _BasicChartCoords(7, 51.0),
    _BasicChartCoords(8, 98.0),
    _BasicChartCoords(9, 41.0),
    _BasicChartCoords(10, 53.0),
    _BasicChartCoords(11, 72.0),
    _BasicChartCoords(12, 86.0),
    _BasicChartCoords(13, 52.0),
    _BasicChartCoords(14, 94.0),
    _BasicChartCoords(15, 92.0),
    _BasicChartCoords(16, 86.0),
    _BasicChartCoords(17, 72.0),
    _BasicChartCoords(18, 94.0),
  ];
  int count = 19;
  ChartSeriesController _chartSeriesController;


  @override
  void initState() {
    super.initState();
    if (widget.DataValue_Stream != null) {
      widget.DataValue_Stream.listen((data) {
        //print("dv : " + data.toString());
        //widget.COG_Value = (data == null || data == 0) ? 0.0 : data * (180 / pi);


    //   try{
    //     var ts = data['timestamp'];

    //     print(ts);

    //     print(DateTime.parse('2018-09-07T17:29:12+02:00'));

    //     var date = DateTime.parse(ts);
    //    if(date.isUtc){
    //      //decode time
    //      print(date.microsecondsSinceEpoch.toString());

    //    }


    //   }catch(e){
    //     print("[DateValueAxisChart] initState : " + e.toString());
    //   }

      }).canceledBy(this);
    }
  }





  @override
  void dispose() {
    timer?.cancel();
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
    return  GestureDetector(
        onTap: () {
          //notifyParent(text, icon);
        },
      child: StreamBuilder(
        stream: null,
        builder: (context, snapshot) {
          return SfCartesianChart(
                 // isTransposed: true,
                  plotAreaBorderWidth: 0,
                  primaryXAxis: NumericAxis(majorGridLines: MajorGridLines(width: 0)),

                  primaryYAxis: NumericAxis(
                      axisLine: AxisLine(width: 0),
                      majorTickLines: MajorTickLines(size: 0)),
                  series: <LineSeries<_BasicChartCoords, int>>[
                    LineSeries<_BasicChartCoords, int>(
                      onRendererCreated: (ChartSeriesController controller) {
                        _chartSeriesController = controller;
                      },
                      dataSource: chartData,
                      color: const Color.fromRGBO(192, 108, 132, 1),
                      xValueMapper: (_BasicChartCoords sales, _) => sales.x,
                      yValueMapper: (_BasicChartCoords sales, _) => sales.y,
                      animationDuration: 0,
                    )
                  ]

          );
        }
      ),
    );
  }









  ///Continously updating the data source based on timer
  void _updateDataSource(Timer timer) {
    if (true) {
      chartData.add(_BasicChartCoords(count, _getRandomInt(10, 100) + .0));
      if (chartData.length == 20) {
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
      count = count + 1;
    }
  }

  ///Get the random data
  int _getRandomInt(int min, int max) {
    final Random _random = Random();
    return min + _random.nextInt(max - min);
  }
}

/// Private calss for storing the chart series data points.
class _BasicChartCoords {
  _BasicChartCoords(this.x, this.y);
  final int x;
  final double y;
}

class _DateValueChartCoords {
  _DateValueChartCoords(this.x, this.y);
  final int x;
  final double y;
}

