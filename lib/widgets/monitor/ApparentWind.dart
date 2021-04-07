import 'package:google_fonts/google_fonts.dart';
import 'package:nautica/Widget.dart';
import 'package:flutter/material.dart';

class ApparentWindIndicator extends UIWidget {
  dynamic apparentWindValue;
  dynamic realWindValue;
  Stream<dynamic> apparentWindStream = null;
  Stream<dynamic> realWindStream = null;

  void subscribeApparentWind(Stream<dynamic> stream) {
    print("subscribe apparent wind");
    this.apparentWindStream = stream;
    final sub = stream.listen((data) {
      this.apparentWindValue = data; //.toDouble();
      //print(this.streamVal);
    });
  }

  void subscribeRealWindSpeed(Stream<dynamic> stream) {
    print("subscribe real wind");
    this.realWindStream = stream;
    final sub = stream.listen((data) {
      this.realWindValue = data; //.toDouble();
      //print(this.streamVal);
    });
  }



  dynamic getBuildStream() {
    return
      StreamBuilder(
          stream: this.apparentWindStream,
          builder: (context, snap) {
            print("WANT BUILD");
            if (!snap.hasData) {
              return CircularProgressIndicator();
            }
            return Text(
                "Apparent Wind : ${_getApparentWindFromSnap(snap.data)}",
                style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.headline4));
          });
  }


  dynamic buildWidget() {


    return Container(
        height: 200,
        width: 200,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
      StreamBuilder(
          stream: this.apparentWindStream,
          builder: (context, snap) {
            print("WANT BUILD");
            if (!snap.hasData) {
              return CircularProgressIndicator();
            }
            return Text(
                "Apparent Wind : ${_getApparentWindFromSnap(snap.data)}",
                style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.headline4));
          }),
      StreamBuilder(
          stream: this.realWindStream,
          builder: (context, snap) {
            print("WANT BUILD");
            if (!snap.hasData) {
              return CircularProgressIndicator();
            }
            return Text(
                "Real Wind : ${_getApparentWindFromSnap(snap.data)}",
                style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.headline4));
          })
    ]));
  }

  String _getApparentWindFromSnap(snapData) {
    if (snapData == null) return 0.toStringAsFixed(2);
    return snapData.toStringAsFixed(2);
  }

  String _getRealWindFromSnap(snapData) {
    if (snapData == null) return 0.toStringAsFixed(2);
    return snapData.toStringAsFixed(2);
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
