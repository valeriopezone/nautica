import 'package:nautica/Widget.dart';
import 'package:flutter/material.dart';

class GPSWidget extends UIWidget{
double latitude,longitude;

void subscribeLatitude(Stream<double> stream){
  final sub = stream.listen((data) => {  this.latitude = data  });
}

void subscribeLongitude(Stream<double> stream){

  final sub = stream.listen((data) => {    this.longitude = data  });
}



  Wrap getBuild(){
    //...
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        Chip(
          avatar: CircleAvatar(backgroundColor: Colors.blue.shade900, child: Text('JL')),
          label: Text(this.title + " " + this.description),
        ),
      ],
    );
  }



}