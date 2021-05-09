import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
part 'models.g.dart';


@HiveType(typeId: 2)
class GridThemeRecord {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  dynamic schema;
  GridThemeRecord({@required this.id, @required this.name,@required this.schema});

}
