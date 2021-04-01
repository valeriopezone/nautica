import 'package:nautica/Widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GPSWidget extends UIWidget {
  dynamic positionData;
  Stream<dynamic> positionStream = null;

  Stream<dynamic> getStream() async* {
    Duration interval = Duration(seconds: 1);
    int i = 0;
    while (true) {
      await Future.delayed(interval);
      yield i++;
    }
  }

  void subscribePosition(Stream<dynamic> stream) {
    print("subscribe position");
    this.positionStream = stream;
    final sub = stream.listen((data) {
      this.positionData = data;
      //print(this.streamVal);
    });
  }

  dynamic getBuildStream() {
    return StreamBuilder(
        stream: this.positionStream,
        builder: (context, snap) {
          print("WANT BUILD");
          if (!snap.hasData) {
            return CircularProgressIndicator();
          }

          return Column(children: <Widget>[
            Text("Lon : ${_getLongitudeFromSnap(snap.data)}",
                style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.headline4)),
            Text("Lat : ${_getLatitudeFromSnap(snap.data)}",
                style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.headline4))
          ]);
        });
  }

  String _getLatitudeFromSnap(snapData) {
    if (snapData == null || snapData == 0) return 0.toStringAsFixed(5);
    if (snapData['latitude'] != null) return snapData['latitude'].toStringAsFixed(5);
    return 0.toStringAsFixed(5);

  }


  String _getLongitudeFromSnap(snapData) {
    if (snapData == null || snapData == 0) return 0.toStringAsFixed(5);
    if (snapData['longitude'] != null) return snapData['longitude'].toStringAsFixed(5);
    return 0.toStringAsFixed(5);
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
