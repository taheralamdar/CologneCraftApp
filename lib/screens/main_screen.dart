import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'webview_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Controllers for each tab
  final List<InAppWebViewController?> _webControllers = List.filled(4, null);

  // Tab URLs
  final List<String> _urls = [
    'https://colognecraft.com/',              // Home
    'https://colognecraft.com/search',        // Search
    'https://colognecraft.com/cart',          // Cart
    'https://colognecraft.com/account',       // Account
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index && index == 0) {
      // 1. If tapping Home tab again, navigate back to the main homepage URL
      _webControllers[0]?.loadUrl(
        urlRequest: URLRequest(url: WebUri(_urls[0])),
      );
    } else if (index == 0) {
      // 1. If switching to Home tab, force load main homepage
      _webControllers[0]?.loadUrl(
        urlRequest: URLRequest(url: WebUri(_urls[0])),
      );
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final currentController = _webControllers[_selectedIndex];
        if (currentController != null && await currentController.canGoBack()) {
          currentController.goBack();
          return false;
        }
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(4, (index) {
            return WebViewScreen(
              initialUrl: _urls[index],
              onControllerCreated: (controller) {
                _webControllers[index] = controller;
              },
            );
          }),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1.0),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey.shade500,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}