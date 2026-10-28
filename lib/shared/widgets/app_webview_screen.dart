import 'package:flutter/material.dart';
import 'circle_icon_button.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_constants.dart';

class AppWebviewScreen extends StatefulWidget {
  final String title;
  final String url;

  const AppWebviewScreen({super.key, required this.title, required this.url});

  @override
  State<AppWebviewScreen> createState() => _AppWebviewScreenState();
}

class _AppWebviewScreenState extends State<AppWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Webview Error: ${error.description}');
          },
        ),
      );

    if (widget.url.contains('google.com/maps/embed')) {
      final htmlString =
          '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    body, html { margin: 0; padding: 0; height: 100%; width: 100%; overflow: hidden; background-color: white; }
    iframe { width: 100%; height: 100%; border: none; }
  </style>
</head>
<body>
  <iframe src="${widget.url}" allowfullscreen></iframe>
</body>
</html>
''';
      _controller.loadHtmlString(htmlString);
    } else {
      _controller.loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: CircleIconButton(
              icon: Icons.arrow_back_ios_new,
              size: 44,
              elevated: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
