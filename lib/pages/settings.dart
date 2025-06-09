import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/components/color.dart';
import 'package:social_media/pages/login.dart';
import 'package:social_media/pages/Settings/profile.dart';
import 'package:social_media/pages/Settings/password.dart';
import 'package:social_media/pages/Settings/security.dart';
import 'package:social_media/pages/Settings/help.dart';
import 'package:social_media/pages/Settings/notifications.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> settingsOptions = [
    "PROFILE",
    "PASSWORD",
    "SECURITY",
    "NOTIFICATIONS",
    "HELP",
    "LOGOUT",
  ];

  final List<Widget> navigationPages = [
    AccountSetPage(),
    PasswordPage(),
    SecurityPage(),
    NotificationsPage(),
    HelpPage(),
    LoginPage(),
  ];

  List<String> randomCodes = [];

  final List<Color> textColors = [
    Color(0xFFFF00FF),
    Color(0xFFFF0000),
    Color(0xFFFFA500),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFAA),
  ];

  @override
  void initState() {
    super.initState();
    generateRandomCodes();
  }

  void generateRandomCodes() {
    Random random = Random();
    randomCodes = List.generate(
      settingsOptions.length,
      (_) => (random.nextInt(900000) + 100000).toString(),
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color24,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 15,
              child: IconButton(
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0),
                  child: Image.asset(
                    'assets/images/icons/wBackButton.png',
                    width: 30,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(settingsOptions.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        if (settingsOptions[index] == "LOGOUT") {
                          _signOut(context);
                        } else {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      navigationPages[index],
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              settingsOptions[index],
                              style: TextStyle(
                                color: textColors[index],
                                fontSize: 25,
                                fontFamily: 'Regular',
                              ),
                            ),
                            Text(
                              randomCodes[index],
                              style: TextStyle(
                                color: textColors[index],
                                fontSize: 25,
                                fontFamily: 'Regular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
