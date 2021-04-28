import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nautica/Configuration.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/models/Helper.dart';

import 'package:nautica/network/StreamSubscriber.dart';
import 'package:nautica/utils/flutter_map/flutter_map.dart';

class LeafLetMap extends StatefulWidget {
  StreamSubscriber StreamObject = null;
  String currentVessel = "";

  LeafLetMap({Key key, @required this.StreamObject, @required this.currentVessel});

  @override
  State<LeafLetMap> createState() => LeafLetMapState();
}

class LeafLetMapState extends State<LeafLetMap> with DisposableWidget, TickerProviderStateMixin {
  MapController mapController;
  BaseModel model = BaseModel.instance;

  LatLng LatLng_Value = null;
  double HT_Value = 0.0;

  Stream<dynamic> LatLng_Stream = null;
  Stream<dynamic> HT_Stream = null;

  bool pinMarkerLoaded = false;
  bool firstCoordsLoaded = false;
  bool moreCoordsLoaded = false;
  double currentZoom = 17;

  List<Marker> markers = <Marker>[];
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    LatLng_Stream = _subscribeToStream("navigation.position");

    if (LatLng_Stream != null) {
      LatLng_Stream.listen((data) {
        if (data != null) {
          try {
            if (data["latitude"] != null && data["longitude"] != null) {
              if (LatLng_Value == null) {
                LatLng_Value = LatLng(data["latitude"], data["longitude"]);
                _updatePinOnMap(LatLng_Value, currentZoom);
                setState(() {
                  firstCoordsLoaded = true;
                });
              } else {
                if (data["latitude"] != LatLng_Value.latitude || data["longitude"] != LatLng_Value.longitude) {
                  if (!moreCoordsLoaded) moreCoordsLoaded = true;
                  LatLng_Value = LatLng(data["latitude"], data["longitude"]);
                  _updatePinOnMap(LatLng_Value, mapController.zoom);
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
        }
      }).canceledBy(this);
    }

    mapController = MapController();
  }

  Stream<dynamic> _subscribeToStream(String path) {
    return widget.StreamObject.getVesselStream(widget.currentVessel, path, Duration(seconds: NAUTICA['configuration']['map']['refreshRate'])).asBroadcastStream();
  }

  @override
  void dispose() {
    print("CANCEL MAPS SUBSCRIPTION");
    cancelSubscriptions();
    if (controller != null) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updatePinOnMap(LatLng destLocation, double destZoom) {
    markers = [];

    markers.add(Marker(
      width: 80.0,
      height: 80.0,
      point: destLocation,
      rotate: true,
      rotateOrigin: Offset(0.0, 0.0),
      builder: (ctx) => Container(
          key: Key('marker'),
          child: Transform.rotate(angle: (HT_Value != null && HT_Value != 0 ? HT_Value : 0.0), child: Image(image: AssetImage('assets/boat_indicator_dashboard.png')))),
    ));

    setState(() {});

    final _latTween = Tween<double>(begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);
    controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)), _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (controller != null) {
          controller.dispose();
        }
      } else if (status == AnimationStatus.dismissed) {
        if (controller != null) {
          controller.dispose();
        }
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(0.0),
        child: Stack(
          children: [
            Column(
              children: [
                Flexible(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(center: LatLng(51.5, -0.09), zoom: 5.0, maxZoom: 25.0, minZoom: 3.0),
                    layers: [
                      TileLayerOptions(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        backgroundColor: Colors.transparent,
                        subdomains: ['a', 'b', 'c'],
                      ),
                      TileLayerOptions(
                        urlTemplate: "https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png",
                        backgroundColor: Colors.transparent,
                      ),
                      MarkerLayerOptions(markers: markers)
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
