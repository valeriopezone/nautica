import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautica/widgets/BottomSheet.dart';

/// Local imports
import 'BaseModel.dart';

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
                    Text('   Main settings',
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
                                  _applyThemeAndPaletteColor(
                                      model, context, value);
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
                   //  Container(
                   //      padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                   //      child: Row(
                   //        children: <Widget>[
                   //          Expanded(
                   //            child: Padding(
                   //              padding:
                   //              const EdgeInsets.fromLTRB(15, 0, 10, 30),
                   //              child: Row(
                   //                  crossAxisAlignment:
                   //                  CrossAxisAlignment.center,
                   //                  mainAxisAlignment:
                   //                  MainAxisAlignment.spaceBetween,
                   //                  children:
                   //                  _addColorPalettes(model, setState)),
                   //            ),
                   //          ),
                   //        ],
                   //      )),
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
                      ),








                      Container(
                          padding: const EdgeInsets.only(top: 25, left: 15),
                          child: const Text(
                            'Options',
                            style: TextStyle(
                                color: Color.fromRGBO(128, 128, 128, 1),
                                fontSize: 14,
                                fontFamily: 'Roboto-Regular'),
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
                            child: const Text('SAVE',
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
  //Navigator.pop(context);
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





Widget showThemeSwitcher(BaseModel model) {
  int _selectedValue = model.selectedThemeIndex;
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    final double _width = MediaQuery.of(context).size.width * 0.4;
    final Color _textColor = model.themeData.brightness == Brightness.light
        ? const Color.fromRGBO(84, 84, 84, 1)
        : const Color.fromRGBO(218, 218, 218, 1);
    return Column(children: <Widget>[
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: StatefulBuilder(builder:
              (BuildContext context, StateSetter setState) {
            return CupertinoSegmentedControl<int>(
              children: <int, Widget>{
                0: Container(
                  padding :  const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text('Day',
                        style: TextStyle(
                            color: _selectedValue == 0
                                ? Colors.white
                                : _textColor,
                            fontFamily: 'Roboto-Medium'))),
                1: Container(
                    padding :  const EdgeInsets.all(5),

                    alignment: Alignment.center,
                    child: Text('Night',
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
              borderColor: Colors.white,
              groupValue: _selectedValue,
              onValueChanged: (int value) {
                _selectedValue = value;
                model.currentThemeData = (value == 0)
                    ? ThemeData.light()
                    : ThemeData.dark();
                _applyThemeAndPaletteColor(
                    model, context, value);

              },
            );
          }))
    ]);
  });
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
                        Text('Hi!',
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

                                _applyThemeAndPaletteColor(
                                    model, context, _selectedIndex);

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
                                      MainAxisAlignment.spaceBetween,),
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



double mapRange(double x, double in_min, double in_max, double out_min, double out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

class DisposableWidget {

  List<StreamSubscription> _subscriptions = [];

  void cancelSubscriptions() {
    _subscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

}

extension DisposableStreamSubscriton on StreamSubscription {
  void canceledBy(DisposableWidget widget) {
    widget.addSubscription(this);
  }
}














































//CONSIDER TO DELETE




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
                      child: const Text('GitHub Project',
                          style: TextStyle(color: Colors.blue, fontSize: 12)),
                    ),
                    Text(' | ',
                        style: TextStyle(
                            fontSize: 12, color: model.textColor.withOpacity(0.7))),

                    InkWell(
                      onTap: () =>(){},
                      child: const Text('Credits',
                          style: TextStyle(color: Colors.blue, fontSize: 12)),
                    ),

                  ],
                ),
                Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('Valerio Pezone | Università degli studi di Napoli Parthenope - Dipartimento di Scienze e Tecnologie - Corso di laurea in Informatica ',
                        style: TextStyle(
                            color: model.textColor.withOpacity(0.7),
                            fontSize: 12,
                            letterSpacing: 0.23)))
              ],
            )),
       // InkWell(
       //   onTap: () => (){},
       //   child: Image.asset(
       //       model.themeData.brightness == Brightness.dark
       //           ? 'images/syncfusion_dark.png'
       //           : 'images/syncfusion.png',
       //       fit: BoxFit.contain,
       //       height: 25,
       //       width: model.isMobileResolution ? 80 : 120),
       // ),
      ],
    ),
  );
}




