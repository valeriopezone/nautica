import 'package:nautica/network/SignalKClient.dart';
import 'package:websocket_manager/websocket_manager.dart';
import 'package:nautica/Configuration.dart';
import 'dart:convert' as convert;

class StreamSubscriber {
  SignalKClient client = null;
  WebsocketManager SKWebSocket = null;
  var subscriptionList; //TODO
  int streamRefreshRate = NAUTICA['configuration']['widget']['refreshRate'];
  int lastWSMessageDate;
  dynamic wsRawData;

  //Map<String, dynamic> wsDataMap;
  Map<String, Map<String, dynamic>> wsDataTable = new Map();
  Map<String, Map<String, dynamic>> wsTimeTable = new Map();

  StreamSubscriber(this.client) {
    //generate config map
    setPathMap();
  }

  void setPathMap() {
    //this.wsDataMap = Map.fromEntries(getWidgetSubscriptionMap().entries.map((e) => MapEntry(e.key, 0)));
  }

  void initDataTable() {
    wsDataTable = Map();
    wsTimeTable = Map();

    Map paths = this.client.getPaths();
    paths.forEach((vessel, value) {
      var keys = value.keys;
      this.wsDataTable[vessel] = Map();
      this.wsTimeTable[vessel] = Map();
      for (String path in keys) {
        this.wsDataTable[vessel][path] = null;
        this.wsTimeTable[vessel][path] = null;
      }
    });
   //print("INIT DATATABLE PATH");
   //print(wsDataTable);
   //print("INIT TIMETABLE PATH");

   // print(wsTimeTable);
  }

  Future<void> reconnectToStream() async {
    //subscribe to stream
    if (this.client.isLoaded()) {
      this.lastWSMessageDate = DateTime.now().millisecondsSinceEpoch;

      initDataTable();

      return await this
          .client
          .WSconnect(this.onCloseCallback, this.onMessageCallback)
          .then((wsResponse) {
        //connected
      }).catchError((Object onError) {
        print('[reconnectToStream] Unable to connect -- on error : $onError');
        return Future.error("UNABLE TO CONNECT TO STREAM");
      });
    }
  }

  Future<void> startListening() async {
    //check connection status
    print("[StreamSubscriber] connect to " + this.client.getWSUrl());
    //connect to websocket
    return await this.reconnectToStream();
  }

  void onMessageCallback(dynamic msg) {
    this.wsRawData = msg;
try{
    dynamic dec = convert.jsonDecode(this.wsRawData);
    dynamic streamedParams, timeParam;

    if (dec != null &&
        dec['context'] != null &&
        dec['updates'] != null &&
        dec['updates'][0] != null &&
        dec['updates'][0]['values'] != null) {
      //todo fix nullable error

      try {
        timeParam = dec['updates'][0]['timestamp'];
      } catch (e) {
        print("Unable to decode time");
      }


      streamedParams = dec['updates'][0]['values'];


      if (streamedParams is List<dynamic>) {
        streamedParams.forEach((param) {
          //check for path and value
          if (dec["context"].toString() != "" &&
              param["path"] != null &&
              param["path"]
                  .toString()
                  .isNotEmpty &&
              //param["path"].toString() != "notifications.server.newVersion" &&
              param["value"] != null) {
            //timestamp!


            try {
              this.wsDataTable[dec["context"].toString()][param["path"]
                  .toString()] = param["value"];
            } catch (e) {
              print("Unable to insert data");
            }

            try {
              this.wsTimeTable[dec["context"].toString()][param["path"]
                  .toString()] = timeParam;
            } catch (e) {
              print("unable to insert time");
            }
          }
        });
      }
    }
  }catch(e){
  print("unable to decode json");
  }
  }

  void onCloseCallback() {
    //...
    print("STREAM SUBSCRIBER CLOSING CALLBACK");
  }

  Stream<dynamic> getVesselStream(
      String vessel, String subscriptionName,Duration refreshRate) async* {
   // if(vessel != null && subscriptionName != null) print("SOMEBODY SUBSCRIBED TO " + vessel + " : " + subscriptionName + " at " + refreshRate.toString());

    Duration interval = refreshRate;//Duration(microseconds: 2000);
    int i = 0;
    while (true) {
      await Future.delayed(interval);
      if(vessel == null || subscriptionName == null) yield null;

      try{
  if (this.wsDataTable[vessel] != null &&
      this.wsDataTable[vessel][subscriptionName] != null) {
    yield this.wsDataTable[vessel][subscriptionName];
  } else {
    yield null;
  }
}catch(e){
  yield null;
}

    }
  }


  Stream<dynamic> getTimedVesselStream(
      String vessel, String subscriptionName,Duration refreshRate) async* {
   // print("SOMEBODY SUBSCRIBED TO " + vessel + " : " + subscriptionName + " at " + refreshRate.toString());
    Duration interval = refreshRate;//Duration(microseconds: 2000);
    int i = 0;

    while (true) {
      await Future.delayed(interval);
      try{
        if (this.wsDataTable[vessel] != null &&
            this.wsDataTable[vessel][subscriptionName] != null) {
          //print(this.wsTimeTable[vessel][subscriptionName]);

          yield {"value" : this.wsDataTable[vessel][subscriptionName], "timestamp" : this.wsTimeTable[vessel][subscriptionName]};
        } else {
          yield {"value" : 0.0, "timestamp" : null};
        }
      }catch(e){
        yield {"value" : 0.0, "timestamp" : null};
      }

    }
  }

  //Stream<dynamic> getStream(String subscriptionName) async* {
  //  Duration interval = Duration(microseconds: 300);
  //  int i = 0;
  //  while (true) {
  //    await Future.delayed(interval);
  //    yield (this.wsDataMap[subscriptionName] != null)
  //        ? this.wsDataMap[subscriptionName]
  //        : null;
  //  }
  //}

  Stream<dynamic> subscribeEverything(String vessel,Duration refreshRate) async* {
    //print("SUBSCRIBE EVERYTHING AT " + refreshRate.toString());
    Duration interval = refreshRate;//Duration(microseconds: 2000);
    int i = 0;
    while (true) {
      await Future.delayed(interval);

      try {
        if (this.wsDataTable[vessel] != null) {
          yield this.wsDataTable[vessel];
        } else {
          yield null;
        }
      }catch(e){
        yield null;
      }

    }
  }
}
