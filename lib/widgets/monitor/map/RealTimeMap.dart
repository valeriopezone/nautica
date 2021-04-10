import 'dart:async';
import 'dart:math';

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



/*
    _polyLine.add(Polyline(
      polylineId: PolylineId("route1"),
      color: Colors.blue,
      patterns: [PatternItem.dash(20.0), PatternItem.gap(10)],
      width: 3,
      points: [
        SOURCE_LOCATION,
        DEST_LOCATION,
      ],
    ));

    _polyLine.add(Polyline(
      polylineId: PolylineId("route1"),
      color: Colors.red,
      patterns: [PatternItem.dash(20.0), PatternItem.gap(10)],
      width: 3,
      points: [
        SOURCE_LOCATION,
        polarToLatLong(SOURCE_LOCATION,8000,180)
      ],
    ));
*/

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
      print("setup first cordS");

      initialCameraPosition = CameraPosition(
          zoom: CAMERA_ZOOM, bearing: CAMERA_BEARING, target: LatLng_Value);
    }
    if (moreCoordsLoaded) {
      print("ADD MORE COORDS");
      initialCameraPosition = CameraPosition(
          target: LatLng(LatLng_Value.latitude, LatLng_Value.longitude),
          //zoom: CAMERA_ZOOM,
          bearing: CAMERA_BEARING);
    }

    return new Scaffold(
      //key: ValueKey<Object>(redrawMap),
      body: Stack(
        children: <Widget>[
          
          (!(firstCoordsLoaded && pinMarkerLoaded)) ? Container(child: Text("loading")) : (FutureBuilder(
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
                    print("PINS SHOWED ON MAP");

                    model.addListener((){
                      if (mounted) {
                        print("THEME CHANGED");
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
      _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: LatLng_Value,
        icon: pinLocationIcon,
        rotation: HT_Value,
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

      print("updating with " + LatLng_Value.toString());
    setState(() {

      var pinPosition = LatLng(LatLng_Value.latitude, LatLng_Value.longitude);

      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition,
          icon: pinLocationIcon,
          infoWindow: InfoWindow(title: widget.currentVessel, snippet: '*'),
          rotation: HT_Value,
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
    if (dist == 0) {
      // distance zero, so just return the point
      return center;
    } else if (center.latitude > 89.9999) {
      // North Pole singularity. Dist is in NM.

      return LatLng(90 - dist / 60, ((radial % 180) - 180));
    } else {
      // normal case
      double sinlat, coslon, outlat, outlon;
      dist /= 3442; // = Earth's radius in nm (not WGS84!)
      sinlat = dgSin(center.latitude) * cos(dist) +
          dgCos(center.latitude) * sin(dist) * dgCos(radial);
      outlat = dgArcsin(sinlat);
      coslon = (cos(dist) - dgSin(center.latitude) * sinlat) /
          (dgCos(center.latitude) * dgCos(outlat));
      outlon = center.longitude +
          (dgSin(radial) >= 0.0 ? -1.0 : 1.0) * dgArccos(coslon);

      return LatLng(outlat, outlon);
    }
  }

  double dgSin(double deg) {
    return sin(deg * (pi / 180));
  } // wrappers for degrees

  double dgCos(double deg) {
    return cos(deg * (pi / 180));
  }

  double dgArcsin(double x) {
    return asin(dgClamp(-1, x, 1)) * (180 / pi);
  }

  double dgArccos(double x) {
    return acos(dgClamp(-1, x, 1)) * (180 / pi);
  }

  double dgClamp(double a, double x, double b) {
    return min(max(a, x), b);
  }

}

class Utils {

  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8ec3b9"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1a3646"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#64779e"
      }
    ]
  },
  {
    "featureType": "administrative.neighborhood",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#334e87"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6f9ba5"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3C7680"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#304a7d"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2c6675"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#255763"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#b0d5ce"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "road.local",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3a4762"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#0e1626"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#4e6d70"
      }
    ]
  }
]''';
  static String mapStyles2 = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
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
