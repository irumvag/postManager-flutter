import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';

/// A reusable form screen for both creating and editing posts.
///
/// When [post] is null  → CREATE mode (POST /posts)
/// When [post] is given → EDIT mode   (PUT /posts/{id})
class PostFormScreen extends StatefulWidget {
  final Post? post;

  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PostService _service = PostService();

  late final TextEditingController _userIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  bool _isLoading = false;

  bool get _isEditMode => widget.post != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields in edit mode; provide defaults in create mode.
    _userIdController = TextEditingController(
      text: widget.post?.userId.toString() ?? '1',
    );
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks.
    _userIdController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate all form fields using their respective validators.
    if (!_formKey.currentState!.validate()) return;

    // Capture context-dependent objects before any await to avoid
    // using BuildContext across async gaps (use_build_context_synchronously).
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      late final Post result;
      if (_isEditMode) {
        // EDIT: build an updated Post using copyWith, then PUT it.
        final updatedPost = widget.post!.copyWith(
          userId: int.parse(_userIdController.text.trim()),
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );
        result = await _service.updatePost(updatedPost);
      } else {
        // CREATE: POST a new post with the form values.
        result = await _service.createPost(
          userId: int.parse(_userIdController.text.trim()),
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Post updated successfully!'
                : 'Post created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      // Pop with the Post so the caller can update its local list directly.
      navigator.pop(result);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Always reset loading state, even if an exception was thrown.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Post' : 'Create Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User ID field
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'User ID is required';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'User ID must be a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                maxLength: 120,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Body field
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.article_outlined),
                ),
                maxLines: 6,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Body is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Body must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button — disabled while request is in flight
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(_isEditMode ? Icons.save : Icons.add),
                  label: Text(_isEditMode ? 'Save Changes' : 'Create Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
