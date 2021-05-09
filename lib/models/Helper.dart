import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'BaseModel.dart';

void _applyThemeAndPaletteColor(BaseModel model, BuildContext context, int selectedValue) {
  model.selectedThemeIndex = selectedValue;
  model.backgroundColor = model.currentThemeData.brightness == Brightness.dark ? model.currentPrimaryColor : model.currentPaletteColor;
  model.paletteColor = model.currentPaletteColor;
  model.changeTheme(model.currentThemeData);
  model.notifyListeners();
}

Widget showThemeSwitcher(BaseModel model) {
  int _selectedValue = model.selectedThemeIndex;
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return Column(children: <Widget>[
      SizedBox(
        height: 45,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return CupertinoSegmentedControl<int>(
                children: <int, Widget>{
                  0: Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: Icon(Icons.wb_sunny, color: _selectedValue == 0 ? Colors.white : Color.fromRGBO(84, 84, 84, 1))),
                  1: Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child:
                          Transform.rotate(angle: 330 * pi / 180, child: Icon(Icons.nightlight_round, color: _selectedValue == 1 ? Colors.white : Color.fromRGBO(84, 84, 84, 1))))
                },
                padding: const EdgeInsets.all(5),
                unselectedColor: Colors.transparent,
                selectedColor: model.paletteColor,
                pressedColor: model.paletteColor,
                borderColor: Colors.white,
                groupValue: _selectedValue,
                onValueChanged: (int value) {
                  _selectedValue = value;
                  model.currentThemeData = (value == 0) ? ThemeData.light() : ThemeData.dark();
                  _applyThemeAndPaletteColor(model, context, value);
                },
              );
            })),
      )
    ]);
  });
}

double mapRange(double x, double in_min, double in_max, double out_min, double out_max) {
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
