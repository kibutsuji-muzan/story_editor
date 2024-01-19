import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_edit_story/pages/video_edit_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  late CameraController _cameraController;
  late AnimationController _animController;
  bool _isRearCameraSelected = true;
  bool _recorging = false;
  Timer? _timer;
  int _counter = 0;

  @override
  void dispose() {
    _cameraController.dispose();
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _counter_func());
    initCamera(widget.cameras![0]);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(() {
        setState(() {});
      });
    _animController.repeat(reverse: true);
    _animController.stop();
  }

  void _counter_func() {
    if (_counter >= 60) {
      takeVideo();
      setState(() {
        _recorging = !_recorging;
      });
    }
    if (_recorging) {
      setState(() {
        _counter++;
      });
    }
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoEditPage(
            file: picture,
            video: !false,
          ),
        ),
      );
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future takeVideo() async {
    // if (!_cameraController.value.isInitialized) {
    //   return null;
    // }
    // if (_cameraController.value.isRecordingVideo) {
    //   return null;
    // }
    setState(() {
      _counter = 0;
    });
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile video = await _cameraController.stopVideoRecording();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoEditPage(
            file: video,
            video: !true,
          ),
        ),
      );
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            (_cameraController.value.isInitialized)
                ? CameraPreview(_cameraController)
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
            // const Spacer(),
            (_recorging)
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_rounded,
                          color: Colors.red,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "00:$_counter",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  )
                : Container(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    color: Colors.black),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 30,
                        icon: Icon(
                            _isRearCameraSelected
                                ? CupertinoIcons.switch_camera
                                : CupertinoIcons.switch_camera_solid,
                            color: Colors.white),
                        onPressed: () {
                          setState(() =>
                              _isRearCameraSelected = !_isRearCameraSelected);
                          initCamera(
                              widget.cameras![_isRearCameraSelected ? 0 : 1]);
                        },
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () {
                        // print('start');
                        setState(
                          () {
                            _recorging = true;
                          },
                        );
                        _cameraController.startVideoRecording();
                        _animController
                          ..forward(from: _animController.value)
                          ..repeat();
                      },
                      onLongPressUp: () {
                        takeVideo();
                        // print('stop');
                        setState(
                          () {
                            _recorging = false;
                          },
                        );
                        _animController.reset();
                      },
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          (_recorging)
                              ? CircularProgressIndicator(
                                  value: _animController.value,
                                  semanticsLabel: 'Circular progress indicator',
                                  strokeWidth: 5,
                                  strokeAlign: 4,
                                )
                              : Container(),
                          IconButton(
                            onPressed: takePicture,
                            iconSize: 50,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.circle, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
