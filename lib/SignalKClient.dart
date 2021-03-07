import 'package:websocket_manager/websocket_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'Configuration.dart';


class SignalKClient{
  String ip;
  int port;
  WebsocketManager socket;

  String serverId,serverVersion;


  String wssURL;
  String httpURL;



  SignalKClient(this.ip,this.port){
    print("load signalk");
    this.loadSignalKData();
    /*if(this.loadSignalKData()){

    }*/
  }

  void WSconnect(String username, String password){
    this.socket.connect();
  }

  void WSdisconnect(){
    this.socket.close();
  }

  void getWSStream(){

  }

  void sendData(){

  }


  void executeHTTPRequest(){

  }

  Future<bool> loadSignalKData(){
    //launch first request
  execHTTPRequest(path:'signalk').then((r) {
    print("res : ");
  print(r.toString());

    var jsonResponse = convert.jsonDecode(r);

  print(jsonResponse['v1']['version']);

  });


  return Future.value(true);
    //preload ws and http url
  }



  Future<dynamic> execHTTPRequest({String path = '/',Map<String,String> data = null }) async {
    if (data == null) data = {};
    print("connecting to "  + '${this.ip}:${this.port}');
    var url = Uri.http('${this.ip}:${this.port}', path, data);
    print('http launcyhed');

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;

      var jsonResponse = convert.jsonDecode(response.body);

      print('Number of books');

      return jsonResponse;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return {};

    }
  }






}