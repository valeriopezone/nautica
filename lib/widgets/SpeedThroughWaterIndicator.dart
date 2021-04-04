import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeedThroughWaterIndicator extends StatelessWidget {
  dynamic STW_Value;
  Stream<dynamic> STW_Stream = null;

  final String text;
  final Icon icon;
  final Function(String text, Icon icon) notifyParent;

  SpeedThroughWaterIndicator({Key key, @required this.STW_Stream,@required this.text, this.icon, this.notifyParent}) : super(key: key){
    STW_Stream.listen((data) {
      STW_Value = data;
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        notifyParent(text, icon);
      },
      child: StreamBuilder(
          stream: STW_Stream,
          builder: (context, snap) {
            if (!snap.hasData) {
              return CircularProgressIndicator();
            }
            return Text(
                "Speed through water: ${(snap.data.toStringAsFixed(2))}",
                style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.headline4));
          }),
    );
  }

}