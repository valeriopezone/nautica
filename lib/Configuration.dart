

class Authentication {
  Authentication(this.username,this.password);
  String username = "";
  String password = "";
}

const Map NAUTICA =  {
  'application':  {'debug': true},
  'signalK':  {'APIVersion': 'v1',
  'connection':
  {
    'address' : '192.168.1.179',
    'port' : 3000
  }},
  'configuration' : {
    'widget' : {
      'refreshRate' : 850 //ms
    },
    'map' : {
      'refreshRate' : 2 //s
    },
    'connection' : {
      'timeout' : 2 //s
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
{"name":"grid1","description":"Descrizione demo","author":"Valerio Pezone","widgets":[{"current":0,"width":4,"height":1,"elements":[{"widgetTitle":"Apparent Wind","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Angle","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Speed","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}}]},{"current":1,"width":2,"height":2,"elements":[{"widgetTitle":"Apparent Wind 2","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Angle 2","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Speed 2","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}}]},{"current":1,"width":1,"height":4,"elements":[{"widgetTitle":"COG(m)","widgetClass":"CompassIndicator","widgetSubscriptions":{"COG_Stream":"navigation.courseOverGroundMagnetic"}},{"widgetTitle":"about COG(m)","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.courseOverGroundMagnetic"}}]},{"current":1,"width":1,"height":4,"elements":[{"widgetTitle":"Apparent Wind 3","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Angle 3","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Speed 3","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}}]},{"current":1,"width":2,"height":2,"elements":[{"widgetTitle":"Apparent  4","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Angle 4","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Speed 4","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}}]},{"current":1,"width":4,"height":1,"elements":[{"widgetTitle":"Apparent  5","widgetClass":"WindIndicator","widgetSubscriptions":{"Angle_Stream":"environment.wind.angleApparent","Intensity_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Angle 5","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Speed 5","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Speed 6","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Speed 7","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}},{"widgetTitle":"Speed 8","widgetClass":"BasicGraph","widgetSubscriptions":{"DataValue_Stream":"environment.wind.speedApparent"}}]}]}
''';
String x =  '''
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



