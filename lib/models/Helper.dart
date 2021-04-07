import 'dart:async';
/// dart imports
import 'dart:io' show Platform;
import 'dart:typed_data';

/// Package imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautica/widgets/BottomSheet.dart';

/// Local imports
import 'BaseModel.dart';

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;


/// Darwer to show the product related links.
Widget getLeftSideDrawer(BaseModel _model) {
  return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
            width: MediaQuery.of(context).size.width *
                (MediaQuery.of(context).size.width < 600 ? 0.7 : 0.4),
            child: Drawer(
                child: Container(
                  color: _model.themeData.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  child: Column(
                    children: <Widget>[
                      Stack(children: <Widget>[
                        _model.themeData.brightness == Brightness.light
                            ? Container(
                          padding: const EdgeInsets.fromLTRB(10, 30, 30, 10),
                          child: Image.asset('images/image_nav_banner.png',
                              fit: BoxFit.cover),
                        )
                            : Container(
                          padding: const EdgeInsets.fromLTRB(10, 30, 30, 10),
                          child: Image.asset(
                              'images/image_nav_banner_darktheme.png',
                              fit: BoxFit.cover),
                        )
                      ]),
                      Expanded(
                        /// ListView contains a group of widgets
                        /// that scroll inside the drawer
                        child: ListView(
                          children: <Widget>[
                            SingleChildScrollView(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                                    child: Text('Fast . Fluid . Flexible',
                                        style: TextStyle(
                                            color: _model.drawerTextIconColor,
                                            fontSize: 14,
                                            letterSpacing: 0.26,
                                            fontFamily: 'Roboto-Regular',
                                            fontWeight: FontWeight.normal)),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            splashColor: Colors.grey.withOpacity(0.4),
                                            onTap: () {
                                              Feedback.forLongPress(context);

                                            },
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    25, 0, 0, 0),
                                                child: Column(
                                                  children: <Widget>[
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.only(top: 10)),
                                                    Row(children: <Widget>[
                                                      Image.asset('images/product.png',
                                                          fit: BoxFit.contain,
                                                          height: 22,
                                                          width: 22,
                                                          color: _model.webIconColor),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.fromLTRB(
                                                            15, 0, 0, 0),
                                                        child: Text('Product page',
                                                            style: TextStyle(
                                                                color: _model
                                                                    .drawerTextIconColor,
                                                                fontSize: 16,
                                                                letterSpacing: 0.4,
                                                                fontFamily:
                                                                'Roboto-Regular',
                                                                fontWeight:
                                                                FontWeight.normal)),
                                                      )
                                                    ]),
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.only(top: 10)),
                                                  ],
                                                )))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            splashColor: Colors.grey.withOpacity(0.4),
                                            onTap: () {
                                              Feedback.forLongPress(context);

                                            },
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    25, 0, 0, 0),
                                                child: Column(
                                                  children: <Widget>[
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.only(top: 10)),
                                                    Row(children: <Widget>[
                                                      Image.asset(
                                                          'images/documentation.png',
                                                          fit: BoxFit.contain,
                                                          height: 22,
                                                          width: 22,
                                                          color: _model.webIconColor),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.fromLTRB(
                                                            15, 0, 0, 0),
                                                        child: Text('Documentation',
                                                            style: TextStyle(
                                                                color: _model
                                                                    .drawerTextIconColor,
                                                                fontSize: 16,
                                                                letterSpacing: 0.4,
                                                                fontFamily:
                                                                'Roboto-Regular',
                                                                fontWeight:
                                                                FontWeight.normal)),
                                                      )
                                                    ]),
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.only(top: 10)),
                                                  ],
                                                )))),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 40, 0),
                              child: Container(
                                  height: 2, width: 5, color: _model.backgroundColor),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 3, 0),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(15, 10, 0, 0),
                                    child: Row(children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: Text('Other products',
                                            style: TextStyle(
                                                color: _model.drawerTextIconColor,
                                                fontSize: 16,
                                                letterSpacing: 0.4,
                                                fontFamily: 'Roboto-Regular',
                                                fontWeight: FontWeight.bold)),
                                      )
                                    ]),
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                                  Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                          splashColor: Colors.grey.withOpacity(0.4),
                                          onTap: () {
                                            Feedback.forLongPress(context);

                                          },
                                          child: Column(
                                            children: <Widget>[
                                              const Padding(
                                                  padding: EdgeInsets.only(top: 10)),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                      padding:
                                                      const EdgeInsets.fromLTRB(
                                                          15, 0, 0, 0),
                                                      child: Image.asset(
                                                          'images/img_xamarin.png',
                                                          fit: BoxFit.contain,
                                                          height: 28,
                                                          width: 28)),
                                                  Container(
                                                      padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 0, 0),
                                                      child: Text('Xamarin Demo',
                                                          style: TextStyle(
                                                              color: _model
                                                                  .drawerTextIconColor,
                                                              fontSize: 16,
                                                              letterSpacing: 0.4,
                                                              fontFamily:
                                                              'Roboto-Regular',
                                                              fontWeight:
                                                              FontWeight.normal))),
                                                  const Spacer(),
                                                  Container(
                                                    child: Icon(Icons.arrow_forward,
                                                        color: _model.backgroundColor),
                                                  ),
                                                ],
                                              ),
                                              const Padding(
                                                  padding: EdgeInsets.only(top: 10)),
                                            ],
                                          ))),
                                  Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                          splashColor: Colors.grey.withOpacity(0.4),
                                          onTap: () {
                                            Feedback.forLongPress(context);

                                          },
                                          child: Column(
                                            children: <Widget>[
                                              const Padding(
                                                  padding: EdgeInsets.only(top: 10)),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                      padding:
                                                      const EdgeInsets.fromLTRB(
                                                          15, 0, 0, 0),
                                                      child: Image.asset(
                                                          'images/img_xamarin_ui.png',
                                                          fit: BoxFit.contain,
                                                          height: 28,
                                                          width: 28)),
                                                  Container(
                                                    padding: const EdgeInsets.fromLTRB(
                                                        10, 0, 0, 0),
                                                    child: Text('Xamarin UI kit Demo',
                                                        style: TextStyle(
                                                            color: _model
                                                                .drawerTextIconColor,
                                                            fontSize: 16,
                                                            letterSpacing: 0.4,
                                                            fontFamily:
                                                            'Roboto-Regular',
                                                            fontWeight:
                                                            FontWeight.normal)),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    child: Icon(Icons.arrow_forward,
                                                        color: _model.backgroundColor),
                                                  ),
                                                ],
                                              ),
                                              const Padding(
                                                  padding: EdgeInsets.only(top: 10)),
                                            ],
                                          ))),
                                  Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                          splashColor: Colors.grey.withOpacity(0.4),
                                          onTap: () {
                                            Feedback.forLongPress(context);

                                          },
                                          child: Column(
                                            children: <Widget>[
                                              const Padding(
                                                  padding: EdgeInsets.only(top: 10)),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                      padding:
                                                      const EdgeInsets.fromLTRB(
                                                          15, 0, 0, 0),
                                                      child: Image.asset(
                                                          'images/img_JS.png',
                                                          fit: BoxFit.contain,
                                                          height: 28,
                                                          width: 28)),
                                                  Container(
                                                    padding: const EdgeInsets.fromLTRB(
                                                        10, 0, 0, 0),
                                                    child: Text('JavaScript Demo',
                                                        style: TextStyle(
                                                            color: _model
                                                                .drawerTextIconColor,
                                                            fontSize: 16,
                                                            letterSpacing: 0.4,
                                                            fontFamily:
                                                            'Roboto-Regular',
                                                            fontWeight:
                                                            FontWeight.normal)),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    child: Icon(Icons.arrow_forward,
                                                        color: _model.backgroundColor),
                                                  ),
                                                ],
                                              ),
                                              const Padding(
                                                  padding: EdgeInsets.only(top: 10)),
                                            ],
                                          ))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// This container holds the align
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Image.asset(
                                  _model.themeData.brightness == Brightness.dark
                                      ? 'images/syncfusion_dark.png'
                                      : 'images/syncfusion.png',
                                  fit: BoxFit.contain,
                                  height: 50,
                                  width: 100,
                                )),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Text('Version 19.1.0.54',
                                    style: TextStyle(
                                        color: _model.drawerTextIconColor,
                                        fontSize: 12,
                                        letterSpacing: 0.4,
                                        fontFamily: 'Roboto-Regular',
                                        fontWeight: FontWeight.normal)))
                          ],
                        ),
                      ),
                    ],
                  ),
                )));
      });
}

/// Shows copyright message, product related links
/// at the bottom of the home page.
Widget getFooter(BuildContext context, BaseModel model) {
  return Container(
    height: 60,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(width: 0.8, color: model.dividerColor),
      ),
      color: model.themeData.brightness == Brightness.dark
          ? const Color.fromRGBO(33, 33, 33, 1)
          : const Color.fromRGBO(234, 234, 234, 1),
    ),
    padding: model.isMobileResolution
        ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.025, 0,
        MediaQuery.of(context).size.width * 0.025, 0)
        : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.05, 0,
        MediaQuery.of(context).size.width * 0.05, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () => (){},
                      child: const Text('Documentation',
                          style: TextStyle(color: Colors.blue, fontSize: 12)),
                    ),
                    Text(' | ',
                        style: TextStyle(
                            fontSize: 12, color: model.textColor.withOpacity(0.7))),
                    InkWell(
                      onTap: () =>(){},
                      child: const Text('Forum',
                          style: TextStyle(color: Colors.blue, fontSize: 12)),
                    ),
                    Text(' | ',
                        style: TextStyle(
                            fontSize: 12, color: model.textColor.withOpacity(0.7))),
                    InkWell(
                      onTap: () =>(){},
                      child: const Text('Blog',
                          style: TextStyle(color: Colors.blue, fontSize: 12)),
                    ),
                    Text(' | ',
                        style: TextStyle(
                            fontSize: 12, color: model.textColor.withOpacity(0.7))),
                    InkWell(
                      onTap: () => (){},
                      child: const Text('Knowledge base',
                          style: TextStyle(color: Colors.blue, fontSize: 12)),
                    )
                  ],
                ),
                Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('Copyright © 2001 - 2021 Syncfusion Inc.',
                        style: TextStyle(
                            color: model.textColor.withOpacity(0.7),
                            fontSize: 12,
                            letterSpacing: 0.23)))
              ],
            )),
        InkWell(
          onTap: () => (){},
          child: Image.asset(
              model.themeData.brightness == Brightness.dark
                  ? 'images/syncfusion_dark.png'
                  : 'images/syncfusion.png',
              fit: BoxFit.contain,
              height: 25,
              width: model.isMobileResolution ? 80 : 120),
        ),
      ],
    ),
  );
}

/// Show Right drawer which contains theme settings for web.
Widget showWebThemeSettings(BaseModel model) {
  int _selectedValue = model.selectedThemeIndex;
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    final double _width = MediaQuery.of(context).size.width * 0.4;
    final Color _textColor = model.themeData.brightness == Brightness.light
        ? const Color.fromRGBO(84, 84, 84, 1)
        : const Color.fromRGBO(218, 218, 218, 1);
    return Drawer(
        child: Container(
            color: model.bottomSheetBackgroundColor,
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('   Settings',
                        style: TextStyle(
                            color: model.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto-Medium')),
                    IconButton(
                        icon: Icon(Icons.close, color: model.webIconColor),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Column(children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return CupertinoSegmentedControl<int>(
                                children: <int, Widget>{
                                  0: Container(
                                      width: _width,
                                      alignment: Alignment.center,
                                      child: Text('Light theme',
                                          style: TextStyle(
                                              color: _selectedValue == 0
                                                  ? Colors.white
                                                  : _textColor,
                                              fontFamily: 'Roboto-Medium'))),
                                  1: Container(
                                      width: _width,
                                      alignment: Alignment.center,
                                      child: Text('Dark theme',
                                          style: TextStyle(
                                              color: _selectedValue == 1
                                                  ? Colors.white
                                                  : _textColor,
                                              fontFamily: 'Roboto-Medium')))
                                },
                                padding: const EdgeInsets.all(5),
                                unselectedColor: Colors.transparent,
                                selectedColor: model.paletteColor,
                                pressedColor: model.paletteColor,
                                borderColor: model.paletteColor,
                                groupValue: _selectedValue,
                                onValueChanged: (int value) {
                                  _selectedValue = value;
                                  model.currentThemeData = (value == 0)
                                      ? ThemeData.light()
                                      : ThemeData.dark();

                                  setState(() {
                                    /// update the theme changes
                                    /// tp [CupertinoSegmentedControl]
                                  });
                                },
                              );
                            }))
                      ]),
                      Container(
                          padding: const EdgeInsets.only(top: 25, left: 15),
                          child: const Text(
                            'Theme colors',
                            style: TextStyle(
                                color: Color.fromRGBO(128, 128, 128, 1),
                                fontSize: 14,
                                fontFamily: 'Roboto-Regular'),
                          )),
                      Container(
                          padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(15, 0, 10, 30),
                                  child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children:
                                      _addColorPalettes(model, setState)),
                                ),
                              ),
                            ],
                          )),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  model.paletteColor),
                            ),
                            onPressed: () => _applyThemeAndPaletteColor(
                                model, context, _selectedValue),
                            child: const Text('APPLY',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Roboto-Bold',
                                    color: Colors.white))),
                      )
                    ],
                  ),
                ),
              ],
            )));
  });
}

/// Apply the selected theme to the whole application.
void _applyThemeAndPaletteColor(
    BaseModel model, BuildContext context, int selectedValue) {
  model.selectedThemeIndex = selectedValue;
  model.backgroundColor = model.currentThemeData.brightness == Brightness.dark
      ? model.currentPrimaryColor
      : model.currentPaletteColor;
  model.paletteColor = model.currentPaletteColor;
  model.changeTheme(model.currentThemeData);
  // ignore: invalid_use_of_protected_member
  model.notifyListeners();
  Navigator.pop(context);
}

/// Adding the palette color in the theme setting panel.
List<Widget> _addColorPalettes(BaseModel model, [StateSetter setState]) {
  final List<Widget> _colorPaletteWidgets = <Widget>[];
  if(model != null && model.paletteColors != null) {
    for (int i = 0; i < model.paletteColors.length; i++) {
      _colorPaletteWidgets.add(Material(
          color: model.bottomSheetBackgroundColor,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border:
              Border.all(color: model.paletteBorderColors[i], width: 2.0),
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: () => _changeColorPalette(model, i, setState),
              child: Icon(
                Icons.brightness_1,
                size: 40.0,
                color: model.paletteColors[i],
              ),
            ),
          )));
    }
  }


  return _colorPaletteWidgets;
}

/// Changing the palete color of the application.
void _changeColorPalette(BaseModel model, int index,
    [StateSetter setState]) {
  for (int j = 0; j < model.paletteBorderColors.length; j++) {
    model.paletteBorderColors[j] = Colors.transparent;
  }
  model.paletteBorderColors[index] = model.paletteColors[index];
  model.currentPaletteColor = model.paletteColors[index];
  model.currentPrimaryColor = model.darkPaletteColors[index];

  model.isWebFullView
      ? setState(() {
    /// update the palette color changes
  })
      :
  // ignore: invalid_use_of_protected_member
  model.notifyListeners();
}


/// show bottom sheet which contains theme settings.
void showBottomSettingsPanel(BaseModel model, BuildContext context) {
  int _selectedIndex = model.selectedThemeIndex;
  final double _orientationPadding =
      ((MediaQuery.of(context).size.width) / 100) * 10;
  final double _width = MediaQuery.of(context).size.width * 0.3;
  final Color _textColor = model.themeData.brightness == Brightness.light
      ? const Color.fromRGBO(84, 84, 84, 1)
      : const Color.fromRGBO(218, 218, 218, 1);
  showRoundedModalBottomSheet<dynamic>(
      context: context,
      color: model.bottomSheetBackgroundColor,
      builder: (BuildContext context) => Container(
          height: 250,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 0, 0),
                child: Stack(children: <Widget>[
                  Container(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Settings',
                            style: TextStyle(
                                color: model.textColor,
                                fontSize: 18,
                                letterSpacing: 0.34,
                                fontFamily: 'HeeboBold',
                                fontWeight: FontWeight.w500)),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: model.textColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  )
                ]),
              ),
              Expanded(
                /// ListView contains a group of widgets
                /// that scroll inside the drawer
                child: ListView(
                  children: <Widget>[
                    Column(children: <Widget>[
                      Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return CupertinoSegmentedControl<int>(
                              children: <int, Widget>{
                                0: Container(
                                    width: _width,
                                    alignment: Alignment.center,
                                    child: Text('System theme',
                                        style: TextStyle(
                                            color: _selectedIndex == 0
                                                ? Colors.white
                                                : _textColor,
                                            fontFamily: 'HeeboMedium'))),
                                1: Container(
                                    width: _width,
                                    alignment: Alignment.center,
                                    child: Text('Light theme',
                                        style: TextStyle(
                                            color: _selectedIndex == 1
                                                ? Colors.white
                                                : _textColor,
                                            fontFamily: 'HeeboMedium'))),
                                2: Container(
                                    width: _width,
                                    alignment: Alignment.center,
                                    child: Text('Dark theme',
                                        style: TextStyle(
                                            color: _selectedIndex == 2
                                                ? Colors.white
                                                : _textColor,
                                            fontFamily: 'HeeboMedium')))
                              },
                              unselectedColor: Colors.transparent,
                              selectedColor: model.paletteColor,
                              pressedColor: model.paletteColor,
                              borderColor: model.paletteColor,
                              groupValue: _selectedIndex,
                              padding:
                              const EdgeInsets.fromLTRB(10, 15, 10, 15),
                              onValueChanged: (int value) {
                                _selectedIndex = value;
                                if (value == 0) {
                                  model.currentThemeData =
                                  model.systemTheme.brightness !=
                                      Brightness.dark
                                      ? ThemeData.light()
                                      : ThemeData.dark();
                                } else if (value == 1) {
                                  model.currentThemeData = ThemeData.light();
                                } else {
                                  model.currentThemeData = ThemeData.dark();
                                }
                                setState(() {
                                  /// update the theme changes to
                                  /// [CupertinoSegmentedControl]
                                });
                              },
                            );
                          }))
                    ]),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: MediaQuery.of(context).orientation ==
                          Orientation.portrait
                          ? Container(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15, 0, 10, 30),
                                  child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: _addColorPalettes(model)),
                                ),
                              ),
                            ],
                          ))
                          : Container(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      _orientationPadding + 10,
                                      0,
                                      _orientationPadding + 10,
                                      30),
                                  child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: _addColorPalettes(model)),
                                ),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
              Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(0),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              model.paletteColor),
                        ),
                        onPressed: () => _applyThemeAndPaletteColor(
                            model, context, _selectedIndex),
                        child: const Text('APPLY',
                            style: TextStyle(
                                fontFamily: 'HeeboMedium',
                                color: Colors.white))),
                  ))
            ],
          )));
}

///To show the settings panel content in the bottom sheet
void showBottomSheetSettingsPanel(BuildContext context, Widget propertyWidget) {
  final BaseModel _model = BaseModel.instance;
  showRoundedModalBottomSheet<dynamic>(
      context: context,
      color: _model.bottomSheetBackgroundColor,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(15, 0, 0, 5),
        child: Stack(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Settings',
                  style: TextStyle(
                      color: _model.textColor,
                      fontSize: 18,
                      letterSpacing: 0.34,
                      fontWeight: FontWeight.w500)),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: _model.textColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Theme(
              data: ThemeData(
                  brightness: _model.themeData.brightness,
                  primaryColor: _model.backgroundColor),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 50, 0, 0),
                  child: propertyWidget))
        ]),
      ));
}

///To show the sample description in the bottom sheet
void showBottomInfo(BuildContext context, String information) {
  final BaseModel _model = BaseModel.instance;
  if (information != null && information != '') {
    showRoundedModalBottomSheet<dynamic>(
        context: context,
        color: _model.bottomSheetBackgroundColor,
        builder: (BuildContext context) => Theme(
            data: ThemeData(
                brightness: _model.themeData.brightness,
                primaryColor: _model.backgroundColor),
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 5),
              child: Stack(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Description',
                        style: TextStyle(
                            color: _model.textColor,
                            fontSize: 18,
                            letterSpacing: 0.34,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: _model.textColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 45, 12, 15),
                    child: ListView(shrinkWrap: true, children: [
                      Text(
                        information,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            color: _model.textColor,
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0,
                            letterSpacing: 0.2,
                            height: 1.2),
                      )
                    ]))
              ]),
            )));
  }
}




Future<ui.Image> loadUiImage(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  final list = Uint8List.view(data.buffer);
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(list, completer.complete);
  return completer.future;
}