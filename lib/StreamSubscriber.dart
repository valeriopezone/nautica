import 'package:nautica/SignalKClient.dart';
import 'package:websocket_manager/websocket_manager.dart';
import 'Configuration.dart';
import 'dart:convert' as convert;

class StreamSubscriber {
  SignalKClient client = null;
  WebsocketManager SKWebSocket = null;
  var subscriptionList; //TODO
  int streamRefreshRate = NAUTICA['configuration']['widget']['refreshRate'];
  int lastWSMessageDate;
  dynamic wsRawData;

  Map<String, dynamic> wsDataMap;

  StreamSubscriber(this.client) {
    //generate config map
    setPathMap();
  }

  void setPathMap() {
    this.wsDataMap = Map.fromEntries(
        getWidgetSubscriptionMap().entries.map((e) => MapEntry(e.key, 0)));
    print(this.wsDataMap);
  }

  Future<void> reconnectToStream() async {
    //subscribe to stream
    this.lastWSMessageDate = DateTime.now().millisecondsSinceEpoch;
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

  Future<void> startListening() async {
    //check connection status
    print("[StreamSubscriber] connect to " + this.client.getWSUrl());
    //connect to websocket
    return await this.reconnectToStream();
  }

  void onMessageCallback(dynamic msg) {
    this.wsRawData = msg;

    dynamic dec = convert.jsonDecode(this.wsRawData);
    String givenPath = "";
    dynamic streamedParams;

    if (dec != null &&
        dec['updates'] != null &&
        dec['updates'][0] != null &&
        dec['updates'][0]['values'] != null) {
      //todo fix nullable error
      streamedParams = dec['updates'][0]['values'];
      if (streamedParams is List<dynamic>) {
        streamedParams.forEach((param) {
          //check for path and value
          if (param["path"] != null && param["value"] != null) {
            var subscriptionName = getSubscriptionSlugByFullName(param["path"]);
            if (subscriptionName.isNotEmpty &&
                this.wsDataMap[subscriptionName] != null) {
                  this.wsDataMap[subscriptionName] = param["value"];
              //print("[onMessageCallback] $subscriptionName set to");
              //  print(this.wsDataMap);
            }
          }
        });
      }
    }
  }

  void onCloseCallback() {
    //...
  }

  Stream<dynamic> getStream(String subscriptionName) async* {
    Duration interval = Duration(microseconds: 300);
    int i = 0;
    while (true) {
      await Future.delayed(interval);
      yield (this.wsDataMap[subscriptionName] != null)
          ? this.wsDataMap[subscriptionName]
          : null;
    }
  }
}
