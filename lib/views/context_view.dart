import 'package:actualia/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//TODO: Everything, this is merely a placeholder, this PR needs 3 other PRs to be merged first in order to be implemented

class ContextView extends StatefulWidget {
  final XFile? image;
  const ContextView({super.key, this.image});

  @override
  State<ContextView> createState() => _ContextViewState();
}

class _ContextViewState extends State<ContextView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<NewsRecognitionViewModel>(context, listen: false)
            .Ocr(widget.image));
  }

  @override
  Widget build(BuildContext context) {
    Widget loading =
        const LoadingView(text: "The image is being processed. Please wait.");

    final newsRecognitionViewModel =
        Provider.of<NewsRecognitionViewModel>(context);
    final context = newsRecognitionViewModel.context;
    Widget body;
    if (contex == null) {
      body = loading;
    } else {
      body = const Text("TO BE IMPLEMENTED");
    }

    return body;
  }
}
