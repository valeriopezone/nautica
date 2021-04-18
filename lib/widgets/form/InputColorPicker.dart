/// package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:nautica/models/BaseModel.dart';
import 'package:nautica/utils/HexColor.dart';

class InputColorPicker extends StatefulWidget {
  Color currentColor = Colors.black;
  String currentTextColor = "#000000";
  TextEditingController currentController;
  final Future<void> Function(String newColor) onColorChanged;

  InputColorPicker({
    Key key,
    @required this.currentColor,
    @required this.onColorChanged,
    this.currentController,
  }) : super(key: key);

  @override
  _InputColorPicker createState() => _InputColorPicker();
}

class _InputColorPicker extends State<InputColorPicker> {
  BaseModel model = BaseModel.instance;

  @override
  void initState() {
    super.initState();

    if(widget.currentController != null){
      widget.currentTextColor = widget.currentController.text;
      widget.currentColor = HexColor(widget.currentTextColor);
    }
  }
  @override

  void dispose() {
    print("COLOR DISPOSE");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


            return AlertDialog(
              titlePadding: const EdgeInsets.all(0.0),
              contentPadding: const EdgeInsets.all(0.0),
              content: SingleChildScrollView(
                child: FutureBuilder(
                  builder: (context, snapshot) {
                    return ColorPicker(
                      pickerColor: widget.currentColor,
                      onColorChanged: (Color color) {
                        print("NEW COLOR - > " + color.toString());

                       setState((){
                         widget.currentColor = color;
                         widget.currentTextColor = "#" + color.toString().split('(0x')[1].split(')')[0];
                         widget.onColorChanged(widget.currentTextColor);


                       });
                      },
                      colorPickerWidth: 300.0,
                      pickerAreaHeightPercent: 0.7,
                      enableAlpha: true,
                      displayThumbColor: true,
                      showLabel: true,
                      paletteType: PaletteType.hsv,
                      pickerAreaBorderRadius: const BorderRadius.only(
                        topLeft: const Radius.circular(2.0),
                        topRight: const Radius.circular(2.0),
                      ),
                    );
                  }
                ),
              ),
            );


  }
}
