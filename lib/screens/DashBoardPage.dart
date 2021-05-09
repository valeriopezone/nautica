import 'package:hive/hive.dart';
import 'package:SKDashboard/Configuration.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:SKDashboard/models/database/models.dart';
import 'package:SKDashboard/widgets/monitor/MonitorDrag.dart';
import 'package:SKDashboard/widgets/monitor/SubscriptionsGrid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:websocket_manager/websocket_manager.dart';

import 'package:SKDashboard/network/SignalKClient.dart';
import 'package:SKDashboard/network/StreamSubscriber.dart';

import 'package:SKDashboard/models/BaseModel.dart';
import 'package:SKDashboard/models/Helper.dart';

class DashBoard extends StatefulWidget {
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

      case "subscriptions":
        return new SubscriptionsGrid(key: UniqueKey(), StreamObject: this.SKFlow, currentVessel: currentVessel, vesselsDataTable: vesselsDataTable);
        break;

      case "monitors":
      default:
        return new MonitorDrag(
            key: MonitorDragKey,
            StreamObject: this.SKFlow,
            currentVessel: currentVessel,
            vesselsDataTable: vesselsDataTable,
            isEditingMode: editingMode,
            onGridStatusChangeCallback: (vessel, gridId, hasChanged) async {
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
      signalKServerAddress = settings.get("signalk_address") ?? CONF['signalK']['connection']['address'];
      signalKServerPort = settings.get("signalk_port") ?? CONF['signalK']['connection']['port'];
      var gridIndex = settings.get("current_grid_index") ?? 1; //remember for future updates

      Hive.openBox<GridThemeRecord>("grid_schema").then((grid) {
        var allGrids = grid.values;
        if (allGrids != null) {
          gridsList = {};
          allGrids.forEach((element) {
            if (element.id != 2) gridsList[element.id] = element.name;
          });
        }

        signalK = SignalKClient(signalKServerAddress, signalKServerPort, loginData);
        SKFlow = StreamSubscriber(signalK);

        signalK.loadSignalKData().then((x) {
          SKFlow.startListening().then((isListening) {
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
            print('[DashBoard initState] Unable to stream -- on error : $onError');
            cleanPreferences().then((value) => goToSetup());
          });
        }).catchError((Object onError) {
          print('[DashBoard initState] Unable to connect -- on error : $onError');
          cleanPreferences().then((value) => goToSetup());
        });
      });
    });
  }

  Future<void> cleanPreferences() async {
    return await Hive.openBox("settings").then((settings) async {
      await settings.put("first_setup_done", false);
    });
  }

  Future<void> _changeSelectedGrid(int themeId) async {
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
    if (mounted)
      setState(() {
        sectionLoaded = false;
      });
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      var tempTheme = grid.get(2);
      if (tempTheme != null) {
        GridThemeRecord updatedThemeRecord = GridThemeRecord(id: currentGridIndex, name: gridsList[currentGridIndex], schema: tempTheme.schema);
        await grid.put(updatedThemeRecord.id, updatedThemeRecord).then((value) async {
          await grid.close();
          if (mounted)
            setState(() {
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
    if (mounted)
      setState(() {
        sectionLoaded = false;
      });
    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      var tempTheme = grid.get(currentGridIndex);
      if (tempTheme != null) {
        GridThemeRecord updatedThemeRecord = GridThemeRecord(id: 2, name: gridsList[currentGridIndex], schema: tempTheme.schema);
        await grid.put(updatedThemeRecord.id, updatedThemeRecord).then((value) async {
          await grid.close();
          if (mounted)
            setState(() {
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
    final BaseModel model = themeModel;
    model.isMobileResolution = (MediaQuery.of(context).size.width) < 768;

    return !sectionLoaded
        ? getSpinnerPage(model)
        : FutureBuilder(builder: (context, snapshot) {
            return Container(
              child: SafeArea(
                  child: Scaffold(
                      key: scaffoldKey,
                      backgroundColor: model.webBackgroundColor,
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
                                  flex: 2,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Container(
                                        transform: Matrix4.translationValues(0, 4, 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(24, 10, 0, 0),
                                              child: const Text('SKDashboard ', style: TextStyle(color: Colors.white, fontSize: 28, letterSpacing: 0.53, fontFamily: 'Roboto-Bold')),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
                                                child: Text('Open Source Marine Electronics',
                                                    style: TextStyle(
                                                        color: Colors.white, fontSize: 14, fontFamily: 'Roboto-Regular', letterSpacing: 0.26, fontWeight: FontWeight.normal))),
                                            const Padding(
                                              padding: EdgeInsets.only(top: 15),
                                            ),
                                          ],
                                        )),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0, right: 5, left: 15),
                                    child: Container(
                                        color: Colors.transparent,
                                        transform: Matrix4.translationValues(0, 4, 0),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              //I row
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  const Padding(
                                                    padding: EdgeInsets.only(left: 24, top: 10),
                                                  ),
                                                  Expanded(
                                                      child: Align(
                                                    alignment: Alignment.centerRight,
                                                    child: FittedBox(
                                                        fit: BoxFit.fitHeight,
                                                        child: (currentGridIndex != null)
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
                                                            : Container()),
                                                  )),
                                                  FittedBox(fit: BoxFit.fitHeight, child: showEditGridSwitcher()),
                                                  FittedBox(fit: BoxFit.fitHeight, child: showMonitorPageSwitcher()),
                                                  FittedBox(fit: BoxFit.fitHeight, child: showThemeSwitcher(themeModel)),
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
                                                    padding: EdgeInsets.only(left: 24, top: 10),
                                                  ),

                                                  Expanded(
                                                      child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: FittedBox(
                                                              fit: BoxFit.fitHeight,
                                                              child: (currentVessel != null)
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
                                                                            child: Text(value), //Text("Vessel #" + (vesselsList.indexOf(value) + 1).toString()),
                                                                          );
                                                                        }).toList(),
                                                                      ),
                                                                    )
                                                                  : Container()))),

                                                  // FittedBox(fit:BoxFit.fitHeight, child: showThemeSwitcher(themeModel)),
                                                  FittedBox(
                                                    fit: BoxFit.fitHeight,
                                                    child: Padding(
                                                        padding: EdgeInsets.only(left: 0),
                                                        child: Container(
                                                          child: IconButton(
                                                            icon: const Icon(Icons.help_center_outlined, color: Colors.white),
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    titlePadding: const EdgeInsets.all(0.0),
                                                                    contentPadding: const EdgeInsets.all(0.0),
                                                                    content: SingleChildScrollView(
                                                                      child: FutureBuilder(builder: (context, snapshot) {
                                                                        return Container(
                                                                          padding: EdgeInsets.all(8.0),
                                                                          child: Column(
                                                                            children: [
                                                                              Text("SKDashboard",
                                                                                  style:
                                                                                      TextStyle(color: Colors.black, fontSize: 28, letterSpacing: 0.53, fontFamily: 'Roboto-Bold')),
                                                                              Padding(padding: EdgeInsets.all(3)),
                                                                              Text("a signalK fully customizable drag and drop dashboard for the open-source marine electronics ",
                                                                                  style:
                                                                                      TextStyle(color: Colors.black, fontSize: 13, letterSpacing: 0.53, fontFamily: 'Roboto-Bold')),
                                                                              Padding(padding: EdgeInsets.all(3)),
                                                                              Divider(
                                                                                height: 1,
                                                                                color: Color.fromRGBO(193, 193, 193, 1.0),
                                                                                thickness: 0.8,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(top: 18.0, bottom: 18),
                                                                                child: Column(
                                                                                  children: [
                                                                                    Text("Author",
                                                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                                                                                    InkWell(
                                                                                        child: Text("Valerio Pezone", style: TextStyle(color: Colors.black, fontSize: 13)),
                                                                                        onTap: () => launch('http://www.valeriopezone.it')),
                                                                                    Padding(padding: EdgeInsets.all(6)),
                                                                                    Text("Credits",
                                                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                                                                                    InkWell(
                                                                                        child: Text("Raffaele Montella", style: TextStyle(color: Colors.black, fontSize: 13)),
                                                                                        onTap: () => launch('http://www.raffaelemontella.it/')),
                                                                                    Padding(padding: EdgeInsets.all(6)),
                                                                                    Text("Special Thanks",
                                                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                                                                                    InkWell(
                                                                                        child: Text("Unknown Devices", style: TextStyle(color: Colors.black, fontSize: 13)),
                                                                                        onTap: () => launch('https://www.instagram.com/unwndevices/?hl=it')),
                                                                                    InkWell(
                                                                                        child: Text("Alessandro de Crescenzo", style: TextStyle(color: Colors.black, fontSize: 13)),
                                                                                        onTap: () => launch('https://www.instagram.com/aledecri/?hl=it')),
                                                                                    InkWell(
                                                                                        child: Text("Valeria Ferone", style: TextStyle(color: Colors.black, fontSize: 13)),
                                                                                        onTap: () => launch('https://www.instagram.com/ferrvale/?hl=it')),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Text("Parthenope University of Naples - Computer Science ",
                                                                                  style:
                                                                                      TextStyle(color: Colors.black, fontSize: 13, letterSpacing: 0.53, fontFamily: 'Roboto-Bold')),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        )),
                                                  ),

                                                  FittedBox(
                                                    fit: BoxFit.fitHeight,
                                                    child: Padding(
                                                        padding: EdgeInsets.only(left: 0),
                                                        child: Container(
                                                          child: IconButton(
                                                            icon: const Icon(Icons.exit_to_app, color: Colors.white),
                                                            onPressed: () {
                                                              cleanPreferences().then((value) => goToSetup());
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
                            actions: <Widget>[Column()],
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
            onPressed: () async {
              await _persistentSaveCurrentGridChanges();
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text("Undo changes"),
            onPressed: () async {
              await _persistentDeleteCurrentGridChanges();
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text("Go back"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Widget showEditGridSwitcher() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(children: <Widget>[
        SizedBox(
          height: 45,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                return CupertinoSegmentedControl<int>(
                  children: <int, Widget>{
                    0: Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: Icon(Icons.remove_red_eye, color: !editingMode ? Colors.white : Color.fromRGBO(84, 84, 84, 1))),
                    1: Container(
                        padding: const EdgeInsets.all(5), alignment: Alignment.center, child: Icon(Icons.edit, color: editingMode ? Colors.white : Color.fromRGBO(84, 84, 84, 1)))
                  },
                  padding: const EdgeInsets.all(5),
                  unselectedColor: Colors.transparent,
                  selectedColor: themeModel.paletteColor,
                  pressedColor: themeModel.paletteColor,
                  borderColor: Colors.white,
                  groupValue: editingMode ? 1 : 0,
                  onValueChanged: (int value) {
                    if (value == 0 && haveGridChanges) {
                      showSaveAlertDialog();
                      return null;
                    }

                    if (mounted) {
                      setState(() {
                        editingMode = value == 0 ? false : true;
                      });
                    }

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
      return Column(children: <Widget>[
        SizedBox(
          height: 45,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                return CupertinoSegmentedControl<int>(
                  children: <int, Widget>{
                    0: Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: Icon(Icons.grid_on, color: currentViewState == "monitors" ? Colors.white : Color.fromRGBO(84, 84, 84, 1))),
                    1: Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: Icon(Icons.stream, color: currentViewState != "monitors" ? Colors.white : Color.fromRGBO(84, 84, 84, 1)))
                  },
                  padding: const EdgeInsets.all(5),
                  unselectedColor: Colors.transparent,
                  selectedColor: themeModel.paletteColor,
                  pressedColor: themeModel.paletteColor,
                  borderColor: Colors.white,
                  groupValue: currentViewState == "monitors" ? 0 : 1,
                  onValueChanged: (int value) {
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
            // endDrawer: showWebThemeSettings(model),
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
                            child: const Text('SKDashboard', style: TextStyle(color: Colors.white, fontSize: 28, letterSpacing: 0.53, fontFamily: 'Roboto-Bold')),
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
}
