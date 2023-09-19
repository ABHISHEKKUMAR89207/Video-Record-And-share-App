import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:location/location.dart';
import 'package:signupwithotp/components/PreviewVideo.dart';

class CameraPreviewWidget extends StatefulWidget {
  final CameraController cameraController;

  CameraPreviewWidget({required this.cameraController});

  @override
  _CameraPreviewWidgetState createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  late bool isRecording;
  late XFile? videoFile;
  Location location = Location();
  late LocationData currentLocation = LocationData.fromMap({
    'latitude': 0.0,
    'longitude': 0.0,
  });

  final List<String> supportedAspectRatios = ["9:16", "1:1", "16:9", "3:4"];

  int selectedAspectRatioIndex = 0;

  @override
  void initState() {
    super.initState();
    isRecording = false;
    _getLocation();
    _initializeCamera();
  }

  Future<void> _getLocation() async {
    try {
      var userLocation = await location.getLocation();
      setState(() {
        currentLocation = userLocation;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _initializeCamera() async {
    try {
      await widget.cameraController.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> startRecording() async {
    try {
      await widget.cameraController.startVideoRecording();
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      XFile video = await widget.cameraController.stopVideoRecording();
      setState(() {
        isRecording = false;
        videoFile = video;
      });

      if (video != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(
              videoUrl: videoFile?.path ?? '',
              latitude: currentLocation.latitude,
              longitude: currentLocation.longitude,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  void changeAspectRatio(int newIndex) {
    setState(() {
      selectedAspectRatioIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatioString = supportedAspectRatios[selectedAspectRatioIndex];
    final aspectRatio = aspectRatioString
        .split(':')
        .map((e) => double.parse(e))
        .reduce((a, b) => a / b);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 43, 159, 186),
        title: Text(
          'Camera',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          child: widget.cameraController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: aspectRatio,
                  child: CameraPreview(widget.cameraController),
                )
              : CircularProgressIndicator(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 43, 159, 186),
        items: [
          BottomNavigationBarItem(
            icon: Icon(isRecording ? Icons.stop : Icons.fiber_manual_record),
            label: isRecording ? 'Stop' : 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.aspect_ratio),
            label: 'Aspect Ratio',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            if (isRecording) {
              stopRecording();
            } else {
              startRecording();
            }
          } else if (index == 1) {
            changeAspectRatio(
              (selectedAspectRatioIndex + 1) % supportedAspectRatios.length,
            );
          }
        },
      ),
    );
  }
}
