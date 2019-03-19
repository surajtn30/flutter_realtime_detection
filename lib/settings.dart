import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Create a Form Widget
class SettingsForm extends StatefulWidget {

  SettingsForm();

  @override
  _SettingsFormState createState() => new _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  double _objectDetectionThreshold = 0.0;
  double _classificationThreshold = 0.0;

  getDoublePreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _objectDetectionThreshold = (prefs.getDouble('objectDetectionThreshold') ?? 0.6);
      _classificationThreshold = (prefs.getDouble('classificationThreshold') ?? 0.6);
    });
  }

  @override
  Widget build(BuildContext context){
    getDoublePreference();
    return ListView(
      children:[
        Card(
          child: Column(
            children:[
              ListTile(
                leading: Icon(Icons.account_box),
                title: Text('Object Detection Threshold'),
                subtitle: Text('Confidence threshold for object detection'),
              ),
                ButtonTheme.bar(
                 // make buttons use the appropriate styles for cards
                 child: ButtonBar(
                 children: <Widget>[
                  Slider(
                      min: 0.0,
                      max: 1.0,
                      onChanged: (newRating) async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        setState(() => _objectDetectionThreshold = newRating);
                        await prefs.setDouble('objectDetectionThreshold', _objectDetectionThreshold);
                      },
                      value: _objectDetectionThreshold),
                      Text((_objectDetectionThreshold*100).toStringAsPrecision(2)+"%"),
            ]
          )
          )]
          )
        ),
        Card(
            child: Column(
                children:[
                  ListTile(
                    leading: Icon(Icons.supervisor_account),
                    title: Text('Classification Threshold'),
                    subtitle: Text('Confidence threshold for classification'),
                  ),
                  ButtonTheme.bar(
                    // make buttons use the appropriate styles for cards
                      child: ButtonBar(
                          children: <Widget>[
                             Slider(
                               min: 0.0,
                               max: 1.0,
                               onChanged: (newRating) async{
                                 SharedPreferences prefs = await SharedPreferences.getInstance();
                                 setState(() => _classificationThreshold = newRating);
                                 await prefs.setDouble('classificationThreshold', _classificationThreshold);
                               },
                               value: _classificationThreshold),
                             Text((_classificationThreshold*100).toStringAsPrecision(2)+"%")
                          ]
                      )
                  )
                ]
            )
        ),
      ]
    );
  }
}