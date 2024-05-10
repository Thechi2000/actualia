import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    final permission = await Permission.camera.request();

    if (permission.isGranted) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        debugPrint('Path to picture: ${photo.path}');
      }
    } else {
      log('Permission denied', level: Level.WARNING.value);
    }
  }

//initState
  @override
  void initState() {
    super.initState();
    _takePicture();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _takePicture,
      icon: const Icon(Icons.camera_alt),
    );
  }
}
