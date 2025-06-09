import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/pages/authservice.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/color.dart';
import '../../components/appBar.dart';
import '../../components/button.dart';
import '../../components/textfield.dart';

class AccountSetPage extends StatefulWidget {
  const AccountSetPage({super.key});

  @override
  State<AccountSetPage> createState() => _AccountSetPageState();
}

class _AccountSetPageState extends State<AccountSetPage> {
  String userDisplayText = "Loading...";
  String userRandomCode = "";
  Color userRandomColor = Colors.white;
  String? profileImageUrl;
  bool hasChangedCode = false;

  XFile? _imageFile;

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  XFile? _coverFile;
  String? coverImageUrl;


  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      final userData = userDoc.data()!;
      setState(() {
        userDisplayText = "${userData['order']}  ${userData['nickname']}";
        userRandomCode = "#${userData['randomNumber']}";
        userRandomColor = Color(userData['randomColor'] ?? 0xFFFFFFFF);
        profileImageUrl = userData['profileImageUrl'];
        _userNameController.text = userData['nickname'] ?? '';
        _bioController.text = userData['biography'] ?? '';
        hasChangedCode = userData['codeChanged'] == true;
        coverImageUrl = userData['coverImageUrl'];
      });
    } else {
      setState(() {
        userDisplayText = "User data not found.";
      });
    }
  }

  Future<void> _updateProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    String? newImageUrl = profileImageUrl;
    String? newCoverUrl = coverImageUrl;


    if (_imageFile != null) {
      newImageUrl = await _authService.uploadImageToFirebase(
        XFile(_imageFile!.path),
      );
    }

    if (_coverFile != null) {
      newCoverUrl = await _authService.uploadImageToFirebase(
        XFile(_coverFile!.path),
      );
    }

    final Map<String, dynamic> updatedData = {
      'nickname': _userNameController.text.trim(),
      'biography': _bioController.text.trim(),
      'profileImageUrl': newImageUrl,
      'coverImageUrl': newCoverUrl,

    };

    if (!hasChangedCode && _codeController.text
        .trim()
        .isNotEmpty) {
      final int? newCode = int.tryParse(_codeController.text.trim());
      if (newCode != null && newCode >= 100000 && newCode <= 999999) {
        final duplicate =
        await FirebaseFirestore.instance
            .collection("users")
            .where("randomNumber", isEqualTo: newCode)
            .get();
        if (duplicate.docs.isEmpty) {
          updatedData['randomNumber'] = newCode;
          updatedData['codeChanged'] = true;
          hasChangedCode = true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This code is already in use.')),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid 6-digit number.')),
        );
        return;
      }
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(updatedData);

    setState(() {
      profileImageUrl = newImageUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverFile = image;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: AppColors.color24,
      body:

      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _pickCoverImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.cherry,
                  image: _coverFile != null
                      ? DecorationImage(
                    image: FileImage(File(_coverFile!.path)),
                    fit: BoxFit.cover,
                  )
                      : (coverImageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(coverImageUrl!),
                    fit: BoxFit.cover,
                  )
                      : null),
                ),
                child: _coverFile == null && coverImageUrl == null
                    ? const Center(
                  child: Text(
                    "Tap to select cover photo",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : null,
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.cherry,
                    border: Border.all(color: AppColors.coffee, width: 1),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: _imageFile != null
                        ? Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.cover,
                    )
                        : (profileImageUrl != null
                        ? Image.network(
                      profileImageUrl!,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/images/cat.png',
                      fit: BoxFit.cover,
                    )),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),

            /// Nickname
            TextField1(
              controller: _userNameController,
              obscureText: false,
              hintText: 'Nickname',
            ),
            const SizedBox(height: 8),

            /// Biography
            TextField1(
              controller: _bioController,
              obscureText: false,
              hintText: 'Biography',
            ),
            const SizedBox(height: 8),

            if (!hasChangedCode)
              TextField1(
                controller: _codeController,
                obscureText: false,
                hintText: 'Change your 6-digit code (only once)',
              )
            else
              const Text(
                'You have already changed your code once.',
                style: TextStyle(color: Colors.grey),
              ),

            const SizedBox(height: 16),
            Button1(text: ('UPDATE'), onTap: _updateProfile, width: 200),
          ],
        ),
      ),
    );
  }
}