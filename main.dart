import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Summary App',
      home: YouTubeSummaryScreen(),
    );
  }
}

class YouTubeSummaryScreen extends StatefulWidget {
  @override
  _YouTubeSummaryScreenState createState() => _YouTubeSummaryScreenState();
}

class _YouTubeSummaryScreenState extends State<YouTubeSummaryScreen> {
  final TextEditingController _controller = TextEditingController();
  String _summary = "";
  List<String> _keyframes = [];

  Future<void> _fetchSummaryAndKeyframes(String url) async {
    final response = await http.post(
      Uri.parse('http://<YOUR_BACKEND_URL>/process_video'),
      body: json.encode({'url': url}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _summary = data['summary'];
        _keyframes = List<String>.from(data['keyframes']);
      });
    } else {
      throw Exception('Failed to load summary and keyframes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Summary App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter YouTube URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _fetchSummaryAndKeyframes(_controller.text);
              },
              child: Text('Get Summary and Keyframes'),
            ),
            SizedBox(height: 20),
            Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_summary),
            SizedBox(height: 20),
            Text('Keyframes:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var keyframe in _keyframes) ...[
              Image.network(keyframe),
            ],
          ],
        ),
      ),
    );
  }
}
