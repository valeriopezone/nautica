class APITreeExplorer {
  Map<String, Map> paths = new Map();
  dynamic map;

  APITreeExplorer(this.map);

  Map<String, Map> retrieveAllRoutes() {
    findTree(this.map, "", "", "");
    return paths;
  }

  void findTree(dynamic o, String key, String parentKey, dynamic parentObject) {
    if (o != null) {
      if (key == "meta") {
        if (parentKey.substring(0, 1) == '.') {
          paths[parentKey.substring(1)] = o;
        } else {
          paths[parentKey] = o;
        }
      } else {
        try {
          var lastKeys = o.keys;
          lastKeys.forEach((k) {
            findTree(
                o[k], k, (k == "meta") ? parentKey : parentKey + "." + k, o);
          });
        } on NoSuchMethodError {}
      }
    }
  }
}
