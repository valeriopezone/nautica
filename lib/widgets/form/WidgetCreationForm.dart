import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nautica/models/BaseModel.dart';

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
  final Future<bool> Function(int widgetPositionId, dynamic newWidgetData)
      onGoingToSaveWidgetCallback;


  WidgetCreationForm(
      {Key key,
      @required this.model,
      @required this.monitorContext,
        @required this.vesselsDataTable,
         this.currentPositionId,
      @required this.mainLoadedWidgetList,
      @required this.onGoingToSaveWidgetCallback})
      : super(key: key) {}

  @override
  _WidgetCreationFormState createState() {
    return _WidgetCreationFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class _WidgetCreationFormState extends State<WidgetCreationForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  bool isLoadingForSaving = false;

  bool formLoaded = false;
  List<String> allSubscriptionsList = [];
  List<String> selectedSubWidgets = [];
  Map<String, String> subWidgetsNames = new Map();

  //controllers
  String selectedWidget;
  Map<String, String> selectedSubscriptions = new Map();
  List<SubWidgetSelectionTile> subWidgets = [];

  TextEditingController widgetNameController = TextEditingController();

  String widgetToAvoid = "";
  /*
  name
  type{

  }



   */

  @override
  void initState() {
    super.initState();


    //preload all static data for widget form
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
        subWidgetsNames[i.toString() + "_" + j.toString()] =
            current['widgetTitle'] + " - " + current['widgetClass'];
        j++;
      }

      i++;
    }


    //check if is new or editing mode

    if(widget.currentPositionId != null && widget.currentPositionId != -1){
      //get widget data and init this vars :
      //selectedWidget
      //selectedSubscriptions
      //subWidgets
      //widgetNameController
      dynamic mainList = widget.mainLoadedWidgetList[widget.currentPositionId];
      int currentToEdit = mainList['current'];

      dynamic editingW = mainList['elements'][currentToEdit];//currently editing

      //print("EDITING : " + editingW.toString());

      widgetNameController.text = editingW['widgetTitle'];
      selectedWidget = editingW['widgetClass'];
      print("SHOULD AVOID " + widget.currentPositionId.toString() + "_" + currentToEdit.toString());

      int j = 0,l = 0;
      widgetToAvoid = widget.currentPositionId.toString() + "_" + currentToEdit.toString();
      for(dynamic single in mainList['elements']){
       // _addNewWidgetToSubWidgetForm
        if(j != currentToEdit){
          print("subw : " + single.toString());
          print("call $j  --->  ${widget.currentPositionId}_$j");
          _addNewWidgetToSubWidgetForm(l, widget.currentPositionId.toString() + "_" + j.toString(), widgetToAvoid);
          l++;
        }
        j++;
      }

      //load in subWidgets and
    }


    setState(() {
      formLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.

    double screenWidth = MediaQuery.of(widget.monitorContext).size.width;
    double screenHeight = MediaQuery.of(widget.monitorContext).size.height;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

    final List<int> _items = List<int>.generate(50, (int index) => index);

    return !formLoaded
        ? CupertinoActivityIndicator()
        : FutureBuilder(builder: (context, snapshot) {
            return Center(
              child: Material(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
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
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 13.0,
                                                          top: 5,
                                                          right: 8,
                                                          bottom: 3),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(' Informations',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Roboto-Medium')),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                      controller:
                                                          widgetNameController,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please enter some text';
                                                        }
                                                        return null;
                                                      },
                                                      cursorColor: Colors.red,
                                                      style: TextStyle(
                                                          height: 0.85,
                                                          fontSize: 14.0,
                                                          color: Colors.red),
                                                      textAlignVertical:
                                                          TextAlignVertical(
                                                              y: 0.6),
                                                      autofocus: false,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  'Widget name',
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              hintStyle:
                                                                  TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          4.0),
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .red,
                                                                      width:
                                                                          1.0,
                                                                      style: BorderStyle
                                                                          .solid)),
                                                              focusedBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          4.0),
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .red,
                                                                      width:
                                                                          1.0,
                                                                      style: BorderStyle
                                                                          .solid)),
                                                              hintText: "Define a name for this widget")),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: DropdownButtonFormField<
                                                          String>(
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please enter some text';
                                                        }
                                                        return null;
                                                      },
                                                      isExpanded: true,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  'Widget type',
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              hintStyle:
                                                                  TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          4.0),
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .red,
                                                                      width:
                                                                          1.0,
                                                                      style: BorderStyle
                                                                          .solid)),
                                                              focusedBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          4.0),
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .red,
                                                                      width:
                                                                          1.0,
                                                                      style: BorderStyle
                                                                          .solid)),
                                                              hintText:
                                                                  "Select a type"),
                                                      value: selectedWidget,
                                                      icon: const Icon(Icons.arrow_downward),
                                                      iconSize: 24,
                                                      style: TextStyle(height: 0.85, fontSize: 14.0, color: Colors.red),
                                                      onChanged: (String _selectedWidget) {
                                                        print(
                                                            "you chose widget type : " +
                                                                _selectedWidget
                                                                    .toString());
                                                        setState(() {
                                                          selectedWidget =
                                                              _selectedWidget;
                                                        });
                                                      },
                                                      dropdownColor: Colors.white,
                                                      items: IndicatorSpecs.entries.map<DropdownMenuItem<String>>((g) {
                                                        return DropdownMenuItem<
                                                                String>(
                                                            child: Text(g.key),
                                                            value: g.key);
                                                      }).toList()),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          top: 5,
                                                          right: 8,
                                                          bottom: 3),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                          ' Stream Subscriptions',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Roboto-Medium')),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.red,
                                                            width: 1.1),
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    12.0)),
                                                        boxShadow: <
                                                            BoxShadow>[]),
                                                    child: Builder(builder:
                                                        (BuildContext context) {
                                                      print(IndicatorSpecs[
                                                              selectedWidget]
                                                          .toString());
                                                      if (selectedWidget ==
                                                              null ||
                                                          IndicatorSpecs[
                                                                  selectedWidget] ==
                                                              null) {
                                                        return Text("");
                                                      } else {
                                                        List<Widget>
                                                            subscriptionFormList =
                                                            [];
                                                        selectedSubscriptions
                                                            .clear();

                                                        for (dynamic subscription
                                                            in IndicatorSpecs[
                                                                selectedWidget]) {
                                                          selectedSubscriptions[
                                                                  subscription] =
                                                              SuggestedIndicatorStreams[
                                                                  subscription];

                                                          subscriptionFormList.add(Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: DropDownField(
                                                                  strict: false,
                                                                  itemsVisibleInDropdown: 5,

                                                                  //key:UniqueKey(),
                                                                  required: true,
                                                                  onValueChanged: (dynamic value) {
                                                                    print(
                                                                        "selected : $value");

                                                                    selectedSubscriptions[
                                                                            subscription] =
                                                                        value;
                                                                  },
                                                                  labelStyle: TextStyle(height: 0.85, fontSize: 14.0, color: Colors.red),
                                                                  value: SuggestedIndicatorStreams[subscription],
                                                                  //selectedWidget,
                                                                  hintText: 'Select a subscription for this stream',
                                                                  labelText: subscription.replaceAll("_", " "),
                                                                  items: allSubscriptionsList)));
                                                        }
                                                        return Column(
                                                          children:
                                                              subscriptionFormList,
                                                        );
                                                      }
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(' Sub-widgets',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        'Roboto-Medium')),
                                            (subWidgetsNames.length == 0 || (subWidgetsNames.length == 1 && subWidgetsNames[widgetToAvoid] != null))
                                                ? Text("")
                                                : IconButton(
                                                icon: Icon(Icons.add,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  _addNewWidgetToSubWidgetForm(
                                                      subWidgets.length, "[FIRST_ONE]",widgetToAvoid);
                                                }),
                                          ],
                                        ),
                                        (subWidgetsNames.length == 0 || (subWidgetsNames.length == 1 && subWidgetsNames[widgetToAvoid] != null))
                                            ? Container()
                                            : Container(
                                                width: screenWidth * 0.7,
                                                height: 180,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.red,
                                                        width: 1.1),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                12.0)),
                                                    boxShadow: <BoxShadow>[]),
                                                child: FutureBuilder(builder:
                                                    (context, snapshot) {
                                                  print(
                                                      "W LE : ${subWidgets.length}");
                                                  return ReorderableListView(
                                                    children: <Widget>[
                                                      for (int index = 0;
                                                          index <
                                                              subWidgets.length;
                                                          index++)
                                                        subWidgets[index],
                                                    ],
                                                    onReorder: (int oldIndex,
                                                        int newIndex) {
                                                      setState(() {
                                                        if (oldIndex <
                                                            newIndex) {
                                                          newIndex -= 1;
                                                        }

                                                        //SubWidgetSelectionTile newSubW = subWidgets.elementAt(newIndex);
                                                        SubWidgetSelectionTile
                                                            oldSubW =
                                                            subWidgets.removeAt(
                                                                oldIndex);
                                                        //oldSubW.changeCurrentPosition(newIndex);
                                                        //newSubW.changeCurrentPosition(oldIndex);
                                                        subWidgets.insert(
                                                            newIndex, oldSubW);
                                                        subWidgets
                                                            .asMap()
                                                            .forEach(
                                                                (i, element) {
                                                          //notify all tiles that position changed
                                                          subWidgets[i]
                                                              .changeCurrentPosition(
                                                                  i);
                                                        });

                                                        dynamic selW =
                                                            selectedSubWidgets
                                                                .removeAt(
                                                                    oldIndex);
                                                        selectedSubWidgets
                                                            .insert(
                                                                newIndex, selW);
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

                                      await _saveWidget().then((res){
                                        if(res){
                                          //ok
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                              content:
                                              Text('Widget correctly inserted into grid')));
                                          Navigator.pop(context);
                                        }else{
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                              content:
                                              Text('Error! Unable to save widget')));
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
                                  child: isLoadingForSaving
                                      ? CupertinoActivityIndicator()
                                      : Text('Save'),
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

  Future<bool> _saveWidget() async {

    //disable input, buttons, ...
    setState(() {
      isLoadingForSaving = true;
    });
    print("YOU HAVE ALL!");

    dynamic composed = {};
    composed['current'] = 0;//(widget.currentPositionId == null || widget.currentPositionId == -1) ? 0 : widget.currentPositionId;
    composed['width'] = 1;
    composed['height'] = 1;
    composed['elements'] = <dynamic>[];

    dynamic firstEl = Map();

    firstEl['widgetTitle'] = widgetNameController.text;
    firstEl['widgetClass'] = selectedWidget;
    firstEl['widgetSubscriptions'] = {};
    composed['elements'].add(firstEl);

    if (selectedSubscriptions.length > 0) {
      selectedSubscriptions.entries.forEach((sub) {
        composed['elements'][0]['widgetSubscriptions'][sub.key] = sub.value;
      });
    }

    if (widget.mainLoadedWidgetList.length > 0 &&
        selectedSubWidgets.length > 0) {
      print("WIDGET LIST : ${widget.mainLoadedWidgetList.length}");

      int i = 1;
      selectedSubWidgets.forEach((element) {
        //split N_N -> widgetPosition_subWidgetPosition
        var wKeys = element.split("_");
        int widgetPosition = int.parse(wKeys[0]);
        int subWidgetPosition = int.parse(wKeys[1]);
        //print("widgetPosition = $widgetPosition subWidgetPosition $subWidgetPosition");
        composed['elements'].add(widget.mainLoadedWidgetList[widgetPosition]
            ['elements'][subWidgetPosition]);
        i++;
      });
    }

    //notify MonitorDrag for saving

    print("COMPOSING");
    print(composed.toString());

    bool res = await widget.onGoingToSaveWidgetCallback(
        widget.currentPositionId, composed);

    print("i'm child and i got $res from monitor");


if(res == false){
  //enable inputs again
  setState(() {
    isLoadingForSaving = false;
  });
}



    return Future.value(res);
  }

  void _addNewWidgetToSubWidgetForm(
      int currentPositionIndex, String currentSelectedWidget, String avoidWidgetInList) {


    var cleanedWidgetList = subWidgetsNames;
  if(avoidWidgetInList != "") {
    print(subWidgetsNames.toString());
    print("REM $avoidWidgetInList with sel $currentSelectedWidget");
    cleanedWidgetList.remove(avoidWidgetInList);
    print(cleanedWidgetList.toString());
  }

  if(currentSelectedWidget == "[FIRST_ONE]"){
    currentSelectedWidget = cleanedWidgetList.keys.first;
  }

  selectedSubWidgets.add(currentSelectedWidget);


    setState(() {
      subWidgets.add(SubWidgetSelectionTile(
        //key: Key("list_tile_" + currentPositionIndex.toString()),
        key: UniqueKey(),
        //Key("list_tile_" + currentPositionIndex.toString()),
        model: widget.model,
        currentPositionIndex: currentPositionIndex,
        avoidWidget: avoidWidgetInList,
        currentWidgetSelectedIndex: currentSelectedWidget,
        subWidgetsNames: cleanedWidgetList,///subWidgetsNames.remove(avoidWidgetInList),
        onGoingToEditCallback: (currentPositionIndex, currentSelectedWidget) {
          //update values
          print(
              "notified edit by child -> $currentPositionIndex | $currentSelectedWidget");
          selectedSubWidgets[currentPositionIndex] = currentSelectedWidget;
        },
        onGoingToDeleteCallback: (currentPositionIndex) {
          print("notified delete by child -> $currentPositionIndex");

          //subWidgets.clear();
          //selectedSubWidgets.clear();

          subWidgets.removeAt(currentPositionIndex);
          selectedSubWidgets.removeAt(currentPositionIndex);

          //notify other tiles about their id

          if (subWidgets.length > 0) {
            subWidgets.asMap().forEach((i, element) {
              //print(subWidgets[i].toString());
              subWidgets[i].changeCurrentPosition(i);
            });
          }

          setState(() {});
        },
      ));

      // subWidgets.add(ListTile(
      //   leading: Icon(Icons.widgets),
      //   key: Key("list_tile_" + currentPosition.toString()),
      //  // tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
      //   title: Container(child: Padding(
      //     padding: const EdgeInsets.only(right : 25.0),
      //     child: DropdownButtonFormField<String>(
      //         validator: (value) {
      //           if (value == null || value.isEmpty) {
      //             return 'Please enter some text';
      //           }
      //           return null;
      //         },
      //         isExpanded: true,
      //         decoration: InputDecoration(
      //           //labelText: 'Widget type',
      //             filled: true,
      //             fillColor: Colors.white,
      //             hintStyle: TextStyle(
      //               color: Colors.red,
      //             ),
      //             enabledBorder: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(4.0),
      //                 borderSide: BorderSide(
      //                     color: Colors.red, width: 1.0, style: BorderStyle.solid)),
      //             focusedBorder: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(4.0),
      //                 borderSide: BorderSide(
      //                     color: Colors.red, width: 1.0, style: BorderStyle.solid)),
      //             hintText: "Select a type"),
      //         value: "0_0",
      //         icon: const Icon(Icons.arrow_downward),
      //         iconSize: 24,
      //         style: TextStyle(height: 0.85, fontSize: 14.0, color: Colors.red),
//
      //             onChanged: (String _selectedWidget)  {
      //           print("you chose widget type : " + _selectedWidget.toString());
//
      //           selectedSubWidgets.add("0_0");
//
//
//
//
      //         },
      //         dropdownColor: Colors.white,
      //         items: subWidgetsNames.keys.map<DropdownMenuItem<String>>((String k){
      //           return  DropdownMenuItem<String>(
      //               child: Text(subWidgetsNames[k]),
      //               value: k
      //           );
      //         }).toList()
//
      //     ),
      //   )),
      // ));
    });
  }
}
