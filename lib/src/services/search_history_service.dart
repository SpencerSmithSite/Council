import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _historyKey = 'search_history';
  static const int _maxItems = 20;
  
  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();
  
  /// Get recent searches (newest first)
  Future<List<SearchHistoryItem>> getHistory() async {
    final prefs = await _prefs;
    final json = prefs.getString(_historyKey);
    if (json == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((d) => SearchHistoryItem.fromJson(d)).toList();
    } catch (_) {
      return [];
    }
  }
  
  /// Add a search to history
  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final history = await getHistory();
    
    // Remove if already exists (move to top)
    history.removeWhere((h) => h.query.toLowerCase() == query.toLowerCase());
    
    // Add new item at beginning
    history.insert(0, SearchHistoryItem(
      query: query.trim(),
      timestamp: DateTime.now(),
    ));
    
    // Trim to max
    while (history.length > _maxItems) {
      history.removeLast();
    }
    
    await _saveHistory(history);
  }
  
  /// Remove a search from history
  Future<void> removeSearch(String query) async {
    final history = await getHistory();
    history.removeWhere((h) => h.query == query);
    await _saveHistory(history);
  }
  
  /// Clear all history
  Future<void> clearHistory() async {
    final prefs = await _prefs;
    await prefs.remove(_historyKey);
  }
  
  /// Save history
  Future<void> _saveHistory(List<SearchHistoryItem> history) async {
    final prefs = await _prefs;
    final json = jsonEncode(history.map((h) => h.toJson()).toList());
    await prefs.setString(_historyKey, json);
  }
}

class SearchHistoryItem {
  final String query;
  final DateTime timestamp;
  
  SearchHistoryItem({
    required this.query,
    required this.timestamp,
  });
  
  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      query: json['query'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
