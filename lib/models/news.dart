class News {
  final String title;
  final String date;
  final List<Paragraph> paragraphs;

  News({
    required this.title,
    required this.date,
    required this.paragraphs,
  });
}

class Paragraph {
  final String text;
  final String source;

  Paragraph({required this.text, required this.source});
}
