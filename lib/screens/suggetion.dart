import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestionsPage extends StatefulWidget {
  final String companyName;

  const SuggestionsPage({Key? key, required this.companyName})
      : super(key: key);

  @override
  _SuggestionsPageState createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  late Future<List<String>> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    _suggestionsFuture = fetchSuggestions(widget.companyName);
  }

  Future<List<String>> fetchSuggestions(String companyName) async {
    try {
      // Get the document snapshot from Firestore
      DocumentSnapshot suggestionsDoc = await FirebaseFirestore.instance
          .collection('Suggestion_record')
          .doc(companyName)
          .collection('store')
          .doc('Suggestions')
          .get();

      // Initialize an empty list of suggestions
      List<String> suggestions = [];

      // Check if the document exists and contains the "suggestions" field
      if (suggestionsDoc.exists && suggestionsDoc.data() != null) {
        Map<String, dynamic> data =
            suggestionsDoc.data() as Map<String, dynamic>;
        if (data.containsKey('suggestions')) {
          // Retrieve the suggestions list
          List<dynamic> suggestionsList = data['suggestions'] as List<dynamic>;
          // Convert the list items to String and add them to the suggestions list
          suggestions = suggestionsList.map((item) => item.toString()).toList();
        }
      }

      // Return the list of suggestions
      return suggestions;
    } catch (e) {
      // Log the error and rethrow it
      print('Error fetching suggestions: $e');
      throw Exception('Failed to fetch suggestions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggestions for ${widget.companyName}'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<String>>(
        future: _suggestionsFuture,
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            List<String>? suggestions = snapshot.data;
            if (suggestions == null || suggestions.isEmpty) {
              return const Center(
                child: Text('No suggestions available'),
              );
            } else {
              return ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(suggestions[index]),
                    ),
                  );
                },
              );
            }
          } else {
            return const Center(
              child: Text('No suggestions available'),
            );
          }
        },
      ),
    );
  }
}
