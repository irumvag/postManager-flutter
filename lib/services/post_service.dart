import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  // ─── READ ALL ─────────────────────────────────────────────────────────────

  /// Fetches all posts from GET /posts.
  /// Returns a [List<Post>] on success, throws an [Exception] on failure.
  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) => Post.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to load posts. Status code: ${response.statusCode}',
      );
    }
  }

  // ─── READ ONE ─────────────────────────────────────────────────────────────

  /// Fetches a single post by [id] from GET /posts/{id}.
  Future<Post> getPost(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to load post $id. Status code: ${response.statusCode}',
      );
    }
  }

  // ─── CREATE ───────────────────────────────────────────────────────────────

  /// Sends POST /posts with new post data.
  /// JSONPlaceholder echoes back the object with a fake id (always 101).
  Future<Post> createPost({
    required int userId,
    required String title,
    required String body,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'userId': userId,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create post. Status code: ${response.statusCode}',
      );
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  /// Sends PUT /posts/{id} with the full updated [post].
  Future<Post> updatePost(Post post) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/${post.id}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(post.toJson()),
    );

    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update post ${post.id}. Status code: ${response.statusCode}',
      );
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  /// Sends DELETE /posts/{id}. Returns true on success.
  Future<bool> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    // JSONPlaceholder returns 200 for DELETE
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to delete post $id. Status code: ${response.statusCode}',
      );
    }
  }
}
