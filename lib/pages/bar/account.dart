import 'dart:math';
import 'package:flutter/material.dart';
import 'package:social_media/components/color.dart';
import 'package:social_media/components/bottom_nav_bar.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/pages/settings.dart';
import 'package:social_media/pages/cam/post.dart';
import 'package:social_media/pages/authservice.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}


class _AccountPageState extends State<AccountPage> {
  String userDisplayText = "Loading...";
  String userRandomCode = "";
  Color userRandomColor = Colors.white;
  String followersCount = "0";
  String followingCount = "0";
  bool isLoading = true;
  String bio = "";
  String? profileImageUrl;
  //XFile? _coverFile;
  //String? coverImageUrl;


  final RefreshController _refreshController = RefreshController();

  final AuthService _authService = AuthService();

  void _onRefresh() async {
    await fetchUserData();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = _authService.getCurrentUser();
      if (user != null) {
        String uid = user.uid;

        Map<String, dynamic>? userData = await _authService.getUserData(uid);

        if (userData != null) {
          setState(() {
            userDisplayText =
                "${userData['order']?.toString() ?? 'No Order'}  ${userData['nickname'] ?? 'Unknown'}";
            userRandomCode =
                "#${userData['randomNumber']?.toString() ?? '000000'}";
            followersCount = userData['followers']?.toString() ?? "0";
            followingCount = userData['followings']?.toString() ?? "0";
            userRandomColor = generateColorFromUID(uid);
            bio = userData['biography'] ?? '';
            profileImageUrl = userData['profileImageUrl'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          userDisplayText = "No user found.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userDisplayText = "Error: $e";
        isLoading = false;
      });
    }
  }

  Color generateColorFromUID(String uid) {
    final Random random = Random(uid.hashCode);
    return Color.fromARGB(
      255,
      100 + random.nextInt(156),
      100 + random.nextInt(156),
      100 + random.nextInt(156),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color24,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/cherry.png', width: 100),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) => SettingsPage(),
                transitionDuration: Duration.zero,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/icons/fireball.png',
              width: 35,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          SelectContentTypePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          header: CustomHeader(
            builder: (BuildContext context, RefreshStatus? mode) {
              if (mode == RefreshStatus.refreshing) {
                return Container(
                  alignment: Alignment.center,
                  height: 100.0,
                  child: Image.asset("assets/cat.gif", width: 200),
                );
              }
              ///glitch290-500
              ///cat100_200
              return Container(height: 80.0);
            },
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(color: AppColors.cherry),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -70,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.cherry,
                        border: Border.all(color: AppColors.color24, width: 2),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1),
                        child:
                            profileImageUrl != null
                                ? Image.network(
                                  profileImageUrl!,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  'assets/images/icons/cat.png',
                                  fit: BoxFit.cover,
                                ),
                        //Image.asset(
                        // 'assets/images/cat.png',
                        // alignment: Alignment.bottomLeft,
                        //),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                            userDisplayText,
                            style: const TextStyle(
                              fontFamily: "Pixellium",
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      const SizedBox(height: 5),
                      isLoading
                          ? Container()
                          : Text(
                            userRandomCode,
                            style: TextStyle(
                              fontFamily: 'Mania',
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: userRandomColor,
                            ),
                          ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                bio.isNotEmpty ? bio : "bio?",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "FOLLOWERS",
                            style: const TextStyle(
                              fontFamily: 'Calculator',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            followersCount,
                            style: const TextStyle(
                              fontFamily: 'Calculator',
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(
                      color: Colors.white,
                      thickness: 1,
                      width: 30,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "FOLLOWING",
                            style: const TextStyle(
                              fontFamily: 'Calculator',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            followingCount,
                            style: const TextStyle(
                              fontFamily: 'Calculator',
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(130),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.color18,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
    );
  }
}
