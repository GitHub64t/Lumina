import 'package:equatable/equatable.dart';

class Article extends Equatable {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.author,
    this.categoryId,
    this.imageUrl,
    required this.publishedAt,
    this.readMinutes = 0,
    this.likes = 0,
    this.dislikes = 0,
  });

  final String id;
  final String title;
  final String summary;
  /// Backend field name: content (was: body).
  final String content;
  final String author;
  /// Backend field name: categoryId (was: category string).
  final String? categoryId;
  final String? imageUrl;
  final DateTime publishedAt;
  final int readMinutes;
  final int likes;
  final int dislikes;

  /// Convenience alias kept for display compatibility.
  String get body => content;

  @override
  List<Object?> get props => [
    id, title, summary, content, author, categoryId,
    imageUrl, publishedAt, readMinutes, likes, dislikes,
  ];
}
