import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:async/async.dart' show StreamGroup;

class BoatVectorsIndicator extends StatelessWidget {
  dynamic ST_Value = 0;
  dynamic ATW_Value = 0;
  dynamic AA_Value = 0;
  dynamic SA_Value = 0;
  dynamic HT_Value = 0;
  dynamic COG_Value = 0;
  dynamic SOG_Value = 0;
  Stream<dynamic> ST_Stream = null;
  Stream<dynamic> ATW_Stream = null;
  Stream<dynamic> AA_Stream = null;
  Stream<dynamic> SA_Stream = null;
  Stream<dynamic> HT_Stream = null;
  Stream<dynamic> COG_Stream = null;
  Stream<dynamic> SOG_Stream = null;




  final String text;
  final Icon icon;
  final Function(String text, Icon icon) notifyParent;

  BoatVectorsIndicator(
      {Key key,
        @required this.ST_Stream,
        @required this.ATW_Stream,
        @required this.AA_Stream,
        @required this.SA_Stream,
        @required this.HT_Stream,
        @required this.COG_Stream,
        @required this.SOG_Stream,
        @required this.text,
        this.icon,
        this.notifyParent})
      : super(key: key) {
    ST_Stream.listen((data) {
      ST_Value = data;
    });

    ATW_Stream.listen((data) {
      ATW_Value = data;
    });

    AA_Stream.listen((data) {
      AA_Value = data;
    });

    SA_Stream.listen((data) {
      SA_Value = data;
    });

    HT_Stream.listen((data) {
      HT_Value = (data == null || data == 0) ? 0.0 : data;
    });

    COG_Stream.listen((data) {
      COG_Value = data;
    });

    SOG_Stream.listen((data) {
      SOG_Value = data;
    });




  }

  Stream<dynamic> getData() {
    //   return ST_Stream.combineLatest(ATQ_)
    return  StreamGroup.merge([ST_Stream, ATW_Value]);
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        notifyParent(text, icon);
      },
      child: StreamBuilder(
          stream: ATW_Stream,
          builder: (context, snap) {
            if (!snap.hasData) {
              return CircularProgressIndicator();
            }
            return Container(
                margin: const EdgeInsets.all(0.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: const Color(0xff7c94b6),
                  //image: const DecorationImage(
                  //  image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                  //  fit: BoxFit.cover,
                  //),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                        child :
                Transform.rotate(
                angle: (HT_Value),
                  child:
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff7c94b6),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          child: CustomPaint(
                            //                       <-- CustomPaint widget
                            size: Size(100, 200),
                            painter: DrawVectors(
                                angleTrueWater : ATW_Value,
                                speedTrue : ST_Value,
                                angleApparent : AA_Value,
                                speedApparent : SA_Value,
                                COG : COG_Value,
                                SOG : SOG_Value,
                                centerCoords : Offset(50,100)
                            ),
                          ),
                        )),
                    ),

                    //Center(
                    //child : Image(image: AssetImage('assets/boat.png'))),
                    Center(
                        child :Text(
                            "ATW: ${(ATW_Value.toStringAsFixed(4))}",
                            style: GoogleFonts.lato(
                                textStyle: Theme.of(context).textTheme.headline6))),
                    Center(
                        child :Text(
                            "ST: ${(ST_Value.toStringAsFixed(4))}",
                            style: GoogleFonts.lato(
                                textStyle: Theme.of(context).textTheme.headline6))),
                    Center(
                        child :Text(
                            "AA: ${(this.AA_Value.toStringAsFixed(4))}",
                            style: GoogleFonts.lato(
                                textStyle: Theme.of(context).textTheme.headline6))),
                    Center(
                        child :Text(
                            "SA: ${(this.SA_Value.toStringAsFixed(4))}",
                            style: GoogleFonts.lato(
                                textStyle: Theme.of(context).textTheme.headline6))),
                    Center(
                        child :Text(
                            "HT: ${(this.HT_Value.toStringAsFixed(4))}",
                            style: GoogleFonts.lato(
                                textStyle: Theme.of(context).textTheme.headline6))),
                    Center(
                        child :Text(
                            "COG: ${(this.COG_Value.toStringAsFixed(4))}",
                            style: GoogleFonts.lato(
                                textStyle: Theme.of(context).textTheme.headline6))),
                    Center(
                        child :Text(
                            "SOG: ${(this.SOG_Value.toStringAsFixed(4))}",
                            style: GoogleFonts.lato(
                                textStyle: Theme.of(context).textTheme.headline6))),
                  ],
                ));
          }),
    );
  }
}

class DrawVectors extends CustomPainter {

  Canvas mainCanvas;


  var l = 20; //length of every arrow side in pixels
  var t = 0.736332; //angle of arrow in radians

  double angleTrueWater = 0.0;
  double speedTrue = 0.0;
  double angleApparent = 0.0;
  double speedApparent = 100;
  double COG = 0;
  double SOG = 0;
  Offset centerCoords = Offset(0,0);

  DrawVectors({@required angleTrueWater,@required speedTrue,@required angleApparent,@required speedApparent,@required COG,@required SOG,@required this.centerCoords}){

    print("ANALIZE " + angleTrueWater.toString());
    this.angleTrueWater = (angleTrueWater == null || angleTrueWater == 0) ? 0.0 : (angleTrueWater as double);
    this.speedTrue = (speedTrue == 0) ? 0.0 : (speedTrue as double);
    this.angleApparent = (angleApparent == null || angleApparent == 0) ? 0.0 : (angleApparent as double);
    this.speedApparent = (speedApparent == 0) ? 0.0 : (speedApparent as double);
    this.COG = (COG == 0) ? 0.0 : (COG as double);
    this.SOG = (SOG == 0) ? 0.0 : (SOG as double);

  //make vector length fixed (for now)
    this.speedTrue = 100;
    this.speedApparent = 100;
    this.SOG = 100;
  }




  @override
  void paint(Canvas canvas, Size size) {
    this.mainCanvas = canvas;

    print("${angleTrueWater} - ${speedTrue} - ${angleApparent} - ${speedApparent}");


    //draw true vector
    double ATWx1 = this.centerCoords.dx + speedTrue*cos(angleTrueWater - pi/2);
    double ATWy1 = this.centerCoords.dy + speedTrue*sin(angleTrueWater - pi/2);

    List<Offset> vectorPoints = [this.centerCoords,Offset(ATWx1,ATWy1)];

    final ATW_Style = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    drawSingleVector(vectorPoints,angleTrueWater,ATW_Style,true,true);

    //draw apparent vector

    double AAx1 = this.centerCoords.dx + speedApparent*cos(angleApparent - pi/2);
    double AAy1 = this.centerCoords.dy + speedApparent*sin(angleApparent - pi/2);
     vectorPoints = [this.centerCoords,Offset(AAx1,AAy1)];

    final AA_Style = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    drawSingleVector(vectorPoints,angleApparent,AA_Style,true,true);


    //draw COG&SOG

    double CSx1 = this.centerCoords.dx + SOG*cos(COG - pi/2);
    double CSy1 = this.centerCoords.dy + SOG*sin(COG - pi/2);
    vectorPoints = [this.centerCoords,Offset(CSx1,CSy1)];

    final CS_Style = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    drawSingleVector(vectorPoints,COG,CS_Style,true,true);



    //draw middle line
    double MLx1 = size.width/2;
    double MLWy1 = 0;
    vectorPoints = [Offset(size.width/2,size.height),Offset(MLx1,MLWy1)];

    final ML_Style = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;


    drawSingleVector(vectorPoints,0,ML_Style,!true,true);



  }

  void drawSingleVector(List<Offset> coords, double angle,Paint paint, bool headArrow, bool baseArrow){

    mainCanvas.drawPoints(PointMode.polygon, coords, paint);

    double x0 = coords.elementAt(0).dx;
    double y0 = coords.elementAt(0).dy;
    double x1 = coords.elementAt(1).dx;
    double y1 = coords.elementAt(1).dy;

    if(headArrow) { //arrow pointing to head
      mainCanvas.drawLine(Offset(x1, y1), Offset(
          (x1 + l * cos(angle - pi / 2 - pi + t / 2)),
          (y1 + l * sin(angle - pi / 2 - pi + t / 2))), paint);
      mainCanvas.drawLine(Offset(x1, y1), Offset(
          (x1 + l * cos(angle - pi / 2 - pi - t / 2)),
          (y1 + l * sin(angle - pi / 2 - pi - t / 2))), paint);
    }

    if(baseArrow) { //arrow pointing to origin
      mainCanvas.drawLine(Offset(x0, y0), Offset(
          (x0 + l * cos(angle - pi / 2 + t / 2)),
          (y0 + l * sin(angle - pi / 2 + t / 2))), paint);
      mainCanvas.drawLine(Offset(x0, y0), Offset(
          (x0 + l * cos(angle - pi / 2 - t / 2)),
          (y0 + l * sin(angle - pi / 2 - t / 2))), paint);
    }

  }


  @override
  void paintCopy(Canvas canvas, Size size) {
    this.mainCanvas = canvas;

    print("${angleTrueWater} - ${speedTrue} - ${angleApparent} - ${speedApparent}");
    //draw true vector
    double x0 = 50.0;
    double y0 = 100.0;
    Offset base = Offset(x0,y0);
    double x1 = 0.0;
    double y1 = 0.0;

    x1 = x0 + speedTrue*cos(angleTrueWater - pi/2);
    y1 = y0 + speedTrue*sin(angleTrueWater - pi/2);

    final pointMode = PointMode.polygon;
    List<Offset> vectorPoints = [
      base,
      Offset(x1,y1)
    ];


    final paint = Paint()
      ..color = Colors.lightBlue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(pointMode, vectorPoints, paint);
    //arrow pointing to head
    //canvas.drawLine(Offset(x1,y1), Offset((x1 + l*cos(angle - pi/2 - pi + t/2)),(y1 + l*sin(angle - pi/2 - pi + t/2))), paint); // arrow right
    //canvas.drawLine(Offset(x1,y1), Offset((x1 + l*cos(angle - pi/2 - pi - t/2)),(y1 + l*sin(angle - pi/2 - pi - t/2))), paint); // arrow right

    //arrow pointing to origin
    canvas.drawLine(Offset(x0,y0), Offset((x0 + l*cos(angleTrueWater - pi/2 + t/2)),(y0 + l*sin(angleTrueWater - pi/2  + t/2))), paint); // arrow right
    canvas.drawLine(Offset(x0,y0), Offset((x0 + l*cos(angleTrueWater - pi/2 - t/2)),(y0 + l*sin(angleTrueWater - pi/2  - t/2))), paint); // arrow right


    //draw apparent vector




  }






  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
