/// Dart import
import 'dart:convert';
import 'dart:io' show Platform;

/// Package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseModel extends Listenable {
  /// Contains the category, control, theme information
  BaseModel() {

  }

  /// Used to create the instance of [SampleModel]
static BaseModel instance = BaseModel();


/// holds theme based current palette color
Color backgroundColor = const Color.fromRGBO(0, 116, 227, 1);

/// holds light theme current palette color
Color paletteColor = const Color.fromRGBO(0, 116, 227, 1);

/// holds current palette color
/// on toggling the palette colors before or after apply settings
Color currentPrimaryColor = const Color.fromRGBO(0, 116, 227, 1);

/// holds the current theme data
ThemeData themeData;

/// Holds theme baased color of web outputcontainer
Color textColor = const Color.fromRGBO(51, 51, 51, 1);

/// Holds theme based drawer text color
Color drawerTextIconColor = Colors.black;

/// Holds theme based bottom sheet color
Color bottomSheetBackgroundColor = Colors.white;

/// Holds theme based card color
Color cardThemeColor = Colors.white;

/// Holds theme based web page background color
Color webBackgroundColor = const Color.fromRGBO(246, 246, 246, 1);

/// Holds theme based color of icon
Color webIconColor = const Color.fromRGBO(0, 0, 0, 0.54);

/// Holds theme based input container color
Color webInputColor = const Color.fromRGBO(242, 242, 242, 1);

/// Holds theme based web outputcontainer color
Color webOutputContainerColor = Colors.white;

/// Holds the theme based card's color
Color cardColor = Colors.white;

/// Holds the theme based divider color
Color dividerColor = const Color.fromRGBO(204, 204, 204, 1);

/// Holds the old browser window's height and width
Size oldWindowSize;

/// Holds the current browser window's height and width
 Size currentWindowSize;


/// Holds the current visible sample, only for web
 dynamic currentRenderSample;

/// Holds the current rendered sample's key, only for web
 String currentSampleKey;

/// Contains the light theme pallete colors
 List<Color> paletteColors;

/// Contains the pallete's border colors
 List<Color> paletteBorderColors;

/// Contains dark theme theme palatte colors
 List<Color> darkPaletteColors;

/// Holds current theme data
ThemeData currentThemeData;

/// Holds current pallete color
Color currentPaletteColor = const Color.fromRGBO(0, 116, 227, 1);

/// holds the index to finding the current theme
/// In mobile sb - system 0, light 1, dark 2
int selectedThemeIndex = 0;

/// Holds the information of isCardView or not
bool isCardView = true;

/// Holds the information of isMobileResolution or not
/// To render the appbar and search bar based on it
 bool isMobileResolution;

/// Holds the current system theme
 ThemeData systemTheme;

/// Editing controller which used in the search text field
TextEditingController editingController = TextEditingController();

/// Holds the information of to be maximize or not
bool needToMaximize = false;


///check whether application is running on web/linuxOS/windowsOS/macOS
bool isWebFullView = false;

///Check whether application is running on a mobile device
bool isMobile = false;

///Check whether application is running on the web browser
bool isWeb = false;

///Check whether application is running on the desktop
bool isDesktop = false;

///Check whether application is running on the Android mobile device
bool isAndroid = false;

///Check whether application is running on the Windows desktop OS
bool isWindows = false;

///Check whether application is running on the iOS mobile device
bool isIOS = false;

///Check whether application is running on the Linux desktop OS
bool isLinux = false;

///Check whether application is running on the macOS desktop
bool isMacOS = false;

/// Switching between light, dark, system themes
void changeTheme(ThemeData _themeData) {
  themeData = _themeData;
  switch (_themeData.brightness) {
    case Brightness.dark:
      {
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
        break;
      }
    default:
      {
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
        break;
      }
  }
}

//ignore: prefer_collection_literals
final Set<VoidCallback> _listeners = Set<VoidCallback>();
@override

/// [listener] will be invoked when the model changes.
void addListener(VoidCallback listener) {
  _listeners.add(listener);
}

@override

/// [listener] will no longer be invoked when the model changes.
void removeListener(VoidCallback listener) {
  _listeners.remove(listener);
}

/// Should be called only by [Model] when the model has changed.
@protected
void notifyListeners() {
  _listeners.toList().forEach((VoidCallback listener) => listener());
}
}