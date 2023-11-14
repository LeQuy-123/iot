import 'package:flutter/material.dart';
import 'package:iot_app/home_page.dart';
import 'package:iot_app/mqtt_page.dart';

class NavigationBottomTab extends StatefulWidget {
  const NavigationBottomTab({super.key});

  @override
  State<NavigationBottomTab> createState() => _NavigationBottomTabState();
}

class _NavigationBottomTabState extends State<NavigationBottomTab> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color(0xFF579FF1),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.cast_connected),
            label: 'Iot',
          ),
        
        ],
      ),
      body: <Widget>[
        const MyHomePage(title: 'Weather'),
        const MqttPage()
      ][currentPageIndex],
    );
  }
}
