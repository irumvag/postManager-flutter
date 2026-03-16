import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final PostService _service = PostService();

  // FutureBuilder watches this Future for the loading/error/success states.
  // Stored as a field — never created inside build() to avoid firing a new
  // HTTP request on every frame rebuild.
  late Future<List<Post>> _postsFuture;

  // Local copy of posts. Populated once by the Future, then updated in-place
  // for every create / update / delete so changes appear immediately without
  // a redundant network round-trip (JSONPlaceholder does not persist mutations).
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  /// Fires a fresh GET /posts request and populates [_posts] when it resolves.
  void _loadPosts() {
    _postsFuture = _service.getPosts();
    _postsFuture.then((posts) {
      if (mounted) setState(() => _posts = List.from(posts));
    }).catchError((_) {
      // Errors are surfaced through FutureBuilder's snapshot.hasError branch.
    });
  }

  /// Clears the local list (to re-show the loading spinner) then re-fetches.
  void _refresh() {
    setState(() => _posts = []);
    _loadPosts();
  }

  Future<void> _confirmDelete(BuildContext context, Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to delete "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deletePost(post.id);
        // Remove locally — no re-fetch needed.
        setState(() => _posts.removeWhere((p) => p.id == post.id));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting post: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          // ── Loading state ─────────────────────────────────────────────────
          // Show spinner only while waiting AND no local data is available yet.
          if (snapshot.connectionState == ConnectionState.waiting &&
              _posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error state ───────────────────────────────────────────────────
          // Show error only if we have no local data to fall back on.
          if (snapshot.hasError && _posts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load posts.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Empty state ───────────────────────────────────────────────────
          if (_posts.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }

          // ── Success state — render from the local _posts list ─────────────
          return ListView.builder(
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return PostCard(
                post: post,
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: post,
                  );
                  if (result is Post) {
                    // Post was edited — replace it in the local list.
                    setState(() {
                      final idx = _posts.indexWhere((p) => p.id == result.id);
                      if (idx != -1) _posts[idx] = result;
                    });
                  } else if (result == 'deleted') {
                    // Post was deleted from the detail screen — remove locally.
                    setState(() => _posts.removeWhere((p) => p.id == post.id));
                  }
                },
                onDelete: () => _confirmDelete(context, post),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create');
          if (result is Post) {
            // Insert the newly created post at the top of the list.
            setState(() => _posts.insert(0, result));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }
}
