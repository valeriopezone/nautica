import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeedOverGroundIndicator extends StatelessWidget {
  dynamic SOG_Value;
  Stream<dynamic> SOG_Stream = null;

  final String text;
  final Icon icon;
  final Function(String text, Icon icon) notifyParent;

  SpeedOverGroundIndicator({Key key, @required this.SOG_Stream,@required this.text, this.icon, this.notifyParent}) : super(key: key){
    SOG_Stream.listen((data) {
      SOG_Value = data;
    });
  }




/*
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        notifyParent(text, icon);
      },
      child: Card(
        child: Center(
            child: icon == null
                ? Text(
              "ciao",
              style: TextStyle(fontSize: 38),
            )
                : icon),
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        notifyParent(text, icon);
      },
      child: StreamBuilder(
            stream: SOG_Stream,
          builder: (context, snap) {
            if (!snap.hasData) {
              return CircularProgressIndicator();
            }
            return Text(
                "Speed : ${(snap.data)}",
                style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.headline4));
          }),
    );
  }

}