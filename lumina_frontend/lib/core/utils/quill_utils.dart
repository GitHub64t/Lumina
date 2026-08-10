import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class QuillUtils {
  /// Converts a content string (Delta JSON, HTML, or plain text) into a
  /// [QuillController] initialized with a valid [Document].
  ///
  /// Priority order:
  ///   1. Double-encoded JSON string (stringified JSON array)
  ///   2. Delta JSON array (starts with '[')
  ///   3. HTML (contains '<' and '>')
  ///   4. Plain text fallback
  static QuillController controllerFromContent(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return QuillController.basic();
    }

    // 1. Attempt JSON decoding (supports double-encoded JSON strings from
    //    legacy storage that stored Delta JSON as a serialised string)
    try {
      var decoded = jsonDecode(trimmed);
      if (decoded is String) {
        final subTrimmed = decoded.trim();
        if (subTrimmed.startsWith('[')) {
          decoded = jsonDecode(subTrimmed);
        }
      }
      if (decoded is List) {
        final doc = Document.fromJson(decoded);
        return QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } catch (_) {}

    // 2. Direct JSON decode for Delta arrays
    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          final doc = Document.fromJson(decoded);
          return QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      } catch (_) {}
    }

    // 3. HTML → Delta conversion (current storage format)
    if (trimmed.contains('<') && trimmed.contains('>')) {
      try {
        final delta = HtmlToDelta().convert(trimmed);
        if (delta.isNotEmpty) {
          final doc = Document.fromDelta(delta);
          return QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      } catch (_) {}
    }

    // 4. Fallback: plain text
    final cleanText = stripHtmlTags(trimmed);
    final doc = Document()..insert(0, cleanText);
    return QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  /// Converts the current Quill document to an **HTML string** suitable for
  /// sending to the backend and storing in the database.
  ///
  /// The backend is shared by both the Flutter app and the web app, so the
  /// content must be stored as HTML.
  static String contentFromController(QuillController controller) {
    final deltaJson = controller.document
        .toDelta()
        .toJson()
        .cast<Map<String, dynamic>>();
    final converter = QuillDeltaToHtmlConverter(deltaJson, ConverterOptions());
    return converter.convert();
  }

  /// Extracts clean plain text from Delta JSON, HTML, or raw text.
  /// Used for word-count estimation and feed card excerpts.
  static String extractPlainText(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return '';

    // Try Delta JSON (single or double-encoded)
    try {
      var decoded = jsonDecode(trimmed);
      if (decoded is String) {
        final subTrimmed = decoded.trim();
        if (subTrimmed.startsWith('[')) {
          decoded = jsonDecode(subTrimmed);
        }
      }
      if (decoded is List) {
        final doc = Document.fromJson(decoded);
        return doc.toPlainText().trim();
      }
    } catch (_) {}

    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          final doc = Document.fromJson(decoded);
          return doc.toPlainText().trim();
        }
      } catch (_) {}
    }

    // Strip HTML tags for plain-text extraction from HTML content
    return stripHtmlTags(trimmed).trim();
  }

  /// Removes HTML tags from a string.
  static String stripHtmlTags(String htmlString) {
    final regExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlString
        .replaceAll(regExp, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
