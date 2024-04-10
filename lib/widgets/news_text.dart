import 'package:flutter/material.dart';

class NewsText extends StatelessWidget {
  final String title;
  final String date;
  final String textBody;

  const NewsText(
      {super.key,
      required this.title,
      required this.date,
      required this.textBody});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            //Box containing the title and the date
            //NB : The alignment will change after we add the button to play the audio
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFFCDCDDC),
                    fontSize: 8,
                    fontFamily: 'Fira Code',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontFamily: 'EB Garamond',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 64.0, vertical: 20.0),
            child: Text(
              textBody,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Fira Code',
                fontWeight: FontWeight.w300,
              ),
              softWrap: true,
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
