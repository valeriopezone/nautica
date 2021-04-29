import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../Configuration.dart';

class GridOptionsForm extends StatefulWidget {
  BaseModel model;
  BuildContext monitorContext;
  final Future<bool> Function(dynamic gridData) onGoingToSaveOptionsCallback;
  final Future<bool> Function(int gridId) onGoingToDeleteGridCallback;

  int gridId;
  double baseHeight;
  int numCols;
  String currentGridName;
  String currentAuthorName;
  String currentGridDescription;

  bool isLastGrid = false;

  GridOptionsForm(
      {Key key,
      @required this.gridId,
      @required this.baseHeight,
      @required this.numCols,
      @required this.isLastGrid,
      @required this.currentGridName,
      @required this.currentAuthorName,
      @required this.currentGridDescription,
      @required this.model,
      @required this.monitorContext,
      @required this.onGoingToSaveOptionsCallback,
      @required this.onGoingToDeleteGridCallback})
      : super(key: key);

  @override
  _GridOptionsFormState createState() {
    return _GridOptionsFormState();
  }
}

class _GridOptionsFormState extends State<GridOptionsForm> {
  final _formKey1 = GlobalKey<FormState>();

  bool isLoadingForSaving = false;
  bool isLoadingForDeleting = false;
  bool formLoaded = false;
  TextEditingController titleTextController = TextEditingController();
  TextEditingController authorTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  TextEditingController numColsTextController = TextEditingController();
  TextEditingController baseHeightTextController = TextEditingController();
  int numColsSliderValue;
  double numColsDoubleSliderValue;
  double baseHeightSliderValue;

  double minBaseHeight = NAUTICA['configuration']['design']['grid']['minBaseHeight'];
  double maxBaseHeight = NAUTICA['configuration']['design']['grid']['maxBaseHeight'];
  int minNumCols = NAUTICA['configuration']['design']['grid']['minNumCols'];
  int maxNumCols = NAUTICA['configuration']['design']['grid']['maxNumCols'];

  void setupValues() {
    if(mounted) setState(() {
      numColsSliderValue = widget.numCols ?? NAUTICA['configuration']['design']['grid']['numCols'];
      numColsDoubleSliderValue = numColsSliderValue.toDouble();
      baseHeightSliderValue = widget.baseHeight ?? NAUTICA['configuration']['design']['grid']['baseHeight'];
      numColsTextController.text = numColsSliderValue.toString();
      baseHeightTextController.text = baseHeightSliderValue.toString();
      titleTextController.text = widget.currentGridName ?? NAUTICA['configuration']['design']['grid']['defaultGridName'];
      authorTextController.text = widget.currentAuthorName ?? NAUTICA['configuration']['design']['grid']['defaultGridAuthorName'];
      descriptionTextController.text = widget.currentGridDescription ?? NAUTICA['configuration']['design']['grid']['defaultGridDescription'];
    });
  }

  @override
  void initState() {
    super.initState();

    print("ID : ${widget.gridId}");
    print("baseHeight : ${widget.baseHeight}");
    print("numCols : ${widget.numCols}");
    print("currentGridName : ${widget.currentGridName}");
    print("currentAuthorName : ${widget.currentAuthorName}");
    print("currentGridDescription : ${widget.currentGridDescription}");
    setupValues();
    if(mounted) setState(() {
      formLoaded = true;
    });
  }

  Future<bool> _saveGridData() async {
    if(mounted) setState(() {
      isLoadingForSaving = true;
    });

    dynamic gridData = Map();
    gridData['name'] = titleTextController.text;
    gridData['author'] = authorTextController.text;
    gridData['description'] = descriptionTextController.text;
    gridData['numCols'] = numColsSliderValue;
    gridData['baseHeight'] = baseHeightSliderValue;

    bool res = await widget.onGoingToSaveOptionsCallback(gridData);

    if (res == false) {
      //enable inputs again
      if(mounted) setState(() {
        isLoadingForSaving = false;
        isLoadingForDeleting = false;
      });
    }

    return Future.value(res);
  }

  Future<bool> _deleteGrid() async {
    if(mounted) setState(() {
      isLoadingForDeleting = true;
    });

    bool res = await widget.onGoingToDeleteGridCallback(widget.gridId);
    if (res == false) {
      if(mounted) setState(() {
        isLoadingForDeleting = false;
      });
    }

    return Future.value(res);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(widget.monitorContext).size.width;
    double screenHeight = MediaQuery.of(widget.monitorContext).size.height;

    return !formLoaded
        ? CupertinoActivityIndicator()
        : GestureDetector(onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          }, child: FutureBuilder(builder: (context, snapshot) {
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
                                                      flex: 2,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: TextFormField(
                                                            controller: titleTextController,
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
                                                                hintText: "Title")),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: TextFormField(
                                                            controller: authorTextController,
                                                            validator: (value) {
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
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: TextFormField(
                                                            controller: descriptionTextController,
                                                            validator: (value) {
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
                                                                hintText: "Description")),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 3,
                                                            child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: SfSlider(
                                                                  interval: 1,
                                                                  showTicks: true,
                                                                  stepSize: 1,
                                                                  showDivisors: false,
                                                                  min: minNumCols.toDouble(),
                                                                  max: maxNumCols.toDouble(),
                                                                  value: numColsDoubleSliderValue,
                                                                  onChanged: (dynamic values) {
                                                                    if(mounted) setState(() {
                                                                      numColsDoubleSliderValue = values;
                                                                      numColsSliderValue = numColsDoubleSliderValue.toInt();
                                                                      numColsTextController.text = numColsSliderValue.toStringAsFixed(0);
                                                                    });
                                                                  },
                                                                  enableTooltip: true,
                                                                  //numberFormat: NumberFormat('#'),
                                                                )),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(right: 8.0),
                                                              child: TextFormField(
                                                                  controller: numColsTextController,
                                                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                                                  validator: (value) {
                                                                    if (value == null || value.isEmpty) {
                                                                      return '';
                                                                    }

                                                                    var numCols = int.parse(value);
                                                                    if (numCols < minNumCols) numCols = minNumCols;
                                                                    if (numCols > maxNumCols) numCols = maxNumCols;
                                                                    if(mounted) setState(() {
                                                                      numColsTextController.text = numCols.toString();
                                                                      numColsDoubleSliderValue = numCols.toDouble();
                                                                      numColsSliderValue = numCols;
                                                                      numColsTextController.text = numColsSliderValue.toStringAsFixed(0);
                                                                    });

                                                                    return null;
                                                                  },
                                                                  cursorColor: Colors.red,
                                                                  style:
                                                                      GoogleFonts.abel(textStyle: TextStyle(height: 0.85, fontSize: 17.0, color: widget.model.formInputTextColor)),
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
                                                                      hintText: "")),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 3,
                                                            child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: SfSlider(
                                                                  interval: 100,
                                                                  showTicks: true,
                                                                  stepSize: 1,

                                                                  showDivisors: false,
                                                                  min: minBaseHeight,
                                                                  max: maxBaseHeight,
                                                                  value: baseHeightSliderValue,
                                                                  onChanged: (dynamic values) {
                                                                    if(mounted) setState(() {
                                                                      baseHeightSliderValue = values;
                                                                      baseHeightTextController.text = values.toStringAsFixed(2);
                                                                    });
                                                                  },
                                                                  enableTooltip: true,
                                                                  //numberFormat: NumberFormat('#'),
                                                                )),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(right: 8.0),
                                                              child: TextFormField(
                                                                  controller: baseHeightTextController,
                                                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))],
                                                                  validator: (value) {
                                                                    if (value == null || value.isEmpty) {
                                                                      return '';
                                                                    }

                                                                    var height = double.parse(value);
                                                                    if (height < minBaseHeight) height = minBaseHeight;
                                                                    if (height > maxBaseHeight) height = minBaseHeight;
                                                                    if(mounted) setState(() {
                                                                      baseHeightTextController.text = height.toString();
                                                                      baseHeightSliderValue = height;
                                                                    });

                                                                    return null;
                                                                  },
                                                                  cursorColor: Colors.red,
                                                                  style:
                                                                      GoogleFonts.abel(textStyle: TextStyle(height: 0.85, fontSize: 17.0, color: widget.model.formInputTextColor)),
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
                                                                      hintText: "")),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  color: Colors.red,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding: EdgeInsets.all(5.0),
                                                          child: CupertinoButton(
                                                            color: Colors.green,
                                                            onPressed: () async {
                                                              //return data to parent monitor grid
                                                              await _deleteGrid().then((res) {
                                                                if (res) {
                                                                  Navigator.pop(context);
                                                                } else {
                                                                  //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error! Unable to save widget')));
                                                                }
                                                              });
                                                            },
                                                            child: isLoadingForDeleting ? CupertinoActivityIndicator() : Text('Delete this grid'),
                                                          ),
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
                                                                //return data to parent monitor grid
                                                                await _saveGridData().then((res) {
                                                                  if (res) {
                                                                    Navigator.pop(context);
                                                                  } else {
                                                                    //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error! Unable to save widget')));
                                                                  }
                                                                });
                                                              }
                                                            },
                                                            child: isLoadingForSaving ? CupertinoActivityIndicator() : Text('Save'),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
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
          }));
  }
}
