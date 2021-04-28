import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nautica/models/BaseModel.dart';

class GridOptionsForm extends StatefulWidget {


  BaseModel model;
  BuildContext monitorContext;
  dynamic mainLoadedWidgetList;
  final Future<bool> Function(String loadedJSON) onGoingToSaveOptionsCallback;

  GridOptionsForm({Key key, @required this.model, @required this.monitorContext, @required this.mainLoadedWidgetList, @required this.onGoingToSaveOptionsCallback})
      : super(key: key);

  @override
  _GridOptionsFormState createState() {
    return _GridOptionsFormState();
  }
}

class _GridOptionsFormState extends State<GridOptionsForm> {
  final _formKey1 = GlobalKey<FormState>();

  bool isLoadingForSaving = false;
  bool formLoaded = false;
  TextEditingController gridTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    print("OPT -> ${widget.mainLoadedWidgetList}");
    setState(() {
      formLoaded = true;
    });
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
                  child: Column(children: [
                    Container(
                        color: widget.model.backgroundForm,
                        height: screenHeight * 0.7,
                        width: screenWidth * 0.7,
                        padding: EdgeInsets.all(8.0),
                        child: CustomScrollView(slivers: <Widget>[
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
                              title: Text('Import grid'),
                              //background: FlutterLogo(),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              child: Center(
                                child: Column(
                                  children: [
                                    Form(
                                        key: _formKey1,
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0, top: 5, right: 8, bottom: 3),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text(' Grid options',
                                                    style: TextStyle(
                                                        color: widget.model.formSectionLabelColor, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex:2,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                      controller: gridTextController,
                                                      validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return '';
                                                        }
                                                        return null;
                                                      },
                                                      cursorColor: Colors.red,
                                                      style: GoogleFonts.abel(textStyle: TextStyle(height: 0.85, fontSize: 17.0, color: widget.model.formInputTextColor)),
                                                      textAlignVertical: TextAlignVertical(y: 0.6),
                                                      autofocus: false,

                                                      decoration: InputDecoration(
                                                        //labelText: 'JSON Grid',
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
                                                          hintText: "Name")),
                                                ),
                                              ),
                                              Expanded(
                                                flex:2,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                      controller: gridTextController,
                                                      validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return '';
                                                        }
                                                        return null;
                                                      },
                                                      cursorColor: Colors.red,
                                                      style: GoogleFonts.abel(textStyle: TextStyle(height: 0.85, fontSize: 17.0, color: widget.model.formInputTextColor)),
                                                      textAlignVertical: TextAlignVertical(y: 0.6),
                                                      autofocus: false,

                                                      decoration: InputDecoration(
                                                        //labelText: 'JSON Grid',
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
                                                          hintText: "Author")),
                                                ),
                                              ),
                                            ],
                                          ),

                                          Row(
                                            children: [
                                              Expanded(
                                                flex:1,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                      controller: gridTextController,
                                                      validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return '';
                                                        }
                                                        return null;
                                                      },
                                                      cursorColor: Colors.red,
                                                      style: GoogleFonts.abel(textStyle: TextStyle(height: 0.85, fontSize: 17.0, color: widget.model.formInputTextColor)),
                                                      textAlignVertical: TextAlignVertical(y: 0.6),
                                                      autofocus: false,

                                                      decoration: InputDecoration(
                                                        //labelText: 'JSON Grid',
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
                                                          hintText: "Name")),
                                                ),
                                              )
                                            ],
                                          ),


                                          Row(
                                            children: [
                                              Expanded(
                                                flex:2,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                      controller: gridTextController,
                                                      validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return '';
                                                        }
                                                        return null;
                                                      },
                                                      cursorColor: Colors.red,
                                                      style: GoogleFonts.abel(textStyle: TextStyle(height: 0.85, fontSize: 17.0, color: widget.model.formInputTextColor)),
                                                      textAlignVertical: TextAlignVertical(y: 0.6),
                                                      autofocus: false,

                                                      decoration: InputDecoration(
                                                        //labelText: 'JSON Grid',
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
                                                          hintText: "Name")),
                                                ),
                                              ),
                                              Expanded(
                                                flex:2,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                      controller: gridTextController,
                                                      validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return '';
                                                        }
                                                        return null;
                                                      },
                                                      cursorColor: Colors.red,
                                                      style: GoogleFonts.abel(textStyle: TextStyle(height: 0.85, fontSize: 17.0, color: widget.model.formInputTextColor)),
                                                      textAlignVertical: TextAlignVertical(y: 0.6),
                                                      autofocus: false,

                                                      decoration: InputDecoration(
                                                        //labelText: 'JSON Grid',
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
                                                          hintText: "Author")),
                                                ),
                                              ),
                                            ],
                                          ),

                                          Row(
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
                                                      if (_formKey1.currentState.validate()) {

                                                        isLoadingForSaving = true;

                                                      }
                                                    },

                                                    child: isLoadingForSaving ? CupertinoActivityIndicator() : Text('Save'),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ])),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                    ),
                                   
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate([
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(" "),
                              )
                            ]),
                          )
                        ]))
                  ]))));
    });
  }
}
