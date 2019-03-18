import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Create a Form Widget
class SettingsForm extends StatefulWidget {

  SettingsForm();

  @override
  _SettingsFormState createState() => new _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  double _objectDetectionThreshold = 0.6;
  double _classificationThreshold = 0.6;

  getObjectDetectionThreshold() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _objectDetectionThreshold = (prefs.getDouble('objectDetectionThreshold') ?? 0.6);
    _classificationThreshold = (prefs.getDouble('classificationThreshold') ?? 0.6);
  }

  @override
  Widget build(BuildContext context) {
    getObjectDetectionThreshold();
    return Column(
      children:[
        Row(
          children:[
            Text("Object Detection Threshold:"),
            Text("$_objectDetectionThreshold"),
          ]
        ),
        Row(
            children:[
              Text("Classfication Threshold:"),
              Text("$_classificationThreshold"),
            ]
        )
      ]
    );
  }
}