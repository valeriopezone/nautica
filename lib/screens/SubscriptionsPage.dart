import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SubscriptionsPage extends StatelessWidget {
  /// creates the home page layout
  const SubscriptionsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("subscriptions"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first screen when tapped.
            Navigator.pushNamed(context, '/dashboard');

          },
          child: Text('Load dashboard'),
        ),
      ),
    );
  }
}
