import 'package:hive/hive.dart';
import 'package:nautica/Configuration.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nautica/models/database/models.dart';
import 'package:nautica/widgets/monitor/MonitorDrag.dart';
import 'package:nautica/widgets/monitor/MonitorGrid.dart';
import 'package:nautica/widgets/monitor/SubscriptionsGrid.dart';
import 'package:nautica/widgets/monitor/map/RealTimeMap.dart';
import 'package:websocket_manager/websocket_manager.dart';

import 'package:nautica/network/SignalKClient.dart';
import 'package:nautica/network/StreamSubscriber.dart';

import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';

class ModalFit extends StatelessWidget {
  const ModalFit({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('Edit'),
            leading: Icon(Icons.edit),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: Text('Copy'),
            leading: Icon(Icons.content_copy),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: Text('Cut'),
            leading: Icon(Icons.content_cut),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: Text('Move'),
            leading: Icon(Icons.folder_open),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: Text('Delete'),
            leading: Icon(Icons.delete),
            onTap: () => Navigator.of(context).pop(),
          )
        ],
      ),
    ));
  }
}

/// Home page of the sample browser for both mobile and web
class DashBoard extends StatefulWidget {
  /// creates the home page layout
  const DashBoard();

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  BaseModel themeModel;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController controller = ScrollController();

  SignalKClient signalK;
  WebsocketManager socket;
  StreamSubscriber SKFlow;
  Authentication loginData;

  String signalKServerAddress;
  int signalKServerPort;
  int currentGridIndex;

  String currentViewState = "monitors";
  String currentVessel;

  List<String> vesselsList;
  Map vesselsDataTable;

  bool gridSelectorLoaded = false;
  bool sectionLoaded = false;
  bool haveGridChanges = false;

  bool editingMode = false;

  Map<int, String> gridsList = {1: "Nautica"};

  UniqueKey MonitorDragKey;

  //connect to db

  // NauticaDB db;

  void _setViewState(String state) {
    if (mounted)
      setState(() {
        currentViewState = state;
      });
  }

  void _setCurrentVessel(String vessel) {
    if (mounted)
      setState(() {
        currentVessel = vessel;
        // currentViewState = "monitors";
      });
  }

  Widget _getCurrentView() {
    switch (currentViewState) {
      case "blank":
        return new Text("blank");
        break;

      case "real_time_map":
        return new MapSample(key: UniqueKey(), StreamObject: this.SKFlow, currentVessel: currentVessel);
        break;

      case "subscriptions":
        return new SubscriptionsGrid(key: UniqueKey(), StreamObject: this.SKFlow, currentVessel: currentVessel, vesselsDataTable: vesselsDataTable);
        break;

      case "monitors_r":
        return new MonitorGrid(
          key: UniqueKey(),
          StreamObject: this.SKFlow,
          currentVessel: currentVessel,
        );

        break;

      case "monitors":
      default:
        return new MonitorDrag(
            key: MonitorDragKey,
            StreamObject: this.SKFlow,
            currentVessel: currentVessel,
            vesselsDataTable: vesselsDataTable,
            isEditingMode:editingMode,
            onGridStatusChangeCallback: (vessel, gridId, hasChanged) async {
              //print("I'M PARENT -> ${vessel} ,${gridId} ,${hasChanged} ");
              haveGridChanges = hasChanged;
            },
            onGridListChangedCallback: () async {
              await _reloadGridList();
            },
            freezeInputsCallback: () async {
              showSaveAlertDialog();
            });
        break;
    }
  }

  Future<void> _reloadGridList() async {
    if (mounted)
      setState(() {
        gridSelectorLoaded = false;
      });

    await Hive.openBox("settings").then((settings) async {
      var gridIndex = settings.get("current_grid_index") ?? 1; //remember for future updates
      await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) {
        var allGrids = grid.values;
        if (allGrids != null) {
          gridsList = {};
          allGrids.forEach((element) {
            if (element.id != 2) gridsList[element.id] = element.name;
          });

          if (mounted)
            setState(() {
              currentGridIndex = gridIndex;
              gridSelectorLoaded = true;
            });
        }
      });
    });
  }

  @override
  void initState() {
    themeModel = BaseModel.instance;
    themeModel.addListener(_handleChange);

    super.initState();

    if (mounted)
      setState(() {
        sectionLoaded = false;
        gridSelectorLoaded = false;
        if (currentViewState == "monitors") {
          MonitorDragKey = UniqueKey();
        }
      });

    Hive.openBox("settings").then((settings) {
      signalKServerAddress = settings.get("signalk_address") ?? NAUTICA['signalK']['connection']['address'];
      signalKServerPort = settings.get("signalk_port") ?? NAUTICA['signalK']['connection']['port'];
      var gridIndex = settings.get("current_grid_index") ?? 1; //remember for future updates
      print("OPENING GRID -> " + gridIndex.toString());

      //load all grid id=>name

      Hive.openBox<GridThemeRecord>("grid_schema").then((grid) {
        var allGrids = grid.values;
        if (allGrids != null) {
          gridsList = {};
          allGrids.forEach((element) {
            if (element.id != 2) gridsList[element.id] = element.name;
          });

          print("FIRST LOADED GRIDS : $gridsList");
        }

        print("INIT ONCE!");

        signalK = SignalKClient(signalKServerAddress, signalKServerPort, loginData);
        SKFlow = StreamSubscriber(signalK);

        signalK.loadSignalKData().then((x) {
          SKFlow.startListening().then((isListening) {
            print("we are listening!");
            vesselsList = signalK.getVessels();
            vesselsDataTable = signalK.getPaths();

            if (mounted)
              setState(() {
                // The listenable's state was changed already.
                currentGridIndex = gridIndex;
                currentVessel = (vesselsList[0] != null) ? vesselsList[0] : null;
                sectionLoaded = true;
                gridSelectorLoaded = true;
              });
          }).catchError((Object onError) {
            print('[main] Unable to stream -- on error : $onError');
            cleanPrefsAndGoToSetup().then((value) => goToSetup());
          });
        }).catchError((Object onError) {
          print('[main] Unable to connect -- on error : $onError');
          cleanPrefsAndGoToSetup().then((value) => goToSetup());
        });
      });
    });
  }

  Future<void> cleanPrefsAndGoToSetup() async {
    return await Hive.openBox("settings").then((settings) async {
      await settings.put("first_setup_done", false);
    });
  }

  Future<void> _changeSelectedGrid(int themeId) async {
    print("SAVING AS DEFAULT GRID -> " + themeId.toString());
    return await Hive.openBox("settings").then((settings) async {
      await settings.put("current_grid_index", themeId);
    });
  }

  void goToSplashScreen() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/');
  }

  void goToSetup() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/');
  }

  @override
  void dispose() {
    if (signalK != null) signalK.WSdisconnect();
    sectionLoaded = false;
    super.dispose();
  }

  ///Notify the framework by calling this method
  void _handleChange() {
    if (mounted)
      setState(() {
        // The listenable's state was changed already.
      });
  }


  Future<void> _persistentSaveCurrentGridChanges() async {
    if(mounted) setState(() {
      sectionLoaded = false;
    });
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      var tempTheme = grid.get(2);
      if(tempTheme != null) {
        GridThemeRecord updatedThemeRecord = GridThemeRecord(id: currentGridIndex, name: gridsList[currentGridIndex], schema: tempTheme.schema);
        await grid.put(updatedThemeRecord.id, updatedThemeRecord).then((value) async {
          await grid.close();
          if (mounted) setState(() {
            sectionLoaded = true;
          });
          haveGridChanges = false;
          MonitorDragKey = UniqueKey();
          _setViewState("monitors");
        });
      }
    });
  }


  Future<void> _persistentDeleteCurrentGridChanges() async {

    if(mounted) setState(() {
      sectionLoaded = false;
    });
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      var tempTheme = grid.get(currentGridIndex);
      if(tempTheme != null) {
        GridThemeRecord updatedThemeRecord = GridThemeRecord(id: 2, name: gridsList[currentGridIndex], schema: tempTheme.schema);
        await grid.put(updatedThemeRecord.id, updatedThemeRecord).then((value) async {
          await grid.close();
          if (mounted) setState(() {
            sectionLoaded = true;
          });
          haveGridChanges = false;
          MonitorDragKey = UniqueKey();
          _setViewState("monitors");
        });
      }
    });



  }


  @override
  Widget build(BuildContext context) {

    final bool isMaxxSize = MediaQuery.of(context).size.width >= 1000;
    final BaseModel model = themeModel;
    model.isMobileResolution = (MediaQuery.of(context).size.width) < 768;

    return !sectionLoaded
        ? getSpinnerPage(model)
        : FutureBuilder(builder: (context, snapshot) {
            return Container(
              child: SafeArea(
                  child: Scaffold(
                      // bottomNavigationBar: getFooter(context, model),
                      key: scaffoldKey,
                      backgroundColor: model.webBackgroundColor,
                      endDrawer: showWebThemeSettings(model),
                      resizeToAvoidBottomInset: false,
                      appBar: PreferredSize(
                          preferredSize: const Size.fromHeight(85.0),
                          child: AppBar(
                            leading: Container(),
                            elevation: 0.0,
                            backgroundColor: model.paletteColor,
                            flexibleSpace: Row(
                              children: [
                                Expanded(
                                  flex:2,
                                  child: FittedBox(
                                      fit:BoxFit.contain,
                                    child: Container(
                                        transform: Matrix4.translationValues(0, 4, 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(24, 10, 0, 0),
                                              child: const Text('Nautica ', style: TextStyle(color: Colors.white, fontSize: 28, letterSpacing: 0.53, fontFamily: 'Roboto-Bold')),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
                                                child: Text('Open Source Marine Electronics',
                                                    style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Roboto-Regular', letterSpacing: 0.26, fontWeight: FontWeight.normal))),
                                            const Padding(
                                              padding: EdgeInsets.only(top: 15),
                                            ),
                                          ],
                                        )),
                                  ),
                                ),

                                Expanded(
                                  flex:5,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom:8.0,right:5,left:15),
                                    child: Container(
                                        color:Colors.transparent,
                                          transform: Matrix4.translationValues(0, 4, 0),
                                          child: Column(
                                            children: [


                                              Expanded(//I row
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: <Widget>[

                                                    const Padding(
                                                      padding: EdgeInsets.only(left: 24, top:10),
                                                    ),

                                                    Expanded(
                                                      child: Align(
                                                        alignment: Alignment.centerRight,
                                                        child: FittedBox(fit:BoxFit.fitHeight, child :

                                                        (currentGridIndex != null)
                                                          ? (!gridSelectorLoaded)
                                                          ? CupertinoActivityIndicator()
                                                          : SizedBox(
                                                          child: DropdownButton<int>(
                                                              value: currentGridIndex,
                                                              icon: const Icon(Icons.arrow_downward),
                                                              iconSize: 24,
                                                              elevation: 16,
                                                              style: const TextStyle(color: Colors.white),
                                                              underline: Container(
                                                                height: 0,
                                                                color: model.splashScreenBackground,
                                                              ),
                                                              onChanged: (int _selectedGrid) async {
                                                                print("you chose : " + _selectedGrid.toString());

                                                                if (_selectedGrid != currentGridIndex) {
                                                                  //check if changes are made, if yes alert

                                                                  if (haveGridChanges) {
                                                                    showSaveAlertDialog();
                                                                    return null;
                                                                  } else {
                                                                    await _changeSelectedGrid(_selectedGrid).then((value) {
                                                                      //update view
                                                                      setState(() {
                                                                        currentGridIndex = _selectedGrid;
                                                                      });
                                                                      if (currentViewState == "monitors") {
                                                                        if (mounted)
                                                                          setState(() {
                                                                            MonitorDragKey = UniqueKey();
                                                                          });
                                                                      }

                                                                      _setViewState("monitors");
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                              dropdownColor: Colors.black,
                                                              items: gridsList.entries.map<DropdownMenuItem<int>>((g) {
                                                                return DropdownMenuItem<int>(child: Text(g.value), value: g.key);
                                                              }).toList()))
                                                          : Container()
                                                        ),
                                                      )),




                                                    FittedBox(fit:BoxFit.fitHeight, child: showEditGridSwitcher()),

                                                    FittedBox(fit:BoxFit.fitHeight, child: showMonitorPageSwitcher()),
                                                    FittedBox(fit:BoxFit.fitHeight, child: showThemeSwitcher(themeModel)),





                                                    const Padding(
                                                      padding: EdgeInsets.only(right: 15),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  children: <Widget>[

                                                    const Padding(
                                                      padding: EdgeInsets.only(left: 24, top:10),
                                                    ),

                                                    Expanded(
                                                        child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: FittedBox(fit:BoxFit.fitHeight, child :
                                                            (currentVessel != null)
                                                                ?  SizedBox(
                                                              child: DropdownButton<String>(
                                                                value: currentVessel,
                                                                icon: const Icon(Icons.arrow_downward),
                                                                iconSize: 24,
                                                                elevation: 16,
                                                                style: const TextStyle(color: Colors.white),
                                                                underline: Container(
                                                                  height: 0,
                                                                  color: model.splashScreenBackground,
                                                                ),
                                                                onChanged: (String vessel) {
                                                                  if (haveGridChanges) {
                                                                    showSaveAlertDialog();
                                                                    return null;
                                                                  } else {
                                                                    if (currentViewState == "monitors") {
                                                                      if (mounted)
                                                                        setState(() {
                                                                          MonitorDragKey = UniqueKey();
                                                                        });
                                                                    }
                                                                    _setCurrentVessel(vessel);
                                                                  }
                                                                },
                                                                dropdownColor: Colors.black,
                                                                items: vesselsList.map<DropdownMenuItem<String>>((String value) {
                                                                  return DropdownMenuItem<String>(
                                                                    value: value,
                                                                    child: Text(value),//Text("Vessel #" + (vesselsList.indexOf(value) + 1).toString()),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            )
                                                                : Container()
                                                            ))),

                                                    // FittedBox(fit:BoxFit.fitHeight, child: showThemeSwitcher(themeModel)),
                                                    FittedBox(fit:BoxFit.fitHeight, child:
                                                    Padding(
                                                        padding: EdgeInsets.only(left:  0),
                                                        child: Container(
                                                       //   margin:EdgeInsets.only(bottom: 30,right:15),
                                                        //  padding: EdgeInsets.only(top: 10, right: 15),

                                                          child: IconButton(
                                                            icon: const Icon(Icons.help_center_outlined, color: Colors.white),
                                                            onPressed: () {
                                                              scaffoldKey.currentState.openEndDrawer();
                                                            },
                                                          ),
                                                        )),




                                                    ),


                                                    FittedBox(fit:BoxFit.fitHeight, child:
                                                    Padding(
                                                        padding: EdgeInsets.only(left:  0),
                                                        child: Container(
                                                          //   margin:EdgeInsets.only(bottom: 30,right:15),
                                                          //  padding: EdgeInsets.only(top: 10, right: 15),

                                                          child: IconButton(
                                                            icon: const Icon(Icons.exit_to_app, color: Colors.white),
                                                            onPressed: () {
                                                              cleanPrefsAndGoToSetup().then((value) => goToSetup());
                                                            },
                                                          ),
                                                        )),




                                                    ),








                                                    const Padding(
                                                      padding: EdgeInsets.only(right: 15),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          )),
                                  ),
                                ),
                              ],
                            ),
                            actions: (true) ? <Widget>[Column()] : <Widget>[
                              Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      //mainAxisSize: MainAxisSize.min,
                                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          color:Colors.red,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(top: 10, left:  0),
                                            child: Container(child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                              return Row(
                                                children: [
                                                  (currentVessel != null)
                                                      ? SizedBox(
                                                          child: DropdownButton<String>(
                                                          value: currentVessel,
                                                          icon: const Icon(Icons.arrow_downward),
                                                          iconSize: 24,
                                                          elevation: 16,
                                                          style: const TextStyle(color: Colors.white),
                                                          underline: Container(
                                                            height: 0,
                                                            color: model.splashScreenBackground,
                                                          ),
                                                          onChanged: (String vessel) {
                                                            if (haveGridChanges) {
                                                              showSaveAlertDialog();
                                                              return null;
                                                            } else {
                                                              if (currentViewState == "monitors") {
                                                                if (mounted)
                                                                  setState(() {
                                                                    MonitorDragKey = UniqueKey();
                                                                  });
                                                              }
                                                              _setCurrentVessel(vessel);
                                                            }
                                                          },
                                                          dropdownColor: Colors.black,
                                                          items: vesselsList.map<DropdownMenuItem<String>>((String value) {
                                                            return DropdownMenuItem<String>(
                                                              value: value,
                                                              child: Text("Vessel #" + (vesselsList.indexOf(value) + 1).toString()),
                                                            );
                                                          }).toList(),
                                                        ))
                                                      : Container(),

                                                  Padding(padding: EdgeInsets.only(left: 8)),

                                                  (currentGridIndex != null)
                                                      ? (!gridSelectorLoaded)
                                                          ? CupertinoActivityIndicator()
                                                          : SizedBox(
                                                              child: DropdownButton<int>(
                                                                  value: currentGridIndex,
                                                                  icon: const Icon(Icons.arrow_downward),
                                                                  iconSize: 24,
                                                                  elevation: 16,
                                                                  style: const TextStyle(color: Colors.white),
                                                                  underline: Container(
                                                                    height: 0,
                                                                    color: model.splashScreenBackground,
                                                                  ),
                                                                  onChanged: (int _selectedGrid) async {
                                                                    print("you chose : " + _selectedGrid.toString());

                                                                    if (_selectedGrid != currentGridIndex) {
                                                                      //check if changes are made, if yes alert

                                                                      if (haveGridChanges) {
                                                                        showSaveAlertDialog();
                                                                        return null;
                                                                      } else {
                                                                        await _changeSelectedGrid(_selectedGrid).then((value) {
                                                                          //update view
                                                                          setState(() {
                                                                            currentGridIndex = _selectedGrid;
                                                                          });
                                                                          if (currentViewState == "monitors") {
                                                                            if (mounted)
                                                                              setState(() {
                                                                                MonitorDragKey = UniqueKey();
                                                                              });
                                                                          }

                                                                          _setViewState("monitors");
                                                                        });
                                                                      }
                                                                    }
                                                                  },
                                                                  dropdownColor: Colors.black,
                                                                  items: gridsList.entries.map<DropdownMenuItem<int>>((g) {
                                                                    return DropdownMenuItem<int>(child: Text(g.value), value: g.key);
                                                                  }).toList()))
                                                      : Container(),

                                                  Padding(padding: EdgeInsets.only(left: 25)),
                                                  SizedBox(
                                                    child: MaterialButton(
                                                      onPressed: () {
                                                        _setViewState("monitors");
                                                      }, //_setViewState("subscriptions"),
                                                      child: Text("DASH"),
                                                      color: Colors.white,
                                                    ),
                                                  ),
//
                                                  Padding(padding: EdgeInsets.only(left: 25)),

                                                  SizedBox(
                                                    child: MaterialButton(
                                                      onPressed: () {
                                                        _setViewState("subscriptions");
                                                      }, //_setViewState("subscriptions"),
                                                      child: Text("SUB"),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.only(left: 25)),

                                                  SizedBox(
                                                    child: MaterialButton(
                                                      onPressed: () {
                                                        cleanPrefsAndGoToSetup().then((value) => goToSetup());
                                                      }, //_setViewState("subscriptions"),
                                                      child: Text("EXIT"),
                                                      color: Colors.white,
                                                    ),
                                                  ),

                                                  Padding(padding: EdgeInsets.only(left: 25)),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      showThemeSwitcher(themeModel),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),





                            //  Padding(
                            //      padding: EdgeInsets.only(left: isMaxxSize ? 15 : 0),
                            //      child: Container(
                            //        padding: MediaQuery.of(context).size.width < 500 ? const EdgeInsets.only(top: 20, left: 5) : EdgeInsets.only(top: 10, right: 15),
                            //        height: 60,
                            //        width: 60,
                            //        child: IconButton(
                            //          icon: const Icon(Icons.settings, color: Colors.white),
                            //          onPressed: () {
                            //            scaffoldKey.currentState.openEndDrawer();
                            //          },
                            //        ),
                            //      )),





                            ],
                          )),
                      body: _getCurrentView())),
            );
          });
  }

  void showSaveAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text("Warning!"),
        content: new Text("You cannot leave this grid before saving or discarding your updates."),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text("Save"),
            onPressed: () async{
              await _persistentSaveCurrentGridChanges();
              Navigator.pop(context);
            },

          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text("Undo changes"),
            onPressed: () async{
              await _persistentDeleteCurrentGridChanges();
              Navigator.pop(context);

            },

          ),
          CupertinoDialogAction(
              isDefaultAction: true,
              child: new Text("Go back"),
            onPressed: (){
                Navigator.pop(context);

            },
          )
        ],
      ),
    );
  }



  Widget showEditGridSwitcher() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      final Color _textColor = themeModel.themeData.brightness == Brightness.light
          ? const Color.fromRGBO(84, 84, 84, 1)
          : const Color.fromRGBO(218, 218, 218, 1);
      return Column(children: <Widget>[
        SizedBox(
          height:45,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: StatefulBuilder(builder:
                  (BuildContext context, StateSetter setState) {
                return CupertinoSegmentedControl<int>(
                  children: <int, Widget>{
                    0: Container(
                        padding :  const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: Icon(Icons.remove_red_eye, color: !editingMode
                            ? Colors.white
                            : _textColor)),
                    1: Container(
                        padding :  const EdgeInsets.all(5),

                        alignment: Alignment.center,
                        child: Icon(Icons.edit, color: editingMode
                            ? Colors.white
                            : _textColor))
                  },
                  padding: const EdgeInsets.all(5),
                  unselectedColor: Colors.transparent,
                  selectedColor: themeModel.paletteColor,
                  pressedColor: themeModel.paletteColor,
                  borderColor: Colors.white,
                  groupValue:  editingMode ? 1 : 0,
                  onValueChanged: (int value) {
                    if (value == 0 && haveGridChanges) {
                      showSaveAlertDialog();
                      return null;
                    }


                    if(mounted){
  setState((){
    editingMode = value == 0 ? false : true;
  });
}

print("CHANGE EDIT");
MonitorDragKey = UniqueKey();
_setViewState("monitors");

                  },
                );
              })),
        )
      ]);
    });
  }


  Widget showMonitorPageSwitcher() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      final Color _textColor = themeModel.themeData.brightness == Brightness.light
          ? const Color.fromRGBO(84, 84, 84, 1)
          : const Color.fromRGBO(218, 218, 218, 1);
      return Column(children: <Widget>[
        SizedBox(
          height:45,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: StatefulBuilder(builder:
                  (BuildContext context, StateSetter setState) {
                return CupertinoSegmentedControl<int>(
                  children: <int, Widget>{
                    0: Container(
                        padding :  const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child:  Icon(Icons.grid_on, color: currentViewState == "monitors"
                            ? Colors.white
                            : _textColor) ),
                    1: Container(
                        padding :  const EdgeInsets.all(5),
                        alignment: Alignment.center,
                child:  Icon(Icons.stream, color: currentViewState != "monitors"
                ? Colors.white
                    : _textColor) )
                  },
                  padding: const EdgeInsets.all(5),
                  unselectedColor: Colors.transparent,
                  selectedColor: themeModel.paletteColor,
                  pressedColor: themeModel.paletteColor,
                  borderColor: Colors.white,
                  groupValue:  currentViewState == "monitors" ? 0 : 1,
                  onValueChanged: (int value) {

                  //  if(mounted){
                  //    setState((){
                  //      currentViewState = ;
                  //    });
                  //  }

                    if (value == 1 && haveGridChanges) {
                      showSaveAlertDialog();
                      return null;
                    }

                    _setViewState(value == 0 ? "monitors" : "subscriptions");

                  },
                );
              })),
        )
      ]);
    });
  }


  Widget getSpinnerPage(BaseModel model) {
    return Container(
      child: SafeArea(
        child: Scaffold(
            // bottomNavigationBar: getFooter(context, model),
            key: scaffoldKey,
            backgroundColor: model.webBackgroundColor,
            endDrawer: showWebThemeSettings(model),
            resizeToAvoidBottomInset: false,
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(90.0),
                child: AppBar(
                  leading: Container(),
                  elevation: 0.0,
                  backgroundColor: model.paletteColor,
                  flexibleSpace: Container(
                      transform: Matrix4.translationValues(0, 4, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 10, 0, 0),
                            child: const Text('Nautica ', style: TextStyle(color: Colors.white, fontSize: 28, letterSpacing: 0.53, fontFamily: 'Roboto-Bold')),
                          ),
                          const Padding(
                              padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
                              child: Text('Open Source Marine Electronics',
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Roboto-Regular', letterSpacing: 0.26, fontWeight: FontWeight.normal))),
                          const Padding(
                            padding: EdgeInsets.only(top: 15),
                          ),
                          Container(
                              alignment: Alignment.bottomCenter,
                              width: double.infinity,
                              height: kIsWeb ? 16 : 14,
                              decoration: BoxDecoration(
                                  color: model.webBackgroundColor,
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: model.webBackgroundColor,
                                      offset: const Offset(0, 2.0),
                                      blurRadius: 0.25,
                                    )
                                  ]))
                        ],
                      )),
                  actions: <Widget>[
                    Container(),
                  ],
                )),
            body: model.getLoadingPage()),
      ),
    );
  }

  /// get scrollable widget to getting stickable view
  Widget _getScrollableWidget(BaseModel model) {
    return Container(
        color: model.paletteColor,
        child: GlowingOverscrollIndicator(
            color: model.paletteColor,
            axisDirection: AxisDirection.down,
            child: CustomScrollView(
              controller: controller,
              physics: const ClampingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Text('Nautica', style: TextStyle(color: Colors.white, fontSize: 25, letterSpacing: 0.53, fontFamily: 'HeeboBold', fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 0, 0),
                      child: Text('Fast . Fluid . Flexible',
                          style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 0.26, fontFamily: 'HeeboBold', fontWeight: FontWeight.normal)),
                    )
                  ],
                )),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PersistentHeaderDelegate(model),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    Container(color: model.webBackgroundColor, child: _getCurrentView()),
                  ]),
                )
              ],
            )));
  }

  /// Add the palette colors

}

/// Search bar, rounded corner
class _PersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PersistentHeaderDelegate(BaseModel sampleModel) {
    _themeModel = sampleModel;
  }

  BaseModel _themeModel;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 90,
      child: Container(
          color: _themeModel.paletteColor,
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                height: 70,
                child: Text("search"),
              ),
              Container(
                  height: 20,
                  decoration: BoxDecoration(
                      color: _themeModel.webBackgroundColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: _themeModel.webBackgroundColor,
                          offset: const Offset(0, 2.0),
                          blurRadius: 0.25,
                        )
                      ])),
            ],
          )),
    );
  }

  @override
  double get maxExtent => 90;

  @override
  double get minExtent => 90;

  @override
  bool shouldRebuild(_PersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
