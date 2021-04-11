import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseModel extends Listenable {
  BaseModel() {
    //set style4 as default
   // selectedThemeIndex = 2;

    for (int j = 0; j < paletteBorderColors.length; j++) {
      paletteBorderColors[j] = Colors.transparent;
    }

    paletteBorderColors[4] = paletteColors[4];
    currentPaletteColor = paletteColors[4];
    currentPrimaryColor = darkPaletteColors[4];
    //_setDarkColors();

    selectedThemeIndex = 0;
    backgroundColor = currentPrimaryColor;
    paletteColor = currentPaletteColor;
    // ignore: invalid_use_of_protected_member

  }

static BaseModel instance = BaseModel();

Color backgroundColor = const Color.fromRGBO(0, 116, 227, 1);
Color paletteColor = const Color.fromRGBO(0, 116, 227, 1);
Color currentPrimaryColor = const Color.fromRGBO(0, 116, 227, 1);

ThemeData themeData;
Color textColor = const Color.fromRGBO(51, 51, 51, 1);
Color drawerTextIconColor = Colors.black;
Color bottomSheetBackgroundColor = Colors.white;
Color cardThemeColor = Colors.white;
Color webBackgroundColor = const Color.fromRGBO(246, 246, 246, 1);
Color webIconColor = const Color.fromRGBO(0, 0, 0, 0.54);
Color webInputColor = const Color.fromRGBO(242, 242, 242, 1);
Color webOutputContainerColor = Colors.white;
Color cardColor = Colors.white;
  Color dividerColor = const Color.fromRGBO(204, 204, 204, 1);
  Color splashScreenBackground = const Color.fromRGBO(212, 212, 212, 1.0);

Size oldWindowSize;
Size currentWindowSize;
dynamic currentRenderSample;
String currentSampleKey;

List<Color> paletteColors = <Color>[
  const Color.fromRGBO(0, 116, 227, 1),
  const Color.fromRGBO(230, 74, 25, 1),
  const Color.fromRGBO(216, 27, 96, 1),
  const Color.fromRGBO(103, 58, 184, 1),
  const Color.fromRGBO(2, 137, 123, 1.0)
];
List<Color> paletteBorderColors = <Color>[
  const Color.fromRGBO(68, 138, 255, 1),
  const Color.fromRGBO(255, 110, 64, 1),
  const Color.fromRGBO(238, 79, 132, 1),
  const Color.fromRGBO(180, 137, 255, 1),
  const Color.fromRGBO(29, 233, 182, 1)
];

List<Color> darkPaletteColors =  <Color>[
  const Color.fromRGBO(0, 116, 227, 1),
  Colors.transparent,
  Colors.transparent,
  Colors.transparent,
  Colors.transparent
];


//widget, gauges, ecc

  Color positiveWind = Color.fromRGBO(20, 148, 0, 1.0);
  Color negativeWind = Color.fromRGBO(141, 0, 10, 1.0);





ThemeData currentThemeData;
Color currentPaletteColor = const Color.fromRGBO(0, 116, 227, 1);
int selectedThemeIndex = 0;
bool isCardView = true;
bool isMobileResolution;
ThemeData systemTheme;
TextEditingController editingController = TextEditingController();
bool needToMaximize = false;
bool isWebFullView = false;
bool isMobile = false;
bool isWeb = false;
bool isDesktop = false;
bool isAndroid = false;
bool isWindows = false;
bool isIOS = false;
bool isLinux = false;
bool isMacOS = false;

String currentMapTheme;


void _setDarkColors(){
  dividerColor = const Color.fromRGBO(61, 61, 61, 1);
  cardColor = const Color.fromRGBO(48, 48, 48, 1);
  webIconColor = const Color.fromRGBO(255, 255, 255, 0.65);
  webOutputContainerColor = const Color.fromRGBO(23, 23, 23, 1);
  webInputColor = const Color.fromRGBO(44, 44, 44, 1);
  webBackgroundColor = const Color.fromRGBO(33, 33, 33, 1);
  drawerTextIconColor = Colors.white;
  bottomSheetBackgroundColor = const Color.fromRGBO(34, 39, 51, 1);
  textColor = const Color.fromRGBO(242, 242, 242, 1);
  cardThemeColor = const Color.fromRGBO(33, 33, 33, 1);
  currentMapTheme = '[{"elementType":"geometry","stylers":[{"color":"#1d2c4d"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},{"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#64779e"}]},{"featureType":"administrative.neighborhood","stylers":[{"visibility":"off"}]},{"featureType":"administrative.province","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},{"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#334e87"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#023e58"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#283d6a"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#6f9ba5"}]},{"featureType":"poi","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#023e58"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#3C7680"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#304a7d"}]},{"featureType":"road","elementType":"labels","stylers":[{"visibility":"off"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},{"featureType":"road","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"road.arterial","stylers":[{"visibility":"off"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2c6675"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#255763"}]},{"featureType":"road.highway","elementType":"labels","stylers":[{"visibility":"off"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#b0d5ce"}]},{"featureType":"road.highway","elementType":"labels.text.stroke","stylers":[{"color":"#023e58"}]},{"featureType":"road.local","stylers":[{"visibility":"off"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},{"featureType":"transit","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},{"featureType":"transit.line","elementType":"geometry.fill","stylers":[{"color":"#283d6a"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#3a4762"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1626"}]},{"featureType":"water","elementType":"labels.text","stylers":[{"visibility":"off"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4e6d70"}]}]';

}

void _setLightColors(){
  dividerColor = const Color.fromRGBO(204, 204, 204, 1);
  cardColor = Colors.white;
  webIconColor = const Color.fromRGBO(0, 0, 0, 0.54);
  webOutputContainerColor = Colors.white;
  webInputColor = const Color.fromRGBO(242, 242, 242, 1);
  webBackgroundColor = const Color.fromRGBO(246, 246, 246, 1);
  drawerTextIconColor = Colors.black;
  bottomSheetBackgroundColor = Colors.white;
  textColor = const Color.fromRGBO(51, 51, 51, 1);
  cardThemeColor = Colors.white;
  currentMapTheme = '[{"elementType":"geometry","stylers":[{"color":"#f5f5f5"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f5f5"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},{"featureType":"road.arterial","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dadada"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9c9c9"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]}]';

}

void changeTheme(ThemeData _themeData) {
  themeData = _themeData;
  switch (_themeData.brightness) {
    case Brightness.dark:
      {
        _setDarkColors();
        break;
      }
    default:
      {
        _setLightColors();
        break;
      }
  }
}

Widget getLoadingPage(){
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Stack(
              children: [
                SizedBox(
                  width:130,
                  height:130,
                  child: CircularProgressIndicator(
                    backgroundColor: paletteColor,
                    valueColor: new AlwaysStoppedAnimation<Color>(dividerColor),
                    strokeWidth: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

final Set<VoidCallback> _listeners = Set<VoidCallback>();
@override

void addListener(VoidCallback listener) {
  _listeners.add(listener);
}

@override
void removeListener(VoidCallback listener) {
  _listeners.remove(listener);
}

@protected
void notifyListeners() {
  _listeners.toList().forEach((VoidCallback listener) => listener());
}
}