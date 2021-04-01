import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PositionIndicator extends StatelessWidget {
  dynamic Position_Value;
  Stream<dynamic> Position_Stream = null;

  final String text;
  final Icon icon;
  final Function(String text, Icon icon) notifyParent;

  PositionIndicator({Key key, @required this.Position_Stream,@required this.text, this.icon, this.notifyParent}) : super(key: key){
    Position_Stream.listen((data) {
      Position_Value = data;
    });
  }





  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        notifyParent(text, icon);
      },
      child: StreamBuilder(
          stream: Position_Stream,
          builder: (context, snap) {
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
          }),
    );
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


}