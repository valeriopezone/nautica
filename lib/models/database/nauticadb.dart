/*
class NauticaDB {
  static const dbName = 'nautica';
  Database db;



  Future<bool> createSettingsTable(Database db) async {
    final todoSql = '''CREATE TABLE settings (
      paramkey TEXT PRIMARY KEY,
      paramvalue TEXT
      )''';
    return await db.execute(todoSql).then((res) {
      //ok
      return Future.value(true);
    }).onError((error, stackTrace) {
      //on error
      return Future.value(false);
    });
  }

  Future<bool> createGridThemeTable(Database db) async {
    final todoSql = '''CREATE TABLE grid_themes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
      schema TEXT
      )''';
    return await db.execute(todoSql).then((res) {
      //ok
      return Future.value(true);
    }).onError((error, stackTrace) {
      //on error
      return Future.value(false);
    });
    ;

    //insert demo theme
  }

  Future<bool> addGridThemeRecord(GridThemeRecord theme) async {
    final sql = '''INSERT INTO grid_themes
                    id,name,schema
                  VALUES (?,?,?)
                ''';
    List<dynamic> params = [theme.id, theme.name, theme.schema];
    return await db.rawInsert(sql, params).then((res) {
      //ok
      return Future.value(true);
    }).onError((error, stackTrace) {
      //on error
      return Future.value(false);
    });
  }

  Future<void> addSettingRecord(SettingRecord setting) async {
    final sql = '''INSERT INTO grid_themes
                    paramkey,paramvalue
                  VALUES (?,?,?)
                ''';
    List<dynamic> params = [setting.paramkey, setting.paramvalue];
    return await db.rawInsert(sql, params).then((res) {
      //ok
      return Future.value(true);
    }).onError((error, stackTrace) {
      //on error
      return Future.value(false);
    });
  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);
    if (!await Directory(dirname(path)).exists()) {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath(dbName);
    db = await openDatabase(path, version: 1, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    await createSettingsTable(db).then((value) async {
      await createGridThemeTable(db).then((value) async {
        await addGridThemeRecord(GridThemeRecord(0,"theme1","JSONDATA")).then((value) async {
          await addSettingRecord(SettingRecord("settingkey","settingvalue"))
              .then((value) async {})
              .onError((error, stackTrace) {
            //on error
            print("error db creation [insert setting record] -> " +
                error.toString() +
                " | " +
                stackTrace.toString());
          });
        }).onError((error, stackTrace) {
          //on error
          print("error db creation [insert grid record] -> " +
              error.toString() +
              " | " +
              stackTrace.toString());
        });
      }).onError((error, stackTrace) {
        //on error
        print("error db creation [create grid table] -> " +
            error.toString() +
            " | " +
            stackTrace.toString());
      });
    }).onError((error, stackTrace) {
      //on error
      print("error db creation [create settings table] -> " +
          error.toString() +
          " | " +
          stackTrace.toString());
    });
  }
}*/