import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';

/// Shows the full details of a single post.
/// The [post] is passed as a constructor argument — no async loading needed.
class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
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

    if (confirmed == true && context.mounted) {
      try {
        await PostService().deletePost(post.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted'),
              backgroundColor: Colors.green,
            ),
          );
          // Pop with 'deleted' so the list screen can remove the item locally.
          Navigator.pop(context, 'deleted');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
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
        title: Text('Post #${post.id}'),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit post',
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/edit',
                arguments: post,
              );
              // Pop with the updated Post so the list can replace it locally.
              if (result is Post && context.mounted) {
                Navigator.pop(context, result);
              }
            },
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete post',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata chips
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text('Post ID: ${post.id}'),
                  backgroundColor: Colors.indigo.shade50,
                ),
                Chip(
                  label: Text('User ID: ${post.userId}'),
                  backgroundColor: Colors.teal.shade50,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title section
            const Text(
              'TITLE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),

            // Body section
            const Text(
              'BODY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              post.body,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
