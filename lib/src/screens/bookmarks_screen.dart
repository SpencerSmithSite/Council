import 'package:flutter/material.dart';

import '../services/bookmark_service.dart';
import 'content_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Bookmark>? _bookmarks;
  bool _isLoading = true;
  
  final BookmarkService _bookmarkService = BookmarkService();
  
  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }
  
  Future<void> _loadBookmarks() async {
    final bookmarks = await _bookmarkService.getBookmarks();
    if (mounted) {
      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _removeBookmark(int contentId) async {
    await _bookmarkService.removeBookmark(contentId);
    _loadBookmarks();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from bookmarks'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    if (_bookmarks == null || _bookmarks!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on any passage\nto save it here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookmarks!.length,
      itemBuilder: (context, index) {
        final bookmark = _bookmarks![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.bookmark),
            title: Text(
              bookmark.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookmark.source,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (bookmark.preview != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    bookmark.preview!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeBookmark(bookmark.contentId),
            ),
            onTap: () => _navigateToContent(bookmark.contentId),
          ),
        );
      },
    );
  }
  
  void _navigateToContent(int contentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentDetailScreen(contentId: contentId),
      ),
    );
  }
}
