import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/localization/app_localizations.dart';

class PanoramaScreen extends StatefulWidget {
  final String url;

  /// AppBar title; defaults to the localized "360° View".
  final String? title;

  /// When true the panorama is a street view the user can walk through:
  /// shows an "open in Google Maps" escape hatch for these coordinates.
  final bool allowNavigate;
  final double? latitude;
  final double? longitude;

  const PanoramaScreen({
    super.key,
    required this.url,
    this.title,
    this.allowNavigate = false,
    this.latitude,
    this.longitude,
  });

  @override
  State<PanoramaScreen> createState() => _PanoramaScreenState();
}

class _PanoramaScreenState extends State<PanoramaScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              '🔥 [360 View WebView Error] ${error.description} (Code: ${error.errorCode})',
            );
            debugPrint('URL failed: ${error.url}');
            if (mounted) setState(() => _hasError = true);
          },
          onHttpError: (HttpResponseError error) {
            debugPrint(
              '🔥 [360 View HTTP Error] Status Code: ${error.response?.statusCode}',
            );
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
    body, html { margin: 0; padding: 0; height: 100%; width: 100%; overflow: hidden; background-color: black; }
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

  Future<void> _openInGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps?q=${widget.latitude},${widget.longitude}&layer=c',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title?.isNotEmpty == true ? widget.title! : t.view360,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (widget.allowNavigate &&
              widget.latitude != null &&
              widget.longitude != null)
            IconButton(
              tooltip: t.streetViewOpen,
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              onPressed: _openInGoogleMaps,
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  t.view360NotAvailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
