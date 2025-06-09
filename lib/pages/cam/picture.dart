import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media/components/appBar.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:image/image.dart' as img;
import '../../components/color.dart';
import '../../components/button.dart';
import '../drafts/picDrafts.dart';

class PicturePage extends StatefulWidget {
  const PicturePage({super.key});

  @override
  _PicturePageState createState() => _PicturePageState();
}

Color getInvertedColor(Color color) {
  return Color.fromARGB(
    color.alpha,
    255 - color.red,
    255 - color.green,
    255 - color.blue,
  );
}

class _PicturePageState extends State<PicturePage> {
  File? _image;
  final TextEditingController _captionController = TextEditingController();
  final picker = ImagePicker();

  bool isUploading = false;
  Color? dominantColor;
  double? _imageAspectRatio;

  void goToDrafts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || _image == null) return;

    final storageRef = FirebaseStorage.instance.ref().child(
      "draft_images/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    await storageRef.putFile(_image!);
    final imageUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance.collection('drafts').add({
      'content': _captionController.text,
      'userId': userId,
      'type': 'picture',
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Saved as draft")));
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final selectedImage = File(pickedFile.path);
      final imageBytes = await selectedImage.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage != null) {
        setState(() {
          _imageAspectRatio = decodedImage.width / decodedImage.height;
        });
      }
      await analyzeImageColor(selectedImage);
      setState(() {
        _image = selectedImage;
        _captionController.clear();
      });
    }
  }

  Future<void> analyzeImageColor(File imageFile) async {
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      FileImage(imageFile),
      maximumColorCount: 10,
    );

    setState(() {
      dominantColor = paletteGenerator.dominantColor?.color ?? AppColors.blue3;
    });
  }

  Future<void> postImage() async {
    if (_image == null) return;

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
        "post_images/$imageId.jpg",
      );
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();

      final postRef = FirebaseFirestore.instance.collection('posts').doc();

      await postRef.set({
        'postId': postRef.id,
        'userId': user.uid,
        'nickname': userData['nickname'] ?? '',
        'profileImageUrl': userData['profileImageUrl'] ?? '',
        'text': _captionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'contentTypes': 'picture',
        'contentUrl': imageUrl,
        'likedBy': [],
        'likes': 0,
        'comments': 0,
        'dominantColor': {
          'r': dominantColor?.red ?? 0,
          'g': dominantColor?.green ?? 0,
          'b': dominantColor?.blue ?? 0,
        },
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Posted!")));

      Navigator.pop(context);
    } catch (e) {
      print("Error posting picture: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final imageAndCaptionBox = Center(
      child: Container(
        width: screenSize.width * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dominantColor ?? AppColors.blue3,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _image != null
                ? GestureDetector(
                  onTap: pickImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: AspectRatio(
                      aspectRatio: _imageAspectRatio ?? 1,
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ),
                )
                : GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.cherry,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_photo_alternate,
                        size: 50,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 12),
            TextField(
              enabled: _image != null,
              controller: _captionController,
              maxLines: null,
              decoration: InputDecoration(
                hintText:
                    _image == null
                        ? "Add an image first"
                        : "Write a caption...",
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor:
                    _image == null
                        ? AppColors.cherry
                        : getInvertedColor(dominantColor ?? AppColors.blue3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              style: TextStyle(
                color: dominantColor ?? Colors.black,
                fontSize: 16,
              ),
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
              if (_image != null) {
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
                MaterialPageRoute(builder: (context) => PicDraftsPage()),
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                imageAndCaptionBox,
                const Spacer(),
                Center(
                  child: Button1(
                    text: isUploading ? "UPLOADING..." : "GO!",
                    backgroundColor:
                        _image == null || isUploading
                            ? Colors.grey
                            : AppColors.coffee,
                    textColor: Colors.white,
                    width: 280,
                    onTap: _image == null || isUploading ? null : postImage,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
