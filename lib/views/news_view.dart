import 'package:actualia/views/loading_view.dart';
import 'package:actualia/views/no_news_view.dart';
import 'package:flutter/material.dart';
import 'package:actualia/widgets/news_text.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/share_button.dart';

class NewsView extends StatefulWidget {
  const NewsView({super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<NewsViewModel>(context, listen: false).getNewsList());
  }

  @override
  Widget build(BuildContext context) {
    Widget loading =
        const LoadingView(text: "Please wait while we fetch the news for you.");

    final newsViewModel = Provider.of<NewsViewModel>(context);
    final _newsList = newsViewModel.newsList;
    final hasNews = newsViewModel.hasNews;
    Widget body;

    if (_newsList.isEmpty) {
      if (hasNews) {
        body = loading;
      } else {
        body = const NoNewsView(
            title: "You don't have any news yet.",
            text:
                "The first one will be generated the first time the alarm goes off.");
      }
    } else {
      body = ListView.builder(
          itemCount: _newsList.length,
          itemBuilder: (context, index) {
            return NewsText(news: _newsList[index]);
          });
    }

    return Scaffold(
      appBar: const TopAppBar(),
      body: body,
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () =>
                Share.share(newsViewModel.newsList.first.fullTranscript),
            icon: const Icon(Icons.text_fields),
          ),
          ActionButton(
            onPressed: () async => await Share.shareXFiles([
              XFile(
                  '${(await getApplicationDocumentsDirectory()).path}/audios/${newsViewModel.newsList.first.transcriptId}.mp3')
            ], text: 'Check my personalized news audio!'),
            icon: const Icon(Icons.audiotrack),
          ),
          ActionButton(
            onPressed: () => Share.share(
                'https://actualia.app/shared/${newsViewModel.newsList.first.transcriptId}'),
            icon: const Icon(Icons.link),
          ),
        ],
      ),
    );
  }
}
