import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;

import 'objectdetection.dart';
import 'classification.dart';
import 'bndbox.dart';



class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _objectDetectionRecognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }


  setObjectDetections(recognitions, imageHeight, imageWidth) {
    setState(() {
      _objectDetectionRecognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> navBarChildren(screen, selectedIndex) {
    switch (selectedIndex) {
      case 0: return [
        ObjectDetection(
            widget.cameras,
            setObjectDetections
        ),
        BndBox(
          _objectDetectionRecognitions == null
              ? []
              : _objectDetectionRecognitions,
          math.max(_imageHeight, _imageWidth),
          math.min(_imageHeight, _imageWidth),
          screen.height,
          screen.width,
        ),
      ];
      case 1: return [
        Classification(
          widget.cameras
        ),
      ];
      default: return [Container()];
  }
  }
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter TFLite Demo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: null,
          ),
        ],
      ),
      body: Stack(
        children: navBarChildren(screen, _selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.account_box), title: Text('Object Detection')),
          BottomNavigationBarItem(icon: Icon(Icons.supervisor_account), title: Text('Classification')),
          BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text('Settings')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
