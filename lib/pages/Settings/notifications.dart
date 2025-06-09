import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/appBar.dart';
import '../../components/color.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Map<String, bool> _notificationSettings = {
    "Likes": false,
    "Comments": false,
    "Follows": false,
    "Mentions": false,
    "Messages": false,
    "App Updates": false,
    "Security Alerts": false,
  };

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationSettings.forEach((key, _) {
        _notificationSettings[key] = prefs.getBool(key) ?? false;
      });
    });
  }

  Future<void> _saveNotificationSetting(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color24,
      appBar: CustomAppBar(),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _notificationSettings.length,
        itemBuilder: (context, index) {
          String key = _notificationSettings.keys.elementAt(index);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  key,
                  style: const TextStyle(
                    fontFamily: 'Digital',
                    //fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.color13,
                  ),
                ),
                Switch(
                  value: _notificationSettings[key]!,
                  activeColor: Colors.deepPurpleAccent,
                  onChanged: (bool value) {
                    setState(() {
                      _notificationSettings[key] = value;
                      _saveNotificationSetting(key, value);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
