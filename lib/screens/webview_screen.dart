import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatefulWidget {
  final String initialUrl;
  final Function(InAppWebViewController)? onControllerCreated;

  const WebViewScreen({
    super.key,
    required this.initialUrl,
    this.onControllerCreated,
  });

  @override
  State<WebViewScreen> createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;

  double progress = 0;
  bool isError = false;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    currentUrl = widget.initialUrl;

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.black,
      ),
      onRefresh: () async {
        if (webViewController != null) {
          webViewController!.reload();
        }
      },
    );
  }

  Future<bool> _handleExternalLink(Uri uri) async {
    final String scheme = uri.scheme;
    final String host = uri.host;

    // Native app external schemes or specific social platforms
    bool isExternalScheme = scheme == 'whatsapp' ||
        scheme == 'tel' ||
        scheme == 'mailto' ||
        scheme == 'geo' ||
        host.contains('instagram.com') ||
        host.contains('facebook.com') ||
        host.contains('wa.me');

    if (isExternalScheme) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (!isError)
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
                pullToRefreshController: pullToRefreshController,
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: true,
                  mediaPlaybackRequiresUserGesture: false,
                  javaScriptEnabled: true,
                  cacheEnabled: true,
                  domStorageEnabled: true,
                  supportZoom: false,
                  transparentBackground: false,
                  allowsBackForwardNavigationGestures: true,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  if (widget.onControllerCreated != null) {
                    widget.onControllerCreated!(controller);
                  }
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url;
                  if (uri != null && await _handleExternalLink(uri)) {
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    isError = false;
                    if (url != null) {
                      currentUrl = url.toString();
                    }
                  });
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController?.endRefreshing();
                  setState(() {
                    if (url != null) {
                      currentUrl = url.toString();
                    }
                  });
                },
                onProgressChanged: (controller, progressPercentage) {
                  if (progressPercentage == 100) {
                    pullToRefreshController?.endRefreshing();
                  }
                  setState(() {
                    progress = progressPercentage / 100;
                  });
                },
                onReceivedError: (controller, request, error) {
                  pullToRefreshController?.endRefreshing();
                  if (request.isForMainFrame ?? true) {
                    setState(() {
                      isError = true;
                    });
                  }
                },
              ),
            if (progress < 1.0 && !isError)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: Colors.black,
                minHeight: 2.5,
              ),
            if (isError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Connection Error',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your internet connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isError = false;
                          });
                          webViewController?.reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
    );
  }
}