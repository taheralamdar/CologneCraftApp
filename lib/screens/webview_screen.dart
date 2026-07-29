import 'dart:io';
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
  bool isInitialLoad = true;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    currentUrl = widget.initialUrl;

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.black,
        backgroundColor: Colors.white,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  Future<bool> _handleExternalLink(Uri uri) async {
    final String scheme = uri.scheme;
    final String host = uri.host;

    // Phase 5: External Apps routing
    bool isWhatsApp = scheme == 'whatsapp' || host.contains('wa.me');
    bool isPhone = scheme == 'tel';
    bool isEmail = scheme == 'mailto';
    bool isMaps = scheme == 'geo' || host.contains('maps.google.com') || host.contains('maps.app.goo.gl');
    bool isInstagram = host.contains('instagram.com');
    bool isFacebook = host.contains('facebook.com') || host.contains('fb.com') || scheme == 'fb';

    if (isWhatsApp || isPhone || isEmail || isMaps || isInstagram || isFacebook) {
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
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
                // Session Persistence
                thirdPartyCookiesEnabled: true,
                sharedCookiesEnabled: true,
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
                  if (url != null) currentUrl = url.toString();
                });
              },
              onLoadStop: (controller, url) async {
                pullToRefreshController?.endRefreshing();
                setState(() {
                  isInitialLoad = false;
                  if (url != null) currentUrl = url.toString();
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
                    isInitialLoad = false;
                  });
                }
              },
              // Phase 7: Download support
              onDownloadStartRequest: (controller, downloadRequest) async {
                final uri = downloadRequest.url;
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),

            // Phase 4: Better Initial Loading UI
            if (isInitialLoad && !isError)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              ),

            // Subtle Linear Loading progress for page navigations
            if (!isInitialLoad && progress < 1.0 && !isError)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  color: Colors.black,
                  minHeight: 2.5,
                ),
              ),

            // Phase 4: Offline / Error Screen with Retry Button
            if (isError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Connection',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Please check your internet connection and try again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                isError = false;
                                isInitialLoad = true;
                              });
                              webViewController?.reload();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}