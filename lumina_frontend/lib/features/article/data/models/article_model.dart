import '../../../../core/utils/quill_utils.dart';
import '../../../../shared/models/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.summary,
    required super.content,
    required super.author,
    super.categoryId,
    super.categoryName,
    super.imageUrl,
    required super.publishedAt,
    super.readMinutes,
    super.likes,
    super.dislikes,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    // ── Author ───────────────────────────────────────────────────────────────
    // The API returns author as either a plain string OR a nested object:
    //   { id, firstName, lastName, email, ... }
    final String author;
    final authorRaw = json['author'];
    if (authorRaw is Map) {
      final first = authorRaw['firstName']?.toString() ?? '';
      final last = authorRaw['lastName']?.toString() ?? '';
      author = '$first $last'.trim();
    } else {
      author = authorRaw?.toString() ??
          json['authorName']?.toString() ??
          'Editorial desk';
    }

    // ── Category ─────────────────────────────────────────────────────────────
    // The API returns category as a nested object:
    //   { id, name, slug }
    // OR just a plain categoryId string at the root.
    String? categoryId;
    String? categoryName;
    final categoryRaw = json['category'];
    if (categoryRaw is Map) {
      categoryId = categoryRaw['id']?.toString();
      categoryName = categoryRaw['name']?.toString();
    } else {
      // Flat categoryId at root level.
      categoryId = json['categoryId']?.toString();
      categoryName = null; // name not available without the nested object
    }

    // ── Image URL ─────────────────────────────────────────────────────────────
    // featuredImage can be a URL string or null.
    final imageUrl = json['featuredImage']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image']?.toString();

    // ── Read time ─────────────────────────────────────────────────────────────
    // Estimate from content length if not provided (~200 wpm).
    final contentText = json['content']?.toString() ?? json['body']?.toString() ?? '';
    final plainText = QuillUtils.extractPlainText(contentText);
    final wordCount = plainText.isEmpty ? 0 : plainText.split(RegExp(r'\s+')).length;
    final estimatedMinutes = (wordCount / 200).ceil().clamp(1, 60);
    final readMinutes = int.tryParse(json['readMinutes']?.toString() ?? '') ??
        int.tryParse(json['readTime']?.toString() ?? '') ??
        estimatedMinutes;

    final rawSummary = json['summary']?.toString() ?? json['excerpt']?.toString();
    final summary = (rawSummary != null && rawSummary.isNotEmpty)
        ? QuillUtils.stripHtmlTags(rawSummary)
        : (plainText.length > 120
            ? '${plainText.substring(0, 120)}…'
            : plainText);

    return ArticleModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: summary,
      content: contentText,
      author: author.isEmpty ? 'Editorial desk' : author,
      categoryId: categoryId,
      categoryName: categoryName,
      imageUrl: imageUrl,
      publishedAt: DateTime.tryParse(
            json['publishedAt']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      readMinutes: readMinutes,
      likes: int.tryParse(json['likes']?.toString() ?? '') ?? 0,
      dislikes: int.tryParse(json['dislikes']?.toString() ?? '') ?? 0,
    );
  }

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
