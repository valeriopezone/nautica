import 'package:nautica/SignalKClient.dart';
import 'package:websocket_manager/websocket_manager.dart';

class StreamSubscriber{
  SignalKClient client = null;
  WebsocketManager SKWebSocket = null;
  var subscriptionList;//TODO


  StreamSubscriber(this.client) {
    //check connection status
  print("[StreamSubscriber] connect to " + this.client.getWSUrl());
    //connect to websocket
  this.reconnectToStream();
    //set listener
  }




  void reconnectToStream(){
  //subscribe to stream

  }

  void socketListener(){
    //update internal vars
  }


  void getStream(String streamToSubscribe){

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