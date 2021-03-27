import 'package:nautica/Widget.dart';
import 'package:flutter/material.dart';

class GPSWidget extends UIWidget{
dynamic positionData;
Stream<dynamic> positionStream = null;


Stream<dynamic> getStream() async*{
  Duration interval = Duration(seconds: 1);
  int i = 0;
  while (true) {
    await Future.delayed(interval);
    yield i++;
  }
}


void subscribePosition(Stream<dynamic> stream){
print("subscribe position");
this.positionStream = stream;
  final sub = stream.listen((data) {   this.positionData = data;
  //print(this.streamVal);
    });

}




  dynamic getBuildStream(){
   return StreamBuilder(
       stream: this.positionStream,
       builder: (context, snap) {
         print("WANT BUILD");
          if(!snap.hasData){
              return CircularProgressIndicator();
          }
         return Text("${snap.data.toString()}");
       });
  }

/*
 return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        Chip(
          avatar: CircleAvatar(backgroundColor: Colors.blue.shade900, child: Text('AS')),
          label: Text("lat = " + vv.toString()),
        ),
      ],
    );

 */
}