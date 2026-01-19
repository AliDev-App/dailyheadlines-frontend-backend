import 'package:dailyheadlines/view/userauth/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Assuming this import leads to your DomainNewsScreen for navigation
import 'package:dailyheadlines/domainside/news_delete.dart';

class DomainPostNewsScreen extends StatefulWidget {
  @override
  _DomainPostNewsScreenState createState() => _DomainPostNewsScreenState();
}

class _DomainPostNewsScreenState extends State<DomainPostNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _authorController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitNews() async {
    // Validate form input fields
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    // Set loading state to true to show CircularProgressIndicator
    setState(() => _isLoading = true);

    // Define the backend API URL. Adjust for emulator/device if not running on web.
    // For Flutter Web on Chrome, 'localhost' is usually fine.
    // For Android Emulator, use '10.0.2.2'.
    // For physical devices, use your machine's local IP address (e.g., '192.168.1.X').
    final url = Uri.parse("http://localhost:3000/add-news");

    try {
      // Send the POST request to the backend
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'imageUrl': _imageUrlController.text,
          'author': _authorController.text,
        }),
      );

      // Update UI state based on the response.
      // All UI updates, including controller clears, should be inside setState.
      setState(() {
        _isLoading = false; // Stop loading indicator

        // Decode the JSON response body
        final message = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message['message'] ?? '✅ News posted!')),
          );
          // Clear all text controllers after successful post
          _titleController.clear();
          _descriptionController.clear();
          _imageUrlController.clear();
          _authorController.clear();
          // NOTE: _formKey.currentState!.reset(); is removed as controller.clear()
          // is more direct for TextEditingControllers and reset() can sometimes
          // interfere or is more suited for forms using initialValue without controllers.
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message['error'] ?? '❌ Failed to post news'),
            ),
          );
          print(
            'Server error: ${response.statusCode} - ${response.body}',
          ); // For debugging
        }
      });
    } catch (e) {
      // Catch any network errors (e.g., server unreachable, no internet)
      setState(() {
        _isLoading = false; // Stop loading indicator even on error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Network error or failed to post news: $e')),
        );
      });
      print('Error submitting news: $e'); // Log error for debugging
    }
  }

  @override
  void dispose() {
    // Dispose all TextEditingControllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  // Helper widget to build consistent text form fields
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator:
            (value) =>
                value!.isEmpty
                    ? 'Please enter $label'
                    : null, // Simple validation
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true, // Make text field filled
          fillColor: Colors.grey[50], // Light grey background
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Floating Action Button to navigate to the news listing/delete screen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the DomainNewsScreen (where you might show news for deletion)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DomainNewsScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.arrow_forward, size: 30, color: Colors.white),
        tooltip: 'Go to News List (Domain)',
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
        backgroundColor: Colors.blueGrey[900], // Darker AppBar background
        title: const Text(
          '📢 Post News',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0, // No shadow for AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8, // More pronounced shadow for the card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // More rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField("Title", _titleController),
                    _buildTextField(
                      "Description",
                      _descriptionController,
                      maxLines: 3,
                    ),
                    _buildTextField("Image URL", _imageUrlController),
                    _buildTextField("Author", _authorController),
                    const SizedBox(height: 25), // Increased spacing
                    _isLoading
                        ? const CircularProgressIndicator() // Show loading indicator
                        : ElevatedButton.icon(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ), // White icon
                          label: const Text(
                            "Post News",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ), // White text, larger font
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.black, // Blue background for button
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30, // Increased horizontal padding
                              vertical: 16, // Increased vertical padding
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // Pill-shaped button
                            ),
                            elevation: 5, // Button shadow
                          ),
                          onPressed: _submitNews, // Call the submit method
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
