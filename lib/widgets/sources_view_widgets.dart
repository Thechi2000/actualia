import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScrollableText extends StatelessWidget {
  final String text;

  const ScrollableText({this.text = "", super.key});

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: SingleChildScrollView(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'Fira Code',
              fontWeight: FontWeight.w300,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.left,
          ),
        )
      )
    );
  }
}

class ReturnButton extends StatelessWidget {
  const ReturnButton({super.key});

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () => {/*todo*/},
      borderRadius: BorderRadius.circular(20.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8, 16, 4, 16),
            child: Icon(Icons.arrow_back_ios_new),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4, 16, 16, 16),
            child: Text("Back"),
          ),
        ],
      ),
    );
  }
}

class DisplayOrigin extends StatelessWidget {
  final String origin;
  final String date;

  const DisplayOrigin({this.origin = "", this.date = "00/00/0000", super.key});

  @override
  Widget build(BuildContext context) {

    return Text(
      "Article from $origin,\n$date",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontFamily: 'EB Garamond',
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
    );
  }
}

class DisplayTitle extends StatelessWidget {
  final String title;

  const DisplayTitle({this.title = "", super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        "Title of the article : $title",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontFamily: 'EB Garamond',
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
      )
    );
  }
}