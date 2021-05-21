import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SKDashboard/models/BaseModel.dart';
import 'package:SKDashboard/utils/json_schema/json_schema.dart';
import 'dart:convert' as convert;
import 'package:SKDashboard/Configuration.dart';

class GridImportForm extends StatefulWidget {

  BaseModel model;
  BuildContext monitorContext;
  String jsonSchema;
  final Future<bool> Function(String loadedJSON) onGoingToImportWidgetCallback;
  //final Future<bool> Function(String loadedJSON) onGoingToImportWidgetCallback;

  GridImportForm({Key key, @required this.model, @required this.monitorContext, @required this.jsonSchema, @required this.onGoingToImportWidgetCallback})
      : super(key: key);

  @override
  _GridImportFormState createState() {
    return _GridImportFormState();
  }
}

class _GridImportFormState extends State<GridImportForm> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  bool isLoadingForSaving = false;
  bool formLoaded = false;
  TextEditingController gridTextController = TextEditingController();
  TextEditingController exportTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(widget.jsonSchema != null) exportTextController.text = widget.jsonSchema;//load export json

  if(mounted) {
    setState(() {
      formLoaded = true;
    });
  }
  }

  String importFromText() {
    return gridTextController.text;
  }

  Future<String> importFromFile() async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        String fileContent = convert.utf8.decode(file.bytes);
        return fileContent != null ? fileContent : "";
      } else {
        return "";
      }
    } catch (e) {
      print("[GridImportForm] unable to load -> $e");
    }

    return "";
  }

  Future<bool> schemaValidation(String jsonInput) async {
    try {
      Map<dynamic, dynamic> schema = convert.jsonDecode(JSONSchema);
      var decodedSource = convert.jsonDecode(jsonInput);

      return await Schema.createSchema(schema).then((schema) {
        return schema.validate(decodedSource);
      });
    } catch (e) {
      print("[GridImportForm] unable to load -> $e");
    }

    return false;
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
                                    title: Text('Import/Export grid'),
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
                                                      Text(' Import from clipboard or local device storage',
                                                          style: TextStyle(
                                                              color: widget.model.formSectionLabelColor, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                      controller: gridTextController,
                                                      validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Paste here your JSON grid';
                                                        }
                                                        return null;
                                                      },
                                                      cursorColor: Colors.red,
                                                      style: GoogleFonts.abel(textStyle: TextStyle(height: 0.85, fontSize: 17.0, color: widget.model.formInputTextColor)),
                                                      textAlignVertical: TextAlignVertical(y: 0.6),
                                                      autofocus: false,
                                                      maxLines: 8,
                                                      //decoration: InputDecoration.collapsed(hintText: "Enter your text here"),

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
                                                          hintText: "Paste your JSON grid here")),
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        padding: EdgeInsets.all(5.0),
                                                        child: CupertinoButton(
                                                          child: Text("Import from file"),
                                                          color: Colors.green,
                                                          onPressed: () async {
                                                            String inputJSON = await importFromFile();
                                                            if (inputJSON.isNotEmpty) {
                                                              bool isSchemaValid = await schemaValidation(inputJSON);

                                                              if (isSchemaValid) {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    isLoadingForSaving = true;
                                                                  });
                                                                }
                                                                widget.onGoingToImportWidgetCallback(inputJSON);
                                                                Navigator.pop(context);
                                                                //  widget.onGoingToImportWidgetCallback(inputJSON).then((response) {
                                                                //    if (mounted) {
                                                                //      setState(() {
                                                                //        isLoadingForSaving = false;
                                                                //      });
                                                                //      Navigator.pop(context);
                                                                //    }
                                                                //  });
                                                              }
                                                            }
                                                          },
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
                                                              String inputJSON = importFromText();
                                                              if (inputJSON.isNotEmpty) {
                                                                bool isSchemaValid = await schemaValidation(inputJSON);

                                                                if (isSchemaValid) {
                                                                  if (mounted) {
                                                                    setState(() {
                                                                      isLoadingForSaving = true;
                                                                    });
                                                                  }
                                                                  widget.onGoingToImportWidgetCallback(inputJSON);
                                                                  Navigator.pop(context);

                                                               // widget.onGoingToImportWidgetCallback(inputJSON).then((response) {
                                                               //   if (mounted) {
                                                               //     setState(() {
                                                               //       isLoadingForSaving = false;
                                                               //     });
                                                               //     Navigator.pop(context);
                                                               //   }
                                                               // });
                                                                } else {
                                                                  //err
                                                                }
                                                              }
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
                                                )
                                              ])),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                          ),
                                          Form(
                                              key: _formKey2,
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0, top: 5, right: 8, bottom: 3),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Text(' Copy your JSON grid or export to document folder',
                                                          style: TextStyle(
                                                              color: widget.model.formSectionLabelColor, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Medium')),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                      controller: exportTextController,
                                                      cursorColor: Colors.red,
                                                      style: GoogleFonts.abel(textStyle: TextStyle(height: 0.85, fontSize: 17.0, color: widget.model.formInputTextColor)),
                                                      textAlignVertical: TextAlignVertical(y: 0.6),
                                                      autofocus: false,
                                                      maxLines: 8,
                                                      //decoration: InputDecoration.collapsed(hintText: "Enter your text here"),
                                                      readOnly: true,

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
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        padding: EdgeInsets.all(5.0),
                                                        child: CupertinoButton(
                                                          child: Text("Export"),
                                                          color: Colors.green,
                                                          onPressed: () async {
                                                            String inputJSON = await importFromFile();
                                                            if (inputJSON.isNotEmpty) {
                                                              bool isSchemaValid = await schemaValidation(inputJSON);

                                                              if (isSchemaValid) {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    isLoadingForSaving = true;
                                                                  });
                                                                }
                                                                widget.onGoingToImportWidgetCallback(inputJSON);
                                                                Navigator.pop(context);
                                                                //  widget.onGoingToImportWidgetCallback(inputJSON).then((response) {
                                                                //    if (mounted) {
                                                                //      setState(() {
                                                                //        isLoadingForSaving = false;
                                                                //      });
                                                                //      Navigator.pop(context);
                                                                //    }
                                                                //  });
                                                              }
                                                            }
                                                          },
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
                                                              String inputJSON = importFromText();
                                                              if (inputJSON.isNotEmpty) {
                                                                bool isSchemaValid = await schemaValidation(inputJSON);

                                                                if (isSchemaValid) {
                                                                  if (mounted) {
                                                                    setState(() {
                                                                      isLoadingForSaving = true;
                                                                    });
                                                                  }
                                                                  widget.onGoingToImportWidgetCallback(inputJSON);
                                                                  Navigator.pop(context);

                                                                  // widget.onGoingToImportWidgetCallback(inputJSON).then((response) {
                                                                  //   if (mounted) {
                                                                  //     setState(() {
                                                                  //       isLoadingForSaving = false;
                                                                  //     });
                                                                  //     Navigator.pop(context);
                                                                  //   }
                                                                  // });
                                                                } else {
                                                                  //err
                                                                }
                                                              }
                                                            }
                                                          },

                                                          //onPressed: () async {
                                                          //  // Navigate back to first screen when tapped.
                                                          //
                                                          //  await _saveWidget();
                                                          //  return null;
                                                          //},
                                                          child: isLoadingForSaving ? CupertinoActivityIndicator() : Text('Copy'),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ])),
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
