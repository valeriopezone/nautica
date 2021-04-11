import 'dart:async';
import 'dart:math';
import 'package:maps_toolkit/maps_toolkit.dart' as MTool;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nautica/Configuration.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';

import 'package:nautica/network/StreamSubscriber.dart';

const double CAMERA_ZOOM = 12;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;



class MapSample extends StatefulWidget {
  StreamSubscriber StreamObject = null;
  String currentVessel = "";

  MapSample(
      {Key key, @required this.StreamObject, @required this.currentVessel});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> with DisposableWidget {
  BaseModel model = BaseModel.instance;
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = Set<Marker>();
  double pinPillPosition = -100;

  BitmapDescriptor pinLocationIcon;

  LatLng LatLng_Value = null; // = LatLng(0.0,0.0);
  double HT_Value = 0.0; // = LatLng(0.0,0.0);
  Stream<dynamic> LatLng_Stream = null;
  Stream<dynamic> HT_Stream = null;

  List<Polyline> _polyLine = [];


  bool pinMarkerLoaded = false;
  bool firstCoordsLoaded = false;
  bool moreCoordsLoaded = false;


  Object redrawMap = Object();

  @override
  void initState() {
    super.initState();


    LatLng_Stream = _subscribeToStream("navigation.position");

    if (LatLng_Stream != null) {
      LatLng_Stream.listen((data) {
        if(data != null) {
          try {
            if (data["latitude"] != null && data["longitude"] != null) {
              if (LatLng_Value == null) {
                LatLng_Value = LatLng(data["latitude"], data["longitude"]);
                setState(() {
                  firstCoordsLoaded = true;
                });
              } else {
                if (data["latitude"] != LatLng_Value.latitude ||
                    data["longitude"] != LatLng_Value.longitude) {
                  if(!moreCoordsLoaded) moreCoordsLoaded = true;
                  LatLng_Value = LatLng(data["latitude"], data["longitude"]);
                  updatePinOnMap();
                }
              }
            }
          } catch (e) {}
        }

      }).canceledBy(this);
    }


    HT_Stream = _subscribeToStream("navigation.headingTrue");

    if (HT_Stream != null) {
      HT_Stream.listen((data) {
        if (data != null) {
          HT_Value = (data != null && data != 0) ? data : 0.0;
          //convert to deg
          //HT_Value = HT_Value * 180/pi;
          //print("LAT LNG : " + LatLng_Value.toString());
        }
      }).canceledBy(this);
    }

    setCustomMapPin();


  }

  Stream<dynamic> _subscribeToStream(String path){
    return widget.StreamObject.getVesselStream(widget.currentVessel,path,Duration(seconds: NAUTICA['configuration']['map']['refreshRate'])).asBroadcastStream();
  }


  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/boat_indicator_small.png');

    setState(() {
      pinMarkerLoaded = true;
    });
  }

  @override
  void dispose() {
    print("CANCEL MAPS SUBSCRIPTION");
    cancelSubscriptions();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition;
    if (firstCoordsLoaded && !moreCoordsLoaded) {

      initialCameraPosition = CameraPosition(
          zoom: CAMERA_ZOOM, bearing: CAMERA_BEARING, target: LatLng_Value);
    }
    if (moreCoordsLoaded) {
      initialCameraPosition = CameraPosition(
          target: LatLng(LatLng_Value.latitude, LatLng_Value.longitude),
          //zoom: CAMERA_ZOOM,
          bearing: CAMERA_BEARING);
    }

    return new Scaffold(
      //key: ValueKey<Object>(redrawMap),
      body: Stack(
        children: <Widget>[
          
          (!(firstCoordsLoaded && pinMarkerLoaded)) ? model.getLoadingPage() : (FutureBuilder(
            builder: (context, snapshot) {
              return GoogleMap(

                  myLocationEnabled: false,
                  compassEnabled: false,
                  tiltGesturesEnabled: false,
                  markers: _markers,
                  polylines: _polyLine.toSet(),
                  mapType: MapType.normal,
                  initialCameraPosition: initialCameraPosition,
                  onTap: (LatLng loc) {
                    pinPillPosition = -100;
                  },
                  onMapCreated: (GoogleMapController controller) {

                    controller.setMapStyle(model.currentMapTheme);
                    _controller.complete(controller);
                    showPinsOnMap();

                    model.addListener((){
                      if (mounted) {
                        controller.setMapStyle(model.currentMapTheme);

                      }
                    });


                  });
            }
          )

          ),
          MapPinPillComponent(
              pinPillPosition: pinPillPosition)
        ],
      ),
    );
  }


  void showPinsOnMap() {




    setState(() {

      _polyLine.add(Polyline(
        polylineId: PolylineId("route1"),
        color: Colors.red,
        patterns: [PatternItem.dash(20.0), PatternItem.gap(10)],
        width: 3,
        points: [
          LatLng_Value,
          polarToLatLong(LatLng_Value,5000,HT_Value)
        ],
      ));


      _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: LatLng_Value,
        anchor: const Offset(0.5, 0.5),
        icon: pinLocationIcon,
        rotation: HT_Value * 181 / pi,
        infoWindow: InfoWindow(title: widget.currentVessel, snippet: '*'),
        onTap: () {
          setState(() {
            pinPillPosition = 0;
          });
        },
      ));
    });
  }

  void updatePinOnMap() async {


    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(LatLng_Value.latitude, LatLng_Value.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    setState(() {

      var pinPosition = LatLng(LatLng_Value.latitude, LatLng_Value.longitude);

      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _polyLine.removeWhere((m) => m.polylineId.value == 'route1');


      setState(() {

        _polyLine.add(Polyline(
          polylineId: PolylineId("route1"),
          color: Colors.red,
          patterns: [PatternItem.dash(20.0), PatternItem.gap(10)],
          width: 3,
          points: [
            pinPosition,
            polarToLatLong(pinPosition,5000,HT_Value)
          ],
        ));




        _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition,
          icon: pinLocationIcon,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(title: widget.currentVessel, snippet: '*'),
          rotation: HT_Value*180/pi,
          onTap: () {
            setState(() {
              pinPillPosition = 0;
            });
          },
        ));
      });
    });
  }





  LatLng polarToLatLong(LatLng center, double dist, double radial) {
    MTool.LatLng pointerCoords = MTool.SphericalUtil.computeOffset(
        MTool.LatLng(center.latitude,center.longitude),
        dist,
      radial
    );
    print("CONVERT " + center.toString() + " " + (radial*180/pi).toString() + "°to " + pointerCoords.latitude.toString() + " : "+ pointerCoords.longitude.toString());

    return LatLng(pointerCoords.latitude,pointerCoords.longitude);

  }

}



class MapPinPillComponent extends StatefulWidget {
  double pinPillPosition;

  MapPinPillComponent({this.pinPillPosition});

  @override
  State<StatefulWidget> createState() => MapPinPillComponentState();
}

class MapPinPillComponentState extends State<MapPinPillComponent> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      bottom: widget.pinPillPosition,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.all(20),
          height: 70,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(50)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                      "ciao") //ClipOval(child: Image.asset(widget.currentlySelectedPin.avatarPath, fit: BoxFit.cover )),
                  ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("ciao")
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    "ciao2"), //Image.asset(widget.currentlySelectedPin.pinPath, width: 50, height: 50),
              )
            ],
          ),
        ),
      ),
    );
  }
}
