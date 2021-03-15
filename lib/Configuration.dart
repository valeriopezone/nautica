class Authentication {
  String username = "";
  String password = "";
}

const Map NAUTICA =  {
  'application':  {'debug': true},
  'signalK':  {'APIVersion': 'v1'}
};

const WidgetSubscriptionMap = {
  "nav.speedThroughWater" : {"navigation","speedThroughWater","value"},
  "nav.courseOverGroundMagnetic" : {"navigation","courseOverGroundMagnetic","value"},
  "nav.courseOverGroundTrue" : {"navigation","courseOverGroundTrue","value"},
  "nav.speedOverGround" : {"navigation","speedOverGround","value"},
  "nav.crossTrackError" : {"navigation","courseRhumbline","crossTrackError","value"},
  "nav.longitude" : {"navigation","position","value","longitude"},
  "nav.latitude" : {"navigation", "position","value","latitude"},

  "per.velocityMadeGood" : {"performance","velocityMadeGood","value"},

  "env.wind.speedApparent" : {"environment","wind","speedApparent","value"},
  "env.wind.angleApparent" : {"environment","wind","angleApparent","value"},
  "env.wind.speedTrue" : {"environment","wind","speedTrue","value"},
  "env.wind.angleTrueWater" : {"environment","wind","angleTrueWater","value"},
  "env.depth.belowTransducer" : {"environment","depth","belowTransducer","value"},
  "env.current.setTrue" : {"environment","current","setTrue","value"},
  "env.current.setMagnetic" : {"environment","current","setMagnetic","value"},
  "env.current.drift" : {"environment","current","drift","value"},

};

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


