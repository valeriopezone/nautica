import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:nautica/utils/HexColor.dart';
import 'package:nautica/widgets/form/InputColorPicker.dart';

import '../../Configuration.dart';
import 'SubWidgetSelectionTile.dart';

// Define a custom Form widget.
class WidgetCreationForm extends StatefulWidget {
  //if adding widgetData and currentPositionId the form is in editing mode
  int currentPositionId = -1;
  dynamic widgetData;

  dynamic vesselsDataTable = [];
  BaseModel model;
  BuildContext monitorContext;
  dynamic mainLoadedWidgetList;
  final Future<bool> Function(int widgetPositionId, dynamic newWidgetData) onGoingToSaveWidgetCallback;

  WidgetCreationForm(
      {Key key,
      @required this.model,
      @required this.monitorContext,
      @required this.vesselsDataTable,
      this.currentPositionId,
      @required this.mainLoadedWidgetList,
      @required this.onGoingToSaveWidgetCallback})
      : super(key: key);

  @override
  _WidgetCreationFormState createState() {
    return _WidgetCreationFormState();
  }
}



class _WidgetCreationFormState extends State<WidgetCreationForm> {


  final _formKey = GlobalKey<FormState>();

  bool isLoadingForSaving = false;
  int currentToEdit = 0;
  bool formLoaded = false;
  List<String> allSubscriptionsList = [];
  List<String> selectedSubWidgets = [];
  Map<String, String> subWidgetsNames = new Map();

  //controllers
  String selectedWidget;
  Map<String, String> selectedSubscriptions = new Map();
  List<SubWidgetSelectionTile> subWidgets = [];

  TextEditingController widgetNameController = TextEditingController();

  dynamic widgetGraphicControllers = new Map();

  String widgetToAvoid = "";

  @override
  void initState() {
    super.initState();

    //preload all static data for widget form
    _preloadWidgetsList();

    //check if is new or editing mode
    _preloadFormIfEditing();

    setState(() {
      formLoaded = true;
    });
  }

  void _preloadWidgetsList() {
    selectedWidget = IndicatorSpecs.keys.first;
    List<String> subscriptions = [];

    widget.vesselsDataTable.keys.forEach((vesselId) {
      dynamic sub = widget.vesselsDataTable[vesselId].keys;
      subscriptions.addAll(sub);
    });
    allSubscriptionsList = subscriptions.toSet().toList();

//get all single elements from main loaded widget list
    int i = 0;
    for (dynamic widgets in widget.mainLoadedWidgetList) {
      int j = 0;
      for (dynamic current in widgets['elements']) {
        subWidgetsNames[i.toString() + "_" + j.toString()] = current['widgetTitle'] + " - " + current['widgetClass'];
        j++;
      }

      i++;
    }

    widgetGraphicControllers['lightTheme'] = new Map();
    widgetGraphicControllers['darkTheme'] = new Map();
  }

  void _preloadFormIfEditing() {
    if (widget.currentPositionId != null && widget.currentPositionId != -1) {
      //get widget data and init this vars :
      //selectedWidget
      //selectedSubscriptions
      //subWidgets
      //widgetNameController

      dynamic mainList = widget.mainLoadedWidgetList[widget.currentPositionId];
      currentToEdit = mainList['current'];
      dynamic editingW = mainList['elements'][currentToEdit]; //currently editing

      widgetNameController.text = editingW['widgetTitle'];
      selectedWidget = editingW['widgetClass'];


      int j = 0, l = 0;
      widgetToAvoid = widget.currentPositionId.toString() + "_" + currentToEdit.toString();
      for (dynamic single in mainList['elements']) {
        if (j != currentToEdit) {
          _addNewWidgetToSubWidgetForm(l, widget.currentPositionId.toString() + "_" + j.toString(), widgetToAvoid);
          l++;
        }
        j++;
      }
    }
  }

  Future<bool> _saveWidget() async {
    //disable input, buttons, ...
    setState(() {
      isLoadingForSaving = true;
    });


    dynamic composed = {};
    composed['current'] = 0; //(widget.currentPositionId == null || widget.currentPositionId == -1) ? 0 : widget.currentPositionId;
    composed['width'] = 1;
    composed['height'] = 1;
    composed['elements'] = <dynamic>[];

    dynamic firstEl = Map();

    firstEl['widgetTitle'] = widgetNameController.text;
    firstEl['widgetClass'] = selectedWidget;
    firstEl['widgetSubscriptions'] = {};
    firstEl['widgetOptions'] = {};
    firstEl['widgetOptions']['graphics'] = {};
    firstEl['widgetOptions']['graphics']['lightTheme'] = {};
    firstEl['widgetOptions']['graphics']['darkTheme'] = {};
    composed['elements'].add(firstEl);


    for (dynamic options in widgetGraphicControllers['lightTheme'].keys) {
      firstEl['widgetOptions']['graphics']['lightTheme'][options] = widgetGraphicControllers['lightTheme'][options].text.toString();
    }
    for (dynamic options in widgetGraphicControllers['darkTheme'].keys) {
      firstEl['widgetOptions']['graphics']['darkTheme'][options] = widgetGraphicControllers['darkTheme'][options].text.toString();
    }

    if (selectedSubscriptions.length > 0) {
      selectedSubscriptions.entries.forEach((sub) {
        composed['elements'][0]['widgetSubscriptions'][sub.key] = sub.value;
      });
    }

    if (widget.mainLoadedWidgetList.length > 0 && selectedSubWidgets.length > 0) {
      print("WIDGET LIST : ${widget.mainLoadedWidgetList.length}");

      selectedSubWidgets.forEach((element) {
        //split N_N -> widgetPosition_subWidgetPosition
        var wKeys = element.split("_");
        int widgetPosition = int.parse(wKeys[0]);
        int subWidgetPosition = int.parse(wKeys[1]);
        composed['elements'].add(widget.mainLoadedWidgetList[widgetPosition]['elements'][subWidgetPosition]);
      });
    }

    //notify MonitorDrag for saving

    print(composed.toString());

    bool res = await widget.onGoingToSaveWidgetCallback(widget.currentPositionId, composed);

    if (res == false) {
      //enable inputs again
      setState(() {
        isLoadingForSaving = false;
      });
    }

    return Future.value(res);
  }

  void _addNewWidgetToSubWidgetForm(int currentPositionIndex, String currentSelectedWidget, String avoidWidgetInList) {
    var cleanedWidgetList = subWidgetsNames;
    if (avoidWidgetInList != "") {
      cleanedWidgetList.remove(avoidWidgetInList);
    }

    if (currentSelectedWidget == "[FIRST_ONE]") {
      currentSelectedWidget = cleanedWidgetList.keys.first;
    }

    selectedSubWidgets.add(currentSelectedWidget);

    setState(() {
      subWidgets.add(SubWidgetSelectionTile(
        key: UniqueKey(),
        model: widget.model,
        currentPositionIndex: currentPositionIndex,
        avoidWidget: avoidWidgetInList,
        currentWidgetSelectedIndex: currentSelectedWidget,
        subWidgetsNames: cleanedWidgetList,
        onGoingToEditCallback: (currentPositionIndex, currentSelectedWidget) {
          selectedSubWidgets[currentPositionIndex] = currentSelectedWidget;
        },
        onGoingToDeleteCallback: (currentPositionIndex) {
          subWidgets.removeAt(currentPositionIndex);
          selectedSubWidgets.removeAt(currentPositionIndex);

          //notify other tiles about their id
          if (subWidgets.length > 0) {
            subWidgets.asMap().forEach((i, element) {
              subWidgets[i].changeCurrentPosition(i);
            });
          }

          setState(() {});
        },
      ));
    });
  }

  Widget _displayColorPicker(TextEditingController controller) {
    Color currentColor = (controller.text.isNotEmpty) ? HexColor(controller.text) : Colors.black;

    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return InputColorPicker(
                key: UniqueKey(),
                currentColor: currentColor,
                currentController: controller,
                onColorChanged: (String newColor) {
                  controller.text = newColor;
                });
          },
        );
      },
      child: Icon(Icons.color_lens_outlined),
    );
  }

  Widget _getSingleOptionField(String title, String type, dynamic defaultValue, TextEditingController controller) {
    title = (title == null) ? "" : title;

    controller.text = defaultValue.toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(title, style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
        ),
        (type == "color") ? _displayColorPicker(controller) : Container(),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: controller,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '';
              }
              return null;
            },

            inputFormatters: (type == "double")
                ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp("[.0-9]"))]
                : (type == "color")
                    ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp("[#a-fA-F0-9]"))]
                    : <TextInputFormatter>[],

            cursorColor: Colors.red,
            style: TextStyle(height: 0.85, fontSize: 14.0, color: Colors.red),
            textAlignVertical: TextAlignVertical(y: 0.6),
            autofocus: false,
            //ecoration: InputDecoration(
            //   labelText: defaultValue.toString(),
            //   filled: true,
            //   fillColor: Colors.white,

            //   enabledBorder: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(4.0),
            //       borderSide: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
            //   focusedBorder: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(4.0),
            //       borderSide: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
            //  )
          ),
        )
      ],
    );
  }

  Widget _getGraphicOptionsForm(String selectedWidgetClass, dynamic currentGraphicData) {
    if (IndicatorGraphicSpecs[selectedWidget] == null) return Text("");

    widgetGraphicControllers['lightTheme'] = new Map();
    widgetGraphicControllers['darkTheme'] = new Map();

    dynamic lightThemeList = IndicatorGraphicSpecs[selectedWidget]['lightTheme'];
    dynamic darkThemeList = IndicatorGraphicSpecs[selectedWidget]['darkTheme'];

    List<Widget> lightThemeOptions = [];
    List<Widget> darkThemeOptions = [];


    if (lightThemeList.keys.length > 0) {

      for (dynamic option in lightThemeList.keys) {

        var type = lightThemeList[option]['type'];
        var defaultValue = lightThemeList[option]['default'];
        if (currentGraphicData != null) {
          try {
            defaultValue = currentGraphicData['lightTheme'][option];
          } catch (e) {
            print("[lightTheme] unable to preload default value for option $option");
          }
        }

        widgetGraphicControllers['lightTheme'][option] = new TextEditingController();
        lightThemeOptions.add(_getSingleOptionField(option, type, defaultValue, widgetGraphicControllers['lightTheme'][option]));
      }
    }

    if (darkThemeList.keys.length > 0) {

      for (dynamic option in darkThemeList.keys) {

        var type = darkThemeList[option]['type'];
        var defaultValue = darkThemeList[option]['default'];
        if (currentGraphicData != null) {
          try {
            defaultValue = currentGraphicData['darkTheme'][option];
          } catch (e) {
            print("[darkTheme] unable to preload default value for option $option");
          }
        }
        widgetGraphicControllers['darkTheme'][option] = new TextEditingController();
        darkThemeOptions.add(_getSingleOptionField(option, type, defaultValue, widgetGraphicControllers['darkTheme'][option]));
      }
    }


    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(' Light Theme', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
            Text(' Dark Theme', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.yellow,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: lightThemeOptions,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: darkThemeOptions,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(widget.monitorContext).size.width;
    double screenHeight = MediaQuery.of(widget.monitorContext).size.height;

    return !formLoaded
        ? CupertinoActivityIndicator()
        : FutureBuilder(builder: (context, snapshot) {
            return Center(
              child: Material(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
                    //borderRadius: const BorderRadius.all(Radius.circular(12))
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: screenHeight * 0.7,
                        width: screenWidth * 0.7,
                        padding: EdgeInsets.all(8.0),
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverAppBar(
                              leading: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                              pinned: true,
                              snap: true,
                              floating: true,
                              expandedHeight: 30.0,
                              flexibleSpace: const FlexibleSpaceBar(
                                title: Text('Create new widget'),
                                //background: FlutterLogo(),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                child: Center(
                                  child: Column(
                                    children: [
                                      Form(
                                          key: _formKey,
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, top: 5, right: 8, bottom: 3),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(' Informations',
                                                      style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                  controller: widgetNameController,
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please enter some text';
                                                    }
                                                    return null;
                                                  },
                                                  cursorColor: Colors.red,
                                                  style: TextStyle(height: 0.85, fontSize: 14.0, color: Colors.red),
                                                  textAlignVertical: TextAlignVertical(y: 0.6),
                                                  autofocus: false,
                                                  decoration: InputDecoration(
                                                      labelText: 'Widget name',
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      hintStyle: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          borderSide: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          borderSide: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
                                                      hintText: "Define a name for this widget")),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: DropdownButtonFormField<String>(
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please enter some text';
                                                    }
                                                    return null;
                                                  },
                                                  isExpanded: true,
                                                  decoration: InputDecoration(
                                                      labelText: 'Widget type',
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      hintStyle: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          borderSide: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          borderSide: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
                                                      hintText: "Select a type"),
                                                  value: selectedWidget,
                                                  icon: const Icon(Icons.arrow_downward),
                                                  iconSize: 24,
                                                  style: TextStyle(height: 0.85, fontSize: 14.0, color: Colors.red),
                                                  onChanged: (String _selectedWidget) {
                                                    print("you chose widget type : " + _selectedWidget.toString());
                                                    setState(() {
                                                      selectedWidget = _selectedWidget;
                                                      widgetGraphicControllers['lightTheme'] = new Map();
                                                      widgetGraphicControllers['darkTheme'] = new Map();
                                                      //widgetGraphicControllers.add()
                                                    });
                                                  },
                                                  dropdownColor: Colors.white,
                                                  items: IndicatorSpecs.entries.map<DropdownMenuItem<String>>((g) {
                                                    return DropdownMenuItem<String>(child: Text(g.key), value: g.key);
                                                  }).toList()),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, top: 5, right: 8, bottom: 3),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(' Stream Subscriptions',
                                                      style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.red, width: 1.1),
                                                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                                    boxShadow: <BoxShadow>[]),
                                                child: Builder(builder: (BuildContext context) {
                                                  print(IndicatorSpecs[selectedWidget].toString());
                                                  if (selectedWidget == null || IndicatorSpecs[selectedWidget] == null) {
                                                    return Text("");
                                                  } else {
                                                    List<Widget> subscriptionFormList = [];
                                                    selectedSubscriptions.clear();

                                                    dynamic currentGrid = {};
                                                    if (widget.currentPositionId != null && widget.currentPositionId != -1) {
                                                      currentGrid = widget.mainLoadedWidgetList[widget.currentPositionId];
                                                    }

                                                    for (dynamic subscription in IndicatorSpecs[selectedWidget]) {
                                                      selectedSubscriptions[subscription] = SuggestedIndicatorStreams[subscription];

                                                      if (widget.currentPositionId != null && widget.currentPositionId != -1) {
                                                        try {
                                                          if (currentGrid['elements'][currentToEdit]['widgetSubscriptions'][subscription] != null) {
                                                            selectedSubscriptions[subscription] = currentGrid['elements'][currentToEdit]['widgetSubscriptions'][subscription];
                                                          }
                                                        } catch (e) {
                                                          print("Error while setting current value subscription for  ${widget.currentPositionId} view ${currentToEdit}");
                                                        }
                                                      }

                                                      subscriptionFormList.add(Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: DropdownButtonFormField<String>(
                                                              validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                  return 'Please select a subscription';
                                                                }
                                                                return null;
                                                              },
                                                              isExpanded: true,
                                                              decoration: InputDecoration(
                                                                  labelText: subscription.replaceAll("_", " "),
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  hintStyle: TextStyle(
                                                                    color: Colors.red,
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                      borderSide: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                      borderSide: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
                                                                  hintText: "Select a type"),
                                                              value: selectedSubscriptions[subscription],
                                                              icon: const Icon(Icons.arrow_downward),
                                                              iconSize: 24,
                                                              style: TextStyle(height: 0.85, fontSize: 14.0, color: Colors.red),
                                                              onChanged: (String value) {
                                                                print("selected : $value");

                                                                selectedSubscriptions[subscription] = value;
                                                              },
                                                              dropdownColor: Colors.white,
                                                              items: allSubscriptionsList.map<DropdownMenuItem<String>>((g) {
                                                                print("INSERTING -> " + g.toString());
                                                                return DropdownMenuItem<String>(child: Text(g), value : g);
                                                              }).toList())










                                                       //  DropDownField(
                                                       //      strict: false,
                                                       //      itemsVisibleInDropdown: 5,

                                                       //      //key:UniqueKey(),
                                                       //      required: true,
                                                       //      onValueChanged: (dynamic value) {
                                                       //        print("selected : $value");

                                                       //        selectedSubscriptions[subscription] = value;
                                                       //      },
                                                       //      labelStyle: TextStyle(height: 0.85, fontSize: 14.0, color: Colors.red),
                                                       //      value: SuggestedIndicatorStreams[subscription],
                                                       //      //selectedWidget,
                                                       //      hintText: 'Select a subscription for this stream',
                                                       //      labelText: subscription.replaceAll("_", " "),
                                                       //      items: allSubscriptionsList)










                                                      ));
                                                    }
                                                    return Column(
                                                      children: subscriptionFormList,
                                                    );
                                                  }
                                                }),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, top: 5, right: 8, bottom: 3),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(' Style and settings',
                                                      style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.red, width: 1.1),
                                                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                                    boxShadow: <BoxShadow>[]),
                                                child: Builder(builder: (BuildContext context) {
                                                  if (selectedWidget == null || IndicatorGraphicSpecs[selectedWidget] == null) {
                                                    return Text("This widget have no settings");
                                                  }

                                                  //preload widget options value and controllers if editing
                                                  if (widget.currentPositionId != null && widget.currentPositionId != -1) {
                                                    try {
                                                      dynamic currentGrid = widget.mainLoadedWidgetList[widget.currentPositionId];
                                                      if (currentGrid['elements'][currentToEdit]['widgetClass'] == selectedWidget) {
                                                        dynamic options = currentGrid['elements'][currentToEdit]['widgetOptions']['graphics'];
                                                        return _getGraphicOptionsForm(selectedWidget, options);
                                                      }
                                                    } catch (e) {
                                                      print("Error while loading settings (editing mode) position ${widget.currentPositionId} view ${currentToEdit}");
                                                    }
                                                  }
                                                  return _getGraphicOptionsForm(selectedWidget, null);
                                                }),
                                              ),
                                            ),
                                          ]))
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            //nested widget list
                            SliverList(
                              delegate: SliverChildListDelegate([
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(' Sub-widgets', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                                            (subWidgetsNames.length == 0 || (subWidgetsNames.length == 1 && subWidgetsNames[widgetToAvoid] != null))
                                                ? Text("")
                                                : IconButton(
                                                    icon: Icon(Icons.add, color: Colors.red),
                                                    onPressed: () {
                                                      _addNewWidgetToSubWidgetForm(subWidgets.length, "[FIRST_ONE]", widgetToAvoid);
                                                    }),
                                          ],
                                        ),
                                        (subWidgetsNames.length == 0 || (subWidgetsNames.length == 1 && subWidgetsNames[widgetToAvoid] != null))
                                            ? Container()
                                            : Container(
                                                width: screenWidth * 0.7,
                                                height: (subWidgets.length < 7) ? subWidgets.length * 70.0 : 490.0,
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.red, width: 1.1),
                                                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                                    boxShadow: <BoxShadow>[]),
                                                child: FutureBuilder(builder: (context, snapshot) {
                                                  return ReorderableListView(
                                                    children: <Widget>[
                                                      for (int index = 0; index < subWidgets.length; index++) subWidgets[index],
                                                    ],
                                                    onReorder: (int oldIndex, int newIndex) {
                                                      setState(() {
                                                        if (oldIndex < newIndex) {
                                                          newIndex -= 1;
                                                        }

                                                        SubWidgetSelectionTile oldSubW = subWidgets.removeAt(oldIndex);
                                                        subWidgets.insert(newIndex, oldSubW);
                                                        subWidgets.asMap().forEach((i, element) {
                                                          //notify all tiles that position changed
                                                          subWidgets[i].changeCurrentPosition(i);
                                                        });

                                                        dynamic selW = selectedSubWidgets.removeAt(oldIndex);
                                                        selectedSubWidgets.insert(newIndex, selW);
                                                      });
                                                    },
                                                  );
                                                }),
                                              ),
                                      ],
                                    ),
                                  ),
                                )
                              ]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white,

                          //borderRadius: const BorderRadius.all(Radius.circular(12))
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.all(5.0),
                                child: Text(""),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.all(5.0),
                                child: CupertinoButton(
                                  color: Colors.green,
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      await _saveWidget().then((res) {
                                        if (res) {
                                          //ok
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Widget correctly inserted into grid')));
                                          Navigator.pop(context);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error! Unable to save widget')));
                                        }
                                      });
                                    }
                                  },

                                  //onPressed: () async {
                                  //  // Navigate back to first screen when tapped.
                                  //
                                  //  await _saveWidget();
                                  //  return null;
                                  //},
                                  child: isLoadingForSaving ? CupertinoActivityIndicator() : Text('Save'),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
  }
}
