import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:SKDashboard/models/BaseModel.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      tileColor: widget.model.backgroundForm,
      trailing: Icon(Icons.drag_indicator, color: widget.model.formLabelTextColor),
      leading: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () {
              widget.onGoingToDeleteCallback(widget.currentPositionIndex);
            }),
      ]),
      key: widget.key,
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
                labelText: 'Sub-Widget',
                filled: true,
                fillColor: widget.model.backgroundForm,
                hintStyle: TextStyle(
                  color: widget.model.formInputTextColor,
                ),
                labelStyle: TextStyle(
                  color: widget.model.formLabelTextColor,
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                hintText: "Select a widget"),
            dropdownColor: widget.model.backgroundForm,
            value: widget.currentWidgetSelectedIndex,
            icon: Icon(Icons.arrow_downward, color: widget.model.formLabelTextColor),
            iconSize: 24,
            style: TextStyle(height: 0.85, fontSize: 14.0, fontWeight: FontWeight.normal, color: widget.model.formLabelTextColor),
            onChanged: (String _selectedWidget) {
              widget.currentWidgetSelectedIndex = _selectedWidget;
              widget.onGoingToEditCallback(widget.currentPositionIndex, _selectedWidget);
            },
            items: widget.subWidgetsNames.keys.map<DropdownMenuItem<String>>((String k) {
              return DropdownMenuItem<String>(child: Text(widget.subWidgetsNames[k]), value: k);
            }).toList()),
      )),
    );
  }
}
