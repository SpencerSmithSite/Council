import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarks';
  
  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();
  
  /// Get all bookmarks sorted by date added (newest first)
  Future<List<Bookmark>> getBookmarks() async {
    final prefs = await _prefs;
    final json = prefs.getString(_bookmarksKey);
    if (json == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(json);
      final bookmarks = decoded.map((b) => Bookmark.fromJson(b)).toList();
      bookmarks.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return bookmarks;
    } catch (_) {
      return [];
    }
  }
  
  /// Add a bookmark
  Future<void> addBookmark({
    required int contentId,
    required String title,
    required String source,
    String? preview,
  }) async {
    final bookmarks = await getBookmarks();
    
    // Check if already bookmarked
    if (bookmarks.any((b) => b.contentId == contentId)) {
      return; // Already bookmarked
    }
    
    bookmarks.add(Bookmark(
      contentId: contentId,
      title: title,
      source: source,
      preview: preview,
      addedAt: DateTime.now(),
    ));
    
    await _saveBookmarks(bookmarks);
  }
  
  /// Remove a bookmark
  Future<void> removeBookmark(int contentId) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b.contentId == contentId);
    await _saveBookmarks(bookmarks);
  }
  
  /// Toggle bookmark status
  Future<bool> toggleBookmark({
    required int contentId,
    required String title,
    required String source,
    String? preview,
  }) async {
    final currentlyBookmarked = await isBookmarked(contentId);
    if (currentlyBookmarked) {
      await removeBookmark(contentId);
      return false;
    } else {
      await addBookmark(
        contentId: contentId,
        title: title,
        source: source,
        preview: preview,
      );
      return true;
    }
  }
  
  /// Check if content is bookmarked
  Future<bool> isBookmarked(int contentId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b.contentId == contentId);
  }
  
  /// Get bookmark count
  Future<int> getBookmarkCount() async {
    final bookmarks = await getBookmarks();
    return bookmarks.length;
  }
  
  /// Save bookmarks to preferences
  Future<void> _saveBookmarks(List<Bookmark> bookmarks) async {
    final prefs = await _prefs;
    final json = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
    await prefs.setString(_bookmarksKey, json);
  }
}

class Bookmark {
  final int contentId;
  final String title;
  final String source;
  final String? preview;
  final DateTime addedAt;
  
  Bookmark({
    required this.contentId,
    required this.title,
    required this.source,
    this.preview,
    required this.addedAt,
  });
  
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      contentId: json['contentId'] as int,
      title: json['title'] as String,
      source: json['source'] as String,
      preview: json['preview'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'title': title,
      'source': source,
      'preview': preview,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
