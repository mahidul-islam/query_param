import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'dart:html' as html;
import 'package:path_provider/path_provider.dart';

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
  bool isCapturing = false;
  Uint8List? capturedImage;

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
      isCapturing = true;
    });

    try {
      // Find the RenderRepaintBoundary
      RenderRepaintBoundary boundary =
          _widgetKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Capture the image with good quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Convert to byte data in PNG format
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        // Convert to Uint8List which can be used with Image.memory
        final bytes = byteData.buffer.asUint8List();

        setState(() {
          // Store the captured image in the class property
          capturedImage = bytes;
        });

        print('Image captured successfully! ${bytes.length} bytes');
      }
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      setState(() {
        isCapturing = false;
      });
    }
  }

  Future<void> shareImage() async {
    if (capturedImage == null) {
      print('No image to share');
      return;
    }

    try {
      // For web platform specifically
      if (kIsWeb) {
        // Convert image bytes to blob
        final blob = html.Blob([capturedImage!], 'image/png');

        // Create a URL for the blob
        final url = html.Url.createObjectUrl(blob);

        // Create a temp file for sharing
        final xFile = XFile.fromData(
          capturedImage!,
          name: 'parameters.png',
          mimeType: 'image/png',
        );

        // Share options
        final shareResult = await Share.shareXFiles(
          [xFile],
          text: 'Check out these parameters I captured!',
          subject: 'Shared Parameters',
        );

        // Revoke the object URL to free memory
        html.Url.revokeObjectUrl(url);

        // Log the result
        print('Share result: ${shareResult.status}');
      } else {
        // For non-web platforms (if you need this in the future)
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/parameters.png');
        await file.writeAsBytes(capturedImage!);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Check out these parameters I captured!',
          subject: 'Shared Parameters',
        );
      }
    } catch (e) {
      print('Error sharing image: $e');

      // Fallback for browsers that don't support Web Share API
      _downloadImage();
    }
  }

  // Helper method for browsers without Web Share API support
  void _downloadImage() {
    // Convert image to data URL
    final base64 = base64Encode(capturedImage!);
    final dataUrl = 'data:image/png;base64,$base64';

    // Create a download link
    final anchor =
        html.AnchorElement(href: dataUrl)
          ..setAttribute(
            "download",
            "parameters-${DateTime.now().millisecondsSinceEpoch}.png",
          )
          ..click();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isCapturing ? null : _captureAndShare,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  icon:
                      isCapturing
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.save),
                  label: Text(isCapturing ? 'Saving...' : 'Capture Image'),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: shareImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  icon:
                      isCapturing
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.share),
                  label: Text('Share Image'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Add this to your build method after your existing UI
            if (capturedImage != null)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Captured Image Preview',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Image.memory(
                      capturedImage!,
                      width: 300, // You can adjust the size
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
