import 'dart:developer';

import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/viewmodels/news_recognition.dart';
import 'package:actualia/views/context_view.dart';
import 'package:actualia/views/news_view.dart';
import 'package:actualia/widgets/share_button.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
  late String? _ocrText;

  void setCurrentViewState(Views view) {
    if (view != Views.CAMERA) {
      setState(() {
        _currentViews = view;
      });
    }
  }

  Future<void> cameraButtonPressed(Views view) async {
    log("Camera button pressed on navigation bar", level: Level.INFO.value);
    NewsRecognitionViewModel newsRecognitionVM =
        Provider.of<NewsRecognitionViewModel>(context, listen: false);
    XFile? image = await newsRecognitionVM.takePicture();

    if (image != null) {
      _ocrText = await newsRecognitionVM.ocr(image.path);
      setState(() {
        _currentViews = Views.CONTEXT;
      });
    }
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
    var firstTranscript = Provider.of<NewsViewModel>(context).newsList.first;

    Widget body;
    Widget button = const SizedBox();
    switch (_currentViews) {
      case Views.NEWS:
        body = const NewsView();
        button = ExpandableFab(
          distance: 112,
          children: [
            ActionButton(
              onPressed: () => Share.share(firstTranscript.fullTranscript),
              icon: const Icon(Icons.text_fields),
            ),
            ActionButton(
              onPressed: () async => await Share.shareXFiles([
                XFile(
                    // ignore: use_build_context_synchronously
                    '${(await getApplicationDocumentsDirectory()).path}/audios/${firstTranscript.transcriptId}.mp3')
              ], text: 'Check my personalized news audio!'),
              icon: const Icon(Icons.audiotrack),
            ),
            ActionButton(
              onPressed: () => Share.share(
                  'https://actualia.app/shared/${firstTranscript.transcriptId}'),
              icon: const Icon(Icons.link),
            ),
          ],
        );
        break;
      case Views.CAMERA:
        body = const Center(child: Text("To be implemented"));
        break;
      case Views.FEED:
        body = const Center(child: Text("To be implemented"));
        break;
      case Views.CONTEXT:
        body = ContextView(text: _ocrText ?? "No text found");
        break;
      default:
        body = const Center(child: Text("SHOULD NOT BE DISPLAYED"));
        break;
    }

    var newsViewModel;
    Widget screen = Scaffold(
      appBar: const TopAppBar(),
      bottomNavigationBar: ActualiaBottomNavigationBar(
        destinations: _destinations,
      ),
      body: body,
      floatingActionButton: button,
    );

    return screen;
  }
}
