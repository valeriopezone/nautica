import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:nautica/models/BaseModel.dart';


class SubWidgetSelectionTile extends StatefulWidget {
  BaseModel model;
  dynamic subWidgetsNames;
  String currentWidgetSelectedIndex = "0_0";
  String avoidWidget = "";
  int currentPositionIndex;

  final void Function(int positionId, String selectedWidget) onGoingToEditCallback;
  final void Function(int positionId) onGoingToDeleteCallback;

  SubWidgetSelectionTile(
      {Key key,
      @required this.model,
      @required this.currentPositionIndex,
      @required this.currentWidgetSelectedIndex,
      @required this.subWidgetsNames,
      @required this.onGoingToEditCallback,
      @required this.onGoingToDeleteCallback,
      this.avoidWidget})
      : super(key: key);

  void changeCurrentPosition(int positionId) {
    print("Hi, i am ${subWidgetsNames[currentWidgetSelectedIndex]} $currentPositionIndex and now i'm $positionId");
    currentPositionIndex = positionId;
  }

  @override
  _SubWidgetSelectionTileState createState() => _SubWidgetSelectionTileState();
}

class _SubWidgetSelectionTileState extends State<SubWidgetSelectionTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose tile");
    //should call subwidget?
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      dense: true,

      trailing: Icon(Icons.drag_indicator),
      leading: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () {
              print("going to delete ${widget.subWidgetsNames[widget.currentWidgetSelectedIndex]} at ${widget.currentPositionIndex}");
              widget.onGoingToDeleteCallback(widget.currentPositionIndex);
              //widget.currentPositionIndex, _selectedWidget);
            }),
      ]),
      key: widget.key,
      // tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
      title: Container(
          child: Padding(
        padding: const EdgeInsets.only(right: 0.0),
        child: DropdownButtonFormField<String>(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            isExpanded: true,
            decoration: InputDecoration(
                //labelText: 'Widget type',
                filled: true,
                fillColor: Colors.white,
                hintStyle: TextStyle(
                  color: Colors.red,
                ),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
                hintText: "Select a type"),
            value: widget.currentWidgetSelectedIndex,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            style: TextStyle(height: 0.85, fontSize: 14.0, color: Colors.red),
            onChanged: (String _selectedWidget) {
              print("you chose widget type : " + _selectedWidget.toString());
              widget.currentWidgetSelectedIndex = _selectedWidget;
              //call edit callback
              widget.onGoingToEditCallback(widget.currentPositionIndex, _selectedWidget);
            },
            dropdownColor: Colors.white,
            items: widget.subWidgetsNames.keys.map<DropdownMenuItem<String>>((String k) {
              //print("$k != ${widget.avoidWidget} curr : ${widget.currentWidgetSelectedIndex}");
              //if (k != widget.avoidWidget) {
              return DropdownMenuItem<String>(child: Text(widget.subWidgetsNames[k]), value: k);
              // }
            }).toList()),
      )),
    );
  }
}
