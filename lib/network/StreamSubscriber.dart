import 'package:SKDashboard/network/SignalKClient.dart';
import 'package:websocket_manager/websocket_manager.dart';
import 'package:SKDashboard/Configuration.dart';
import 'dart:convert' as convert;

class StreamSubscriber {
  SignalKClient client;
  WebsocketManager SKWebSocket;

  int streamRefreshRate = CONF['configuration']['widget']['refreshRate'];
  DateTime lastWSMessageDate;
  dynamic wsRawData;

  Map<String, Map<String, dynamic>> wsDataTable = new Map();
  Map<String, Map<String, dynamic>> wsTimeTable = new Map();

  StreamSubscriber(this.client);

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
  }

  Future<void> reconnectToStream() async {
    if (this.client.isLoaded()) {
      this.lastWSMessageDate = DateTime.now();

      initDataTable();
      return await this.client.WSconnect(this.onCloseCallback, this.onMessageCallback).then((wsResponse) {
        //connected
      }).catchError((Object onError) {
        print('[reconnectToStream] Unable to connect -- on error : $onError');
        return Future.error("UNABLE TO CONNECT TO STREAM");
      });
    }
  }

  bool isWebsocketDisconnected() {
    int delta = (DateTime.now()).difference(lastWSMessageDate).inSeconds;
    return (delta > CONF['configuration']['connection']['websocket']['timeout']);
  }

  Future<void> startListening() async {
    print("[startListening] connect to " + this.client.getWSUrl());
    return await this.reconnectToStream();
  }

  void onMessageCallback(dynamic msg) {
    this.wsRawData = msg;
    this.lastWSMessageDate = DateTime.now();

    try {
      dynamic dec = convert.jsonDecode(this.wsRawData);
      dynamic streamedParams, timeParam;

      if (dec != null && dec['context'] != null && dec['updates'] != null && dec['updates'][0] != null && dec['updates'][0]['values'] != null) {
        try {
          timeParam = dec['updates'][0]['timestamp'];
        } catch (e) {
          print("[onMessageCallback] Unable to decode time");
        }

        streamedParams = dec['updates'][0]['values'];

        if (streamedParams is List<dynamic>) {
          streamedParams.forEach((param) {
            //check for path and value
            if (dec["context"].toString() != "" && param["path"] != null && param["path"].toString().isNotEmpty && param["value"] != null) {
              try {
                this.wsDataTable[dec["context"].toString()][param["path"].toString()] = param["value"];
              } catch (e) {}

              try {
                this.wsTimeTable[dec["context"].toString()][param["path"].toString()] = timeParam;
              } catch (e) {}
            }
          });
        }
      }
    } catch (e) {
      print("[onMessageCallback] unable to decode json");
    }
  }

  void onCloseCallback() {
    //...
    print("[onCloseCallback] STREAM SUBSCRIBER CLOSING CALLBACK");
  }

  Stream<dynamic> getVesselStream(String vessel, String subscriptionName, Duration refreshRate) async* {
    Duration interval = refreshRate;
    while (true) {
      await Future.delayed(interval);
      if (vessel == null || subscriptionName == null) yield null;

      try {
        if (this.wsDataTable[vessel] != null && this.wsDataTable[vessel][subscriptionName] != null) {
          yield this.wsDataTable[vessel][subscriptionName];
        } else {
          yield null;
        }
      } catch (e) {
        yield null;
      }
    }
  }

  Stream<dynamic> getTimedVesselStream(String vessel, String subscriptionName, Duration refreshRate) async* {
    Duration interval = refreshRate;

    while (true) {
      await Future.delayed(interval);
      try {
        if (this.wsDataTable[vessel] != null && this.wsDataTable[vessel][subscriptionName] != null) {
          yield {"value": this.wsDataTable[vessel][subscriptionName], "timestamp": this.wsTimeTable[vessel][subscriptionName]};
        } else {
          yield {"value": 0.0, "timestamp": null};
        }
      } catch (e) {
        yield {"value": 0.0, "timestamp": null};
      }
    }
  }

  Stream<dynamic> subscribeEverything(String vessel, Duration refreshRate) async* {
    Duration interval = refreshRate;
    while (true) {
      await Future.delayed(interval);

      try {
        if (this.wsDataTable[vessel] != null) {
          yield this.wsDataTable[vessel];
        } else {
          yield null;
        }
      } catch (e) {
        yield null;
      }
    }
  }
}
