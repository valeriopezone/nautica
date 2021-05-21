import 'dart:io' show Platform, exit;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SKDashboard/screens/SplashScreen.dart';
import 'package:SKDashboard/screens/MonitoringEnvironment.dart';
import 'Configuration.dart';
import 'models/BaseModel.dart';
import 'models/database/models.dart';
import 'dart:convert' as convert;
import 'package:path_provider/path_provider.dart';

//for web usage disable canvaskit -> flutter run -d chrome --web-renderer html

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool storageLoaded = await initializeStorage();

  if(!storageLoaded) exit(0); //kill app if storage not loaded

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/Orbitron/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });


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
  BaseModel _themeModel;

  @override
  void initState() {
    _themeModel = BaseModel.instance;
    _initializeProperties();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final Map<LogicalKeySet, Intent> shortcuts =
        Map.of(WidgetsApp.defaultShortcuts)
          ..remove(LogicalKeySet(LogicalKeyboardKey.escape));

    if (_themeModel != null && _themeModel.isWebFullView) {
      _themeModel.currentThemeData = ThemeData.dark();
      _themeModel.paletteBorderColors = <Color>[];
      _themeModel.changeTheme(_themeModel.currentThemeData);
    }

    return MaterialApp(
        initialRoute: '/',
        routes: {
          '/monitoring_environment': (context) => Builder(builder: (BuildContext context) {
                if (_themeModel != null) {
                  _themeModel.systemTheme = Theme.of(context);
                  _themeModel.currentThemeData =
                      (_themeModel.systemTheme.brightness !=
                              Brightness.dark
                          ? ThemeData.light()
                          : ThemeData.dark());
                  _themeModel
                      .changeTheme(_themeModel.currentThemeData);
                }
                return MonitoringEnvironment();
              }),
        },
        debugShowCheckedModeBanner: false,
        title: 'SKDashboard',
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
  GridThemeRecord themeRecord;
  await Hive.initFlutter();

  if(!kIsWeb){
    final document = await getApplicationDocumentsDirectory();
    Hive.init(document.path);
  }

  Hive.registerAdapter(GridThemeRecordAdapter());


  print("Initialize Storage");
  return await Hive.openBox("settings").then((settings) async {
    var signalKAddress = settings.get("signalk_address");
    var signalkPort = settings.get("signalk_port");
    var keepLoggedIn = settings.get("keep_logged_in");
    var firstSetupDone = settings.get("first_setup_done");
    currentThemeIndex = settings.get("current_grid_index");

    //check if have values
    print("[initializeStorage] signalKAddress = " + signalKAddress.toString());
    print("[initializeStorage] signalkPort = " + signalkPort.toString());
    print("[initializeStorage] keepLoggedIn = " + keepLoggedIn.toString());
    print("[initializeStorage] firstSetupDone = " + firstSetupDone.toString());
    print("[initializeStorage] current_grid_index = " + currentThemeIndex.toString());


    if (signalKAddress == null) {
      await settings
          .put("signalk_address", CONF['signalK']['connection']['address'])
          .then((value) {
        print("[initializeStorage] signalk_address inserted");
      });
    }

    if (signalkPort == null) {
      await settings
          .put("signalk_port", CONF['signalK']['connection']['port'])
          .then((value) {
        print("[initializeStorage] signalk_port inserted");
      });
    }

    if (keepLoggedIn == null) {
      await settings.put("keep_logged_in", false).then((value) {
        print("[initializeStorage] keep_logged_in inserted");
      });
    }

    if (firstSetupDone == null) {
      await settings.put("first_setup_done", false).then((value) {
        print("[initializeStorage] first_setup_done inserted");
      });
    }

    if (currentThemeIndex == null) {
      await settings.put("current_grid_index", 1).then((value) {
        print("[initializeStorage] current_grid_index inserted");
      });
    }

    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
      //check if grid #1 exists

      var currentGrid = grid.get(1);
      var mainGridSchema = convert.jsonDecode(mainJSONGridTheme);


      if (currentGrid == null) {
        //insert grid
        themeRecord = new GridThemeRecord(id: 1, name: "Nautica", schema: convert.jsonDecode(mainJSONGridTheme));

        await grid.put(themeRecord.id, themeRecord).then((value) {
          print("[initializeStorage] Default grid inserted in db");
        });
      }else{
        mainGridSchema = currentGrid.schema;
      }

      var tempGrid = grid.get(2);


      if (tempGrid == null) {
        //insert grid
        themeRecord = new GridThemeRecord(id: 2, name: "Temporary Grid", schema: (mainGridSchema));

        await grid.put(themeRecord.id, themeRecord).then((value) {
          print("[initializeStorage] temporary grid inserted in db");
        });
      }




      if (currentThemeIndex != null && currentThemeIndex != 1) {
        //check if exit otherwise update current theme index

        currentGrid = grid.get(currentThemeIndex);
        if (currentGrid == null) {
          //if current grid is corrupted go back to default theme
          await settings.put("current_grid_index", 1).then((value) {
            print("[initializeStorage] current_grid_index inserted (default was missing)!");
          });
        }else{
          //load current grid in temp
          themeRecord = GridThemeRecord(id: 2, name: "Temporary Grid", schema: currentGrid.schema);

          await grid.put(themeRecord.id, themeRecord).then((value) {
            print("[initializeStorage] temporary grid inserted in db");
          });

        }
      }


      return Future.value(true);
    }).onError((error, stackTrace) {
      print("[initializeStorage] Having error " + error.toString());
      return Future.value(false);
    });
  }).onError((error, stackTrace) {
    print("[initializeStorage] Having error " + error.toString());
    return Future.value(false);
  });
}