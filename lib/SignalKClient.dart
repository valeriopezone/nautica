import 'package:websocket_manager/websocket_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'Configuration.dart';

class SignalKClient {
  bool loaded = false, wsConnected = false;
  String ip;
  int port;
  String apiVersion;
  String serverId, serverVersion;
  String wsURL, httpURL, tcpURL;
  Function onWSCloseCallBack = (){}, onWSMessageCallBack = (){};

  WebsocketManager socket;


  String getWSUrl() => this.wsURL;




  SignalKClient(this.ip, this.port, Authentication loginData) {
    this.apiVersion = NAUTICA['signalK']['APIVersion'];
    print("[SignalKClient] Launch");


  }



  Future<void> WSconnect( Function closeCallback, Function messageCallback) async {
//login data?
  if(this.wsURL.isEmpty){
    return Future.value(false);
  }
   this.socket = WebsocketManager(this.wsURL);
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
   return await this.socket.connect().then((v){
     this.wsConnected = true;
     print("[SignalKClient] connected to websocket");
    }).catchError((Object onError){
      print('[SignalKClient] Unable to connect -- on error : $onError');
      return Future.error('Unable to connect -- on error : $onError');

    });

  }




  void WSdisconnect() {
    this.socket.close();
  }





  void getWSStream() {}

  void sendData() {}

  bool isLoaded(){
    return this.loaded;
  }
  void executeHTTPRequest() {}

  Future<void> loadSignalKData() async {
    //launch first request
   dynamic response =  await this.execHTTPRequest(path: 'signalk');
    //.then((response) {
      print("[loadSignalKData] RECEIVED : " + response.toString());
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
      print("[loadSignalKData] configuration done");
     this.loaded = true;
     // return Future.value(true);
  //  });


  }

  Future<dynamic> execHTTPRequest({String path = '/', Map<String, String> data = null}) async {
    if (data == null) data = {};
    print("[execHTTPRequest] http request to ${this.ip}:${this.port}");
    var url = Uri.http('${this.ip}:${this.port}', path, data);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print('[execHTTPRequest] response obtained');
      return convert.jsonDecode(response.body);
    } else {
      print('[execHTTPRequest] Request failed with status: ${response.statusCode}.');
      return {};
    }
  }

}
