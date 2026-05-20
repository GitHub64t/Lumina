import '../../../../shared/models/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.summary,
    required super.content,
    required super.author,
    super.categoryId,
    super.imageUrl,
    required super.publishedAt,
    super.readMinutes,
    super.likes,
    super.dislikes,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
    id: (json['id'] ?? json['_id']).toString(),
    title: json['title']?.toString() ?? '',
    summary: json['summary']?.toString() ?? json['excerpt']?.toString() ?? '',
    // Backend returns 'content'; fall back to 'body' for compat.
    content: json['content']?.toString() ?? json['body']?.toString() ?? '',
    author: json['author']?.toString() ??
        json['authorName']?.toString() ??
        'Editorial desk',
    categoryId: json['categoryId']?.toString() ?? json['category']?.toString(),
    imageUrl: json['featuredImage']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image']?.toString(),
    publishedAt:
        DateTime.tryParse(json['publishedAt']?.toString() ??
            json['createdAt']?.toString() ??
            '') ??
        DateTime.now(),
    readMinutes: int.tryParse(json['readMinutes']?.toString() ?? '') ?? 4,
    likes: int.tryParse(json['likes']?.toString() ?? '') ?? 0,
    dislikes: int.tryParse(json['dislikes']?.toString() ?? '') ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'content': content,
    'author': author,
    'categoryId': categoryId,
    'featuredImage': imageUrl,
    'publishedAt': publishedAt.toIso8601String(),
    'readMinutes': readMinutes,
    'likes': likes,
    'dislikes': dislikes,
  };
}
