import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/components/bottom_nav_bar.dart';
import 'package:social_media/components/color.dart';
import 'package:social_media/components/textfield.dart';

import '../../components/button.dart';
import 'needs/userProfile.dart';

class SurfPage extends StatefulWidget {
  const SurfPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SurfPage> {
  final TextEditingController _orderController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _randomCodeController = TextEditingController();

  List<Map<String, dynamic>> searchResults = [];

  Future<void> searchByOrder() async {
    String order = _orderController.text.trim();
    if (order.isEmpty) return;

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('order', isEqualTo: order)
              .get();

      setState(() {
        searchResults =
            querySnapshot.docs.map((doc) {
              return doc.data() as Map<String, dynamic>;
            }).toList();
      });
    } catch (e) {
      print("Error searching by order: $e");
    }
  }

  Future<void> searchByNickname() async {
    String nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) return;

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('nickname', isEqualTo: nickname)
              .get();

      setState(() {
        searchResults =
            querySnapshot.docs.map((doc) {
              return doc.data() as Map<String, dynamic>;
            }).toList();
      });
    } catch (e) {
      print("Error searching by nickname: $e");
    }
  }

  Future<void> searchByRandomCode() async {
    String randomCode = _randomCodeController.text.trim();
    if (randomCode.isEmpty) return;

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('randomNumber', isEqualTo: int.parse(randomCode))
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        String userId = querySnapshot.docs.first.id;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(userId: userId),
          ),
        );
      } else {
        print("User not found with the given random code");
      }
    } catch (e) {
      print("Error searching by random code: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.brownies, elevation: 0),
      body: Container(
        color: AppColors.color24,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 25,
                  child: TextField1(
                    controller: _orderController,
                    hintText: 'Order Number',
                    obscureText: false,
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  flex: 45,
                  child: TextField1(
                    controller: _nicknameController,
                    hintText: 'Nickname',
                    obscureText: false,
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  flex: 30,
                  child: TextField1(
                    controller: _randomCodeController,
                    hintText: '6 Digit Code',
                    obscureText: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Button1(
              text: "SEARCH",
              width: 180,
              onTap: () {
                if (_orderController.text.isNotEmpty) {
                  searchByOrder();
                } else if (_nicknameController.text.isNotEmpty) {
                  searchByNickname();
                } else if (_randomCodeController.text.isNotEmpty) {
                  searchByRandomCode();
                }
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  var user = searchResults[index];
                  return ListTile(
                    title: Text(user['nickname']),
                    subtitle: Text(user['bio'] ?? 'No bio available'),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        user['profileImageUrl'] ?? 'default_image_url',
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => UserProfilePage(userId: user['uid']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 1),
    );
  }
}
