import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

const String ssd = "SSD MobileNet";

typedef void Callback(List<dynamic> list, int h, int w);


class ObjectDetection extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model = ssd;

  ObjectDetection(this.cameras, this.setRecognitions);

  @override
  _ObjectDetectionState createState() => new _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  CameraController controller;
  bool isDetecting = false;
  bool changeCamera = false;
  int _camera = 0;

  loadModel() async {
    String res;
    res = await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt");
    print(res);
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


          Tflite.detectObjectOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            model: "SSDMobileNet",
            imageHeight: img.height,
            imageWidth: img.width,
            imageMean: 127.5,
            imageStd: 127.5,
            numResultsPerClass: 1,
            threshold: 0.6,
          ).then((recognitions) {
            widget.setRecognitions(recognitions, img.height, img.width);
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
