import 'package:flutter/material.dart';
import 'models/post.dart';
import 'screens/post_list_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/post_form_screen.dart';

void main() {
  runApp(const PostsManagerApp());
}

class PostsManagerApp extends StatelessWidget {
  const PostsManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      // Routes that carry no arguments
      initialRoute: '/',
      routes: {
        '/': (context) => const PostListScreen(),
        '/create': (context) => const PostFormScreen(),
      },
      // Routes that carry a Post object as an argument
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final post = settings.arguments as Post;
          return MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: post),
          );
        }
        if (settings.name == '/edit') {
          final post = settings.arguments as Post;
          return MaterialPageRoute(
            builder: (_) => PostFormScreen(post: post),
          );
        }
        return null;
      },
    );
  }
}
