import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';


typedef void Callback(List<dynamic> list);


class Classification extends StatefulWidget {
  final List<CameraDescription> cameras;

  Classification(this.cameras);

  @override
  _ClassificationState createState() => new _ClassificationState();
}

class _ClassificationState extends State<Classification> {
  CameraController controller;
  bool isDetecting = false;
  bool changeCamera = false;
  int _camera = 0;
  List<dynamic> _recognitions = [];
  double _classificationThreshold = 0.6;

  loadModel() async {
    String res = await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/labels_mobilenet_quant_v1_224.txt",
    );
    print(res);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _classificationThreshold = (prefs.getDouble('classificationThreshold') ?? 0.6);
  }

  bool initCamera(camera){
    controller = new CameraController(
      widget.cameras[_camera],
      ResolutionPreset.medium,
    );


    controller.initialize().then((_) {
      if (!mounted) {
        return false;
      }


      controller.startImageStream((CameraImage img) {
        if (!isDetecting) {
          isDetecting = true;

          Tflite.runModelOnFrame(
            bytesList: img.planes.map((plane) {return plane.bytes;}).toList(),// required
            imageHeight: img.height,
            imageWidth: img.width,
            imageMean: 127.5,   // defaults to 127.5
            imageStd: 127.5,    // defaults to 127.5
            rotation: 90,       // defaults to 90, Android only
            numResults: 2,      // defaults to 5
            threshold: 0.1,     // defaults to 0.1
          ).then((recognitions) {
            setState(() {
              _recognitions = recognitions;
            });

            isDetecting = false;
          });
        }
      });
    });
    return true;

  }

  @override
  void initState() {
    super.initState();
    loadModel();
    print("Inside init state");
    if (widget.cameras == null) {
      print('No camera is found');
    } else {
      if (initCamera(_camera)){
        print("Init done");
      }
      else{
        print("Camera error");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void flipCamera(){
    setState(() {
      changeCamera = true;
      _camera = _camera == 0 ? 1 :

      0;
    });
  }

  Widget showResults(recognitions){
    if (recognitions.isEmpty || (recognitions[0]["confidence"] < _classificationThreshold)){
      return Row(
          children:[
            FlatButton(
                child: Text('Keep looking...'),
                onPressed:null
            )
          ]
      );
    } else{
      return Row(
          children: [
            FlatButton(
              child: Row(
                children:[
                  Padding(
                    padding: EdgeInsets.only(right: 40.0),
                    child: Text(
                    recognitions[0]['label'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                  ),
                  Text("Confidence:" + (recognitions[0]['confidence']*100).toStringAsPrecision(2)+"%"),
              ]
              ),
              onPressed: null,
            )
          ]
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }
    if (changeCamera){
      if (!initCamera(_camera)){
        return Container();
      }
      changeCamera = false;
    }

    var currentSize = MediaQuery.of(context).size;
    var previousSize = controller.value.previewSize;
    if (currentSize != null && previousSize != null) {
      var screenH = math.max(currentSize.height, currentSize.width);
      var screenW = math.min(currentSize.height, currentSize.width);
      var previewH = math.max(previousSize.height, previousSize.width);
      var previewW = math.min(previousSize.height, previousSize.width);
      var screenRatio = screenH / screenW;
      var previewRatio = previewH / previewW;
      return Scaffold(
          body: OverflowBox(
            maxHeight:
            screenRatio > previewRatio ? screenH : screenW / previewW *
                previewH,
            maxWidth:
            screenRatio > previewRatio
                ? screenH / previewH * previewW
                : screenW,
            child:
            CameraPreview(controller),

          ),
          bottomSheet: showResults(_recognitions),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Change camera', // used by assistive technologies
            child: _camera == 0 ? Icon(Icons.camera_front) : Icon(
                Icons.camera_rear),
            onPressed: flipCamera,
          )
      );
    } else {
      return Container();
    }
  }
}
