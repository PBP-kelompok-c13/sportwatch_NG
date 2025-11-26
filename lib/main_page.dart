import 'package:flutter/material.dart';
import 'package:sportwatch_ng/home.dart';
import 'package:sportwatch_ng/portal_berita/news_page.dart';
import 'package:sportwatch_ng/scoreboard/screens/scoreboard_landing_page.dart';
import 'package:sportwatch_ng/shop/screens/shop_landing_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    NewsPage(),
    Text(
      'Halaman Placeholder',
    ),
    ScoreboardLandingPage(),
    ShopPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
                Icons.home,
              color: Colors.black,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper, color: Colors.black,),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.black,),
            label: 'Placeholder',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.scoreboard, color: Colors.black,),
              label: 'Scoreboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout, color: Colors.black,),
            label: 'Shop',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent[400],
        onTap: _onItemTapped,
      ),
    );
  }
}
