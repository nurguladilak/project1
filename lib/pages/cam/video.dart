import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import '../../components/appBar.dart';
import '../../components/button.dart';
import '../../components/color.dart';
import '../drafts/videoDrafts.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  File? _video;
  final TextEditingController _captionController = TextEditingController();
  final picker = ImagePicker();
  bool isUploading = false;
  VideoPlayerController? _videoController;

  Future<void> pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final selectedVideo = File(pickedFile.path);
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(selectedVideo)
        ..initialize().then((_) {
          setState(() {
            _video = selectedVideo;
          });
          _videoController!.setLooping(true);
          _videoController!.play();
        });
    }
  }

  Future<void> postVideo() async {
    if (_video == null) return;

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

      final videoId = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child(
        "post_videos/$videoId.mp4",
      );
      await storageRef.putFile(_video!);
      final videoUrl = await storageRef.getDownloadURL();

      final postRef = FirebaseFirestore.instance.collection('posts').doc();

      await postRef.set({
        'postId': postRef.id,
        'userId': user.uid,
        'nickname': userData['nickname'] ?? '',
        'profileImageUrl': userData['profileImageUrl'] ?? '',
        'text': _captionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'contentTypes': 'video',
        'contentUrl': videoUrl,
        'likedBy': [],
        'likes': 0,
        'comments': 0,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Video posted!")));

      Navigator.pop(context);
    } catch (e) {
      print("Error posting video: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> goToDrafts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || _video == null) return;

    try {
      final draftId = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child(
        "draft_videos/$draftId.mp4",
      );

      await storageRef.putFile(_video!);
      final videoUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('drafts').add({
        'userId': userId,
        'type': 'video',
        'contentUrl': videoUrl,
        'caption': _captionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Saved as draft")));
    } catch (e) {
      print("Error saving draft: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving draft")));
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final videoAndCaptionBox = Center(
      child: Container(
        width: screenSize.width * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.antras,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: pickVideo,
              child:
                  _video != null && _videoController!.value.isInitialized
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                      : Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.cherry,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.video_library,
                            size: 50,
                            color: Colors.white70,
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 12),
            TextField(
              enabled: _video != null,
              controller: _captionController,
              maxLines: null,
              decoration: InputDecoration(
                hintText:
                    _video == null ? "Add a video first" : "Write a caption...",
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ],
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
              if (_video != null) {
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
                MaterialPageRoute(builder: (context) => VideoDraftsPage()),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            videoAndCaptionBox,
            const Spacer(),
            Center(
              child: Button1(
                text: isUploading ? "UPLOADING..." : "POST",
                backgroundColor:
                    _video == null || isUploading
                        ? Colors.grey
                        : AppColors.coffee,
                textColor: Colors.white,
                width: 280,
                onTap: _video == null || isUploading ? null : postVideo,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
