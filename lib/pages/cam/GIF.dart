import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/appBar.dart';
import '../../components/button.dart';
import '../../components/color.dart';
import '../drafts/gifDrafts.dart';

class GIFPage extends StatefulWidget {
  const GIFPage({super.key});

  @override
  _GifPageState createState() => _GifPageState();
}

class _GifPageState extends State<GIFPage> {
  File? _gifFile;
  bool isUploading = false;

  Future<void> pickGif() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && pickedFile.path.toLowerCase().endsWith('.gif')) {
      setState(() {
        _gifFile = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Only '.gif' files are allowed.")));
    }
  }

  Future<void> postGif() async {
    if (_gifFile == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final userData = userDoc.data() ?? {};

      final imageId = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child(
        "gif_posts/$imageId.gif",
      );

      await storageRef.putFile(_gifFile!);
      final gifUrl = await storageRef.getDownloadURL();

      final postRef = FirebaseFirestore.instance.collection('posts').doc();

      await postRef.set({
        'postId': postRef.id,
        'userId': user.uid,
        'nickname': userData['nickname'] ?? '',
        'profileImageUrl': userData['profileImageUrl'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'contentTypes': 'gif',
        'contentUrl': gifUrl,
        'likedBy': [],
        'likes': 0,
        'comments': 0,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("GIF Posted!")));
      Navigator.pop(context);
    } catch (e) {
      print("Error posting GIF: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void goToDrafts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || _gifFile == null) return;

    final storageRef = FirebaseStorage.instance.ref().child(
      "draft_gifs/${DateTime.now().millisecondsSinceEpoch}.gif",
    );
    await storageRef.putFile(_gifFile!);
    final gifUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance.collection('drafts').add({
      'userId': userId,
      'type': 'gif',
      'contentUrl': gifUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Saved as draft")));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final gifBox = Center(
      child: GestureDetector(
        onTap: pickGif,
        child: Container(
          width: screenSize.width * 0.8,
          height: screenSize.width * 0.8,
          decoration: BoxDecoration(
            color: AppColors.blue3,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              _gifFile != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 2.5,
                      child: Image.file(_gifFile!, fit: BoxFit.contain),
                    ),
                  )
                  : Center(
                    child: Icon(Icons.gif_box, color: Colors.white, size: 64),
                  ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.color24,
      appBar: CustomAppBar(
        showBackButton: true,
        title: '',
        actions: [
          GestureDetector(
            onTap: () {
              if (_gifFile != null) {
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
                MaterialPageRoute(builder: (context) => GifDraftsPage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset(
                'assets/images/icons/wEditButton.png',
                height: 32,
                width: 32,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            gifBox,
            const Spacer(),
            Button1(
              text: isUploading ? "UPLOADING..." : "GO!",
              backgroundColor:
                  _gifFile == null || isUploading
                      ? Colors.grey
                      : AppColors.coffee,
              textColor: Colors.white,
              width: 280,
              onTap: _gifFile == null || isUploading ? null : postGif,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
