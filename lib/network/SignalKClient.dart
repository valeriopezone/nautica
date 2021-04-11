import 'package:nautica/utils/APITreeExplorer.dart';
import 'package:websocket_manager/websocket_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../Configuration.dart';


class SignalKClient {
  bool loaded = false, wsConnected = false;
  String ip;
  int port;
  String apiVersion;
  String serverId, serverVersion;
  String wsURL = "ws://192.168.1.162:3000/signalk/v1/stream", httpURL, tcpURL;
  Authentication loginData;

  Function onWSCloseCallBack = () {}, onWSMessageCallBack = () {};

  WebsocketManager socket;

  List<String> vessels = [];

  String getWSUrl() => this.wsURL;

  Map vesselsPaths = new Map();

  SignalKClient(this.ip, this.port, Authentication this.loginData) {
    this.apiVersion = NAUTICA['signalK']['APIVersion'];
    print("[SignalKClient] Launch");
  }

  List<String> getVessels() {
    return vessels;
  }

  Map getPaths() {
    return vesselsPaths;
  }

  Future<bool> WSconnect(
      Function closeCallback, Function messageCallback) async {
//login data?
    if (this.wsURL.isEmpty) {
      return Future.value(false);
    }
    //REMEMBER SUBSCRIBE=ALL
    this.socket = WebsocketManager(this.wsURL + "?subscribe=all");
// Listen to close message
    this.socket.onClose((dynamic message) {
      print('[SignalKClient] close');
      closeCallback();
    });
// Listen to server messages
    this.socket.onMessage((dynamic message) {
      messageCallback(message);
    });
// Connect to server
    return await this.socket.connect().then((v) {
      this.wsConnected = true;
      print("[SignalKClient] connected to websocket");
      return Future.value(true);
    }).catchError((Object onError) {
      print('[SignalKClient] Unable to connect -- on error : $onError');
      return Future.value(false);
    });
  }

  void WSdisconnect() {

    wsConnected = false;
    disconnect();
    this.socket.close();
  }

  void disconnect(){
    loaded = false;
    vessels.clear();
    vesselsPaths.clear();
  }

  bool isLoaded() {
    return this.loaded;
  }

  void executeHTTPRequest() {}

  Future<bool> loadSignalKData() async {
    //launch first request
    dynamic response = await this.execHTTPRequest(path: 'signalk');
    //.then((response) {
    print("[loadSignalKData] RECEIVED : " + response.toString());
    this.serverId = response['server']['id'];
    this.serverVersion = response['endpoints'][this.apiVersion]['version'];

    if (this.serverId == null || this.serverVersion == null) {
      //error....
      print(
          "[loadSignalKData] UNABLE TO READ JSON - PROBABLY WRONG API_VERSION");

      return Future.error("UNABLE TO READ JSON - PROBABLY WRONG API_VERSION");
    }
    this.httpURL = response['endpoints'][this.apiVersion]['signalk-http'];
    this.wsURL = response['endpoints'][this.apiVersion]['signalk-ws'];
    this.tcpURL = response['endpoints'][this.apiVersion]['signalk-tcp'];

    print("[loadSignalKData] serverID : " + this.serverId);
    print("[loadSignalKData] serverVersion : " + this.serverVersion);

    //get signalk info - read vessels

    await loadVesselData();

    print("[loadSignalKData] configuration done");
    this.loaded = true;
     return Future.value(true);
    //  });
  }

  Future<void> loadVesselData() async {
    //load vessels

    var uri = Uri.parse(this.httpURL);

    if (uri != null) {
      dynamic response = await this.execHTTPRequest(path: uri.path);

      if (response['vessels'] != null) {
        try {
          response['vessels'].keys.forEach((v) {
            vessels.add("vessels." + v);
          });

          vessels.forEach((vessel) {
            var i = vessel.toString();
            vesselsPaths[i] = new Map();

            var t = new APITreeExplorer(
                response['vessels'][i.replaceAll("vessels.", "")]);
            vesselsPaths[i] = t.retrieveAllRoutes();
          });
        } on NoSuchMethodError {}
      } else {
        return Future.error("UNABLE TO GET VESSELS");
      }
    }

    print(vesselsPaths.toString());

    //set current available paths
  }



  void loadPaths() {}

  Future<dynamic> execHTTPRequest(
      {String path = '/', Map<String, String> data = null}) async {
    if (data == null) data = {};
    print("[execHTTPRequest] http request to ${this.ip}:${this.port}");
    var url = Uri.http('${this.ip}:${this.port}', path, data);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url).timeout(
      Duration(seconds:NAUTICA['configuration']['connection']['timeout']),
      onTimeout: () {
        // time has run out, do what you wanted to do
        return Future.error("Unable to connect http");
      },
    );
    if (response.statusCode == 200) {
      print('[execHTTPRequest] response obtained');
      return convert.jsonDecode(response.body);
    } else {
      print(
          '[execHTTPRequest] Request failed with status: ${response.statusCode}.');
      return {};
    }
  }
}
