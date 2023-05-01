import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';


class KakaoMapScreen extends StatelessWidget {
  KakaoMapScreen({Key? key, required this.url}) : super(key: key);

  final String url;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final MethodChannel _channel = MethodChannel('openIntentChannel');

  // tweaked for webview version
  late final WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Color(0x00FFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel("Toaster", onMessageReceived: (JavaScriptMessage message) {
        _scaffoldMessengerKey.currentState
            ?.showSnackBar(SnackBar(content: Text(message.message)));
      });

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: SafeArea(
          child: WebViewWidget(
            controller: _controller,
          ),
        ),
      ),
    );
  }

  /// navigate to other app.
  /// It needs to test in real device
  Future<void> _iosNavigate(String url) async {
    if (url.contains('id304608425')) {
      // if kakao map exists open app
      if (!(await launchUrl(Uri.parse('kakaomap://open')))) {
        // if kakao map doesn't exist open market and navigate to app store
        await launchUrl(Uri.parse('https://apps.apple.com/us/app/id304608425'));
      }
    } else {
      // rest of them are just launching..
      await launchUrl(Uri.parse(url));
    }
  }
}
