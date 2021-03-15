import 'package:flutter/material.dart';


/*
Main widget usage :

latitudeStream = StreamSubscriber->getStream("nav.latitude");
LongitudeStream = StreamSubscriber->getStream("nav.longitude");

gps = UIWdiget();
gps->setTitle("gps");
gps->setDescription("current vessel position");
gps->subscribeLatitude(latitudeStream);
gps->subscribeLongitude(LongitudeStream);

return MaterialApp(gps->getBuild());//RENDER WIDGET

 */



abstract class UIWidget{

  String title;
  String icon;
  String description;
  List<String> subscriptionList = [];

  String getTitle() => this.title;
  String getIcon() => this.icon;
  String getDescription() => this.description;
  List<String> getSubscriptionList() => this.subscriptionList;

  set setTitle(String t) => this.title = t;
  set setIcon(String t) => this.icon = t;
  set setDescription(String t) => this.description = t;


  void setStreamsSubscription(List<String> subscriptions){
    if(subscriptions.length > 0){
      this.subscriptionList = subscriptions;
    }
  }

  void listenToStream(Stream<double> s){

  }


  Wrap getBuild(){
    //...
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        Chip(
          avatar: CircleAvatar(backgroundColor: Colors.blue.shade900, child: Text('JL')),
          label: Text('Laurens'),
        ),
      ],
    );
  }
}
