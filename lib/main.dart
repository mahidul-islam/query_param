import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: QueryParamHandler(),
    );
  }
}

class QueryParamHandler extends StatefulWidget {
  const QueryParamHandler({super.key});

  @override
  State<QueryParamHandler> createState() => _QueryParamHandlerState();
}

class _QueryParamHandlerState extends State<QueryParamHandler> {
  Map<String, String> queryParams = {};
  final GlobalKey _widgetKey = GlobalKey();
  bool isSharing = false;

  @override
  void initState() {
    super.initState();
    _parseQueryParams();
  }

  void _parseQueryParams() {
    // Get the current URL
    final Uri uri = Uri.parse(Uri.base.toString());

    // Extract query parameters
    setState(() {
      queryParams = uri.queryParameters;
    });

    // You can also handle specific parameters
    if (queryParams.containsKey('key')) {
      print('Key parameter: ${queryParams['key']}');
      // Process the value as needed
    }
  }

  Future<void> _captureAndShare() async {
    setState(() {
      isSharing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isSharing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Parameters Demo'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The widget to be captured for sharing
            RepaintBoundary(
              key: _widgetKey,
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Query Parameters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (queryParams.isEmpty)
                      const Text(
                        'No parameters found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      ...queryParams.entries.map(
                        (entry) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${entry.key}:',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: isSharing ? null : _captureAndShare,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              icon:
                  isSharing
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.share),
              label: Text(isSharing ? 'Sharing...' : 'Share Parameters'),
            ),
          ],
        ),
      ),
    );
  }
}
