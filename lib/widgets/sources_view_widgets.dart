import 'package:flutter/material.dart';

class ScrollableText extends StatelessWidget {
  final String text;

  const ScrollableText({this.text = "", super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Text(style: Theme.of(context).textTheme.displaySmall, text),
    );
  }
}

class SourceOrigin extends StatelessWidget {
  final String origin;
  final String date;

  const SourceOrigin({this.origin = "", this.date = "", super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
        style: Theme.of(context)
            .textTheme
            .displaySmall
            ?.copyWith(color: const Color(0xFF818181)),
        "$origin, $date");
  }
}

class SourceTitle extends StatelessWidget {
  final String title;

  const SourceTitle({this.title = "", super.key});

  @override
  Widget build(BuildContext context) {
    return Text(style: Theme.of(context).textTheme.titleLarge, title);
  }
}
