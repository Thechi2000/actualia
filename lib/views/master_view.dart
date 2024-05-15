import 'dart:developer';

import 'package:actualia/viewmodels/news_recognition.dart';
import 'package:actualia/views/news_view.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../models/navigation_menu.dart';
import '../widgets/navigation_menu.dart';

class MasterView extends StatefulWidget {
  const MasterView({super.key});

  @override
  State<MasterView> createState() => _MasterView();
}

class _MasterView extends State<MasterView> {
  Views _currentViews = Views.NEWS;
  late List<Destination> _destinations;

  void setCurrentViewState(Views view) {
    if (view != Views.CAMERA) {
      setState(() {
        _currentViews = view;
      });
    }
  }

  void cameraButtonPressed(Views view) {
    log("Camera button pressed on navigation bar", level: Level.INFO.value);
    debugPrint("Camera button pressed");
    NewsRecognitionViewModel newsRecognitionVM =
        Provider.of<NewsRecognitionViewModel>(context, listen: false);
    Future<XFile?> image =
        Future.microtask(() => newsRecognitionVM.takePicture());
    image.then((value) {
      if (value != null) newsRecognitionVM.recognizeText(value.path);
    });
  }

  @override
  void initState() {
    super.initState();
    _destinations = [
      Destination(
          view: Views.NEWS,
          icon: Icons.newspaper,
          onPressed: setCurrentViewState),
      Destination(
          view: Views.CAMERA,
          icon: Icons.camera_alt,
          onPressed: cameraButtonPressed),
      Destination(
          view: Views.FEED, icon: Icons.feed, onPressed: setCurrentViewState)
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentViews) {
      case Views.NEWS:
        body = const NewsView();
        break;
      case Views.CAMERA:
        body = const Center(child: Text("To be implemented"));
        break;
      case Views.FEED:
        body = const Center(child: Text("To be implemented"));
        break;
      default:
        body = const Center(child: Text("SHOULD NOT BE DISPLAYED"));
        break;
    }

    Widget screen = Scaffold(
      appBar: const TopAppBar(),
      bottomNavigationBar: ActualiaBottomNavigationBar(
        destinations: _destinations,
      ),
      body: body,
    );

    return screen;
  }
}
