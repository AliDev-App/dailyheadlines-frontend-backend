import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/news_item.dart'; // your existing NewsItem model

class DomainNewsScreen extends StatefulWidget {
  const DomainNewsScreen({Key? key}) : super(key: key);

  @override
  State<DomainNewsScreen> createState() => _DomainNewsScreenState();
}

class _DomainNewsScreenState extends State<DomainNewsScreen> {
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _fetchNews();
  }

  Future<List<NewsItem>> _fetchNews() async {
    final url = Uri.parse("http://localhost:3000/get-news");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => NewsItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load news (status ${response.statusCode})");
    }
  }

  Future<void> _deleteNews(int id) async {
    final url = Uri.parse("http://localhost:3000/delete-news/$id");
    final response = await http.delete(url);

    // DEBUG
    debugPrint("🗑 DELETE $id → ${response.statusCode}: ${response.body}");

    if (response.statusCode == 200) {
      final msg = (jsonDecode(response.body) as Map)['message'];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ $msg')));
      setState(() => _newsFuture = _fetchNews());
    } else if (response.statusCode == 404) {
      final err = (jsonDecode(response.body) as Map)['error'];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ $err')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted failed (status ${response.statusCode})'),
        ),
      );
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: const Text("This will permanently remove the news item."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteNews(id);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh News',
            onPressed: () {
              setState(() {
                _newsFuture = _fetchNews();
              });
            },
          ),
        ],
        title: const Text(
          "📰 Domain: Manage News",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: _newsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          final news = snap.data!;
          if (news.isEmpty) {
            return const Center(child: Text("No news to manage."));
          }
          return ListView.builder(
            itemCount: news.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (ctx, i) {
              final n = news[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    n.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${n.description}\nBy ${n.author} • ${DateFormat.yMMMd().format(n.publishedAt)}",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(n.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
