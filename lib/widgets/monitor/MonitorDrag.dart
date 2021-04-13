/// dart imports
import 'dart:io' show Platform;
import 'dart:math';

/// package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive/hive.dart';
import 'package:nautica/models/database/models.dart';

import 'package:nautica/network/StreamSubscriber.dart';
import 'package:nautica/models/BaseModel.dart';

import 'package:nautica/Configuration.dart';
import 'package:nautica/widgets/reorderable/reorderable_wrap.dart';
import 'dart:convert' as convert;

import '../DraggableCard.dart';


/// Positioning/aligning the categories as  cards
/// based on the screen width
class MonitorDrag extends StatefulWidget {
  StreamSubscriber StreamObject = null;
  String currentVessel = ""; //vessels.urn:mrn:imo:mmsi:503999999
  int once = 0;

  MonitorDrag(
      {Key key, @required this.StreamObject, @required this.currentVessel})
      : super(key: key) {}

  @override
  _MonitorDragState createState() => _MonitorDragState();
}

class _MonitorDragState extends State<MonitorDrag> {
  BaseModel model = BaseModel.instance;
  double _cardWidth;
  StreamSubscriber mainStreamHandle;
  String vessel;
  int currentGridIndex;
  bool isMainGridReady = false;
  bool haveErrorLoadingGrid = false;
  GridThemeRecord currentJSONGridTheme;
  GridThemeRecord temporaryJSONGridTheme;
  List<Widget> mainWidgetList = [];
  List<int> widgetPositions = [];
  dynamic mainLoadedWidgetList;

  @override
  void dispose() {
    super.dispose();
  }

  void initState() {
    super.initState();
    vessel = widget.currentVessel;
    //});


    getMainGrid();
  }

  Stream<dynamic> _subscribeToStream(String path) {
    return widget.StreamObject.getVesselStream(
            vessel,
            path,
            Duration(
                microseconds: NAUTICA['configuration']['widget']
                    ['refreshRate']))
        .asBroadcastStream();
  }




  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width / 4;

    return Scaffold(

      floatingActionButton: buildSpeedDial(),
     //floatingActionButton: FloatingActionButton.extended(
     //  onPressed: () {
     //    // Add your onPressed code here!
     //  },
     //  label: Text('Save'),

     //  icon:  Icon(Icons.save_outlined),
     //  backgroundColor: Colors.green,
     //),

      body: Stack(
        children: [
          SingleChildScrollView(
            child: FutureBuilder(builder: (context, snapshot) {
              return !isMainGridReady
                  ? (haveErrorLoadingGrid ? Text("error") : Text("loading"))
                  : (ReorderableWrap(
                      onReorder: (oldIndex, newIndex) {
                        if(oldIndex == newIndex) return;

                        setState(() {
                          print("old : " + oldIndex.toString() + " new " + newIndex.toString());
                        //  mainWidgetList.insert(
                          //    newIndex, mainWidgetList.removeAt(oldIndex));
  print(mainLoadedWidgetList.toString());

                         var oldW = mainWidgetList[oldIndex];
                         var newW=  mainWidgetList[newIndex];





  mainWidgetList[oldIndex] =
                        DraggableCard(
                            model: model,
                            widgetData: mainLoadedWidgetList[newIndex],
                            StreamObject: widget.StreamObject,
                            currentVessel: widget.currentVessel,
                            currentPosition : oldIndex,
                            currentWidgetIndex : mainLoadedWidgetList[newIndex]['current'],
                            onCardStatusChangedCallback : (currentPosition,viewId) async{
                              print("1 card changed [${currentPosition}][${viewId}]");
                               await temporaryUpdateWidgetViewStatus(currentPosition,viewId);
                              return oldIndex;
                            });

                            mainWidgetList[newIndex] =
                              DraggableCard(
                                  model: model,
                                  widgetData: mainLoadedWidgetList[oldIndex],
                                  StreamObject: widget.StreamObject,
                                  currentVessel: widget.currentVessel,
                                  currentPosition : newIndex,
                                  currentWidgetIndex : mainLoadedWidgetList[newIndex]['current'],
                                  onCardStatusChangedCallback : (currentPosition,viewId) async{
                                    print("2 card changed [${currentPosition}][${viewId}]");
                                     await temporaryUpdateWidgetViewStatus(currentPosition,viewId);
                                    return newIndex;
                                  });

                          //var tmp = widgetPositions[newIndex];
                          print("widgetPositions[${newIndex}] = ${oldIndex}");
                          print("widgetPositions[${oldIndex}] = ${newIndex}");
                         // widgetPositions[newIndex] = oldIndex;
                         // widgetPositions[oldIndex] = newIndex ;
                          _temporarySaveGridState(oldIndex,newIndex);
                          print("Grid changed ${oldIndex.toString()} to ${newIndex.toString()}");

                        });
                      },
                      children: mainWidgetList.map((singleCard) {
                        return ReorderableWrapItem(
                            key: ValueKey(singleCard), child: singleCard);
                      }).toList(),
                    ));
            }),
          ),




        ],



      ),
    );
  }




  SpeedDial buildSpeedDial() {
    return SpeedDial(
      /// both default to 16
      marginEnd: 18,
      marginBottom: 20,
      icon: Icons.settings,
      activeIcon: Icons.settings,
      buttonSize: 56.0,
      visible: true,


      /// If true user is forced to close dial manually
      /// by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.2,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 8.0,

      children: [
        SpeedDialChild(
          child: Icon(Icons.undo_outlined),
          backgroundColor: Colors.red,
          label: 'cancel changes',
          labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async{
              //save current space
              print("saving grid ${currentGridIndex}");

              return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
                var tempTheme = grid.get(currentGridIndex) ?? GridThemeRecord(id: currentGridIndex, name: "Temporary Grid", schema: currentJSONGridTheme.schema);
                GridThemeRecord updatedThemeRecord = GridThemeRecord(id: 2, name: "Temporary Grid", schema: currentJSONGridTheme.schema);
                await grid.put(updatedThemeRecord.id, updatedThemeRecord).then((value) async{
                  print("CURRENT GRID UPDATED (2)  -  (${currentJSONGridTheme.name})   (${currentJSONGridTheme.schema})  ");
                  //reload?
                  return await grid.close().then((value) async{
                    await getMainGrid();
                  });

                });
              });

            }
        ),
        SpeedDialChild(
          child: Icon(Icons.save_outlined),
          foregroundColor: Colors.white,
          backgroundColor: model.paletteColor,
          label: 'save current configuration',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () async{
            //save current space
            print("saving grid ${currentGridIndex}");

            return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async {
              var tempTheme = grid.get(2) ?? GridThemeRecord(id: 2, name: currentJSONGridTheme.name, schema: currentJSONGridTheme.schema);
              GridThemeRecord updatedThemeRecord = GridThemeRecord(id: currentJSONGridTheme.id, name: currentJSONGridTheme.name, schema: tempTheme.schema);

              return await grid.put(updatedThemeRecord.id, updatedThemeRecord).then((value) async{
                print("CURRENT GRID UPDATED (${currentJSONGridTheme.id})  -  (${currentJSONGridTheme.name})   (${mainJSONGridTheme})  ");
                return await grid.close();
              });
            });

          }
        ),
        SpeedDialChild(
          child: Icon(Icons.widgets_outlined),
          foregroundColor: Colors.white,
          backgroundColor: model.paletteColor,
          label: 'add widget',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('import'),
        ),
        SpeedDialChild(
          child: Icon(Icons.import_export),

          foregroundColor: Colors.white,
          backgroundColor: model.paletteColor,
          label: 'import grid',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('import'),
        ),
        SpeedDialChild(
          child: Icon(Icons.archive_outlined),
          foregroundColor: Colors.white,
          backgroundColor: model.paletteColor,
          label: 'export grid',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('import'),
        ),
      ],
    );
  }




  Widget SimpleCard(String title, List<Widget> children) {
    return Container(
        padding: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
            color: model.cardColor,
            border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        width: _cardWidth,
        child: Column(children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 5, bottom: 2),
            child: Text(
              title,
              style: TextStyle(
                  color: model.paletteColor,
                  fontSize: 16,
                  fontFamily: 'Roboto-Bold'),
            ),
          ),
          Divider(
            color: model.themeData != null &&
                    model.themeData.brightness == Brightness.dark
                ? const Color.fromRGBO(61, 61, 61, 1)
                : const Color.fromRGBO(238, 238, 238, 1),
            thickness: 1,
          ),
          Padding(padding: EdgeInsets.only(bottom: 0, top: 0)),
          Column(children: children)
        ]));
  }


  Future<void> setMainGrid() async{
    return await Hive.openBox("settings").then((settings) async{
      currentGridIndex = settings.get("current_grid_index") ?? 1;

      return await settings.close().then((e) async{
        //get grid json
        return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async{
          currentJSONGridTheme = grid.get(currentGridIndex) ?? GridThemeRecord(id: 1, name: "Nautica", schema: mainJSONGridTheme);
          temporaryJSONGridTheme = grid.get(2) ?? GridThemeRecord(id: 2, name: "Temporary Grid", schema: mainJSONGridTheme); // load temporary grid

          return await grid.close();
        });
        });
        });
      //  signalKUser = prefs.getString('signalKUser') ?? "";
      //  signalKPassword = prefs.getString('signalKPassword') ?? "";
      //  widgetRefreshRate = prefs.getInt('widgetRefreshRate') ?? 350;
      //  mapRefreshRate = prefs.getInt('mapRefreshRate') ?? 2;

  }


  Future<void> _temporarySaveGridState(oldIndex,newIndex) async{

    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async{
      var tempGrid = await grid.get(2) ?? GridThemeRecord(id: 2, name: "Temporary Grid", schema: mainJSONGridTheme);
      oldIndex;
      newIndex;
      try{
        var jsonTheme = convert.jsonDecode(tempGrid.schema);

        print("change [${oldIndex}][] to [${newIndex}][]");
     if(jsonTheme != null){
      print("old : " + oldIndex.toString() + " new : "+ newIndex.toString());
       if(jsonTheme['widgets'][oldIndex] != null &&
           jsonTheme['widgets'][newIndex] != null ){

         var tmp = jsonTheme['widgets'][oldIndex];
         jsonTheme['widgets'][oldIndex] = jsonTheme['widgets'][newIndex];
         jsonTheme['widgets'][newIndex] = tmp;

         GridThemeRecord newTemporaryThemeRecord = GridThemeRecord(id: 2, name: "Temporary Grid", schema: convert.jsonEncode(jsonTheme));
         await grid.put(newTemporaryThemeRecord.id, newTemporaryThemeRecord).then((value) {
           print("temporary grid UPDATED");
         });

         setState(() {
           mainLoadedWidgetList = jsonTheme['widgets'];
         });

       }


     }

      }catch(e){
        print("[temporaryUpdateWidgetViewStatus] " +e.toString());
        return Future.error(e.toString());
      }

      setState(() {
        isMainGridReady = true;
        haveErrorLoadingGrid = false;
      });





      return await grid.close().then((value) async{
        //return await getMainGrid();
      });
    });

  }

  void _persistentSaveGridState(currentGridIndex,oldIndex,newIndex){

  }





  Future<void> temporaryUpdateWidgetViewStatus (int cardId, int viewId) async{
    //update temporary
  //if(viewId == currentWidgetViewIndex) return;
   //

    return await Hive.openBox<GridThemeRecord>("grid_schema").then((grid) async{
      var tempGrid = await grid.get(2) ?? GridThemeRecord(id: 2, name: "Temporary Grid", schema: mainJSONGridTheme);
   try{
     var jsonTheme = convert.jsonDecode(tempGrid.schema);
      //currentGridIndex -> 1..n+1
     //viewId -> 1...n
     if(jsonTheme != null){
       print(jsonTheme['widgets'][cardId]['elements'].toString());




         if(jsonTheme['widgets'][cardId] != null &&
             jsonTheme['widgets'][cardId]['elements'][viewId] != null){


           jsonTheme['widgets'][cardId]['current'] = viewId;

           GridThemeRecord newTemporaryThemeRecord = GridThemeRecord(id: 2, name: "Temporary Grid", schema: convert.jsonEncode(jsonTheme));

           await grid.put(newTemporaryThemeRecord.id, newTemporaryThemeRecord).then((value) {
             print("temporary grid UPDATED");
           });


           //encode and save

            setState(() {
              mainLoadedWidgetList = jsonTheme['widgets'];
              mainWidgetList[cardId] =
                  DraggableCard(
                      model: model,
                      widgetData: mainLoadedWidgetList[cardId],
                      StreamObject: widget.StreamObject,
                      currentVessel: widget.currentVessel,
                      currentPosition : cardId,
                      currentWidgetIndex : viewId,
                      onCardStatusChangedCallback : (currentPosition,viewId) async{
                        print("3 card changed [${currentPosition}][${viewId}]");
                        await temporaryUpdateWidgetViewStatus(currentPosition,viewId);
                      });


            });



         }







     }

   }catch(e){
     print("[temporaryUpdateWidgetViewStatus] " +e.toString());
     return Future.error(e.toString());
   }



     // await grid.put(themeRecord.id, themeRecord).then((value) {
     //   print("Default grid inserted in db");
     // });

      return await grid.close().then((value) async{
       // return await getMainGrid();
      });
    });



      print("wannasave widget shift" + currentGridIndex.toString() + " to " + viewId.toString());
    setState(() {
    });



  }

  void getMainGrid() async {
    setState(() {
      isMainGridReady = false;
      haveErrorLoadingGrid = false;
      mainWidgetList.clear();
      widgetPositions.clear();
    });

    await setMainGrid().then((value) async{

    try {
      dynamic mainGridTheme = convert.jsonDecode(temporaryJSONGridTheme.schema);

      try {
       //print("gegrid");
       //print(mainGridTheme.toString());
        int i = 0;
        mainLoadedWidgetList = mainGridTheme['widgets'];
        for (dynamic widgets in mainLoadedWidgetList)  {
          //0..n widgets
          try{
            widgetPositions.add(i);
            print(widgetPositions[i]);

          }catch(e){
            print("xx" + e.toString());
          }
          print("add");
          mainWidgetList.add(DraggableCard(
                  model: model,
                  widgetData: widgets,
                  StreamObject: widget.StreamObject,
                  currentVessel: widget.currentVessel,
                  currentPosition : i,
                  currentWidgetIndex : widgets['current'],

              onCardStatusChangedCallback : (currentPosition,viewId) async{
                    print("0 card changed [${currentPosition}][${viewId}]");
                    await temporaryUpdateWidgetViewStatus(currentPosition,viewId);
                    return i;
                  }));
          i++;

        }



      //   mainWidgetList.add(FutureBuilder(
      //       future : Future.value(widgetPositions[i]),
      //       builder: (context, snapshot) {
      //         print("future " + snapshot.data.toString());
      //         return (!snapshot.hasData) ? Text("") : DraggableCard(
      //             model: model,
      //             widgetData: widgets,
      //             StreamObject: widget.StreamObject,
      //             currentVessel: widget.currentVessel,
      //             currentPosition :  snapshot.data,
      //             onCardStatusChangedCallback : (currentPosition,viewId) async{
      //               print("HEYYY");
      //               await temporaryUpdateWidgetViewStatus(currentPosition,viewId);
      //               return widgetPositions[currentPosition];
      //             });
      //       }
      //   ));
      //  }

        setState(() {
          isMainGridReady = true;
        });
        //insert into ---> mainWidgetList

      } catch (e) {
        print("err : " + e.toString());
      }
    } catch (e) {
      print("unable to decode json " + e.toString());
    }
    });

  }

/*
  BaseModel model = BaseModel.instance;
  double _cardWidth;
  StreamSubscriber mainStreamHandle;
  String vessel;

  void initState(){
    print("MONITOR CURRENT VESSEL " + widget.currentVessel);
    super.initState();
    vessel = widget.currentVessel;
    //});
  }

  _MonitorGridState(){

  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _getMonitorGrid());
  }

  Stream<dynamic> _subscribeToStream(String path){
    return widget.StreamObject.getVesselStream(vessel,path,Duration(microseconds: NAUTICA['configuration']['widget']['refreshRate'])).asBroadcastStream();
  }



  Widget _getMonitorGrid() {
    final double deviceWidth = MediaQuery.of(context).size.width;

    double padding;
    double _sidePadding = deviceWidth > 1060
        ? deviceWidth * 0.038
        : deviceWidth >= 768
        ? deviceWidth * 0.041
        : deviceWidth * 0.05;

    Widget organizedCardWidget;


    padding = deviceWidth * 0.011;// 0.018;
    _cardWidth = (deviceWidth * 0.9) / 4;//(deviceWidth * 0.9) / 2;
    _sidePadding = (deviceWidth * 0.1) / 8;

    organizedCardWidget = Row(children: [

      Text("ciao")],);


    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.only(top: deviceWidth > 1060 ? 15 : 10),
            child: organizedCardWidget));
  }

  Widget SimpleCard(String title, List<Widget> children) {


    return Container(
        padding: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
            color: model.cardColor,
            border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        width: _cardWidth,
        child: Column(children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 5, bottom: 2),
            child: Text(
              title,
              style: TextStyle(
                  color: model.paletteColor,
                  fontSize: 16,
                  fontFamily: 'Roboto-Bold'),
            ),
          ),
          Divider(
            color: model.themeData!= null && model.themeData.brightness == Brightness.dark
                ? const Color.fromRGBO(61, 61, 61, 1)
                : const Color.fromRGBO(238, 238, 238, 1),
            thickness: 1,
          ),
          Padding(padding: EdgeInsets.only(bottom: 0, top:0)),

          Column(children: children)
        ]));
  }

*/
}
