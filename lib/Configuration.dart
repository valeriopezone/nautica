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
  'DateValueAxisChart': ['DataValue_Stream']
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
  'DBST_Stream': 'environment.depth.surfaceToTransducer'
};

const Map IndicatorOptionsSpecs = {
  'WindIndicator': {'labelFontSize': 20},
  'CompassIndicator': {'labelFontSize': 20},
  'SpeedIndicator': {'labelFontSize': 20},
  'BoatVectorsIndicator': {'labelFontSize': 20},
  'DateValueAxisChart': {'labelFontSize': 20}
};

//types : color | text | double
const Map IndicatorGraphicSpecs = {
  'WindIndicator': {
    'lightTheme': {
      'labelFontSize': {
        'type' : 'double',
        'default' : 20
      },
      'labelFontColor': {
        'type' : 'color',
        'default' : "#003366ff"
      },

      'labelFontColor2': {
        'type' : 'color',
        'default' : "#33333333"
      },
      'labelFontColor3': {
        'type' : 'color',
        'default' : "#33333333"
      },
      'genericText': {
        'type' : 'text',
        'default' : "BLA BLA 123"
      }
    },
    'darkTheme': {
      'labelFontSize': {
        'type' : 'double',
        'default' : 55
      },
      'labelFontColor': {
        'type' : 'color',
        'default' : "#11223344"
      },

      'labelFontColor2': {
        'type' : 'color',
        'default' : "#44332211"
      },
      'labelFontColor3': {
        'type' : 'color',
        'default' : "#11332244"
      },
      'genericText': {
        'type' : 'text',
        'default' : "qww3"
      }
    }
  },
  'CompassIndicator': {
    'lightTheme': {
      'labelFontSize': {
        'type' : 'double',
        'default' : 220
      },
      'labelFontColor': {
        'type' : 'color',
        'default' : "#3366ff00"
      }
    },
    'darkTheme': {
      'labelFontSize': {
        'type' : 'double',
        'default' : 21
      },
      'labelFontColor': {
        'type' : 'color',
        'default' : "#ffffff"
      }
    }
  },
  'SpeedIndicator': {
    'lightTheme': {
      'labelFontSize': {
        'type' : 'double',
        'default' : 20
      },
      'labelFontColor': {
        'type' : 'color',
        'default' : "#3366ff00"
      }
    },
    'darkTheme': {
      'labelFontSize': {
        'type' : 'double',
        'default' : 21
      },
      'labelFontColor': {
        'type' : 'color',
        'default' : "#ffffff"
      }
    }
  },
  'BoatVectorsIndicator': {
    'lightTheme':{
      'labelFontSize': {
        'type' : 'double',
        'default' : 20
      },
      'labelFontColor': {
        'type' : 'color',
        'default' : "#3366ff00"
      }
    },
    'darkTheme':{
      'labelFontSize': {
        'type' : 'double',
        'default' : 21
      },
      'labelFontColor': {
        'type' : 'color',
        'default' : "#ffffff"
      }
    }
  },
  'DateValueAxisChart': {
    'lightTheme': {
      'labelFontSize': {
        'type' : 'double',
        'default' : 20
      },
      'labelFontColor': {
        'type' : 'color',
        'default' : "#3366ff00"
      }
    },
    'darkTheme': {
      'labelFontSize': {
        'type' : 'double',
        'default' : 21
      },
      'labelFontColor': {
        'type' : 'color',
        'default' : "#ffffff"
      }
    }
  }
};
/*
Map models = {"Player": Player.instatiate};
var player = models["Player"]();

class Player{
  int x;
  int y;
  Player(this.x, this.y){

  }
  static instatiate() => Player();
}
*/

String mainJSONGridTheme = '''
{"name":"Nautica","description":"Basic grid","author":"Valerio Pezone","widgets":[{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"Apparent Wind","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Angle","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Speed","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"RPM #1","widgetClass":"SpeedIndicator","widgetSubscriptions":{"COG_Stream":"propulsion.engine_1.revolutions"}},{"widgetTitle":"about COG(m)","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"propulsion.engine_1.revolutions"}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"RPM #2","widgetClass":"SpeedIndicator","widgetSubscriptions":{"COG_Stream":"propulsion.engine_2.revolutions"}},{"widgetTitle":"about COG(m)","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"propulsion.engine_2.revolutions"}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"True wind through water","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleTrueWater","Intensity_Stream":"environment.wind.speedTrue"}},{"widgetTitle":"Angle","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.angleTrueWater"}},{"widgetTitle":"Speed","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedTrue"}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"COG(m)","widgetClass":"CompassIndicator","widgetSubscriptions":{"COG_Stream":"navigation.courseOverGroundMagnetic"}},{"widgetTitle":"Angle","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"navigation.courseOverGroundMagnetic"}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"COG(t)","widgetClass":"CompassIndicator","widgetSubscriptions":{"COG_Stream":"navigation.courseOverGroundMagnetic"}},{"widgetTitle":"Angle","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"navigation.courseOverGroundMagnetic"}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"True wind over ground","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleTrueGround","Intensity_Stream":"environment.wind.speedOverGround"}},{"widgetTitle":"Angle","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.angleTrueGround"}},{"widgetTitle":"Speed","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedOverGround"}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"Speed Through Water","widgetClass":"SpeedIndicator","widgetSubscriptions":{"COG_Stream":"navigation.speedThroughWater"}},{"widgetTitle":"about COG(m)","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"navigation.speedThroughWater"}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"Real time boat","widgetClass":"BoatVectorsIndicator","widgetSubscriptions":{"ATW_Stream":"environment.wind.angleTrueWater","ST_Stream":"environment.wind.speedTrue","AA_Stream":"environment.wind.angleApparent","SA_Stream":"environment.wind.speedApparent","HT_Stream":"navigation.headingTrue","COG_Stream":"navigation.courseOverGroundTrue","SOG_Stream":"navigation.speedOverGround","LatLng_Stream":"navigation.position","DBK_Stream":"environment.depth.belowKeel","DBS_Stream":"environment.depth.belowSurface","DBT_Stream":"environment.depth.belowTransducer","DBST_Stream":"environment.depth.surfaceToTransducer"}},{"widgetTitle":"about COG(m)","widgetClass":"DateValueAxisChart","widgetSubscriptions":{"DataValue_Stream":"navigation.speedThroughWater"}}]}]}
''';

String demoTheme = '''
{"name":"grid1","description":"Descrizione demo","author":"Valerio Pezone","widgets":[{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"Apparent Wind","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"},"widgetOptions":{"settings":[],"graphics":{"lightTheme":{"pointerColor":"#3366FF","textColor":"#3366AA","angleLabelFontSize":15.5,"angleLabelFontColor":"#3366BB","speedLabelFontSize":12.4,"speedLabelFontColor":"#3366EE"},"darkTheme":{"pointerColor":"#FFFFFF","textColor":"#333333","angleLabelFontSize":15.5,"angleLabelFontColor":"#BBBBBB","speedLabelFontSize":12.4,"speedLabelFontColor":"#AAAAAA"}}}},{"widgetTitle":"Apparent Wind1","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"},"widgetOptions":{"settings":[],"graphics":{"lightTheme":{"pointerColor":"#3366FF","textColor":"#3366AA","angleLabelFontSize":15.5,"angleLabelFontColor":"#3366BB","speedLabelFontSize":12.4,"speedLabelFontColor":"#3366EE"},"darkTheme":{"pointerColor":"#FFFFFF","textColor":"#333333","angleLabelFontSize":15.5,"angleLabelFontColor":"#BBBBBB","speedLabelFontSize":12.4,"speedLabelFontColor":"#AAAAAA"}}}},{"widgetTitle":"Apparent Wind2","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"},"widgetOptions":{"settings":[],"graphics":{"lightTheme":{"pointerColor":"#3366FF","textColor":"#3366AA","angleLabelFontSize":15.5,"angleLabelFontColor":"#3366BB","speedLabelFontSize":12.4,"speedLabelFontColor":"#3366EE"},"darkTheme":{"pointerColor":"#FFFFFF","textColor":"#333333","angleLabelFontSize":15.5,"angleLabelFontColor":"#BBBBBB","speedLabelFontSize":12.4,"speedLabelFontColor":"#AAAAAA"}}}}]},{"current":0,"width":1,"height":1,"elements":[{"widgetTitle":"SPEED Wind","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"},"widgetOptions":{"settings":[],"graphics":{"lightTheme":{"pointerColor":"#3366FF","textColor":"#3366AA","angleLabelFontSize":15.5,"angleLabelFontColor":"#3366BB","speedLabelFontSize":12.4,"speedLabelFontColor":"#3366EE"},"darkTheme":{"pointerColor":"#FFFFFF","textColor":"#333333","angleLabelFontSize":15.5,"angleLabelFontColor":"#BBBBBB","speedLabelFontSize":12.4,"speedLabelFontColor":"#AAAAAA"}}}},{"widgetTitle":"SPEED Wind1","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"},"widgetOptions":{"settings":[],"graphics":{"lightTheme":{"pointerColor":"#3366FF","textColor":"#3366AA","angleLabelFontSize":15.5,"angleLabelFontColor":"#3366BB","speedLabelFontSize":12.4,"speedLabelFontColor":"#3366EE"},"darkTheme":{"pointerColor":"#FFFFFF","textColor":"#333333","angleLabelFontSize":15.5,"angleLabelFontColor":"#BBBBBB","speedLabelFontSize":12.4,"speedLabelFontColor":"#AAAAAA"}}}},{"widgetTitle":"SPEED Wind2","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"},"widgetOptions":{"settings":[],"graphics":{"lightTheme":{"pointerColor":"#3366FF","textColor":"#3366AA","angleLabelFontSize":15.5,"angleLabelFontColor":"#3366BB","speedLabelFontSize":12.4,"speedLabelFontColor":"#3366EE"},"darkTheme":{"pointerColor":"#FFFFFF","textColor":"#333333","angleLabelFontSize":15.5,"angleLabelFontColor":"#BBBBBB","speedLabelFontSize":12.4,"speedLabelFontColor":"#AAAAAA"}}}}]}]}
''';

String x = '''
{
	"name": "grid1",
	"widgets": [{
			"widgetTitle": "Apparent Wind",
			"widgetClass": "WindIndicator",
			"widgetSubscriptions": {
				"Angle_Stream": "environment.wind.angleApparent",
				"Intensity_Stream": "environment.wind.speedApparent"
			},
			"extraWidgets": [{
				"widgetTitle": "Angle",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.wind.angleApparent"
				}
			}, {
				"widgetTitle": "Wind speed",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.wind.speedApparent"
				}
			}]
		}, {
			"widgetTitle": "True Wind through Water",
			"widgetClass": "WindIndicator",
			"widgetSubscriptions": {
				"Angle_Stream": "environment.wind.angleTrueWater",
				"Intensity_Stream": "environment.wind.speedTrue"
			},
			"extraWidgets": [{
				"widgetTitle": "Angle True (w)",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.wind.angleTrueWater"
				}
			}, {
				"widgetTitle": "True Wind speed (w)",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.wind.speedTrue"
				}
			}]
		}, {
			"widgetTitle": "True Wind over ground",
			"widgetClass": "WindIndicator",
			"widgetSubscriptions": {
				"Angle_Stream": "environment.wind.angleTrueGround",
				"Intensity_Stream": "environment.wind.speedOverGround"
			},
			"extraWidgets": [{
				"widgetTitle": "Angle True (g)",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.wind.angleTrueGround"
				}
			}, {
				"widgetTitle": "True Wind speed (g)",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.wind.speedOverGround"
				}
			}]
		}, {
			"widgetTitle": "Real time boat",
			"widgetClass": "BoatVectorsIndicator",
			"widgetSubscriptions": {
				"ATW_Stream": "environment.wind.angleTrueWater",
				"ST_Stream": "environment.wind.speedTrue",
				"AA_Stream": "environment.wind.angleApparent",
				"SA_Stream": "environment.wind.speedApparent",
				"HT_Stream": "navigation.headingTrue",
				"COG_Stream": "navigation.courseOverGroundTrue",
				"SOG_Stream": "navigation.speedOverGround",
				"LatLng_Stream": "navigation.position",
				"DBK_Stream": "environment.depth.belowKeel",
				"DBS_Stream": "environment.depth.belowSurface",
				"DBT_Stream": "environment.depth.belowTransducer",
				"DBST_Stream": "environment.depth.surfaceToTransducer"
			},
			"extraWidgets": [{
				"widgetTitle": "Angle",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.wind.angleTrueWater"
				}
			}, {
				"widgetTitle": "Wind speed",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.wind.speedTrue"
				}
			}]
		}, {
			"widgetTitle": "COG(m)",
			"widgetClass": "CompassIndicator",
			"widgetSubscriptions": {
				"COG_Stream": "navigation.courseOverGroundMagnetic"
			},
			"extraWidgets": [{
				"widgetTitle": "about COG(m)",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.courseOverGroundMagnetic"
				}
			}]
		}, {
			"widgetTitle": "COG(t)",
			"widgetClass": "CompassIndicator",
			"widgetSubscriptions": {
				"COG_Stream": "navigation.courseOverGroundTrue"
			},
			"extraWidgets": [{
				"widgetTitle": "about COG(t)",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.courseOverGroundTrue"
				}
			}]
		}, {
			"widgetTitle": "Speed Through Water",
			"widgetClass": "SpeedIndicator",
			"widgetSubscriptions": {
				"ST_Stream": "navigation.speedThroughWater"
			},
			"extraWidgets": [{
				"widgetTitle": "real time chart",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "environment.wind.speedThroughWater"
				}
			}]
		}, {
			"widgetTitle": "RPM #1",
			"widgetClass": "SpeedIndicator",
			"widgetSubscriptions": {
				"ST_Stream": "propulsion.engine_1.revolutions"
			},
			"extraWidgets": [{
				"widgetTitle": "real time chart",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "propulsion.engine_1.revolutions"
				}
			}]
		}, {
			"widgetTitle": "RPM #2",
			"widgetClass": "SpeedIndicator",
			"widgetSubscriptions": {
				"ST_Stream": "propulsion.engine_2.revolutions"
			},
			"extraWidgets": [{
				"widgetTitle": "real time chart",
				"widgetClass": "BasicGraph",
				"widgetSubscriptions": {
					"DataValue_Stream": "propulsion.engine_2.revolutions"
				}
			}]
		}



	]
}
''';
