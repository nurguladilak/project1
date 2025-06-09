import 'package:flutter/material.dart';
import '../../components/button.dart';
import '../../components/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/appBar.dart';
import '../../pages/drafts/textDrafts.dart';

class TextPage extends StatefulWidget {
  const TextPage({super.key});

  @override
  _TextPageState createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  TextEditingController tweetController = TextEditingController();

  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;

  TextStyle textStyle = TextStyle(
    color: Colors.black,
    fontFamily: 'Arcade',
    fontSize: 20,
  );

  final int maxCharacters = 300;
  String currentDateTime = '';

  void updateCurrentDateTime() {
    final now = DateTime.now();
    setState(() {
      currentDateTime =
          "${now.day}/${now.month}/${now.year} - ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    });
  }

  void _updateTextSize(String newText) {
    setState(() {
      tweetController.text = newText;
    });
  }

  void toggleBold() {
    setState(() {
      isBold = !isBold;
      textStyle = textStyle.copyWith(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      );
    });
  }

  void toggleItalic() {
    setState(() {
      isItalic = !isItalic;
      textStyle = textStyle.copyWith(
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      );
    });
  }

  void toggleUnderline() {
    setState(() {
      isUnderline = !isUnderline;
      textStyle = textStyle.copyWith(
        decoration:
            isUnderline ? TextDecoration.underline : TextDecoration.none,
      );
    });
  }

  void postTweet() async {
    String tweetContent = tweetController.text;
    if (tweetContent.isNotEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        final userId = user?.uid;

        if (userId == null) {
          print("User is not logged in.");
          return;
        }

        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        if (!userDoc.exists) {
          print("User document not found.");
          return;
        }

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        DocumentReference postRef =
            FirebaseFirestore.instance.collection('posts').doc();

        await postRef.set({
          'postId': postRef.id,
          'userId': userId,
          'nickname': userData['nickname'] ?? '',
          'profileUrl': userData['profileUrl'] ?? '',
          'text': tweetContent,
          'timestamp': FieldValue.serverTimestamp(),
          'contentTypes': 'text',
          'contentUrl': '',
          'likedBy': [],
          'likes': 0,
          'comments': 0,
          //'visibility': 'public',
        });

        tweetController.clear();
        print("Posted: $tweetContent");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Posted!")));

        Navigator.pop(context);
      } catch (e) {
        print("Error posting tweet: $e");
      }
    }
  }

  void goToDrafts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('drafts').add({
      'content': tweetController.text,
      'userId': userId,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Save as drafts")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color24,
      appBar: CustomAppBar(
        showBackButton: true,
        title: '',
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (tweetController.text.isNotEmpty) {
                    goToDrafts();
                  }
                },
                child: Text(
                  "Save drafts",
                  style: TextStyle(
                    color: AppColors.lemon,
                    fontSize: 18,
                    fontFamily: 'Trash',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 125),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TextDraftPage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Image.asset(
                    'assets/images/icons/wEditButton.png',
                    height: 32,
                    width: 32,
                    // color: AppColors.lemon,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.format_bold,
                        color: isBold ? Colors.blue : Colors.white,
                      ),
                      onPressed: toggleBold,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.format_italic,
                        color: isItalic ? Colors.blue : Colors.white,
                      ),
                      onPressed: toggleItalic,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.format_underline,
                        color: isUnderline ? Colors.blue : Colors.white,
                      ),
                      onPressed: toggleUnderline,
                    ),
                    Spacer(),
                    Button1(
                      text: 'GO!',
                      backgroundColor: AppColors.coffee,
                      textColor: Colors.white,
                      width: 120,
                      onTap:
                          tweetController.text.isNotEmpty &&
                                  tweetController.text.length <= maxCharacters
                              ? postTweet
                              : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.star,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      TextField(
                        controller: tweetController,
                        maxLines: null,
                        maxLength: maxCharacters,
                        onChanged: _updateTextSize,
                        decoration: InputDecoration(
                          hintText: tweetController.text.isEmpty ? "_" : null,
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontFamily: 'Schyler',
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontFamily: 'Sychler',
                          color: Colors.white,
                          fontStyle:
                              isItalic ? FontStyle.italic : FontStyle.normal,
                          fontWeight:
                              isBold ? FontWeight.bold : FontWeight.normal,
                          fontSize: 17,
                          decoration:
                              isUnderline
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                        ),
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ],
                  ),
                ),
                if (tweetController.text.length > maxCharacters) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Character limit reached! Cannot post more.",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
