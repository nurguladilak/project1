import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String userName = '';
  String bio = '';
  String profileImageUrl = '';
  String randomCode = '';
  Color userRandomColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = userData['nickname'] ?? 'Unknown';
          bio = userData['bio'] ?? 'No bio available';
          profileImageUrl = userData['profileImageUrl'] ?? '';
          randomCode = userData['randomNumber'].toString();
          userRandomColor = _generateColorFromRandomCode(
            userData['randomNumber'],
          );
        });
      } else {
        setState(() {
          userName = 'User not found';
          bio = 'No bio available';
        });
      }
    } catch (e) {
      setState(() {
        userName = 'Error loading user data';
        bio = 'No bio available';
      });
    }
  }

  Color _generateColorFromRandomCode(int randomCode) {
    final random = Random(randomCode);
    return Color.fromARGB(
      255,
      (100 + random.nextInt(156)),
      (100 + random.nextInt(156)),
      (100 + random.nextInt(156)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userName\'s Profile'),
        backgroundColor: userRandomColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : const AssetImage('assets/images/default_profile.png')
                          as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              bio,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Text(
              'User Code: #$randomCode',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text('Edit Profile')),
          ],
        ),
      ),
    );
  }
}
