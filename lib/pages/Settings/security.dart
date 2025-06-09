import 'package:flutter/material.dart';
import 'package:social_media/components/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final List<String> securityOptions = [
    "Two-Factor Authentication",
    "Login Mail verification",
    "Account Privacy",
    "Profile reveal",
    "Posts reveal",
    "Count reveal",
    "Nickname reveal",
    "Activation",
  ];

  Map<String, bool> switchValues = {
    "Two-Factor Authentication": false,
    "Login Mail verification": false,
    "Account Privacy": false,
    "Profile reveal": false,
    "Posts reveal": false,
    "Count reveal": false,
    "Nickname reveal": false,
    "Activation": false,
  };

  @override
  void initState() {
    super.initState();
    loadSwitchStates();
  }

  Future<void> loadSwitchStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var key in switchValues.keys) {
        switchValues[key] = prefs.getBool(key) ?? false;
      }
    });
  }

  Future<void> saveSwitchState(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color24,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 30,
              left: 15,
              child: IconButton(
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      -1,
                      0,
                      0,
                      0,
                      255,
                      0,
                      -1,
                      0,
                      0,
                      255,
                      0,
                      0,
                      -1,
                      0,
                      255,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: Image.asset(
                      'assets/images/icons/arrow.png',
                      width: 30,
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                      securityOptions.map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option,
                                style: const TextStyle(
                                  fontFamily: 'Digital',
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.color13,
                                ),
                              ),
                              Switch(
                                value: switchValues[option]!,
                                onChanged: (bool value) {
                                  setState(() {
                                    switchValues[option] = value;
                                    saveSwitchState(option, value);
                                  });
                                },
                                activeColor: AppColors.milk,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
