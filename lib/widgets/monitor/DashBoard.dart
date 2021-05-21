import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive/hive.dart';
import 'package:SKDashboard/models/database/models.dart';
import 'package:SKDashboard/network/StreamSubscriber.dart';
import 'package:SKDashboard/models/BaseModel.dart';
import 'package:SKDashboard/Configuration.dart';
import 'package:SKDashboard/widgets/form/GridImportForm.dart';
import 'package:SKDashboard/widgets/form/GridOptionsForm.dart';
import 'package:SKDashboard/widgets/form/WidgetCreationForm.dart';
import 'package:SKDashboard/widgets/reorderable/reorderable_wrap.dart';
import 'dart:convert' as convert;
import 'package:SKDashboard/widgets/Indicator.dart';

class DashBoard extends StatefulWidget {
  StreamSubscriber StreamObject;
  String currentVessel = "";
  bool isEditingMode = false;
  final Future<void> Function(String vessel, int gridId, bool hasChanged) onGridStatusChangeCallback;
  final Future<void> Function() onGridListChangedCallback;
  final Future<void> Function() freezeInputsCallback;

  dynamic vesselsDataTable = [];

  DashBoard(
      {Key key,
      @required this.StreamObject,
      @required this.currentVessel,
      @required this.isEditingMode,
      @required this.onGridStatusChangeCallback,
      @required this.onGridListChangedCallback,
      @required this.freezeInputsCallback,
      @required this.vesselsDataTable})
      : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  BaseModel model = BaseModel.instance;
  StreamSubscriber mainStreamHandle;
  String vessel;

  int currentGridIndex;
  bool isMainGridReady = false;
  bool haveErrorLoadingGrid = false;
  bool haveGridChanges = false;

  GridThemeRecord currentJSONGridTheme;
  GridThemeRecord temporaryJSONGridTheme;
  List<Widget> mainWidgetList = [];
  List<int> widgetPositions = [];
  dynamic mainLoadedWidgetList;

  String currentGridName = CONF['configuration']['design']['grid']['defaultGridName'];
  String currentAuthorName = CONF['configuration']['design']['grid']['defaultGridAuthorName'];
  String currentGridDescription = CONF['configuration']['design']['grid']['defaultGridDescription'];

  int numCols = CONF['configuration']['design']['grid']['numCols'];
  double baseHeight = CONF['configuration']['design']['grid']['baseHeight'];

  @override
  void dispose() {
    super.dispose();
  }

  void initState() {
    super.initState();
    vessel = widget.currentVessel;
    getMainGrid();
  }

  void _setHavingGridChanges() {
    if (widget.isEditingMode) {
      widget.onGridStatusChangeCallback(vessel, currentGridIndex, haveGridChanges).then((value) {});
    }
  }

  Future<void> _persistentDeleteCurrentGridChanges() async {
    if (mounted)
      setState(() {
        isMainGridReady = false;
      });
    return Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      GridThemeRecord updatedThemeRecord = GridThemeRecord(id: 2, name: "Temporary Grid", schema: currentJSONGridTheme.schema);
      await grid.put(updatedThemeRecord.id, updatedThemeRecord).then((value) async {
        return await grid.close().then((value) async {
          await getMainGrid();
          if (mounted)
            setState(() {
              haveGridChanges = false;
            });
          _setHavingGridChanges();
        });
      });
    });
  }

  Future<void> _persistentSaveCurrentGridChanges() async {
    if (mounted)
      setState(() {
        isMainGridReady = false;
      });
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      var tempTheme = grid.get(2) ?? GridThemeRecord(id: 2, name: currentJSONGridTheme.name, schema: currentJSONGridTheme.schema);
      GridThemeRecord updatedThemeRecord = GridThemeRecord(id: currentJSONGridTheme.id, name: currentJSONGridTheme.name, schema: tempTheme.schema);
      await grid.put(updatedThemeRecord.id, updatedThemeRecord).then((value) async {
        print("JSON : " + convert.jsonEncode(tempTheme.schema));
        await grid.close();
        await widget.onGridListChangedCallback();

        if (mounted)
          setState(() {
            isMainGridReady = true;
          });
        haveGridChanges = false;
        _setHavingGridChanges();
      });
    });
  }

  Future<void> _loadMainGrid({bool useTemp = false}) async {
    if (useTemp) return;
    return await Hive.openBox("settings").then((settings) async {
      currentGridIndex = settings.get("current_grid_index") ?? 1;

      return await settings.close().then((e) async {
        //get grid json
        return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
          currentJSONGridTheme = grid.get(currentGridIndex) ?? GridThemeRecord(id: 1, name: "Nautica", schema: convert.jsonDecode(mainJSONGridTheme));

          await grid.put(2, GridThemeRecord(id: 2, name: "Temporary Grid", schema: currentJSONGridTheme.schema)).then((value) {
            print("[_loadMainGrid] inserted in temp table");
          });

          //move current schema in temporary
          temporaryJSONGridTheme = grid.get(2) ?? GridThemeRecord(id: 2, name: "Temporary Grid", schema: convert.jsonDecode(mainJSONGridTheme)); // load temporary grid
          return await grid.close();
        });
      });
    });
  }

  Future<void> _temporarySaveGridState(oldIndex, newIndex) async {
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      var tempGrid = grid.get(2) ?? GridThemeRecord(id: 2, name: "Temporary Grid", schema: convert.jsonDecode(mainJSONGridTheme));

      try {
        var jsonTheme = (tempGrid.schema);
        if (jsonTheme != null) {
          if (jsonTheme['widgets'][oldIndex] != null && jsonTheme['widgets'][newIndex] != null) {
            var tmp = jsonTheme['widgets'][oldIndex];
            jsonTheme['widgets'][oldIndex] = jsonTheme['widgets'][newIndex];
            jsonTheme['widgets'][newIndex] = tmp;

            GridThemeRecord newTemporaryThemeRecord = GridThemeRecord(id: 2, name: "Temporary Grid", schema: (jsonTheme));
            await grid.put(newTemporaryThemeRecord.id, newTemporaryThemeRecord).then((value) {
              print("[_temporarySaveGridState] temporary grid UPDATED");
            });

            if (mounted)
              setState(() {
                mainLoadedWidgetList = jsonTheme['widgets'];
              });
            haveGridChanges = true;

            _setHavingGridChanges();
          }
        }
      } catch (e) {
        print("[_temporarySaveGridState] " + e.toString());
        return Future.error(e.toString());
      }

      if (mounted)
        setState(() {
          isMainGridReady = true;
          haveErrorLoadingGrid = false;
        });
      return await grid.close().then((value) async {
        //return await getMainGrid();
      });
    });
  }

  Future<void> _temporaryUpdateWidgetViewStatus(int cardId, int viewId) async {
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      var tempGrid = grid.get(2) ?? GridThemeRecord(id: 2, name: "Temporary Grid", schema: convert.jsonDecode(mainJSONGridTheme));
      try {
        var jsonTheme = (tempGrid.schema);
        if (jsonTheme != null) {
          if (jsonTheme['widgets'][cardId] != null && jsonTheme['widgets'][cardId]['elements'][viewId] != null) {
            jsonTheme['widgets'][cardId]['current'] = viewId;
            GridThemeRecord newTemporaryThemeRecord = GridThemeRecord(id: 2, name: "Temporary Grid", schema: (jsonTheme));

            await grid.put(newTemporaryThemeRecord.id, newTemporaryThemeRecord).then((value) {
              //print("temporary grid UPDATED set current = $viewId");
            });

            //encode and save
            if (mounted)
              setState(() {
                mainLoadedWidgetList = jsonTheme['widgets'];
                mainWidgetList[cardId] = Indicator(
                    //key:UniqueKey(),
                    model: model,
                    isEditingMode: widget.isEditingMode,
                    baseHeight: baseHeight,
                    numCols: numCols,
                    widgetData: mainLoadedWidgetList[cardId],
                    StreamObject: widget.StreamObject,
                    currentVessel: widget.currentVessel,
                    currentPosition: cardId,
                    currentWidgetIndex: viewId,
                    vesselsDataTable: widget.vesselsDataTable,
                    onCardStatusChangedCallback: (currentPosition, viewId) async {
                      await _temporaryUpdateWidgetViewStatus(currentPosition, viewId);
                    },
                    onGoingToEditCallback: (currentPosition, viewId) async {
                      await _showEditWidgetDialog(currentPosition);
                    },
                    onGoingToDeleteCallback: (currentPosition, viewId) async {
                      await _temporaryDeleteWidget(currentPosition);
                    });
                haveGridChanges = true;
              });
            _setHavingGridChanges();
          }
        }
      } catch (e) {
        print("[_temporaryUpdateWidgetViewStatus] " + e.toString());
        return Future.error(e.toString());
      }

      return await grid.close().then((value) async {
        // return await getMainGrid();
      });
    });
  }

  Future<void> _temporaryDeleteWidget(int widgetPosition) async {
    //remove from db
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      GridThemeRecord tempGrid = grid.get(2) ?? GridThemeRecord(id: 2, name: "Temporary Grid", schema: convert.jsonDecode(mainJSONGridTheme));
      GridThemeRecord newGrid = GridThemeRecord(id: 2, name: "Temporary Grid", schema: convert.jsonDecode(mainJSONGridTheme));
      newGrid.schema['name'] = tempGrid.schema['name'];
      newGrid.schema['description'] = tempGrid.schema['description'];
      newGrid.schema['author'] = tempGrid.schema['author'];
      newGrid.schema['numCols'] = tempGrid.schema['numCols'];
      newGrid.schema['baseHeight'] = tempGrid.schema['baseHeight'];
      try {
        //var jsonTheme = convert.jsonDecode(tempGrid.schema);
        dynamic jsonTheme = (tempGrid.schema);

        if (jsonTheme != null) {
          if (jsonTheme['widgets'][widgetPosition] != null) {
            newGrid.schema['widgets'] = [];

            int i = 0;
            for (dynamic element in jsonTheme['widgets']) {
              if (i == widgetPosition) {
                widgetPosition = -1;
              } else {
                newGrid.schema['widgets'].insert(i, element);
                i++;
              }
            }

            temporaryJSONGridTheme = newGrid;

            await grid.put(newGrid.id, newGrid).then((value) {
              haveGridChanges = true;

              if (mounted)
                setState(() {
                  mainLoadedWidgetList = newGrid.schema['widgets'];
                  //haveErrorLoadingGrid = false;
                });
              _setHavingGridChanges();

              try {
                //update all widgets in grid
                mainWidgetList.clear();
                widgetPositions.clear();
                //dynamic mainGridTheme = convert.jsonDecode(temporaryJSONGridTheme.schema);
                dynamic mainGridTheme = (temporaryJSONGridTheme.schema);
                try {
                  int i = 0;
                  mainLoadedWidgetList = mainGridTheme['widgets'];
                  for (dynamic widgets in mainLoadedWidgetList) {
                    //0..n widgets
                    try {
                      widgetPositions.add(i);
                    } catch (e) {
                      print("[_temporaryDeleteWidget] Error while reading main grid positions -> " + e.toString());
                    }
                    mainWidgetList.add(Indicator(
                        //key:UniqueKey(),
                        model: model,
                        isEditingMode: widget.isEditingMode,
                        baseHeight: baseHeight,
                        numCols: numCols,
                        widgetData: widgets,
                        StreamObject: widget.StreamObject,
                        currentVessel: widget.currentVessel,
                        currentPosition: i,
                        currentWidgetIndex: widgets['current'],
                        vesselsDataTable: widget.vesselsDataTable,
                        onCardStatusChangedCallback: (currentPosition, viewId) async {
                          await _temporaryUpdateWidgetViewStatus(currentPosition, viewId);
                        },
                        onGoingToEditCallback: (currentPosition, viewId) async {
                          await _showEditWidgetDialog(currentPosition);
                        },
                        onGoingToDeleteCallback: (currentPosition, viewId) async {
                          await _temporaryDeleteWidget(currentPosition);
                        }));
                    i++;
                  }

                  if (mounted)
                    setState(() {
                      // isMainGridReady = true;
                      // haveErrorLoadingGrid = false;
                    });
                } catch (e) {
                  print("err1 : " + e.toString());
                }
              } catch (e) {
                print("unable to decode json " + e.toString());
                if (mounted)
                  setState(() {
                    // isMainGridReady = false;
                    // haveErrorLoadingGrid = false;
                  });
              }
            });
          }
        }
      } catch (e) {
        print("[_temporaryDeleteWidget] " + e.toString());
        return Future.error(e.toString());
      }

      if (mounted)
        setState(() {
          isMainGridReady = true;
        });
      return await grid.close().then((value) async {
        //return await getMainGrid();
      });
    });
  }

  Future<bool> _temporarySaveNewWidget(dynamic widgetData) async {
    //remove from db
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      GridThemeRecord tempGrid = grid.get(2) ?? GridThemeRecord(id: 2, name: "Temporary Grid", schema: convert.jsonDecode(mainJSONGridTheme));
      GridThemeRecord newGrid = GridThemeRecord(id: 2, name: "Temporary Grid", schema: convert.jsonDecode(mainJSONGridTheme));

      newGrid.schema['name'] = tempGrid.schema['name'];
      newGrid.schema['description'] = tempGrid.schema['description'];
      newGrid.schema['author'] = tempGrid.schema['author'];
      newGrid.schema['numCols'] = tempGrid.schema['numCols'];
      newGrid.schema['baseHeight'] = tempGrid.schema['baseHeight'];

      try {
        dynamic jsonTheme = (tempGrid.schema);

        if (jsonTheme == null) return false;
        if (jsonTheme['widgets'] == null) return false;
        //newGrid.schema['widgets'] = [];
        newGrid.schema['widgets'] = [];
        int i = 0;
        for (dynamic element in jsonTheme['widgets']) {
          newGrid.schema['widgets'].insert(i, element);
          i++;
        }
        temporaryJSONGridTheme = newGrid;
        newGrid.schema['widgets'].insert(i, widgetData);

        return await grid.put(newGrid.id, newGrid).then((value) {
          print("temporary grid UPDATED");
          print("NEW SCHEMA : " + newGrid.schema['widgets'].toString());
          mainWidgetList.add(Indicator(
              //key:UniqueKey(),
              model: model,
              isEditingMode: widget.isEditingMode,
              baseHeight: baseHeight,
              numCols: numCols,
              widgetData: widgetData,
              StreamObject: widget.StreamObject,
              currentVessel: widget.currentVessel,
              currentPosition: i,
              currentWidgetIndex: widgetData['current'],
              vesselsDataTable: widget.vesselsDataTable,
              onCardStatusChangedCallback: (currentPosition, viewId) async {
                await _temporaryUpdateWidgetViewStatus(currentPosition, viewId);
              },
              onGoingToEditCallback: (currentPosition, viewId) async {
                await _showEditWidgetDialog(currentPosition);
              },
              onGoingToDeleteCallback: (currentPosition, viewId) async {
                await _temporaryDeleteWidget(currentPosition);
              }));

          if (mounted)
            setState(() {
              mainLoadedWidgetList = newGrid.schema['widgets'];
              haveGridChanges = true;
              isMainGridReady = true;
              //haveErrorLoadingGrid = false;
            });
          _setHavingGridChanges();
          return true;
        });
      } catch (e) {
        print("[_temporarySaveNewWidget] " + e.toString());
        return false;
      }
    });
  }

  Future<bool> _temporaryEditWidget(int positionId, dynamic widgetData) async {
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      GridThemeRecord tempGrid = grid.get(2) ?? GridThemeRecord(id: 2, name: "Temporary Grid", schema: convert.jsonDecode(mainJSONGridTheme));
      GridThemeRecord newGrid = GridThemeRecord(id: 2, name: tempGrid.name, schema: convert.jsonDecode(mainJSONGridTheme));

      newGrid.schema['name'] = tempGrid.schema['name'];
      newGrid.schema['description'] = tempGrid.schema['description'];
      newGrid.schema['author'] = tempGrid.schema['author'];
      newGrid.schema['numCols'] = tempGrid.schema['numCols'];
      newGrid.schema['baseHeight'] = tempGrid.schema['baseHeight'];

      try {
        dynamic jsonTheme = (tempGrid.schema);

        if (jsonTheme == null) return false;
        if (jsonTheme['widgets'] == null) return false;
        if (jsonTheme['widgets'][positionId] == null) return false;
        int i = 0;
        newGrid.schema['widgets'] = [];

        for (dynamic element in jsonTheme['widgets']) {
          if (i == positionId) {
            newGrid.schema['widgets'].insert(i, widgetData);
          } else {
            newGrid.schema['widgets'].insert(i, element);
          }
          i++;
        }
        temporaryJSONGridTheme = newGrid;
        return await grid.put(newGrid.id, newGrid).then((value) {
          mainWidgetList[positionId] = new Indicator(
              //key:UniqueKey(),
              model: model,
              isEditingMode: widget.isEditingMode,
              baseHeight: baseHeight,
              numCols: numCols,
              widgetData: widgetData,
              StreamObject: widget.StreamObject,
              currentVessel: widget.currentVessel,
              currentPosition: positionId,
              currentWidgetIndex: 0,
              //widgetData['current'],
              vesselsDataTable: widget.vesselsDataTable,
              onCardStatusChangedCallback: (currentPosition, viewId) async {
                await _temporaryUpdateWidgetViewStatus(currentPosition, viewId);
              },
              onGoingToEditCallback: (currentPosition, viewId) async {
                await _showEditWidgetDialog(currentPosition);
              },
              onGoingToDeleteCallback: (currentPosition, viewId) async {
                await _temporaryDeleteWidget(currentPosition);
              });
          haveGridChanges = true;

          if (mounted)
            setState(() {
              mainLoadedWidgetList = newGrid.schema['widgets'];
              isMainGridReady = true;
              //haveErrorLoadingGrid = false;
            });
          _setHavingGridChanges();
          return true;
        });
      } catch (e) {
        print("[_temporaryEditWidget] " + e.toString());
        return false;
      }
    });
  }

  Future<bool> _persistentEditGridOptions(dynamic gridData) async {
    if (mounted)
      setState(() {
        isMainGridReady = false;
      });

    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      var tempTheme = grid.get(2) ?? GridThemeRecord(id: 2, name: currentJSONGridTheme.name, schema: currentJSONGridTheme.schema);
      GridThemeRecord updatedThemeRecord = GridThemeRecord(id: 2, name: currentJSONGridTheme.name, schema: tempTheme.schema);

      currentJSONGridTheme.name = gridData['name'];
      updatedThemeRecord.name = gridData['name'];
      updatedThemeRecord.schema['name'] = gridData['name'];
      updatedThemeRecord.schema['author'] = gridData['author'];
      updatedThemeRecord.schema['description'] = gridData['description'];
      updatedThemeRecord.schema['numCols'] = gridData['numCols'];
      updatedThemeRecord.schema['baseHeight'] = gridData['baseHeight'];

      temporaryJSONGridTheme.name = gridData['name'];
      temporaryJSONGridTheme.schema['name'] = gridData['name'];
      temporaryJSONGridTheme.schema['author'] = gridData['author'];
      temporaryJSONGridTheme.schema['description'] = gridData['description'];
      temporaryJSONGridTheme.schema['numCols'] = gridData['numCols'];
      temporaryJSONGridTheme.schema['baseHeight'] = gridData['baseHeight'];
      return await grid.put(2, updatedThemeRecord).then((value) async {
        await grid.close();
        haveGridChanges = true;

        if (mounted)
          setState(() {
            isMainGridReady = true;
          });
        _setHavingGridChanges();

        await getMainGrid(useTemp: true);

        return true;
      });
    }).onError((error, stackTrace) {
      print("[_persistentEditGridOptions] ERROR EDIT OPTIONS _> $error $stackTrace");
      return false;
    });
  }

  Future<bool> _insertNewGrid({String jsonGridData = null}) async {
    if (mounted)
      setState(() {
        isMainGridReady = false;
      });
    try {
      return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
        var c = grid.values.where((element) => element.id != 2).last;
        var newId = (c.id == 1) ? 3 : c.id + 1;
        dynamic schema = convert.jsonDecode((jsonGridData == null) ? genericEmptyGridTheme : jsonGridData);

        var themeRecord = new GridThemeRecord(id: newId, name: schema['name'], schema: schema);

        return await grid.put(themeRecord.id, themeRecord).then((value) async {
          await grid.close();

          return await Hive.openBox("settings").then((settings) async {
            return await settings.put("current_grid_index", newId).then((value) async {
              await settings.close();

              //notify dashboard -> reload available grids
              await widget.onGridListChangedCallback();

              await getMainGrid();

              return true;
            }).onError((error, stackTrace) {
              print("[_insertNewGrid] error : $error $stackTrace");

              if (mounted)
                setState(() {
                  isMainGridReady = false;
                });
            });
          }).onError((error, stackTrace) {
            print("[_insertNewGrid] error : $error $stackTrace");

            if (mounted)
              setState(() {
                isMainGridReady = false;
              });
          });
        }).onError((error, stackTrace) {
          print("[_insertNewGrid] error : $error $stackTrace");

          if (mounted)
            setState(() {
              isMainGridReady = false;
            });
        });
      }).onError((error, stackTrace) {
        print("[_insertNewGrid] error : $error $stackTrace");
        return false;
      });
    } catch (e, s) {
      print("[_insertNewGrid] error : $e $s");

      return false;
    }
  }

  Future<bool> _deleteGrid(int gridId) async {
    try {
      return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
        if (gridId <= 0 || grid.get(gridId) == null) return false;
        var grids = grid.values.where((element) => element.id != 2 && element.id != gridId);
        if (grids == null) return false;
        if (grids.length == 0) return false;
        int newCurrentGridId = grids.last.id;

        return await grid.delete(gridId).then((value) async {
          await grid.close();

          return await Hive.openBox("settings").then((settings) async {
            return await settings.put("current_grid_index", newCurrentGridId).then((value) async {
              await settings.close();

              //notify dashboard -> reload available grids
              await widget.onGridListChangedCallback();

              await getMainGrid();

              return true;
            }).onError((error, stackTrace) {
              print("[_deleteGrid] error :  $error $stackTrace");

              if (mounted)
                setState(() {
                  isMainGridReady = false;
                });
            });
          }).onError((error, stackTrace) {
            print("[_deleteGrid] error :  $error $stackTrace");

            if (mounted)
              setState(() {
                isMainGridReady = false;
              });
          });
        }).onError((error, stackTrace) {
          print("[_deleteGrid] error :  $error $stackTrace");

          if (mounted)
            setState(() {
              isMainGridReady = false;
            });
        });
      }).onError((error, stackTrace) {
        print("[_deleteGrid] error :  $error $stackTrace");
        return false;
      });
    } catch (e, s) {
      print("[_deleteGrid] error :  $e $s");

      return false;
    }
  }

  Future<void> _showEditWidgetDialog(int widgetPosition) {
    showDialog(
      context: context,
      builder: (_) => Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
        WidgetCreationForm(
            key: UniqueKey(),
            baseHeight: baseHeight,
            numCols: numCols,
            monitorContext: context,
            currentPositionId: widgetPosition,
            model: model,
            vesselsDataTable: widget.vesselsDataTable,
            mainLoadedWidgetList: mainLoadedWidgetList,
            onGoingToSaveWidgetCallback: (currentPosition, widgetData) async {
              return await _temporaryEditWidget(widgetPosition, widgetData);
            })
      ]),
    );
    //
  }

  Future<void> _showAddWidgetDialog() {
    //show popup(widgetPosition)
    showDialog(
      context: context,
      builder: (_) => Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
        WidgetCreationForm(
            key: UniqueKey(),
            baseHeight: baseHeight,
            numCols: numCols,
            monitorContext: context,
            model: model,
            vesselsDataTable: widget.vesselsDataTable,
            mainLoadedWidgetList: mainLoadedWidgetList,
            onGoingToSaveWidgetCallback: (currentPosition, widgetData) async {
              return await _temporarySaveNewWidget(widgetData);
            })
      ]),
    );
    //
  }

  Future<void> getMainGrid({bool useTemp = false}) async {
    if (mounted)
      setState(() {
        isMainGridReady = false;
        haveErrorLoadingGrid = false;
        mainWidgetList.clear();
        widgetPositions.clear();
      });

    await _loadMainGrid(useTemp: useTemp).then((value) async {
      try {
        dynamic mainGridTheme = (temporaryJSONGridTheme.schema);

        try {
          var bh = temporaryJSONGridTheme.schema['baseHeight'] ?? CONF['configuration']['design']['grid']['baseHeight'];
          var nc = temporaryJSONGridTheme.schema['numCols'] ?? CONF['configuration']['design']['grid']['numCols'];
          baseHeight = (bh is double) ? bh : double.parse(bh.toString());
          numCols = (nc is int) ? nc : int.parse(nc.toString());
          currentGridName = temporaryJSONGridTheme.schema['name'] ?? currentGridName;
          currentAuthorName = temporaryJSONGridTheme.schema['author'] ?? currentAuthorName;
          currentGridDescription = temporaryJSONGridTheme.schema['description'] ?? currentGridDescription;
        } catch (e) {
          print("[getMainGrid] error while loading card sizes" + e.toString());
        }

        try {
          int i = 0;
          mainLoadedWidgetList = mainGridTheme['widgets'];
          for (dynamic widgets in mainLoadedWidgetList) {
            //0..n widgets
            try {
              widgetPositions.add(i);
            } catch (e) {
              print("Error while reading main grid positions -> " + e.toString());
            }
            mainWidgetList.add(Indicator(
                //key:UniqueKey(),
                model: model,
                isEditingMode: widget.isEditingMode,
                baseHeight: baseHeight,
                numCols: numCols,
                widgetData: widgets,
                StreamObject: widget.StreamObject,
                currentVessel: widget.currentVessel,
                currentPosition: i,
                currentWidgetIndex: widgets['current'],
                vesselsDataTable: widget.vesselsDataTable,
                onCardStatusChangedCallback: (currentPosition, viewId) async {
                  await _temporaryUpdateWidgetViewStatus(currentPosition, viewId);
                },
                onGoingToEditCallback: (currentPosition, viewId) async {
                  await _showEditWidgetDialog(currentPosition);
                },
                onGoingToDeleteCallback: (currentPosition, viewId) async {
                  await _temporaryDeleteWidget(currentPosition);
                }));
            i++;
          }

          if (mounted)
            setState(() {
              isMainGridReady = true;
              haveErrorLoadingGrid = false;
            });
        } catch (e) {
          print("[_loadMainGrid] error : $e");
        }
      } catch (e) {
        print("[_loadMainGrid] unable to decode json " + e.toString());
        if (mounted)
          setState(() {
            isMainGridReady = false;
            haveErrorLoadingGrid = false;
          });
      }
    });
  }

  void _showGridOptionsPopup() async {
    await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      var nGrid = grid.values.where((element) => element.id != 2).length;
      showDialog(
        context: context,
        builder: (_) => Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
          GridOptionsForm(
              key: UniqueKey(),
              isLastGrid: nGrid > 1 ? false : true,
              gridId: currentJSONGridTheme.id,
              baseHeight: baseHeight,
              numCols: numCols,
              currentGridName: currentGridName,
              currentAuthorName: currentAuthorName,
              currentGridDescription: currentGridDescription,
              monitorContext: context,
              model: model,
              onGoingToSaveOptionsCallback: (dynamic gridData) async {
                return await _persistentEditGridOptions(gridData);
              },
              onGoingToDeleteGridCallback: (int gridId) async {
                return await _deleteGrid(gridId);
              })
        ]),
      );
    });
    //
  }

  Future<void> _showImportGridPopup() async {
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      GridThemeRecord tempGrid = grid.get(2) ?? GridThemeRecord(id: 2, name: "Nautica", schema: convert.jsonDecode(mainJSONGridTheme));
      String schema = convert.jsonEncode(tempGrid.schema);
      await grid.close();
      showDialog(
        context: context,
        builder: (_) => Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
          GridImportForm(
              key: UniqueKey(),
              monitorContext: context,
              model: model,
              jsonSchema: schema,
              onGoingToImportWidgetCallback: (String jsonGrid) async {
                return await _insertNewGrid(jsonGridData: jsonGrid);
              })
        ]),
      );
    });

    //
  }

  @override
  Widget build(BuildContext context) {
    List<StaggeredTile> tileInfo = [];
    if (mainLoadedWidgetList != null) {
      try {
        for (dynamic card in mainLoadedWidgetList) {
          var wWidth = (!(card['width'] is int))
              ? 1
              : (card['width'] > 0)
                  ? card['width']
                  : 1;
          var wHeight = (!(card['height'] is int))
              ? 1
              : (card['height'] > 0)
                  ? card['height']
                  : 1;

          tileInfo.add(StaggeredTile.extent(wWidth, wHeight * baseHeight));
        }
      } catch (e, s) {
        print("Exception in monitorDrag build -> $e $s");
      }
    }
    return Scaffold(
      backgroundColor: model.webBackgroundColor,
      floatingActionButton: widget.isEditingMode
          ? Stack(
              children: [_buildWidgetMenuDial(), _showStackedSaveButton(), _showStackedUndoButton()],
            )
          : Text(""),
      body: Stack(
        children: [
          (!isMainGridReady)
              ? model.getLoadingPage()
              : FutureBuilder(builder: (context, snapshot) {
                  return !isMainGridReady
                      ? (haveErrorLoadingGrid ? model.getErrorPage("Unable to load monitor", "check JSON status") : Text(""))
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ((!widget.isEditingMode)
                              ? StaggeredGridView.count(
                                  crossAxisCount: numCols,
                                  staggeredTiles: tileInfo,
                                  children: mainWidgetList.map((singleCard) {
                                    return singleCard;
                                  }).toList(),
                                  mainAxisSpacing: 0.0,
                                  crossAxisSpacing: 0.0,
                                )
                              : ReorderableWrap(
                                  numCols: numCols,
                                  tileInfo: tileInfo,
                                  onReorder: (oldIndex, newIndex) {
                                    if (oldIndex == newIndex) return; //if same object no action

                                    if (mounted)
                                      setState(() {
                                        mainWidgetList[oldIndex] = Indicator(
                                            //key:UniqueKey(),
                                            model: model,
                                            isEditingMode: widget.isEditingMode,
                                            baseHeight: baseHeight,
                                            numCols: numCols,
                                            widgetData: mainLoadedWidgetList[newIndex],
                                            StreamObject: widget.StreamObject,
                                            currentVessel: widget.currentVessel,
                                            currentPosition: oldIndex,
                                            currentWidgetIndex: mainLoadedWidgetList[newIndex]['current'],
                                            vesselsDataTable: widget.vesselsDataTable,
                                            onCardStatusChangedCallback: (currentPosition, viewId) async {
                                              await _temporaryUpdateWidgetViewStatus(currentPosition, viewId);
                                            },
                                            onGoingToEditCallback: (currentPosition, viewId) async {
                                              await _showEditWidgetDialog(currentPosition);
                                            },
                                            onGoingToDeleteCallback: (currentPosition, viewId) async {
                                              await _temporaryDeleteWidget(currentPosition);
                                            });

                                        mainWidgetList[newIndex] = Indicator(
                                            //key:UniqueKey(),
                                            model: model,
                                            isEditingMode: widget.isEditingMode,
                                            baseHeight: baseHeight,
                                            numCols: numCols,
                                            widgetData: mainLoadedWidgetList[oldIndex],
                                            StreamObject: widget.StreamObject,
                                            currentVessel: widget.currentVessel,
                                            currentPosition: newIndex,
                                            currentWidgetIndex: mainLoadedWidgetList[newIndex]['current'],
                                            vesselsDataTable: widget.vesselsDataTable,
                                            onCardStatusChangedCallback: (currentPosition, viewId) async {
                                              await _temporaryUpdateWidgetViewStatus(currentPosition, viewId);
                                            },
                                            onGoingToEditCallback: (currentPosition, viewId) async {
                                              await _showEditWidgetDialog(currentPosition);
                                            },
                                            onGoingToDeleteCallback: (currentPosition, viewId) async {
                                              await _temporaryDeleteWidget(currentPosition);
                                            });

                                        _temporarySaveGridState(oldIndex, newIndex);
                                      });
                                  },
                                  children: mainWidgetList.map((singleCard) {
                                    return ReorderableWrapItem(key: ValueKey(singleCard), child: singleCard);
                                  }).toList(),
                                )),
                        );
                }),
        ],
      ),
    );
  }

  SpeedDial _buildWidgetMenuDial() {
    return SpeedDial(
      /// both default to 16
      marginEnd: 18,
      marginBottom: 20,
      icon: Icons.menu_rounded,
      activeIcon: Icons.menu_rounded,
      buttonSize: 56.0,
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.2,
     // onOpen: () => print('OPENING DIAL'),
     // onClose: () => print('DIAL CLOSED'),
      backgroundColor: model.formSectionLabelColor,
      foregroundColor: Colors.white,
      elevation: 8.0,
      children: [
        SpeedDialChild(
          child: Icon(Icons.widgets_outlined),
          foregroundColor: Colors.white,
          backgroundColor: model.paletteColor,
          label: 'Add widget',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () async {
            //save current space
            return await _showAddWidgetDialog();
          },
        ),
        SpeedDialChild(
            child: Icon(Icons.grid_on_rounded),
            foregroundColor: Colors.white,
            backgroundColor: model.paletteColor,
            label: 'New grid',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              (haveGridChanges) ? widget.freezeInputsCallback() : await _insertNewGrid();
            }),
        SpeedDialChild(
          child: Icon(Icons.import_export),
          foregroundColor: Colors.white,
          backgroundColor: model.paletteColor,
          label: 'Import/Export',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => (haveGridChanges) ? widget.freezeInputsCallback() : _showImportGridPopup(),
        ),
        SpeedDialChild(
            child: Icon(Icons.settings),
            foregroundColor: Colors.white,
            backgroundColor: model.paletteColor,
            label: 'Options',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              _showGridOptionsPopup();
            }),
      ],
    );
  }

  Widget _showStackedSaveButton() {
    return Positioned(
        bottom: 3,
        right: 70.0,
        child: Container(
            height: 57,
            width: 57,
            child: ElevatedButton(
              child: Icon(Icons.save_outlined),
              style: ElevatedButton.styleFrom(
                  elevation: 8.0,
                  primary: model.paletteColor,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  )),
              onPressed: () async {
                //save current space
                return await _persistentSaveCurrentGridChanges();
              },
            )));
  }

  Widget _showStackedUndoButton() {
    return Positioned(
        bottom: 3,
        right: 140.0,
        child: Container(
            height: 57,
            width: 57,
            child: ElevatedButton(
              child: Icon(Icons.undo_outlined),
              style: ElevatedButton.styleFrom(
                  elevation: 8.0,
                  primary: Colors.red,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  )),
              onPressed: () async {
                //save current space
                return await _persistentDeleteCurrentGridChanges();
              },
            )));
  }
}
