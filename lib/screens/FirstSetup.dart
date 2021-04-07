import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstSetup extends StatefulWidget {
  /// creates the home page layout
  const FirstSetup();

  @override
  _FirstSetupState createState() => _FirstSetupState();
}

class _FirstSetupState extends State<FirstSetup> {

  void initState() {

      super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("nautica - setup"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first screen when tapped.
            Navigator.pushNamed(context, '/dashboard');

          },
          child: Text('Register data and go to dashboard'),
        ),
      ),
    );
  }



}



