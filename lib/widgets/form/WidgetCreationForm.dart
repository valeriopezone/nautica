import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:nautica/utils/HexColor.dart';
import 'package:nautica/widgets/form/InputColorPicker.dart';
import 'package:basic_utils/basic_utils.dart';
import 'dart:convert' as convert;

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
  double baseHeight;
  int numCols;
  final Future<bool> Function(int widgetPositionId, dynamic newWidgetData) onGoingToSaveWidgetCallback;

  WidgetCreationForm(
      {Key key,
      @required this.model,
      @required this.baseHeight,
      @required this.numCols,
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
  int widgetWidth = 1;
  int widgetHeight = 1;
  dynamic widgetGraphicControllers = new Map();

  String widgetToAvoid = "";

  List<int> availableWidgetWidths = [1, 2, 3, 4];
  List<int> availableWidgetHeights = [1, 2, 3, 4, 5, 6];


  List<Widget> subscriptionFormList = [];

  @override
  void initState() {
    super.initState();

    //preload all static data for widget form
    _preloadWidgetsList();

    _preloadSubscriptions();

    //check if is new or editing mode
    _preloadFormIfEditing();

    if(mounted) setState(() {
      formLoaded = true;
    });
  }

  void _preloadWidgetsList() {
    if (widget.numCols > 0) {
      availableWidgetWidths = [];
      for (int i = 1; i <= widget.numCols; i++) availableWidgetWidths.add(i);
    }

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

      try {
        widgetWidth = (mainList['width'] != null && mainList['width'] is int) ? mainList['width'] : int.parse(mainList['width']);
        widgetHeight = (mainList['height'] != null && mainList['height'] is int) ? mainList['height'] : int.parse(mainList['height']);
      } catch (e) {
        print("Unable to parse width|height of object");
      }
        //preload subscriptions
      try {

        if (widget.currentPositionId != null && widget.currentPositionId != -1) {
         var currentGrid = widget.mainLoadedWidgetList[widget.currentPositionId];


        selectedSubscriptions.clear();
        subscriptionFormList.clear();
        var subscriptions = editingW['widgetSubscriptions'];
        subscriptions.entries.forEach((sub) {
          selectedSubscriptions[sub.key] = sub.value;
          selectedSubscriptions[sub.key] = currentGrid['elements'][currentToEdit]['widgetSubscriptions'][sub.key];
          subscriptionFormList.add(Padding(
              padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 15.0),
              child: DropdownButtonFormField<String>(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a subscription';
                    }
                    return null;
                  },
                  isExpanded: true,
                  decoration: InputDecoration(
                      labelText: sub.value.replaceAll("_", " "),
                      filled: true,
                      fillColor: widget.model.backgroundForm,
                      hintStyle: TextStyle(
                        color: widget.model.formInputTextColor,
                      ),
                      labelStyle: TextStyle(
                        color: widget.model.formLabelTextColor,
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                      hintText: "Select a type"),
                  value: (selectedSubscriptions[sub.key] != null &&
                      allSubscriptionsList.indexOf(selectedSubscriptions[sub.key]) != -1)
                      ? selectedSubscriptions[sub.key]
                      : allSubscriptionsList.first,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  style: TextStyle(height: 0.85, fontSize: 14.0, color: widget.model.formInputTextColor),
                  onChanged: (String value) {
                    print("SET SUB [$sub.value] -> $value");
                    selectedSubscriptions[sub.key] = value;
                  },
                  dropdownColor: widget.model.backgroundForm,
                  items: allSubscriptionsList.map<DropdownMenuItem<String>>((g) {
                    return DropdownMenuItem<String>(child: Text(g), value: g);
                  }).toList())



          ));
        });

        print("!!!!!!HAVE -> $selectedSubscriptions");
        }

      } catch (e) {
        print("Unable to parse width|height of object");
      }

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

  void _preloadSubscriptions(){
    //TODO fix subscription saving error (move into initializer) and setstate() keyboard error
    print("CLEAN SUBS");
    selectedSubscriptions.clear();
    subscriptionFormList.clear();
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
          padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 15.0),
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
                  fillColor: widget.model.backgroundForm,
                  hintStyle: TextStyle(
                    color: widget.model.formInputTextColor,
                  ),
                  labelStyle: TextStyle(
                    color: widget.model.formLabelTextColor,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                  hintText: "Select a type"),
              value: (selectedSubscriptions[subscription] != null &&
                  allSubscriptionsList.indexOf(selectedSubscriptions[subscription]) != -1)
                  ? selectedSubscriptions[subscription]
                  : allSubscriptionsList.first,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              style: TextStyle(height: 0.85, fontSize: 14.0, color: widget.model.formInputTextColor),
              onChanged: (String value) {
                print("SET SUB [$subscription] -> $value");
                selectedSubscriptions[subscription] = value;
              },
              dropdownColor: widget.model.backgroundForm,
              items: allSubscriptionsList.map<DropdownMenuItem<String>>((g) {
                return DropdownMenuItem<String>(child: Text(g), value: g);
              }).toList())



      ));
    }
  }

  Future<bool> _saveWidget() async {
    //disable input, buttons, ...
    if(mounted) setState(() {
      isLoadingForSaving = true;
    });


    dynamic composed = {};
    composed['current'] = 0; //(widget.currentPositionId == null || widget.currentPositionId == -1) ? 0 : widget.currentPositionId;
    composed['width'] = (!availableWidgetWidths.contains(widgetWidth)) ? availableWidgetWidths.first : widgetWidth;
    composed['height'] = (!availableWidgetHeights.contains(widgetHeight)) ? availableWidgetHeights.first : widgetHeight;
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
      var type = IndicatorGraphicSpecs[selectedWidget]['lightTheme'][options]['type'] ?? "string";
      firstEl['widgetOptions']['graphics']['lightTheme'][options] =
          (type == "double") ? double.parse(widgetGraphicControllers['lightTheme'][options].text.toString()) : widgetGraphicControllers['lightTheme'][options].text.toString();
    }
    for (dynamic options in widgetGraphicControllers['darkTheme'].keys) {
      var type = IndicatorGraphicSpecs[selectedWidget]['lightTheme'][options]['type'] ?? "string";
      firstEl['widgetOptions']['graphics']['darkTheme'][options] =
          (type == "double") ? double.parse(widgetGraphicControllers['darkTheme'][options].text.toString()) : widgetGraphicControllers['darkTheme'][options].text.toString();
    }

    if (selectedSubscriptions.length > 0) {
      print("SELECTED SUBS : $selectedSubscriptions");
      selectedSubscriptions.entries.forEach((sub) {
        composed['elements'][0]['widgetSubscriptions'][sub.key] = sub.value;
      });
    }

    if (widget.mainLoadedWidgetList.length > 0 && selectedSubWidgets.length > 0) {
      selectedSubWidgets.forEach((element) {
        //split N_N -> widgetPosition_subWidgetPosition
        var wKeys = element.split("_");
        int widgetPosition = int.parse(wKeys[0]);
        int subWidgetPosition = int.parse(wKeys[1]);
        composed['elements'].add(widget.mainLoadedWidgetList[widgetPosition]['elements'][subWidgetPosition]);
      });
    }

    //notify MonitorDrag for saving

    bool res = await widget.onGoingToSaveWidgetCallback(widget.currentPositionId, composed);

    if (res == false) {
      //enable inputs again
      if(mounted) setState(() {
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

    if(mounted) setState(() {
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

          if(mounted) setState(() {});
        },
      ));
    });
  }


  Widget _displayColorPicker(TextEditingController controller) {
    Color currentColor = (controller.text.isNotEmpty) ? HexColor(controller.text) : Colors.black;
    //todo fix color change

    return InputColorPicker(
        key: UniqueKey(),
        currentColor: currentColor,
        currentController: controller,
        onColorChanged: (String newColor) {
          controller.text = newColor;
          currentColor = HexColor(newColor);

        });


  }


  Widget _displayColorPickerOLD(TextEditingController controller) {
    Color currentColor = (controller.text.isNotEmpty) ? HexColor(controller.text) : Colors.black;
    //todo fix color change

    return SizedBox(
      width: 35,
      child: ElevatedButton(
        style: ButtonStyle(
          //backgroundColor: MaterialStateProperty.all<Color>(currentColor),
          backgroundColor: MaterialStateProperty.all<Color>(currentColor),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
        ),

        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {


              Widget colorPicker = InputColorPicker(
                  key: UniqueKey(),
                  currentColor: currentColor,
                  currentController: controller,
                  onColorChanged: (String newColor) {
                    controller.text = newColor;
                    currentColor = HexColor(newColor);

                  });
              return colorPicker;
            },
          );
        },
        child: Text(""), //Icon(Icons.color_lens_outlined),
      ),
    );
  }

  Widget _getSingleOptionField(String title, String type, dynamic defaultValue, TextEditingController controller) {
    title = (title == null) ? "" : title;

    controller.text = defaultValue.toString();
    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                    padding: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Text(StringUtils.capitalize(StringUtils.camelCaseToUpperUnderscore(title).replaceAll("_", " "), allWords: true),
                        style: TextStyle(color: widget.model.formInputTextColor, fontSize: 11.5, fontWeight: FontWeight.normal, fontFamily: 'Roboto-Medium'))),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(left: 5.0, right: 0.0),
                  child: TextFormField(
                    controller: controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '';
                      }
                      return null;
                    },
                    decoration: (type == "color")
                        ? InputDecoration(
                            fillColor: widget.model.backgroundForm,
                            hintStyle: TextStyle(
                              color: widget.model.formLabelTextColor,
                              fontSize: 18,
                            ),
                            labelStyle: TextStyle(
                              color: widget.model.formLabelTextColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.zero, borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.zero, borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                            suffixIcon: _displayColorPicker(controller))
                        : InputDecoration(
                            filled: true,
                            fillColor: widget.model.backgroundForm,
                            hintStyle: TextStyle(
                              color: widget.model.formLabelTextColor,
                              fontSize: 18,
                            ),
                            labelStyle: TextStyle(
                              color: widget.model.formLabelTextColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.zero, borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.zero, borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid))),
                    inputFormatters: (type == "double")
                        ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))]
                        : (type == "color")
                            ? <TextInputFormatter>[LengthLimitingTextInputFormatter(9), FilteringTextInputFormatter.allow(RegExp("[#a-fA-F0-9]"))]
                            : <TextInputFormatter>[],
                    keyboardType: (type == "double") ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                    cursorColor: Colors.red,
                    style: TextStyle(height: 0.85, fontSize: 14.0, color: Colors.red),
                    textAlignVertical: TextAlignVertical(y: 0.6),
                    autofocus: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0), //left:10, right : 10, top : 0, bottom :
          child: Divider(
            height: 1,
            color: widget.model.themeData != null && widget.model.themeData.brightness == Brightness.dark
                ? const Color.fromRGBO(238, 238, 238, 1)
                : const Color.fromRGBO(61, 61, 61, 1),
            thickness: 0.8,
          ),
        ),
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            lightThemeOptions.length <= 0
                ? Text("")
                : Expanded(
                    child:
                        Text(' Light Theme', style: TextStyle(color: widget.model.formSectionLabelColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium'))),
            darkThemeOptions.length <= 0
                ? Text("")
                : Expanded(
                    child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(' Dark Theme', style: TextStyle(color: widget.model.formSectionLabelColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                  )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            lightThemeOptions.length <= 0
                ? Text("")
                : Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: widget.model.formLabelTextColor, width: 1),
                          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                          boxShadow: <BoxShadow>[]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: lightThemeOptions,
                      ),
                    ),
                  ),
            darkThemeOptions.length <= 0
                ? Text("")
                : Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: widget.model.formLabelTextColor, width: 1),
                          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                          boxShadow: <BoxShadow>[]),
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
        : GestureDetector(onTap: () {
            //FocusScope.of(context).requestFocus(new FocusNode());
          }, child: FutureBuilder(builder: (context, snapshot) {
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
                        color: widget.model.backgroundForm,
                        height: screenHeight * 0.7,
                        width: screenWidth * 0.7,
                        padding: EdgeInsets.all(8.0),
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverAppBar(
                              backgroundColor: widget.model.paletteColor,
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
                                                      style: TextStyle(
                                                          color: widget.model.formSectionLabelColor, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
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
                                                  style: TextStyle(height: 0.85, fontSize: 14.0, color: widget.model.formInputTextColor),
                                                  textAlignVertical: TextAlignVertical(y: 0.6),
                                                  autofocus: false,
                                                  decoration: InputDecoration(
                                                      labelText: 'Widget name',
                                                      filled: true,
                                                      fillColor: widget.model.backgroundForm,
                                                      hintStyle: TextStyle(
                                                        color: widget.model.formLabelTextColor,
                                                        fontSize: 18,
                                                      ),
                                                      labelStyle: TextStyle(
                                                        color: widget.model.formLabelTextColor,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
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
                                                      fillColor: widget.model.backgroundForm,
                                                      hintStyle: TextStyle(
                                                        color: widget.model.formInputTextColor,
                                                      ),
                                                      labelStyle: TextStyle(
                                                        color: widget.model.formLabelTextColor,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                                                      hintText: "Select a type"),
                                                  value: selectedWidget,
                                                  icon: const Icon(Icons.arrow_downward),
                                                  iconSize: 24,
                                                  style: TextStyle(height: 0.85, fontSize: 14.0, color: widget.model.formInputTextColor),
                                                  onChanged: (String _selectedWidget) {
                                                    if(mounted) setState(() {
                                                      selectedWidget = _selectedWidget;
                                                      widgetGraphicControllers['lightTheme'] = new Map();
                                                      widgetGraphicControllers['darkTheme'] = new Map();
                                                    });
                                                    _preloadSubscriptions();

                                                  },
                                                  dropdownColor: widget.model.backgroundForm,
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
                                                      style: TextStyle(
                                                          color: widget.model.formSectionLabelColor, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                // decoration: BoxDecoration(
                                                //     border: Border.all(color: Colors.red, width: 1.1),
                                                //     borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                                //     boxShadow: <BoxShadow>[]),
                                                child: Builder(builder: (BuildContext context) {
                                                  if (selectedWidget == null || IndicatorSpecs[selectedWidget] == null) {
                                                    return Text("");
                                                  } else {



                                                    /*
                                                    //TODO fix subscription saving error (move into initializer) and setstate() keyboard error
                                                    List<Widget> subscriptionFormList = [];
                                                    print("CLEAN SUBS");
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
                                                          padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 15.0),
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
                                                                  fillColor: widget.model.backgroundForm,
                                                                  hintStyle: TextStyle(
                                                                    color: widget.model.formInputTextColor,
                                                                  ),
                                                                  labelStyle: TextStyle(
                                                                    color: widget.model.formLabelTextColor,
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                      borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                      borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                                                                  hintText: "Select a type"),
                                                              value: (selectedSubscriptions[subscription] != null &&
                                                                      allSubscriptionsList.indexOf(selectedSubscriptions[subscription]) != -1)
                                                                  ? selectedSubscriptions[subscription]
                                                                  : allSubscriptionsList.first,
                                                              icon: const Icon(Icons.arrow_downward),
                                                              iconSize: 24,
                                                              style: TextStyle(height: 0.85, fontSize: 14.0, color: widget.model.formInputTextColor),
                                                              onChanged: (String value) {
                                                                print("SET SUB [$subscription] -> $value");
                                                                selectedSubscriptions[subscription] = value;
                                                              },
                                                              dropdownColor: widget.model.backgroundForm,
                                                              items: allSubscriptionsList.map<DropdownMenuItem<String>>((g) {
                                                                return DropdownMenuItem<String>(child: Text(g), value: g);
                                                              }).toList())



                                                          ));
                                                    }
                                                     */




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
                                                      style: TextStyle(
                                                          color: widget.model.formSectionLabelColor, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, top: 5, right: 8, bottom: 3),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding: EdgeInsets.only(right: 10),
//
                                                      //color: Colors.yellow,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          DropdownButtonFormField<int>(
                                                              validator: (value) {
                                                                if (value == null || value <= 0 || value > availableWidgetWidths.last) {
                                                                  return 'Please select a valid width';
                                                                }
                                                                return null;
                                                              },
                                                              isExpanded: true,
                                                              decoration: InputDecoration(
                                                                  labelText: "Width",
                                                                  filled: true,
                                                                  fillColor: widget.model.backgroundForm,
                                                                  hintStyle: TextStyle(
                                                                    color: widget.model.formInputTextColor,
                                                                  ),
                                                                  labelStyle: TextStyle(
                                                                    color: widget.model.formLabelTextColor,
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                      borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                      borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                                                                  hintText: "Select a type"),
                                                              value: (!availableWidgetWidths.contains(widgetWidth)) ? availableWidgetWidths.first : widgetWidth,
                                                              icon: const Icon(Icons.arrow_downward),
                                                              iconSize: 24,
                                                              style: TextStyle(height: 0.85, fontSize: 14.0, color: widget.model.formLabelTextColor),
                                                              onChanged: (int value) {
                                                                widgetWidth = value;
                                                                //selectedSubscriptions[subscription] = value;
                                                              },
                                                              dropdownColor: widget.model.backgroundForm,
                                                              items: availableWidgetWidths.map<DropdownMenuItem<int>>((int g) {
                                                                return DropdownMenuItem<int>(child: Text(g.toString() + "/" + availableWidgetWidths.last.toString()), value: g);
                                                              }).toList())
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding: EdgeInsets.only(left: 10),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          DropdownButtonFormField<int>(
                                                              validator: (value) {
                                                                if (value == null || value <= 0 || value > availableWidgetHeights.last) {
                                                                  return 'Please select a valid width';
                                                                }
                                                                return null;
                                                              },
                                                              isExpanded: true,
                                                              decoration: InputDecoration(
                                                                  labelText: "Height",
                                                                  filled: true,
                                                                  fillColor: widget.model.backgroundForm,
                                                                  hintStyle: TextStyle(
                                                                    color: widget.model.formInputTextColor,
                                                                  ),
                                                                  labelStyle: TextStyle(
                                                                    color: widget.model.formLabelTextColor,
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                      borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                      borderSide: BorderSide(color: widget.model.formLabelTextColor, width: 1.0, style: BorderStyle.solid)),
                                                                  hintText: "Select a type"),
                                                              value: (!availableWidgetHeights.contains(widgetHeight)) ? availableWidgetHeights.first : widgetHeight,
                                                              icon: const Icon(Icons.arrow_downward),
                                                              iconSize: 24,
                                                              style: TextStyle(height: 0.85, fontSize: 14.0, color: widget.model.formLabelTextColor),
                                                              onChanged: (int value) {
                                                                widgetHeight = value;
                                                                //selectedSubscriptions[subscription] = value;
                                                              },
                                                              dropdownColor: widget.model.backgroundForm,
                                                              items: availableWidgetHeights.map<DropdownMenuItem<int>>((int g) {
                                                                return DropdownMenuItem<int>(child: Text(g.toString() + " Row"), value: g);
                                                              }).toList())
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                //  decoration: BoxDecoration(
                                                //      border: Border.all(color: Colors.red, width: 1.1),
                                                //      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                                //      boxShadow: <BoxShadow>[]),
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
                                            Text(' Sub-widgets',
                                                style:
                                                    TextStyle(color: widget.model.formSectionLabelColor, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                                            (subWidgetsNames.length == 0 || (subWidgetsNames.length == 1 && subWidgetsNames[widgetToAvoid] != null))
                                                ? Text("")
                                                : IconButton(
                                                    icon: Icon(Icons.add, color: widget.model.formSectionLabelColor),
                                                    onPressed: () {
                                                      _addNewWidgetToSubWidgetForm(subWidgets.length, "[FIRST_ONE]", widgetToAvoid);
                                                    }),
                                          ],
                                        ),
                                        (subWidgetsNames.length == 0 || (subWidgetsNames.length == 1 && subWidgetsNames[widgetToAvoid] != null))
                                            ? Container()
                                            : Container(
                                                width: screenWidth * 0.7,
                                                height: (subWidgets.length > 0) ? subWidgets.length * 70.0 : 0.0,
                                                //decoration: BoxDecoration(
                                                //    border: Border.all(color: Colors.red, width: 1.1),
                                                //    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                                //    boxShadow: <BoxShadow>[]),
                                                child: FutureBuilder(builder: (context, snapshot) {
                                                  return ReorderableListView(
                                                    children: <Widget>[
                                                      for (int index = 0; index < subWidgets.length; index++) subWidgets[index],
                                                    ],
                                                    onReorder: (int oldIndex, int newIndex) {
                                                      if(mounted) setState(() {
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
                            color: widget.model.backgroundForm,
                            border: Border.all(color: Colors.transparent),
                            borderRadius: const BorderRadius.all(Radius.zero),
                            boxShadow: <BoxShadow>[]),
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
                                          //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Widget correctly inserted into grid')));
                                          Navigator.pop(context);
                                        } else {
                                          //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error! Unable to save widget')));
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
          }));
  }
}
