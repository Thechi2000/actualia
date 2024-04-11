import 'package:flutter/material.dart';
import 'package:actualia/widgets/news_text.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/models/news.dart';
import 'package:provider/provider.dart';

class NewsView extends StatefulWidget {
  const NewsView({super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<NewsViewModel>(context, listen: false)
            .fetchNews(DateTime.now()));
            /*.pushNews(News(
                title: 'This title was pulled from the DataBase',
                date: '2024-04-11',
                paragraphs: [
              Paragraph(
                  text: 'This is a paragraph, feel free to update it',
                  source: 'This is the source')
            ])));*/
  }

  @override
  Widget build(BuildContext context) {
    final newsViewModel = Provider.of<NewsViewModel>(context);
    final _news = newsViewModel.news;
    Widget body = _news == null
        ? const Center(child: CircularProgressIndicator())
        : NewsText(news: _news);

    return Scaffold(
      appBar: const TopAppBar(),
      body: body,
    );
  }
}
