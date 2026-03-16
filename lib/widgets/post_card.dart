import 'package:flutter/material.dart';
import '../models/post.dart';

/// A reusable card widget that displays a single post summary in a list.
/// It is a pure presentational widget — it receives callbacks and never
/// calls the service layer directly.
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 72, 32, 85),
          child: Text(
            '#${post.id}',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
        title: Text(
          post.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          post.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          tooltip: 'Delete post',
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
