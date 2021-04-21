import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';

class BoatVectorsIndicator extends StatefulWidget {
  BaseModel model;
  dynamic ST_Value = 0;
  dynamic ATW_Value = 0;
  dynamic AA_Value = 0;
  dynamic SA_Value = 0;
  dynamic HT_Value = 0;
  dynamic COG_Value = 0;
  dynamic SOG_Value = 0;
  dynamic Lat_Value = 0;
  dynamic Lng_Value = 0;
  dynamic DBK_Value = 0;
  dynamic DBS_Value = 0;
  dynamic DBT_Value = 0;
  dynamic DBST_Value = 0;
  Stream<dynamic> ST_Stream = null;
  Stream<dynamic> ATW_Stream = null;
  Stream<dynamic> AA_Stream = null;
  Stream<dynamic> SA_Stream = null;
  Stream<dynamic> HT_Stream = null;
  Stream<dynamic> COG_Stream = null;
  Stream<dynamic> SOG_Stream = null;
  Stream<dynamic> LatLng_Stream = null;
  Stream<dynamic> DBK_Stream = null;
  Stream<dynamic> DBS_Stream = null;
  Stream<dynamic> DBT_Stream = null;
  Stream<dynamic> DBST_Stream = null;







  final Function(String text, Icon icon) notifyParent;

  BoatVectorsIndicator({Key key,
    @required this.model,
    @required this.ST_Stream,
    @required this.ATW_Stream,
    @required this.AA_Stream,
    @required this.SA_Stream,
    @required this.HT_Stream,
    @required this.COG_Stream,
    @required this.SOG_Stream,
    @required this.LatLng_Stream,
    @required this.DBK_Stream,
    @required this.DBS_Stream,
    @required this.DBT_Stream,
    @required this.DBST_Stream,
    this.notifyParent}) : super(key:key);


  @override
  _BoatVectorsIndicatorState createState() => _BoatVectorsIndicatorState();
}

class _BoatVectorsIndicatorState extends State<BoatVectorsIndicator> with DisposableWidget{

  ui.Image boatImage;
  bool isImageloaded = false;


  void initState() {
    super.initState();


    if(widget.ST_Stream != null) {
      widget.ST_Stream.listen((data) {
        widget.ST_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }

    if(widget.ATW_Stream != null) {
      widget.ATW_Stream.listen((data) {
        widget.ATW_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }

    if(widget.AA_Stream != null) {
      widget.AA_Stream.listen((data) {
        widget.AA_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }

    if(widget.SA_Stream != null) {
      widget.SA_Stream.listen((data) {
        widget.SA_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }

    if(widget.HT_Stream != null) {
      widget.HT_Stream.listen((data) {
        widget.HT_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }

    if(widget.COG_Stream != null) {
      widget.COG_Stream.listen((data) {
        widget.COG_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }

    if(widget.SOG_Stream != null) {
      widget.SOG_Stream.listen((data) {
        widget.SOG_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }
    if(widget.DBK_Stream != null) {
      widget.DBK_Stream.listen((data) {
        widget.DBK_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }
    if(widget.DBS_Stream != null) {
      widget.DBS_Stream.listen((data) {
        widget.DBS_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }
    if(widget.DBT_Stream != null) {
      widget.DBT_Stream.listen((data) {
        widget.DBT_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }
    if(widget.DBST_Stream != null) {
      widget.DBST_Stream.listen((data) {
        widget.DBST_Value = (data == null || data == 0) ? 0.0 : data.toDouble();
      }).canceledBy(this);
    }

    if (widget.LatLng_Stream != null) {
      widget.LatLng_Stream.listen((data) {
        if(data != null) {
          try {
            if (data["latitude"] != null && data["longitude"] != null) {
              widget.Lat_Value = (data["latitude"] != 0) ? data["latitude"] : 0.0;
              widget.Lng_Value = (data["longitude"] != 0) ? data["longitude"] : 0.0;
            }
          } catch (e) {}
        }

      }).canceledBy(this);
    }


    init();
  }


  @override
  void dispose() {
   // print("CANCEL BOAT VECTORS SUBSCRIPTION");
    cancelSubscriptions();
    super.dispose();
  }

  Future <Null> init() async {
    final ByteData data = await rootBundle.load('assets/boat_indicator_small.png');
    boatImage = await loadImage(new Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      //setState(() {
        isImageloaded = true;
      //});
      return completer.complete(img);
    });
    return completer.future;
  }
 /* Stream<dynamic> getData() {
    //   return ST_Stream.combineLatest(ATQ_)
    return  StreamGroup.merge([ST_Stream, ATW_Value]);
  }*/



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //notifyParent(text, icon);
      },
      child: StreamBuilder(
          stream: widget.ATW_Stream,
          builder: (context, snap) {
            //if (!snap.hasData) {
            //  return CircularProgressIndicator();
            //}
            return Container(
                margin: const EdgeInsets.all(0.0),
                padding: const EdgeInsets.all(5.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                        child :
                Transform.rotate(
                angle: (widget.HT_Value != null && widget.HT_Value != 0 ? widget.HT_Value : 0.0),
                  child:
                        Container(
                          /*decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 0,
                            ),
                          ),*/
                          child: CustomPaint(
                            //                       <-- CustomPaint widget
                            size: Size(100, 200),
                            painter: DrawVectors(
                              model : widget.model,
                              boatVector: boatImage,
                                angleTrueWater : widget.ATW_Value,
                                speedTrue : widget.ST_Value,
                                angleApparent : widget.AA_Value,
                                speedApparent : widget.SA_Value,
                                COG : widget.COG_Value,
                                SOG : widget.SOG_Value,
                                centerCoords : Offset(50,100)
                            ),
                          ),
                        )),
                    ),
                    Padding(padding: EdgeInsets.only(top: 15)),


                      Column(
                        children: [
                          Text("Lat : " + widget.Lat_Value.toStringAsFixed(7),style: TextStyle(
                              color: widget.model.paletteColor,
                              fontSize: 24,
                              fontFamily: 'Roboto-Bold'),),
                          Text("Lon : " + widget.Lng_Value.toStringAsFixed(7),style: TextStyle(
                              color: widget.model.paletteColor,
                              fontSize: 24,
                              fontFamily: 'Roboto-Bold'),),
                          Text("DBK : " + widget.DBK_Value.toStringAsFixed(2),style: TextStyle(
                              color: widget.model.paletteColor,
                              fontSize: 24,
                              fontFamily: 'Roboto-Bold'),),
                          Text("DBS : " + widget.DBS_Value.toStringAsFixed(2),style: TextStyle(
                              color: widget.model.paletteColor,
                              fontSize: 24,
                              fontFamily: 'Roboto-Bold'),),
                          Text("DBT : " + widget.DBT_Value.toStringAsFixed(2),style: TextStyle(
                              color: widget.model.paletteColor,
                              fontSize: 24,
                              fontFamily: 'Roboto-Bold'),),
                          Text("DBST : " + widget.DBST_Value.toStringAsFixed(2),style: TextStyle(
                              color: widget.model.paletteColor,
                              fontSize: 24,
                              fontFamily: 'Roboto-Bold'),),
                        ],
                      )
                    ,
                    //Center(
                    //child : Image(
                    //    image: AssetImage('assets/boat.png'),
                    //  height:140,
                    //)),
                    //Center(
                    //    child :Text(
                    //        "ATW: ${(widget.ATW_Value.toStringAsFixed(4))} AA: ${(widget.AA_Value.toStringAsFixed(4))}",
                    //        style: GoogleFonts.lato(
                    //            textStyle: Theme.of(context).textTheme.headline6))),
                    //Center(
                    //    child :Text(
                    //        "ST: ${(widget.ST_Value.toStringAsFixed(4))} SA: ${(widget.SA_Value.toStringAsFixed(4))}",
                    //        style: GoogleFonts.lato(
                    //            textStyle: Theme.of(context).textTheme.headline6))),
//
                    //Center(
                    //    child :Text(
                    //        "HT: ${(widget.HT_Value.toStringAsFixed(4))} COG: ${(widget.COG_Value.toStringAsFixed(4))} SOG: ${(widget.SOG_Value.toStringAsFixed(4))}",
                    //        style: GoogleFonts.lato(
                    //            textStyle: Theme.of(context).textTheme.headline6))),

                  ],
                ));
          }),
    );
  }
}

class DrawVectors extends CustomPainter {

  Canvas mainCanvas;
  BaseModel model = BaseModel.instance;
  ui.Image boatVector;
  var l = 20; //length of every arrow side in pixels
  var t = 0.736332; //angle of arrow in radians

  double angleTrueWater = 0.0;
  double speedTrue = 0.0;
  double angleApparent = 0.0;
  double speedApparent = 100;
  double COG = 0;
  double SOG = 0;
  Offset centerCoords = Offset(0,0);
  double minVectorLength = 20.0;
  double maxVectorLength = 100.0;
  DrawVectors({@required this.model,@required this.boatVector,@required angleTrueWater,@required speedTrue,@required angleApparent,@required speedApparent,@required COG,@required SOG,@required this.centerCoords}){


    this.angleTrueWater = (angleTrueWater == null || angleTrueWater == 0) ? 0.0 : (angleTrueWater as double);
    this.speedTrue = (speedTrue == 0) ? 0.0 : (speedTrue as double);
    this.angleApparent = (angleApparent == null || angleApparent == 0) ? 0.0 : (angleApparent as double);
    this.speedApparent = (speedApparent == 0) ? 0.0 : (speedApparent as double);
    this.COG = (COG == 0) ? 0.0 : (COG as double);
    this.SOG = (SOG == 0) ? 0.0 : (SOG as double);

  //make vector length fixed (for now)
    this.speedTrue = mapRange(this.speedTrue,0,50,minVectorLength,maxVectorLength);
    this.speedApparent = mapRange(this.speedApparent,0,50,minVectorLength,maxVectorLength);
    this.SOG = mapRange(this.SOG,0,50,minVectorLength,maxVectorLength);

  }

  @override
  void paint(Canvas canvas, Size size) {
    this.mainCanvas = canvas;

  //  print("${angleTrueWater} - ${speedTrue} - ${angleApparent} - ${speedApparent}");

  if(boatVector != null) mainCanvas.drawImage(boatVector, new Offset(size.width/4, size.height/4 - 20), new Paint());



    //draw true vector
    double ATWx1 = this.centerCoords.dx + speedTrue*cos(angleTrueWater - pi/2);
    double ATWy1 = this.centerCoords.dy + speedTrue*sin(angleTrueWater - pi/2);

    List<Offset> vectorPoints = [this.centerCoords,Offset(ATWx1,ATWy1)];

    final ATW_Style = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    drawSingleVector(vectorPoints,angleTrueWater,ATW_Style,false,true);

    //draw apparent vector

    double AAx1 = this.centerCoords.dx + speedApparent*cos(angleApparent - pi/2);
    double AAy1 = this.centerCoords.dy + speedApparent*sin(angleApparent - pi/2);
     vectorPoints = [this.centerCoords,Offset(AAx1,AAy1)];

    final AA_Style = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    drawSingleVector(vectorPoints,angleApparent,AA_Style,false,true);


    //draw COG&SOG

    double CSx1 = this.centerCoords.dx + SOG*cos(COG - pi/2);
    double CSy1 = this.centerCoords.dy + SOG*sin(COG - pi/2);
    vectorPoints = [this.centerCoords,Offset(CSx1,CSy1)];

    final CS_Style = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    drawSingleVector(vectorPoints,COG,CS_Style,true,false);



    //draw vertical middle line
    double MLx1 = size.width/2;
    double MLWy1 = 0;
    double MLx2 = 0;
    double MLWy2 = size.height/2;
    vectorPoints = [Offset(size.width/2,size.height),Offset(MLx1,MLWy1)];

    final ML_Style = Paint()
      ..color = model.textColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    drawSingleVector(vectorPoints,0,ML_Style,true,false);

    vectorPoints = [Offset(size.width,size.height/2),Offset(MLx2,MLWy2)];
    drawSingleVector(vectorPoints,0,ML_Style,false,false);



  }

  void drawSingleVector(List<Offset> coords, double angle,Paint paint, bool headArrow, bool baseArrow){

    mainCanvas.drawPoints(ui.PointMode.polygon, coords, paint);

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

    //print("${angleTrueWater} - ${speedTrue} - ${angleApparent} - ${speedApparent}");
    //draw true vector
    double x0 = 50.0;
    double y0 = 100.0;
    Offset base = Offset(x0,y0);
    double x1 = 0.0;
    double y1 = 0.0;

    x1 = x0 + speedTrue*cos(angleTrueWater - pi/2);
    y1 = y0 + speedTrue*sin(angleTrueWater - pi/2);

    final pointMode = ui.PointMode.polygon;
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
