import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signupwithotp/components/CameraPreviewWidget.dart';
import 'package:signupwithotp/videos/ExploreVideos.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    await _cameraController.initialize();
  }

  Future<void> _checkPermissionsAndOpenCamera() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted && storageStatus.isGranted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              CameraPreviewWidget(cameraController: _cameraController),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Permission Denied'),
            content: Text(
                'Please grant camera and storage permission to use this feature.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExploreVideos(),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 43, 159, 186),
          title: Text(
            'Open Camera',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: EdgeInsets.only(
                    top: 100,
                    // Right margin
                  ),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Record and Post Video",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 38,
                    ),
                  )),
              Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue,
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          CircleBorder(),
                        ),
                      ),
                      onPressed: _checkPermissionsAndOpenCamera,
                      child: Container(
                        width: 150,
                        height: 150,
                        alignment: Alignment.center,
                        child: Text(
                          'Open Camera',
                          style: TextStyle(
                            color: Color.fromARGB(255, 194, 78, 24),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
