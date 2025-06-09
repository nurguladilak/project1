import 'package:flutter/material.dart';
import 'package:social_media/pages/bar/account.dart';
import 'package:social_media/pages/bar/home.dart';
import 'package:social_media/pages/bar/surf.dart';
import 'color.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomePage();
        break;
      case 1:
        nextScreen = const SurfPage();
        break;
      case 2:
        nextScreen = const AccountPage();
        break;
      default:
        nextScreen = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/bar/home.png',
            width: 30,
            height: 30,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/bar/surf.png',
            width: 30,
            height: 30,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/bar/account.png',
            width: 30,
            height: 30,
          ),
          label: '',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.color24,
    );
  }
}
