import 'dart:typed_data';

import 'package:actualia/views/source_view.dart';
import 'package:flutter/material.dart';
import 'package:actualia/models/news.dart';
import 'package:actualia/widgets/play_button.dart';

class NewsText extends StatelessWidget {
  final News news;
  const NewsText({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    String date = convertDate(news.date);
    var source = Uint8List(1);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            //Box containing the title, date and play button
            //NB : The alignment will change after we add the button to play the audio
            //Note for audio : Use the transcriptID and audio fields from the news.
            padding: const EdgeInsets.fromLTRB(30.0, 0.0, 80.0, 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                    alignment: Alignment.topLeft,
                    child: PlayButton(source: source)),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          date,
                          style: const TextStyle(
                            color: Color(0xFFC8C8C8),
                            fontSize: 8,
                            fontFamily: 'Fira Code',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          news.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontFamily: 'EB Garamond',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(64.0, 20.0, 64.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: news.paragraphs
                  .map((paragraph) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => SourceView(
                                      article: paragraph.content,
                                      title: paragraph.title,
                                      date: convertDate(paragraph.date),
                                      newsPaper: paragraph.source)));
                        },
                        child: Text(
                          '${paragraph.transcript}\n',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Fira Code',
                            fontWeight: FontWeight.w300,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const Divider(
            height: 60,
            thickness: 0.5,
            indent: 64.0,
            endIndent: 64.0,
            color: Color(0xFFC8C8C8),
          )
        ],
      ),
    );
  }

  static String convertDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    String suffix;
    if (dateTime.day == 1 || dateTime.day == 21 || dateTime.day == 31) {
      suffix = "st";
    } else if (dateTime.day == 2 || dateTime.day == 22) {
      suffix = "nd";
    } else if (dateTime.day == 3 || dateTime.day == 23) {
      suffix = "rd";
    } else {
      suffix = "th";
    }
    return "${weekDays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}$suffix, ${dateTime.year}";
  }
}
