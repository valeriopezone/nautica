import 'package:flutter/foundation.dart';
import 'package:SKDashboard/utils/APITreeExplorer.dart';
import 'package:websocket_manager/websocket_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'package:SKDashboard/Configuration.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  WebSocketChannel desktopSocket;

  List<String> vessels = [];

  String getWSUrl() => this.wsURL;

  Map vesselsPaths = new Map();

  SignalKClient(this.ip, this.port, this.loginData) {
    this.apiVersion = CONF['signalK']['APIVersion'];
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

    if (this.wsURL.isEmpty) {
      return Future.value(false);
    }

    desktopSocket = null;

    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      //WebsocketManager not supported, use standard

      print("[SignalKClient] websocket on browser");

      desktopSocket = WebSocketChannel.connect(Uri.parse(this.wsURL + "?subscribe=all"));
      if (desktopSocket != null) {
        desktopSocket.stream.listen((message) {
          messageCallback(message);
        }).onError((e) {
          print('[SignalKClient]Browser - Unable to connect -- on error : ' +
              e.toString());
          closeCallback();

        });

        this.wsConnected = true;
        print("[SignalKClient]Browser - connected to websocket");
        return Future.value(true);
      }
      return Future.value(false);
    } else {

      this.socket = WebsocketManager(this.wsURL + "?subscribe=all");


      this.socket.onClose((dynamic message) {
        print('[SignalKClient] close');
        closeCallback();
      });

      this.socket.onMessage((dynamic message) {
        messageCallback(message);
      });


      return await this.socket.connect().then((v) {
        this.wsConnected = true;
        print("[SignalKClient] connected to websocket");
        return Future.value(true);
      }).catchError((Object onError) {
        print('[SignalKClient] Unable to connect -- on error : $onError');
        return Future.value(false);
      });
    }
  }

  void WSdisconnect() {
    wsConnected = false;
    disconnect();
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      if (desktopSocket != null) desktopSocket.sink.close(1000);
    } else {
      if (socket != null) this.socket.close();
    }
  }

  void disconnect() {
    loaded = false;
    vessels.clear();
    vesselsPaths.clear();
  }

  bool isLoaded() {
    return this.loaded;
  }


  Future<bool> loadSignalKData() async {
    //launch first request
    dynamic response = await this.execHTTPRequest(path: 'signalk');
    //.then((response) {
    print("[loadSignalKData] RECEIVED RESPONSE");
    this.serverId = response['server']['id'];
    this.serverVersion = response['endpoints'][this.apiVersion]['version'];

    if (this.serverId == null || this.serverVersion == null) {
      //error....
      print("[loadSignalKData] UNABLE TO READ JSON - PROBABLY WRONG API_VERSION");

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
        return Future.error("[loadVesselData] UNABLE TO GET VESSELS");
      }
    }
  }

  void loadPaths() {}

  Future<dynamic> execHTTPRequest(
      {String path = '/', Map<String, String> data = null}) async {
    if (data == null) data = {};
    print("[execHTTPRequest] http request to ${this.ip}:${this.port}");
    var url = Uri.http('${this.ip}:${this.port}', path, data);

    var response = await http.get(url).timeout(
      Duration(seconds: CONF['configuration']['connection']['http']['timeout']),
      onTimeout: () {
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
