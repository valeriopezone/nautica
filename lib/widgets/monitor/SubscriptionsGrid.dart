import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:nautica/network/StreamSubscriber.dart';

import 'package:nautica/Configuration.dart';

class SubscriptionsGrid extends StatefulWidget {
  StreamSubscriber StreamObject = null;
  String currentVessel = "";
  Map vesselsDataTable;

  SubscriptionsGrid(
      {Key key,
      @required this.StreamObject,
      @required this.currentVessel,
      @required this.vesselsDataTable})
      : super(key: key) {}

  @override
  _SubscriptionsGridState createState() => _SubscriptionsGridState();
}

class _SubscriptionsGridState extends State<SubscriptionsGrid> {
  BaseModel model = BaseModel.instance;

  bool isLandscapeInMobileView = false;

  _RealTimeUpdateDataGridSource realTimeUpdateDataGridSource;

  bool isWebOrDesktop;

  @override
  void initState() {
    super.initState();



    isWebOrDesktop = (model.isWeb || model.isDesktop);
    realTimeUpdateDataGridSource = _RealTimeUpdateDataGridSource(
        isWebOrDesktop: isWebOrDesktop,
        StreamObject: widget.StreamObject,
        currentVessel: widget.currentVessel,
        vesselsDataTable: widget.vesselsDataTable);
  }

  @override
  void dispose() {
    super.dispose();
    realTimeUpdateDataGridSource.dispose();
  }

  SfDataGrid _buildDataGrid() {
    return SfDataGrid(
      source: realTimeUpdateDataGridSource,
      columnWidthMode: isWebOrDesktop || isLandscapeInMobileView
          ? ColumnWidthMode.fill
          : ColumnWidthMode.none,
      columns: <GridColumn>[
        GridTextColumn(
            columnName: 'path',
            width: (isWebOrDesktop && model.isMobileResolution)
                ? 150.0
                : double.nan,
            label: Container(
              alignment: Alignment.centerLeft,
              child: Text('Path'),
            )),
        GridTextColumn(
          columnName: 'value',
          width:
              (isWebOrDesktop && model.isMobileResolution) ? 150.0 : double.nan,
          label: Container(
            alignment: Alignment.centerLeft,
            child: Text(' Value'),
          ),
        ),
        GridTextColumn(
          width: (isWebOrDesktop && model.isMobileResolution) ? 250.0 : 230.0,
          columnName: 'unit',
          label: Container(
            alignment: Alignment.centerLeft,
            child: Text('Unit'),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isLandscapeInMobileView = !isWebOrDesktop &&
        MediaQuery.of(context).orientation == Orientation.landscape;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
        margin: EdgeInsets.only(left: 15.0, right : 15.0),
      child: _buildDataGrid(),
    ));
  }
}

class _PathRecord {
  _PathRecord(this.path, this.value, this.unit);

  String path;
  dynamic value;
  dynamic unit;
}

class _RealTimeUpdateDataGridSource extends DataGridSource
    with DisposableWidget {
  _RealTimeUpdateDataGridSource(
      {@required this.isWebOrDesktop,
      @required this.StreamObject,
      @required this.currentVessel,
      @required this.vesselsDataTable}) {
    records = getRecords();
    buildDataGridRows();
    print("START GRID LISTENING");

    mainStream =  _subscribeToAllStreams();
    if (mainStream != null) {
      mainStream.listen((data) {
        mainStreamResponse = data;
      }).canceledBy(this);
    }
  }

  @override
  void dispose() {
    print("GRID CANCEL GENERAL SUBSCRIPTION");
    cancelSubscriptions();
    super.dispose();
  }


  Stream<dynamic> _subscribeToAllStreams(){
    return StreamObject.subscribeEverything(currentVessel,Duration(microseconds: NAUTICA['configuration']['widget']['refreshRate'])).asBroadcastStream();
  }

  final bool isWebOrDesktop;
  StreamSubscriber StreamObject = null;
  String currentVessel = "";
  Map vesselsDataTable;
  Stream<dynamic> mainStream = null;
  dynamic mainStreamResponse = null;

  List<_PathRecord> records = [];
  List<DataGridRow> dataGridRows = [];

  List<_PathRecord> getRecords() {
    final List<_PathRecord> pathData = <_PathRecord>[];
    if (vesselsDataTable != null && vesselsDataTable[currentVessel] != null) {
      for (dynamic path in vesselsDataTable[currentVessel].keys) {
        pathData.add(_PathRecord(
            path.toString(),
            0,
            vesselsDataTable[currentVessel][path]['units'] != null
                ? vesselsDataTable[currentVessel][path]['units'].toString()
                : ""));
      }
    }
    return pathData;
  }

  void buildDataGridRows() {
    dataGridRows = records.map<DataGridRow>((dataGridRow) {
      return DataGridRow(cells: [
        DataGridCell(columnName: 'path', value: dataGridRow.path),
        DataGridCell(columnName: 'value', value: dataGridRow.value),
        DataGridCell(columnName: 'unit', value: dataGridRow.unit),
      ]);
    }).toList(growable: false);
  }

  Widget buildRecords(String path, dynamic value) {
    return StreamBuilder(
        stream: mainStream,
        builder: (context, snap) {
          return (snap.hasData && path.isNotEmpty && snap.data[path] != null)
              ? Text(snap.data[path].toString())
              : Text(value.toString());
        });
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      Container(
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[0].value.toString()),
      ),
      buildRecords(row.getCells()[0].value.toString(),
          row.getCells()[1].value.toString()),
      Container(
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[2].value.toString()),
      ),
    ]);
  }

  void updateDataSource({@required RowColumnIndex rowColumnIndex}) {
    notifyDataSourceListeners(rowColumnIndex: rowColumnIndex);
  }
}
