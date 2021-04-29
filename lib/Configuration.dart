class Authentication {
  Authentication(this.username, this.password);

  String username = "";
  String password = "";
}

const Map NAUTICA = {
  'application': {'debug': true},
  'signalK': {
    'APIVersion': 'v1',
    'connection': {'address': '192.168.1.179', 'port': 3000}
  },
  'configuration': {
    'widget': {
      'refreshRate': 850 //ms
    },
    'map': {
      'refreshRate': 2 //s
    },
    'connection': {
      'timeout': 2 //s
    },
    'design' : {
      'grid' : {
        'numCols' : 4,
        'baseHeight' : 110.0,
        'minBaseHeight' : 100.0,
        'maxBaseHeight' : 500.0,
        'minNumCols' : 2,
        'maxNumCols' : 10,
        'defaultGridName' : "Dashboard",
        'defaultGridAuthorName' : "Nautica",
        'defaultGridDescription' : "a simple dashboard interface by Nautica"
      }
    }
  }
};


const Map IndicatorSpecs = {
  'WindIndicator': ['Angle_Stream', 'Intensity_Stream'],
  'CompassIndicator': ['Value_Stream'],
  'SpeedIndicator': ['Speed_Stream'],
  'BoatVectorsIndicator': [
    'ATW_Stream',
    'ST_Stream',
    'AA_Stream',
    'SA_Stream',
    'HT_Stream',
    'COG_Stream',
    'SOG_Stream',
    'LatLng_Stream',
    'DBK_Stream',
    'DBS_Stream',
    'DBT_Stream',
    'DBST_Stream'
  ],
  'DateValueAxisChart': ['DataValue_Stream'],
  'TransposedDateValueAxisChart': ['DataValue_Stream'],
  'RealTimeMap': [],
  'TextIndicator': ['Text_Stream']
};

const Map SuggestedIndicatorStreams = {
  'Angle_Stream': 'environment.wind.angleApparent',
  'Intensity_Stream': 'environment.wind.speedApparent',
  'Value_Stream': 'navigation.headingTrue',
  'Speed_Stream': 'propulsion.engine_1.revolutions',
  'ATW_Stream': 'environment.wind.angleTrueWater',
  'ST_Stream': 'environment.wind.speedTrue',
  'AA_Stream': 'environment.wind.angleApparent',
  'SA_Stream': 'environment.wind.speedApparent',
  'HT_Stream': 'navigation.headingTrue',
  'COG_Stream': 'navigation.courseOverGroundTrue',
  'SOG_Stream': 'navigation.speedOverGround',
  'LatLng_Stream': 'navigation.position',
  'DBK_Stream': 'environment.depth.belowKeel',
  'DBS_Stream': 'environment.depth.belowSurface',
  'DBT_Stream': 'environment.depth.belowTransducer',
  'DBST_Stream': 'environment.depth.surfaceToTransducer',
  'Text_Stream': 'environment.depth.belowKeel',
  'DataValue_Stream': 'environment.wind.speedTrue'
};

//types : color | text | double
const Map IndicatorGraphicSpecs = {
  'WindIndicator': {
    'lightTheme': {
      'radiusFactor': {'type': 'double', 'default': 1.05},
      'radialLabelFontColor': {'type': 'color', 'default': '#ff333333'},
      'majorTickSize': {'type': 'double', 'default': 1.5},
      'majorTickLength': {'type': 'double', 'default': 0.1},
      'angleLabelFontSize': {'type': 'double', 'default': 25.0},
      'angleLabelFontColor': {'type': 'color', 'default': '#ff333333'},
      'intensityLabelFontSize': {'type': 'double', 'default': 18.0},
      'intensityLabelFontColor': {'type': 'color', 'default': '#ff333333'},
      'needlePointerColor': {'type': 'color', 'default': '#ff02897b'},
      'gaugePositiveColor': {'type': 'color', 'default': '#ff149400'},
      'gaugeNegativeColor': {'type': 'color', 'default': '#ff8d000a'},
      'minorTickSize': {'type': 'double', 'default': 1.5},
      'minorTickLength': {'type': 'double', 'default': 0.04}
    },
    'darkTheme': {
      'radiusFactor': {'type': 'double', 'default': 1.05},
      'radialLabelFontColor': {'type': 'color', 'default': '#fff2f2f2'},
      'majorTickSize': {'type': 'double', 'default': 1.5},
      'majorTickLength': {'type': 'double', 'default': 0.1},
      'angleLabelFontSize': {'type': 'double', 'default': 25.0},
      'angleLabelFontColor': {'type': 'color', 'default': '#fff2f2f2'},
      'intensityLabelFontSize': {'type': 'double', 'default': 18.0},
      'intensityLabelFontColor': {'type': 'color', 'default': '#fff2f2f2'},
      'needlePointerColor': {'type': 'color', 'default': '#ff02897b'},
      'gaugePositiveColor': {'type': 'color', 'default': '#ff149400'},
      'gaugeNegativeColor': {'type': 'color', 'default': '#ff8d000a'},
      'minorTickSize': {'type': 'double', 'default': 1.5},
      'minorTickLength': {'type': 'double', 'default': 0.04}
    }
  },
  'CompassIndicator': {
    'lightTheme': {
      'axisRadiusFactor': {'type': 'double', 'default': 1.3},
      'axisLabelFontColor': {'type': 'color', 'default': '#FF949494'},
      'axisLabelFontSize': {'type': 'double', 'default': 10.0},
      'minorTickColor': {'type': 'color', 'default': '#FF616161'},
      'minorTickThickness': {'type': 'double', 'default': 1.0},
      'minorTickLength': {'type': 'double', 'default': 0.058},
      'majorTickColor': {'type': 'color', 'default': '#FF949494'},
      'majorTickThickness': {'type': 'double', 'default': 2.3},
      'majorTickLength': {'type': 'double', 'default': 0.087},
      'markerOffset': {'type': 'double', 'default': 0.69},
      'markerHeight': {'type': 'double', 'default': 5.0},
      'markerWidth': {'type': 'double', 'default': 10.0},
      'gaugeFontColor': {'type': 'color', 'default': '#FFDF5F2D'},
      'gaugeFontSize': {'type': 'double', 'default': 16.0}
    },
    'darkTheme': {
      'axisRadiusFactor': {'type': 'double', 'default': 1.3},
      'axisLabelFontColor': {'type': 'color', 'default': '#FF949494'},
      'axisLabelFontSize': {'type': 'double', 'default': 10.0},
      'minorTickColor': {'type': 'color', 'default': '#FF616161'},
      'minorTickThickness': {'type': 'double', 'default': 1.0},
      'minorTickLength': {'type': 'double', 'default': 0.058},
      'majorTickColor': {'type': 'color', 'default': '#FF949494'},
      'majorTickThickness': {'type': 'double', 'default': 2.3},
      'majorTickLength': {'type': 'double', 'default': 0.087},
      'markerOffset': {'type': 'double', 'default': 0.69},
      'markerHeight': {'type': 'double', 'default': 5.0},
      'markerWidth': {'type': 'double', 'default': 10.0},
      'gaugeFontColor': {'type': 'color', 'default': '#FFDF5F2D'},
      'gaugeFontSize': {'type': 'double', 'default': 16.0}
    }
  },
  'SpeedIndicator': {
    'lightTheme': {
      'minValue': {'type': 'double', 'default': 0.0},
      'maxValue': {'type': 'double', 'default': 100.0},
      'axisLabelFontSize': {'type': 'double', 'default': 12.0},
      'gaugeFontColor': {'type': 'color', 'default': "#FF000000"},
      'gaugeFontSize': {'type': 'double', 'default': 17.0},
      'radiusFactor': {'type': 'double', 'default': 1.0},
      'majorTickLength': {'type': 'double', 'default': 0.04},
      'majorTickThickness': {'type': 'double', 'default': 1.5},
      'minorTickLength': {'type': 'double', 'default': 0.04},
      'minorTickThickness': {'type': 'double', 'default': 1.5},
      'labelOffset': {'type': 'double', 'default': 15.0},
      'rangeOffset': {'type': 'double', 'default': 0.08},
      'gradientFrom': {'type': 'color', 'default': '#FF4CAF50'},
      'gradientTo': {'type': 'color', 'default': '#FFF44336'},
      'textColor': {'type': 'color', 'default': '#FF000000'},
      'needleColor': {'type': 'color', 'default': '#FF000000'},
      'knobColor': {'type': 'color', 'default': '#FF000000'},
      'needleStartWidth': {'type': 'double', 'default': 1.0},
      'needleEndWidth': {'type': 'double', 'default': 5.0},
      'needleLength': {'type': 'double', 'default': 0.7},
      'knobRadius': {'type': 'double', 'default': 0.08}
    },
    'darkTheme': {
      'minValue': {'type': 'double', 'default': 0.0},
      'maxValue': {'type': 'double', 'default': 100.0},
      'axisLabelFontSize': {'type': 'double', 'default': 12.0},
      'gaugeFontColor': {'type': 'color', 'default': "#ffffffff"},
      'gaugeFontSize': {'type': 'double', 'default': 17.0},
      'radiusFactor': {'type': 'double', 'default': 1.0},
      'majorTickLength': {'type': 'double', 'default': 0.04},
      'majorTickThickness': {'type': 'double', 'default': 1.5},
      'minorTickLength': {'type': 'double', 'default': 0.04},
      'minorTickThickness': {'type': 'double', 'default': 1.5},
      'labelOffset': {'type': 'double', 'default': 15.0},
      'rangeOffset': {'type': 'double', 'default': 0.08},
      'gradientFrom': {'type': 'color', 'default': '#FF4CAF50'},
      'gradientTo': {'type': 'color', 'default': '#FFF44336'},
      'textColor': {'type': 'color', 'default': '#FFFFFFFF'},
      'needleColor': {'type': 'color', 'default': '#FFFFFFFF'},
      'knobColor': {'type': 'color', 'default': '#FFFFFFFF'},
      'needleStartWidth': {'type': 'double', 'default': 1.0},
      'needleEndWidth': {'type': 'double', 'default': 5.0},
      'needleLength': {'type': 'double', 'default': 0.7},
      'knobRadius': {'type': 'double', 'default': 0.08}
    }
  },
  'BoatVectorsIndicator': {
    'lightTheme': {
      'labelFontSize': {'type': 'double', 'default': 20.0},
      'labelFontColor': {'type': 'color', 'default': "#3366ff00"}
    },
    'darkTheme': {
      'labelFontSize': {'type': 'double', 'default': 21.0},
      'labelFontColor': {'type': 'color', 'default': "#ffffff"}
    }
  },
  'DateValueAxisChart': {
    'lightTheme': {
      'chartMinValue': {'type': 'double', 'default': 0.0},
      'chartMaxValue': {'type': 'double', 'default': 100.0},
      'chartNumDatapoints': {'type': 'double', 'default': 30.0},
      'chartLineColor': {'type': 'color', 'default': "#FFC06C84"},
    },
    'darkTheme': {
      'chartMinValue': {'type': 'double', 'default': 0.0},
      'chartMaxValue': {'type': 'double', 'default': 100.0},
      'chartNumDatapoints': {'type': 'double', 'default': 30.0},
      'chartLineColor': {'type': 'color', 'default': "#FFC06C84"},
    }
  },
  'TransposedDateValueAxisChart': {
    'lightTheme': {
      'chartMinValue': {'type': 'double', 'default': 0.0},
      'chartMaxValue': {'type': 'double', 'default': 100.0},
      'chartNumDatapoints': {'type': 'double', 'default': 30.0},
      'chartLineColor': {'type': 'color', 'default': "#FFC06C84"},
    },
    'darkTheme': {
      'chartMinValue': {'type': 'double', 'default': 0.0},
      'chartMaxValue': {'type': 'double', 'default': 100.0},
      'chartNumDatapoints': {'type': 'double', 'default': 30.0},
      'chartLineColor': {'type': 'color', 'default': "#FFC06C84"},
    }
  },
  'RealTimeMap': {
    'lightTheme': {},
    'darkTheme': {},
  },
  'TextIndicator': {
    'lightTheme': {
      'labelFontSize': {'type': 'double', 'default': 45.0},
      'labelFontColor': {'type': 'color', 'default': '#FF333333'},
      'unitFontSize': {'type': 'double', 'default': 12.0},
      'unitFontColor': {'type': 'color', 'default': '#FF333333'}
    },
    'darkTheme': {
      'labelFontSize': {'type': 'double', 'default': 45.0},
      'labelFontColor': {'type': 'color', 'default': '#FFF2F2F2'},
      'unitFontSize': {'type': 'double', 'default': 12.0},
      'unitFontColor': {'type': 'color', 'default': '#FFF2F2F2'}
    },
  }
};

String JSONSchema = '''
{"\$schema":"http://json-schema.org/draft-04/schema#","type":"object","properties":{"name":{"type":"string"},"description":{"type":"string"},"author":{"type":"string"},"numCols":{"type":"integer"},"baseHeight":{"type":"number"},"widgets":{"type":"array","items":[{"type":"object","properties":{"current":{"type":"integer"},"width":{"type":"integer"},"height":{"type":"integer"},"elements":{"type":"array","items":[{"type":"object","properties":{"widgetTitle":{"type":"string"},"widgetClass":{"type":"string"},"widgetSubscriptions":{"type":"object","properties":{"Angle_Stream":{"type":"string"},"Intensity_Stream":{"type":"string"},"Value_Stream":{"type":"string"},"Speed_Stream":{"type":"string"},"ATW_Stream":{"type":"string"},"ST_Stream":{"type":"string"},"AA_Stream":{"type":"string"},"SA_Stream":{"type":"string"},"HT_Stream":{"type":"string"},"COG_Stream":{"type":"string"},"SOG_Stream":{"type":"string"},"LatLng_Stream":{"type":"string"},"DBK_Stream":{"type":"string"},"DBS_Stream":{"type":"string"},"DBT_Stream":{"type":"string"},"DBST_Stream":{"type":"string"},"Text_Stream":{"type":"string"},"DataValue_Stream":{"type":"string"}}},"widgetOptions":{"type":"object","properties":{"settings":{"type":"array","items":{}},"graphics":{"type":"object","properties":{"lightTheme":{"type":"object","properties":{"radiusFactor":{"type":"number"},"radialLabelFontColor":{"type":"string"},"majorTickSize":{"type":"number"},"majorTickLength":{"type":"number"},"angleLabelFontSize":{"type":"number"},"angleLabelFontColor":{"type":"string"},"intensityLabelFontSize":{"type":"number"},"intensityLabelFontColor":{"type":"string"},"needlePointerColor":{"type":"string"},"gaugePositiveColor":{"type":"string"},"gaugeNegativeColor":{"type":"string"},"minorTickSize":{"type":"number"},"minorTickLength":{"type":"number"},"axisRadiusFactor":{"type":"number"},"axisLabelFontColor":{"type":"string"},"axisLabelFontSize":{"type":"number"},"minorTickColor":{"type":"string"},"minorTickThickness":{"type":"number"},"majorTickColor":{"type":"string"},"majorTickThickness":{"type":"number"},"markerOffset":{"type":"number"},"markerHeight":{"type":"number"},"markerWidth":{"type":"number"},"gaugeFontColor":{"type":"string"},"gaugeFontSize":{"type":"number"},"minValue":{"type":"number"},"maxValue":{"type":"number"},"labelOffset":{"type":"number"},"rangeOffset":{"type":"number"},"gradientFrom":{"type":"string"},"gradientTo":{"type":"string"},"textColor":{"type":"string"},"needleColor":{"type":"string"},"knobColor":{"type":"string"},"needleStartWidth":{"type":"number"},"needleEndWidth":{"type":"number"},"needleLength":{"type":"number"},"knobRadius":{"type":"number"},"labelFontSize":{"type":"number"},"labelFontColor":{"type":"string"},"chartMinValue":{"type":"number"},"chartMaxValue":{"type":"number"},"chartNumDatapoints":{"type":"number"},"chartLineColor":{"type":"string"},"unitFontSize":{"type":"number"},"unitFontColor":{"type":"string"}}},"darkTheme":{"type":"object","properties":{"radiusFactor":{"type":"number"},"radialLabelFontColor":{"type":"string"},"majorTickSize":{"type":"number"},"majorTickLength":{"type":"number"},"angleLabelFontSize":{"type":"number"},"angleLabelFontColor":{"type":"string"},"intensityLabelFontSize":{"type":"number"},"intensityLabelFontColor":{"type":"string"},"needlePointerColor":{"type":"string"},"gaugePositiveColor":{"type":"string"},"gaugeNegativeColor":{"type":"string"},"minorTickSize":{"type":"number"},"minorTickLength":{"type":"number"},"axisRadiusFactor":{"type":"number"},"axisLabelFontColor":{"type":"string"},"axisLabelFontSize":{"type":"number"},"minorTickColor":{"type":"string"},"minorTickThickness":{"type":"number"},"majorTickColor":{"type":"string"},"majorTickThickness":{"type":"number"},"markerOffset":{"type":"number"},"markerHeight":{"type":"number"},"markerWidth":{"type":"number"},"gaugeFontColor":{"type":"string"},"gaugeFontSize":{"type":"number"},"minValue":{"type":"number"},"maxValue":{"type":"number"},"labelOffset":{"type":"number"},"rangeOffset":{"type":"number"},"gradientFrom":{"type":"string"},"gradientTo":{"type":"string"},"textColor":{"type":"string"},"needleColor":{"type":"string"},"knobColor":{"type":"string"},"needleStartWidth":{"type":"number"},"needleEndWidth":{"type":"number"},"needleLength":{"type":"number"},"knobRadius":{"type":"number"},"labelFontSize":{"type":"number"},"labelFontColor":{"type":"string"},"chartMinValue":{"type":"number"},"chartMaxValue":{"type":"number"},"chartNumDatapoints":{"type":"number"},"chartLineColor":{"type":"string"},"unitFontSize":{"type":"number"},"unitFontColor":{"type":"string"}}}},"required":["lightTheme","darkTheme"]}}}},"required":["widgetTitle","widgetClass","widgetSubscriptions"]}]}},"required":["current","width","height","elements"]}]}},"required":["name","description","author","numCols","baseHeight","widgets"]}
''';


String mainJSONGridTheme = '''
{"name":"Nautica","description":"Default grid","author":"Valerio Pezone","numCols" : 4, "baseHeight" : 110.0,"widgets":[{"current":2,"width":1,"height":2,"elements":[{"widgetTitle":"Speed","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"},"widgetOptions":{"graphics":{"lightTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"},"darkTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"}}}},{"widgetTitle":"Angle","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"},"widgetOptions":{"graphics":{"lightTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"},"darkTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"}}}},{"widgetTitle":"Apparent Wind","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"},"widgetOptions":{"graphics":{"lightTheme":{"radiusFactor":1.05,"radialLabelFontColor":"#ff333333","majorTickSize":1.5,"majorTickLength":0.1,"angleLabelFontSize":25,"angleLabelFontColor":"#ff333333","intensityLabelFontSize":18,"intensityLabelFontColor":"#ff333333","needlePointerColor":"#ff02897b","gaugePositiveColor":"#ff149400","gaugeNegativeColor":"#ff8d000a","minorTickSize":1.5,"minorTickLength":0.04},"darkTheme":{"radiusFactor":1.05,"radialLabelFontColor":"#fff2f2f2","majorTickSize":1.5,"majorTickLength":0.1,"angleLabelFontSize":25,"angleLabelFontColor":"#fff2f2f2","intensityLabelFontSize":18,"intensityLabelFontColor":"#fff2f2f2","needlePointerColor":"#ff02897b","gaugePositiveColor":"#ff149400","gaugeNegativeColor":"#ff8d000a","minorTickSize":1.5,"minorTickLength":0.04}}}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"Speed through water","widgetClass":"TextIndicator","widgetSubscriptions":{"Text_Stream":"navigation.speedThroughWater"},"widgetOptions":{"graphics":{"lightTheme":{"labelFontSize":45,"labelFontColor":"#FF333333","unitFontSize":12,"unitFontColor":"#FF333333"},"darkTheme":{"labelFontSize":45,"labelFontColor":"#FFF2F2F2","unitFontSize":12,"unitFontColor":"#FFF2F2F2"}}}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"Water temperature","widgetClass":"TextIndicator","widgetSubscriptions":{"Text_Stream":"environment.water.temperature"},"widgetOptions":{"graphics":{"lightTheme":{"labelFontSize":45,"labelFontColor":"#FF333333","unitFontSize":12,"unitFontColor":"#FF333333"},"darkTheme":{"labelFontSize":45,"labelFontColor":"#FFF2F2F2","unitFontSize":12,"unitFontColor":"#FFF2F2F2"}}}}]},{"current":1,"width":1,"height":2,"elements":[{"widgetTitle":"Angle","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"navigation.courseOverGroundMagnetic"},"widgetOptions":{"graphics":{"lightTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"},"darkTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"}}}},{"widgetTitle":"COG(m)","widgetClass":"CompassIndicator","widgetSubscriptions":{"Value_Stream":"navigation.headingTrue"},"widgetOptions":{"graphics":{"lightTheme":{"axisRadiusFactor":1.3,"axisLabelFontColor":"#FF949494","axisLabelFontSize":10,"minorTickColor":"#FF616161","minorTickThickness":1,"minorTickLength":0.058,"majorTickColor":"#FF949494","majorTickThickness":2.3,"majorTickLength":0.087,"markerOffset":0.69,"markerHeight":5,"markerWidth":10,"gaugeFontColor":"#FFDF5F2D","gaugeFontSize":16},"darkTheme":{"axisRadiusFactor":1.3,"axisLabelFontColor":"#FF949494","axisLabelFontSize":10,"minorTickColor":"#FF616161","minorTickThickness":1,"minorTickLength":0.058,"majorTickColor":"#FF949494","majorTickThickness":2.3,"majorTickLength":0.087,"markerOffset":0.69,"markerHeight":5,"markerWidth":10,"gaugeFontColor":"#FFDF5F2D","gaugeFontSize":16}}}}]},{"current":0,"width":2,"height":2,"elements":[{"widgetTitle":"Real Time Map","widgetClass":"RealTimeMap","widgetSubscriptions":{"LatLng_Stream":"navigation.position","HT_Stream":"navigation.headingTrue"},"widgetOptions":{"graphics":{"lightTheme":{},"darkTheme":{}}}}]},{"current":2,"width":1,"height":2,"elements":[{"widgetTitle":"Speed","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedOverGround"},"widgetOptions":{"graphics":{"lightTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"},"darkTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"}}}},{"widgetTitle":"Angle","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.angleTrueGround"},"widgetOptions":{"graphics":{"lightTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"},"darkTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"}}}},{"widgetTitle":"True wind over ground","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleTrueWater","Intensity_Stream":"navigation.speedOverGround"},"widgetOptions":{"graphics":{"lightTheme":{"radiusFactor":1.05,"radialLabelFontColor":"#ff333333","majorTickSize":1.5,"majorTickLength":0.1,"angleLabelFontSize":25,"angleLabelFontColor":"#ff333333","intensityLabelFontSize":18,"intensityLabelFontColor":"#ff333333","needlePointerColor":"#ff02897b","gaugePositiveColor":"#ff149400","gaugeNegativeColor":"#ff8d000a","minorTickSize":1.5,"minorTickLength":0.04},"darkTheme":{"radiusFactor":1.05,"radialLabelFontColor":"#fff2f2f2","majorTickSize":1.5,"majorTickLength":0.1,"angleLabelFontSize":25,"angleLabelFontColor":"#fff2f2f2","intensityLabelFontSize":18,"intensityLabelFontColor":"#fff2f2f2","needlePointerColor":"#ff02897b","gaugePositiveColor":"#ff149400","gaugeNegativeColor":"#ff8d000a","minorTickSize":1.5,"minorTickLength":0.04}}}}]},{"current":1,"width":1,"height":2,"elements":[{"widgetTitle":"Angle","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"navigation.courseOverGroundMagnetic"},"widgetOptions":{"graphics":{"lightTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"},"darkTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"}}}},{"widgetTitle":"COG(t)","widgetClass":"CompassIndicator","widgetSubscriptions":{"Value_Stream":"navigation.headingTrue"},"widgetOptions":{"graphics":{"lightTheme":{"axisRadiusFactor":1.3,"axisLabelFontColor":"#FF949494","axisLabelFontSize":10,"minorTickColor":"#FF616161","minorTickThickness":1,"minorTickLength":0.058,"majorTickColor":"#FF949494","majorTickThickness":2.3,"majorTickLength":0.087,"markerOffset":0.69,"markerHeight":5,"markerWidth":10,"gaugeFontColor":"#FFDF5F2D","gaugeFontSize":16},"darkTheme":{"axisRadiusFactor":1.3,"axisLabelFontColor":"#FF949494","axisLabelFontSize":10,"minorTickColor":"#FF616161","minorTickThickness":1,"minorTickLength":0.058,"majorTickColor":"#FF949494","majorTickThickness":2.3,"majorTickLength":0.087,"markerOffset":0.69,"markerHeight":5,"markerWidth":10,"gaugeFontColor":"#FFDF5F2D","gaugeFontSize":16}}}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"Depth below surface","widgetClass":"TextIndicator","widgetSubscriptions":{"Text_Stream":"environment.depth.belowSurface"},"widgetOptions":{"graphics":{"lightTheme":{"labelFontSize":"45","labelFontColor":"#FF333333","unitFontSize":"12","unitFontColor":"#FF333333"},"darkTheme":{"labelFontSize":"45","labelFontColor":"#FFF2F2F2","unitFontSize":"12","unitFontColor":"#FFF2F2F2"}}}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"Depth below keel","widgetClass":"TextIndicator","widgetSubscriptions":{"Text_Stream":"environment.depth.belowKeel"},"widgetOptions":{"graphics":{"lightTheme":{"labelFontSize":"45","labelFontColor":"#FF333333","unitFontSize":"12","unitFontColor":"#FF333333"},"darkTheme":{"labelFontSize":"45","labelFontColor":"#FFF2F2F2","unitFontSize":"12","unitFontColor":"#FFF2F2F2"}}}}]},{"current":2,"width":1,"height":2,"elements":[{"widgetTitle":"Speed","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedTrue"},"widgetOptions":{"graphics":{"lightTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"},"darkTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"}}}},{"widgetTitle":"Angle","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.angleTrueWater"},"widgetOptions":{"graphics":{"lightTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"},"darkTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"}}}},{"widgetTitle":"True wind through water","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleTrueWater","Intensity_Stream":"environment.wind.speedTrue"},"widgetOptions":{"graphics":{"lightTheme":{"radiusFactor":1.05,"radialLabelFontColor":"#ff333333","majorTickSize":1.5,"majorTickLength":0.1,"angleLabelFontSize":25,"angleLabelFontColor":"#ff333333","intensityLabelFontSize":18,"intensityLabelFontColor":"#ff333333","needlePointerColor":"#ff02897b","gaugePositiveColor":"#ff149400","gaugeNegativeColor":"#ff8d000a","minorTickSize":1.5,"minorTickLength":0.04},"darkTheme":{"radiusFactor":1.05,"radialLabelFontColor":"#fff2f2f2","majorTickSize":1.5,"majorTickLength":0.1,"angleLabelFontSize":25,"angleLabelFontColor":"#fff2f2f2","intensityLabelFontSize":18,"intensityLabelFontColor":"#fff2f2f2","needlePointerColor":"#ff02897b","gaugePositiveColor":"#ff149400","gaugeNegativeColor":"#ff8d000a","minorTickSize":1.5,"minorTickLength":0.04}}}}]},{"current":0,"width":1,"height":2,"elements":[{"widgetTitle":"Engine 1","widgetClass":"SpeedIndicator","widgetSubscriptions":{"Speed_Stream":"propulsion.engine_1.revolutions"},"widgetOptions":{"graphics":{"lightTheme":{"minValue":0,"maxValue":100,"axisLabelFontSize":12,"gaugeFontColor":"#FF000000","gaugeFontSize":17,"radiusFactor":1,"majorTickLength":0.04,"majorTickThickness":1.5,"minorTickLength":0.04,"minorTickThickness":1.5,"labelOffset":15,"rangeOffset":0.08,"gradientFrom":"#FF4CAF50","gradientTo":"#FFF44336","textColor":"#FF000000","needleColor":"#FF000000","knobColor":"#FF000000","needleStartWidth":1,"needleEndWidth":5,"needleLength":0.7,"knobRadius":0.08},"darkTheme":{"minValue":0,"maxValue":100,"axisLabelFontSize":12,"gaugeFontColor":"#ffffffff","gaugeFontSize":17,"radiusFactor":1,"majorTickLength":0.04,"majorTickThickness":1.5,"minorTickLength":0.04,"minorTickThickness":1.5,"labelOffset":15,"rangeOffset":0.08,"gradientFrom":"#FF4CAF50","gradientTo":"#FFF44336","textColor":"#FFFFFFFF","needleColor":"#FFFFFFFF","knobColor":"#FFFFFFFF","needleStartWidth":1,"needleEndWidth":5,"needleLength":0.7,"knobRadius":0.08}}}}]},{"current":1,"width":1,"height":2,"elements":[{"widgetTitle":"RPM 2 Chart","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"propulsion.engine_2.revolutions"},"widgetOptions":{"graphics":{"lightTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"},"darkTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"}}}},{"widgetTitle":"Engine 2","widgetClass":"SpeedIndicator","widgetSubscriptions":{"Speed_Stream":"propulsion.engine_2.revolutions"},"widgetOptions":{"graphics":{"lightTheme":{"minValue":0,"maxValue":100,"axisLabelFontSize":12,"gaugeFontColor":"#FF000000","gaugeFontSize":17,"radiusFactor":1,"majorTickLength":0.04,"majorTickThickness":1.5,"minorTickLength":0.04,"minorTickThickness":1.5,"labelOffset":15,"rangeOffset":0.08,"gradientFrom":"#FF4CAF50","gradientTo":"#FFF44336","textColor":"#FF000000","needleColor":"#FF000000","knobColor":"#FF000000","needleStartWidth":1,"needleEndWidth":5,"needleLength":0.7,"knobRadius":0.08},"darkTheme":{"minValue":0,"maxValue":100,"axisLabelFontSize":12,"gaugeFontColor":"#ffffffff","gaugeFontSize":17,"radiusFactor":1,"majorTickLength":0.04,"majorTickThickness":1.5,"minorTickLength":0.04,"minorTickThickness":1.5,"labelOffset":15,"rangeOffset":0.08,"gradientFrom":"#FF4CAF50","gradientTo":"#FFF44336","textColor":"#FFFFFFFF","needleColor":"#FFFFFFFF","knobColor":"#FFFFFFFF","needleStartWidth":1,"needleEndWidth":5,"needleLength":0.7,"knobRadius":0.08}}}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"Position","widgetClass":"TextIndicator","widgetSubscriptions":{"Text_Stream":"navigation.position"},"widgetOptions":{"graphics":{"lightTheme":{"labelFontSize":19,"labelFontColor":"#FF333333","unitFontSize":12,"unitFontColor":"#FF333333"},"darkTheme":{"labelFontSize":19,"labelFontColor":"#FFF2F2F2","unitFontSize":12,"unitFontColor":"#FFF2F2F2"}}}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"True wind monitor","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.water.temperature"},"widgetOptions":{"graphics":{"lightTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"},"darkTheme":{"chartMinValue":0,"chartMaxValue":100,"chartNumDatapoints":30,"chartLineColor":"#FFC06C84"}}}}]}]}
''';

String genericEmptyGridTheme = '''
{"name":"Unknown Grid2","description":"","author":"","numCols":4,"baseHeight":110,"widgets":[]}
''';
String demoTheme = '''
{"name":"Nautica","description":"Default template grid","author":"Valerio Pezone","numCols":4,"baseHeight":110,"widgets":[{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"Basic Widget","widgetClass":"WidgetClass","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent","Value_Stream":"navigation.headingTrue","Speed_Stream":"propulsion.engine_1.revolutions","ATW_Stream":"environment.wind.angleTrueWater","ST_Stream":"environment.wind.speedTrue","AA_Stream":"environment.wind.angleApparent","SA_Stream":"environment.wind.speedApparent","HT_Stream":"navigation.headingTrue","COG_Stream":"navigation.courseOverGroundTrue","SOG_Stream":"navigation.speedOverGround","LatLng_Stream":"navigation.position","DBK_Stream":"environment.depth.belowKeel","DBS_Stream":"environment.depth.belowSurface","DBT_Stream":"environment.depth.belowTransducer","DBST_Stream":"environment.depth.surfaceToTransducer"},"widgetOptions":{"settings":[],"graphics":{"lightTheme":{"radiusFactor":1,"radialLabelFontColor":"#ff333333","majorTickSize":1.5,"majorTickLength":0.04,"angleLabelFontSize":15.5,"angleLabelFontColor":"#3366BB","intensityLabelFontSize":18,"intensityLabelFontColor":"#ff333333","needlePointerColor":"#ff02897b","gaugePositiveColor":"#ff149400","gaugeNegativeColor":"#ff8d000a","minorTickSize":1.5,"minorTickLength":0.04,"axisRadiusFactor":1.3,"axisLabelFontColor":"#FF949494","axisLabelFontSize":10,"minorTickColor":"#FF616161","minorTickThickness":1.5,"majorTickColor":"#FF949494","majorTickThickness":1.5,"markerOffset":0.69,"markerHeight":5,"markerWidth":10,"gaugeFontColor":"#FFDF5F2D","gaugeFontSize":16,"labelOffset":15,"rangeOffset":0.08,"gradientFrom":"#FF4CAF50","gradientTo":"#FFF44336","textColor":"#3366AA","pointerColor":"#3366FF","speedLabelFontSize":12.4,"speedLabelFontColor":"#3366EE"},"darkTheme":{"radiusFactor":1,"radialLabelFontColor":"#fff2f2f2","majorTickSize":1.5,"majorTickLength":0.04,"angleLabelFontSize":15.5,"angleLabelFontColor":"#BBBBBB","intensityLabelFontSize":18,"intensityLabelFontColor":"#fff2f2f2","needlePointerColor":"#ff02897b","gaugePositiveColor":"#ff149400","gaugeNegativeColor":"#ff8d000a","minorTickSize":1.5,"minorTickLength":0.04,"axisRadiusFactor":1.3,"axisLabelFontColor":"#FF949494","axisLabelFontSize":10,"minorTickColor":"#FF616161","minorTickThickness":1.5,"majorTickColor":"#FF949494","majorTickThickness":1.5,"markerOffset":0.69,"markerHeight":5,"markerWidth":10,"gaugeFontColor":"#FFDF5F2D","gaugeFontSize":16,"labelOffset":15,"rangeOffset":0.08,"gradientFrom":"#FF4CAF50","gradientTo":"#FFF44336","textColor":"#333333","pointerColor":"#FFFFFF","speedLabelFontSize":12.4,"speedLabelFontColor":"#AAAAAA"}}}}]}]}
''';

