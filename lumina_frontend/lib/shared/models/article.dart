import 'package:equatable/equatable.dart';

class Article extends Equatable {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.author,
    this.categoryId,
    this.categoryName,
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
  /// Formatted author full name.
  final String author;
  /// Raw category ID (UUID).
  final String? categoryId;
  /// Human-readable category name for display.
  final String? categoryName;
  final String? imageUrl;
  final DateTime publishedAt;
  final int readMinutes;
  final int likes;
  final int dislikes;

  /// Convenience alias kept for display compatibility.
  String get body => content;

  @override
  List<Object?> get props => [
    id, title, summary, content, author, categoryId, categoryName,
    imageUrl, publishedAt, readMinutes, likes, dislikes,
  ];
}
