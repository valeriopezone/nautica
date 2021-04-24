import 'dart:async';
import 'dart:math';

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

  LeafLetMap(
      {Key key, @required this.StreamObject, @required this.currentVessel});

  @override
  State<LeafLetMap> createState() => _LeafLetMapState();
}

class _LeafLetMapState extends State<LeafLetMap> with DisposableWidget {

  void initState(){
    super.initState();
  }
  @override
  void dispose() {
    print("CANCEL MAPS SUBSCRIPTION");
    cancelSubscriptions();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(51.5, -0.09),
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(

           // urlTemplate: "https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png",

          //  urlTemplate: "https://backend.navionics.com/tile/{z}/{x}/{y}?LAYERS=config_1_20.00_0&TRANSPARENT=TRUE&UGC=TRUE&theme=0&navtoken=eyJrZXkiOiJOQVZJT05JQ1NfV0VCQVBQX1AwMSIsImtleURvbWFpbiI6IndlYmFwcC5uYXZpb25pY3MuY29tIiwicmVmZXJlciI6IndlYmFwcC5uYXZpb25pY3MuY29tIiwicmFuZG9tIjoxNjE5MjE1MTk1NTQxfQ",
           urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a','b','c']
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(51.5, -0.09),
              builder: (ctx) =>
                  Container(
                    child: FlutterLogo(),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
