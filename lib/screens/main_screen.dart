import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'webview_screen.dart';

class MainScreen extends StatefulWidget {
  final String initialPath;

  const MainScreen({
    super.key,
    this.initialPath = '/',
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final String _baseUrl = 'https://www.colognecraft.com';

  final List<InAppWebViewController?> _webControllers = List.filled(5, null);
  final List<GlobalKey<WebViewScreenState>> _webViewKeys = List.generate(
    5,
        (_) => GlobalKey<WebViewScreenState>(),
  );

  late final List<String> _tabUrls;

  @override
  void initState() {
    super.initState();
    _tabUrls = [
      '$_baseUrl${widget.initialPath}',
      '$_baseUrl/search',
      '$_baseUrl/pages/wishlist',
      '$_baseUrl/cart',
      '$_baseUrl/account',
    ];

    if (widget.initialPath.startsWith('/account')) {
      _currentIndex = 4;
    }
  }

  Future<bool> _onWillPop() async {
    final currentController = _webControllers[_currentIndex];
    if (currentController != null && await currentController.canGoBack()) {
      await currentController.goBack();
      return false;
    }
    return true;
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      final controller = _webControllers[index];
      if (controller != null) {
        controller.scrollTo(x: 0, y: 0, animated: true);
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(5, (index) {
            return WebViewScreen(
              key: _webViewKeys[index],
              initialUrl: _tabUrls[index],
              onControllerCreated: (controller) {
                _webControllers[index] = controller;
              },
            );
          }),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF1A1A1A).withValues(alpha: 0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Color(0xFF1A1A1A)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search, color: Color(0xFF1A1A1A)),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_outlined),
              selectedIcon: Icon(Icons.favorite, color: Color(0xFF1A1A1A)),
              label: 'Wishlist',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag, color: Color(0xFF1A1A1A)),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Color(0xFF1A1A1A)),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}