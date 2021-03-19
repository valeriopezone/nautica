import 'package:flutter/cupertino.dart';

class Authentication {
  String username = "";
  String password = "";
}

const Map NAUTICA =  {
  'application':  {'debug': true},
  'signalK':  {'APIVersion': 'v1'}
};

const Map WidgetSubscriptionMap = {
  "nav.speedThroughWater" : {
    "fullname" : "navigation.speedThroughWater",
    "path" : {"navigation","speedThroughWater","value"}
  },
  "nav.courseOverGroundMagnetic" : {
    "fullname" : "navigation.courseOverGroundMagnetic",
    "path" : {"navigation","courseOverGroundMagnetic","value"}
  },
  "nav.courseOverGroundTrue" : {
    "fullname" : "navigation.courseOverGroundTrue",
    "path" : {"navigation","courseOverGroundTrue","value"}
  },
  "nav.speedOverGround" : {
    "fullname" : "navigation.speedOverGround",
    "path" : {"navigation","speedOverGround","value"}
  },
  "nav.crossTrackError" : {
    "fullname" : "navigation.courseRhumbline.crossTrackError",
    "path" : {"navigation","courseRhumbline","crossTrackError","value"}
  },
  "nav.longitude" : {
    "fullname" : "navigation.position",
    "path" : {"navigation","position","value","longitude"}
  },
  "nav.latitude" : {
    "fullname" : "navigation.position",
    "path" : {"navigation", "position","value","latitude"}
  },
  "per.velocityMadeGood" : {
    "fullname" : "performance.velocityMadeGood",
    "path" : {"performance","velocityMadeGood","value"}
  },
  "env.wind.speedApparent" : {
    "fullname" : "environment.wind.speedApparent",
    "path" : {"environment","wind","speedApparent","value"}
  },
  "env.wind.angleApparent" : {
    "fullname" : "environment.wind.angleApparent",
    "path" : {"environment","wind","angleApparent","value"}
  },
  "env.wind.speedTrue" : {
    "fullname" : "environment.wind.speedTrue",
    "path" : {"environment","wind","speedTrue","value"}
  },
  "env.wind.angleTrueWater" : {
    "fullname" : "environment.wind.angleTrueWater",
    "path" : {"environment","wind","angleTrueWater","value"}
  },
  "env.depth.belowTransducer" : {
    "fullname" : "environment.depth.belowTransducer",
    "path" : {"environment","depth","belowTransducer","value"}
  },
  "env.current.setTrue" : {
    "fullname" : "environment.current.setTrue",
    "path" : {"environment","current","setTrue","value"}
  },
  "env.current.setMagnetic" : {
    "fullname" : "environment.current.setMagnetic",
    "path" : {"environment","current","setMagnetic","value"}
  },
  "env.current.drift" : {
    "fullname" : "environment.current.drift",
    "path" : {"environment","current","drift","value"}
  },
};


//Reversed widget map :
// useful for avoiding looping everytime we look for map keys by fullname
//reversed example :
// "nav.crossTrackError" : {
//     "fullname" : "navigation.courseRhumbline.crossTrackError",
//     "path" : {"navigation","courseRhumbline","crossTrackError","value"}
//   }
// becomes
// {navigation.courseRhumbline.crossTrackError: nav.crossTrackError}
var ReversedWidgetSubscriptionMap = Map.fromEntries(WidgetSubscriptionMap.entries.map((e) => MapEntry(e.value['fullname'], e.key)));


Map getWidgetSubscriptionMap(){
  return WidgetSubscriptionMap;
}

String getSubscriptionFullName(String subscription){
  if(WidgetSubscriptionMap[subscription] == null) return "";
  return WidgetSubscriptionMap[subscription]['fullname'];
}

String getSubscriptionSlugByFullName(String fullName){
  if(fullName == null) return "";
  if(ReversedWidgetSubscriptionMap[fullName] == null) return "";
  return ReversedWidgetSubscriptionMap[fullName];
}

const SubscriptionMap = {
  "navigation": {
    "speedThroughWater": {"value": ""},
    "courseOverGroundMagnetic": {"value": ""},
    "courseOverGroundTrue": {"value": ""},
    "speedOverGround": {"value": ""},
    "courseRhumbline": {
      "crossTrackError": {"value": ""}
    },
    "position": {
      "value": {"longitude": "", "latitude": ""},
    }
  },



  "performance": {
    "velocityMadeGood": {"value": ""}
  },


  "environment": {
    "wind": {
      "speedApparent": {"value": ""},
      "angleApparent": {"value": ""},
      "speedTrue": {"value": ""},
      "angleTrueWater": {"value": ""}
    },
    "depth": {
      "belowTransducer": {"value": ""}
    },
    "current": {
      "value": {"setTrue": "", "setMagnetic": "", "drift": ""}
    }
  }
};


