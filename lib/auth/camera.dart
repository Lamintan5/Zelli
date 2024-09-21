import 'dart:io';

import 'package:Zelli/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final Function setPicture;
  const CameraScreen({super.key, required this.setPicture});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late int _currentCameraIndex;
  late CameraController _controller;
  late int _flashModeIndex;
  bool _loading = false;

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      cameras[_currentCameraIndex],
      ResolutionPreset.medium,
    );
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }
  void _toggleFlashMode() {
    setState(() {
      // Increment the flash mode index
      _flashModeIndex = (_flashModeIndex + 1) % 3;

      // Set the new flash mode
      switch (_flashModeIndex) {
        case 0:
          _controller.setFlashMode(FlashMode.auto);
          setState(() {
            _flashModeIndex = 0;
          });
          break;
        case 1:
          _controller.setFlashMode(FlashMode.torch);
          setState(() {
            _flashModeIndex = 1;
          });
          break;
        case 2:
          _controller.setFlashMode(FlashMode.off);
          setState(() {
            _flashModeIndex = 2;
          });
          break;
      }
    });
  }
  _takePhoto()async{
    try {
      setState(() {
        _loading = true;
      });
      XFile picture = await _controller.takePicture();

      widget.setPicture(File(picture.path));
      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
    } on CameraException catch (e) {
      debugPrint("Error occure while taking picture : $e");
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentCameraIndex = 0;
    _flashModeIndex = 0;
    _initializeCamera();
  }

  void _toggleCamera() async {
    await _controller.dispose();
    if(Platform.isIOS || Platform.isAndroid){
      _currentCameraIndex = (_currentCameraIndex + 1) % 2;
    }
    await _initializeCamera();
  }


  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  width: size.width,
                  child: CameraPreview(_controller),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: size.height/1/6,
                  width: size.width,
                  color: Colors.black12,
                  child: Center(
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _currentCameraIndex==0? IconButton(
                                onPressed: (){_toggleFlashMode();},
                                icon: Icon(_flashModeIndex == 0
                                    ? Icons.flash_auto
                                    : (_flashModeIndex == 1 ? Icons.flash_on : Icons.flash_off)),
                                iconSize: 30, color: Colors.white70,
                              ):SizedBox(
                                width: 48,height: 48,
                              ),
                              InkWell(
                                onTap: ()async{
                                  if(!_controller.value.isInitialized){
                                    return null;
                                  }
                                  if(_controller.value.isTakingPicture){
                                    return null;
                                  }
                                  _takePhoto();
                                },
                                child: Container(
                                  width: 80,height: 80,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white, width: 2
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.white54
                                    ),
                                    child: _loading? CircularProgressIndicator(color: CupertinoColors.activeBlue,) : SizedBox(),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: (){
                                    _toggleCamera();
                                  },
                                  icon: Icon(_currentCameraIndex == 0
                                      ? Icons.flip_camera_ios
                                      : Icons.flip_camera_ios_outlined,),
                                  iconSize: 30, color: Colors.white70
                              )
                            ],
                          ),
                        ),
                        Text("STUDIO5IVE TOOLS", style: TextStyle(color: Colors.white54),)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  IconData _getFlashModeIcon(FlashMode flashMode) {
    switch (flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.torch:
        return Icons.flash_auto;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();

  }
}
