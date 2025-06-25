import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const BlogApp());
}

class BlogApp extends StatefulWidget {
  const BlogApp({super.key});

  @override
  State<BlogApp> createState() => _BlogAppState();
}

class _BlogAppState extends State<BlogApp> {
  String? token;
  int? userId;

  void setAuth(String t, int id) {
    setState(() {
      token = t;
      userId = id;
    });
  }

  void logout() {
    setState(() {
      token = null;
      userId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog Web',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.dark),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            shadowColor: Colors.redAccent,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: token == null
          ? LoginScreen(onLogin: setAuth)
          : PostListScreen(token: token!, onLogout: logout),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final void Function(String, int) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? error;
  bool loading = false;

  Future<void> login() async {
    setState(() { loading = true; error = null; });
    final res = await http.post(
      Uri.parse('http://localhost:8000/api/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );
    setState(() { loading = false; });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      widget.onLogin(data['token'], data['user_id']);
    } else {
      setState(() { error = 'Invalid credentials'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Login')),
      body: GradientBackground(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Blog App', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 8, color: Colors.black, offset: Offset(2,2))])),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: loading ? null : login,
                  child: loading ? const CircularProgressIndicator() : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostListScreen extends StatefulWidget {
  final String token;
  final VoidCallback onLogout;
  const PostListScreen({super.key, required this.token, required this.onLogout});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() { loading = true; });
    final res = await http.get(Uri.parse('http://localhost:8000/api/posts/'));
    if (res.statusCode == 200) {
      setState(() {
        posts = jsonDecode(res.body);
        loading = false;
      });
    } else {
      setState(() { loading = false; });
    }
  }

  void openDetail(Map post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(postId: post['id']),
      ),
    );
  }

  void openCreate() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(token: widget.token),
      ),
    ).then((_) => fetchPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Blog Posts'),
        actions: [
          IconButton(onPressed: openCreate, icon: const Icon(Icons.add)),
          IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: GradientBackground(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, i) {
                  final post = posts[i];
                  return ListTile(
                    title: Text(post['title']),
                    subtitle: Text(post['summary'] ?? ''),
                    onTap: () => openDetail(post),
                  );
                },
              ),
      ),
    );
  }
}

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Map? post;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPost();
  }

  Future<void> fetchPost() async {
    setState(() { loading = true; });
    final res = await http.get(Uri.parse('http://localhost:8000/api/posts/${widget.postId}/'));
    if (res.statusCode == 200) {
      setState(() {
        post = jsonDecode(res.body);
        loading = false;
      });
    } else {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Post Detail')),
      body: GradientBackground(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : post == null
                ? const Center(child: Text('Post not found'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post!['title'], style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text('By ${post!['author']} on ${post!['created_at']}'),
                        const SizedBox(height: 16),
                        Text(post!['content']),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  final String token;
  const CreatePostScreen({super.key, required this.token});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? error;
  bool loading = false;

  Future<void> createPost() async {
    setState(() { loading = true; error = null; });
    final res = await http.post(
      Uri.parse('http://localhost:8000/api/posts/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'title': _titleController.text,
        'content': _contentController.text,
      }),
    );
    setState(() { loading = false; });
    if (res.statusCode == 201) {
      Navigator.of(context).pop();
    } else {
      setState(() { error = 'Failed to create post'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Create Post')),
      body: GradientBackground(
        child: Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: loading ? null : createPost,
                  child: loading ? const CircularProgressIndicator() : const Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
