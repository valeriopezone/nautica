import 'package:nautica/SignalKClient.dart';
import 'package:websocket_manager/websocket_manager.dart';
import 'Configuration.dart';
import 'dart:convert' as convert;

class StreamSubscriber{
  SignalKClient client = null;
  WebsocketManager SKWebSocket = null;
  var subscriptionList;//TODO

  dynamic wsRawData;

  Map<String,dynamic> wsDataMap;


  StreamSubscriber(this.client) {

    //generate config map

    setPathMap();




    //check connection status
  print("[StreamSubscriber] connect to " + this.client.getWSUrl());
    //connect to websocket
  this.reconnectToStream();
    //set listener
  }

  void setPathMap(){
    this.wsDataMap = Map.fromEntries(getWidgetSubscriptionMap().entries.map((e) => MapEntry(e.key,0)));
    print(this.wsDataMap);
  }

  void reconnectToStream(){
  //subscribe to stream
  this.client.WSconnect(this.onCloseCallback,this.onMessageCallback);
  }


  void onMessageCallback(dynamic msg){

    //update internal vars
    this.wsRawData = msg;
   // print('recv: $msg');

    //convert

    dynamic dec = convert.jsonDecode(this.wsRawData);
    String givenPath = "";
    dynamic streamedParams;

    //need foreach
    if(dec != null && (streamedParams = dec['updates'][0]['values']) != null){//todo fix nullable error
      if(streamedParams is List<dynamic>){
        streamedParams.forEach((param) {
          //print(param);
          //check for path and value
          if(param["path"] != null && param["value"] != null){
            var subscriptionName = getSubscriptionSlugByFullName(param["path"]);
            if(subscriptionName.isNotEmpty && this.wsDataMap[subscriptionName] != null){
                this.wsDataMap[subscriptionName] = param["value"];
              //print("[onMessageCallback] $subscriptionName set to");
              print(this.wsDataMap);
            }

          }

        });
      }
    // if(givenValues is array)
    //   foreach(givenValues)
    //     update value
     //if(this.wsDataMap[givenPath] != null){
     //  //update value
     //  this.wsDataMap[givenPath] = dec['updates'][0]['source']['values'][0]['path']
     //}
    }


    //get subscribing path

    //check ['updates'][0]['source']['values'][0]['path'] = fullname
    //fullname = getSubscriptionFullName(slug)
    ////this.wsdatamap[''] = msg
  //String slug = getSubscriptionSlugByFullName(streamToSubscribe);

  //if(slug != null){

  //}
  }

  void onCloseCallback(){
    //...
  }


  void getStream(String streamToSubscribe){



  //yeld this.wsData[..][..][..][..]
  }



  Stream<int> timedCounter(Duration interval, [int maxCount]) async* {
    int i = 0;
    while (true) {
      await Future.delayed(interval);
      yield i++;
      if (i == maxCount) break;
    }
  }
/*
  Stream<String> listenForSpaces() async* {
    var input = <String>[];
    await for (var keyboardEvent in document.onKeyDown) {
      var key = keyboardEvent.key;
      if (key == " ") {
        yield input.join();
        input.clear();
      } else {
        input.add(key.length > 1 ? "[$key]" : key);
      }
    }
  }


*/
  Stream<double> watch() async* {
  double i = 0;
    Duration interval = Duration(seconds: 2);

    while (true) {
      await Future.delayed(interval);
      yield i++;
    }
  }

}