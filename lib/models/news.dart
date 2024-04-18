class News {
  final String title;
  final String date;
  final int transcriptID;
  final String? audio;
  final List<Paragraph> paragraphs;

  News({
    required this.title,
    required this.date,
    required this.transcriptID,
    required this.audio,
    required this.paragraphs,
  });
}

class Paragraph {
  final String transcript; //Text of the paragraph
  final String source; //Newspaper or website where the article comes from
  final String title; //Title of the article
  final String date; //Date of the article
  final String content; //Content of the article

  Paragraph({
    required this.transcript,
    required this.source,
    required this.title,
    required this.date,
    required this.content,
  });
}
