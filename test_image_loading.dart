import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(home: ImageLoadingTest()));
}

class ImageLoadingTest extends StatelessWidget {
  const ImageLoadingTest({super.key});

  @override
  Widget build(BuildContext context) {
    const String googleUrl =
        'https://lh3.googleusercontent.com/a/ACg8ocJCUGRBNtgrGYu0KN8lmftZP-x50XmPOY1g_G4ZhEQ3AfW8RIqn=s100';
    const String firebaseUrl =
        'https://lh3.googleusercontent.com/a/ACg8ocJCUGRBNtgrGYu0KN8lmftZP-x50XmPOY1g_G4ZhEQ3AfW8RIqn=s96-c';

    return Scaffold(
      appBar: AppBar(title: const Text('Image Loading Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Google Sign In URL:'),
            const SizedBox(height: 10),
            Image.network(
              googleUrl,
              width: 100,
              height: 100,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) {
                return Text('Error: $error');
              },
            ),
            const SizedBox(height: 20),
            const Text('Firebase URL:'),
            const SizedBox(height: 10),
            Image.network(
              firebaseUrl,
              width: 100,
              height: 100,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) {
                return Text('Error: $error');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _testUrl(googleUrl, 'Google');
                await _testUrl(firebaseUrl, 'Firebase');
              },
              child: const Text('Test URLs with HTTP'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _testUrl(String url, String name) async {
    try {
      debugPrint('Testing $name URL: $url');
      final response = await http.get(Uri.parse(url));
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Content Type: ${response.headers['content-type']}');
      debugPrint('Content Length: ${response.contentLength} bytes');
      debugPrint('');
    } catch (e) {
      debugPrint('Error testing $name URL: $e');
      debugPrint('');
    }
  }
}
