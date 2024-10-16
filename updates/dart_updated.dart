import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Summary App',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        primarySwatch: Colors.indigo,
      ),
      home: const YouTubeSummaryScreen(),
    );
  }
}

class YouTubeSummaryScreen extends StatefulWidget {
  const YouTubeSummaryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _YouTubeSummaryScreenState createState() => _YouTubeSummaryScreenState();
}

class _YouTubeSummaryScreenState extends State<YouTubeSummaryScreen> {
  final TextEditingController _controller = TextEditingController();
  String _summary = "";
  List<String> _keyframes = [];

  Future<void> _fetchSummaryAndKeyframes(String url) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/process_video'),
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
      extendBodyBehindAppBar: true, // For fullscreen background
      appBar: AppBar(
        title: const Text('AIO: Note Taking App'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // Transparent app bar
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/backgroung.jpg'), // Add a background image here
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100), // Padding from app bar
                Text(
                  'Enter YouTube Video URL to Generate Summary and Keyframes',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        Colors.black, // Text color contrast with the background
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Paste YouTube URL here...',
                    prefixIcon:
                        const Icon(Icons.video_library, color: Colors.white),
                    filled: true,
                    fillColor: Colors.black54, // Translucent field background
                    hintStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                      color: Colors.white), // Ensure text input is visible
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _fetchSummaryAndKeyframes(_controller.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 43, 133, 86), // Set button background color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Get Summary and Keyframes',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16), // Ensure button text is visible
                  ),
                ),
                const SizedBox(height: 30),
                _summary.isNotEmpty
                    ? Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Summary',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _summary,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'Keyframes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              _keyframes.isNotEmpty
                                  ? SizedBox(
                                      height: 150,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _keyframes.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                  _keyframes[index],
                                                  width: 150,
                                                  fit: BoxFit.cover),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Image.asset(
                                          'assets/placeholder.jpg',
                                          width: 200), // Placeholder image
                                    ),
                            ],
                          ),
                        ),
                      )
                    : const Center(
                        child: Text(
                          'No data yet. Enter a YouTube URL to generate summary and keyframes.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
