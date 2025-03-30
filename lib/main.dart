import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: QueryParamHandler());
  }
}

class QueryParamHandler extends StatefulWidget {
  const QueryParamHandler({super.key});

  @override
  State<QueryParamHandler> createState() => _QueryParamHandlerState();
}

class _QueryParamHandlerState extends State<QueryParamHandler> {
  Map<String, String> queryParams = {};

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('URL Parameters Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Query Parameters:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (queryParams.isEmpty)
              const Text('No parameters found')
            else
              ...queryParams.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
