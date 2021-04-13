/// dart imports
import 'dart:io' show Platform, exit;

/// package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nautica/screens/FirstSetup.dart';
import 'package:nautica/screens/SplashScreen.dart';
import 'package:nautica/screens/DashBoardPage.dart';
import 'package:nautica/screens/SubscriptionsPage.dart';
import 'Configuration.dart';
import 'models/BaseModel.dart';
import 'package:path_provider/path_provider.dart';

import 'models/database/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool storageLoaded = await initializeStorage();

  if(!storageLoaded) exit(0); //kill app if storage not loaded

  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    SystemChrome.setEnabledSystemUIOverlays([]).then((_) {
      runApp(new MyApp());
    });
  });

  //runApp(MyApp());
}



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BaseModel _sampleListModel;

  @override
  void initState() {
    _sampleListModel = BaseModel.instance;

    _initializeProperties();
    super.initState();

    //maybe connections should be created here
  }

  @override
  Widget build(BuildContext context) {
    ///Avoiding page poping on escape key press
    final Map<LogicalKeySet, Intent> shortcuts =
        Map.of(WidgetsApp.defaultShortcuts)
          ..remove(LogicalKeySet(LogicalKeyboardKey.escape));

    if (_sampleListModel != null && _sampleListModel.isWebFullView) {
      _sampleListModel.currentThemeData = ThemeData.dark();
      _sampleListModel.paletteBorderColors = <Color>[];
      _sampleListModel.changeTheme(_sampleListModel.currentThemeData);
    }

    return MaterialApp(
        // initialRoute: '/demos',
        //routes: navigationRoutes,
        initialRoute: '/',
        routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          //  '/': (context) => DashBoard(),
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/dashboard': (context) => Builder(builder: (BuildContext context) {
                if (_sampleListModel != null) {
                  _sampleListModel.systemTheme = Theme.of(context);
                  _sampleListModel.currentThemeData =
                      (_sampleListModel.systemTheme.brightness !=
                              Brightness.dark
                          ? ThemeData.light()
                          : ThemeData.dark());
                  _sampleListModel
                      .changeTheme(_sampleListModel.currentThemeData);
                }
                return DashBoard();
              }),
        },
        debugShowCheckedModeBanner: false,
        title: 'Nautica',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: SplashScreen());
  }

  void _initializeProperties() {
    final BaseModel model = BaseModel.instance;
    model.isWebFullView =
        kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    if (kIsWeb) {
      model.isWeb = true;
    } else {
      model.isAndroid = Platform.isAndroid;
      model.isIOS = Platform.isIOS;
      model.isLinux = Platform.isLinux;
      model.isWindows = Platform.isWindows;
      model.isMacOS = Platform.isMacOS;
      model.isDesktop =
          Platform.isLinux || Platform.isMacOS || Platform.isWindows;
      model.isMobile = Platform.isAndroid || Platform.isIOS;
    }
  }


}


Future<bool> initializeStorage() async {
  int currentThemeIndex;

  await Hive.initFlutter();
  //final document = await getApplicationDocumentsDirectory();
  //Hive.init(document.path);
  Hive.registerAdapter(SettingRecordAdapter());
  Hive.registerAdapter(GridThemeRecordAdapter());

  if(false){//clear
    var s1 = await Hive.openBox("settings");
    s1.clear();
    s1.close();
    var s2 = await Hive.openBox("grid_schema");
    s2.clear();
    s2.close();

  }

  print("Initialize Storage");
  return await Hive.openBox("settings").then((settings) async {
    var signalKAddress = settings.get("signalk_address");
    var signalkPort = settings.get("signalk_port");
    var keepLoggedIn = settings.get("keep_logged_in");
    var firstSetupDone = settings.get("first_setup_done");
    currentThemeIndex = settings.get("current_grid_index");

    //check if have values
    print("[hive] signalKAddress = " + signalKAddress.toString());
    print("[hive] signalkPort = " + signalkPort.toString());
    print("[hive] keepLoggedIn = " + keepLoggedIn.toString());
    print("[hive] firstSetupDone = " + firstSetupDone.toString());
    print("[hive] current_grid_index = " + currentThemeIndex.toString());

    //await settings.delete("signalk_port");
    //await settings.delete("keep_logged_in");
    //await settings.delete("first_setup_done");
    //await settings.delete("current_grid_index");

    if (signalKAddress == null) {
      //var usernameSetting = SettingRecord(paramkey : "signalk_address",paramvalue : NAUTICA['signalK']['connection']['address']);
      await settings
          .put("signalk_address", NAUTICA['signalK']['connection']['address'])
          .then((value) {
        print("signalk_address inserted");
      });
    }

    if (signalkPort == null) {
      await settings
          .put("signalk_port", NAUTICA['signalK']['connection']['port'])
          .then((value) {
        print("signalk_port inserted");
      });
    }

    if (keepLoggedIn == null) {
      await settings.put("keep_logged_in", false).then((value) {
        print("keep_logged_in inserted");
      });
    }

    if (firstSetupDone == null) {
      await settings.put("first_setup_done", false).then((value) {
        print("first_setup_done inserted");
      });
    }

    if (currentThemeIndex == null) {
      await settings.put("current_grid_index", 1).then((value) {
        print("current_grid_index inserted");
      });
    }

    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      //check if grid #1 exists

      var currentGrid = grid.get(1);
  print(currentGrid.toString());
      if (currentGrid == null) {
        //insert grid
        GridThemeRecord themeRecord = GridThemeRecord(id: 1, name: "Nautica", schema: mainJSONGridTheme);

        await grid.put(themeRecord.id, themeRecord).then((value) {
          print("Default grid inserted in db");
        });
      }

      var tempGrid = grid.get(2);
      print(tempGrid.toString());

      if (tempGrid == null) {
        //insert grid
        GridThemeRecord themeRecord = GridThemeRecord(id: 2, name: "Temporary Grid", schema: mainJSONGridTheme);

        await grid.put(themeRecord.id, themeRecord).then((value) {
          print("temporary grid inserted in db");
        });
      }

      if (currentThemeIndex != null && currentThemeIndex != 1) {
        //check if exit otherwise update current theme index
        currentGrid = grid.get(currentThemeIndex);
        if (currentGrid == null) {
          //if current grid is corrupted go back to default theme
          await settings.put("current_grid_index", 1).then((value) {
            print("current_grid_index inserted (default was missing)!");
          });
        }
      }
      await settings.close();
      await grid.close();
      return Future.value(true);
    }).onError((error, stackTrace) {
      print("[grid] Having error " + error.toString());
      return Future.value(false);
    });
  }).onError((error, stackTrace) {
    print("[settings] Having error " + error.toString());
    return Future.value(false);
  });
}