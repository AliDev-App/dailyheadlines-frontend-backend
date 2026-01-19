// lib/models/news_item.dart
// This file defines the data model for a single news item.
// ignore_for_file: unused_import

import 'package:intl/intl.dart'; // Add this import for date formatting

class NewsItem {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final DateTime publishedAt;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.publishedAt,
  });

  // Factory constructor to create a NewsItem object from a JSON map.
  // The keys here must exactly match the column names returned by your SQL Server's GetAllNews procedure.
  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      // Ensure key names match your SQL Server column names (case-sensitive as returned by mssql package)
      id: json['Id'] as int? ?? 0, // Assuming 'Id' is returned as int
      title: json['Title'] as String? ?? 'No Title',
      description: json['Description'] as String? ?? 'No Description',
      imageUrl:
          json['ImageUrl'] as String? ??
          'https://placehold.co/600x400/CCCCCC/333333?text=No+Image', // Placeholder image
      author: json['Author'] as String? ?? 'Unknown Author',
      // Parse the date string. Ensure your SQL Server returns a valid ISO 8601 format or compatible.
      publishedAt:
          DateTime.tryParse(json['PublishedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
