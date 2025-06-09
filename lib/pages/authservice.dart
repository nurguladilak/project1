import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //////////////////////////////////////////////////////////////////////////

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      if (uid.isEmpty) {
        log("User not logged in");
        return null;
      }

      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(uid).get();
      if (!userDoc.exists) {
        log("User document does not exist");
        return null;
      }

      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      log("Firestore read error: $e");
      return null;
    }
  }

  /////////////////////////////////////////////////////////////////////////////

  Future<Map<String, dynamic>> getUserDataForNewUser() async {
    try {
      DocumentReference counterDoc = firestore
          .collection('metadata')
          .doc('userCount');
      int registrationNumber = await firestore.runTransaction((
        transaction,
      ) async {
        final snapshot = await transaction.get(counterDoc);
        final newCount =
            (snapshot.exists ? snapshot.get('count') as int : 0) + 1;
        transaction.set(counterDoc, {'count': newCount});
        return newCount;
      });

      final String orderString = _formatRegistrationNumber(registrationNumber);
      final int randomCode = await generateRandomCode();

      return {"order": orderString, "randomNumber": randomCode};
    } catch (e) {
      log("Error generating user data: $e");
      rethrow;
    }
  }

  //////////////////////////////////////////////////////////////////////////////////

  Future<User?> signUpWithEmail(
    String email,
    String password,
    String nickname,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestoreWithTransaction(user.uid, nickname, email);
        await sendEmailVerification(user, context);
      }

      return user;
    } catch (e) {
      log("Email signup error: $e");
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await firestore.collection("users").doc(user.uid).get();
        if (!userDoc.exists) {
          await _saveUserToFirestoreWithTransaction(
            user.uid,
            user.displayName ?? "GoogleUser",
            user.email ?? "no-email@google.com",
          );
        }
      }
      return user;
    } catch (e) {
      log("Google sign-in error: $e");
      return null;
    }
  }

  //////////////////////////////////////////////////////////////////////////////

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print("No photo selected.");
      return null;
    }
  }

  //////////////////////////////////////////////////////////////////////////////

  Future<String> uploadImageToFirebase(XFile imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_pics/${FirebaseAuth.instance.currentUser!.uid}.jpg',
      );

      await storageRef.putFile(File(imageFile.path));

      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Photo upload error.: $e");
      rethrow;
    }
  }

  //////////////////////////////////////////////////////////////////////////////

  Future<void> updateUserProfile({
    required String userName,
    required String bio,
    File? imageFile,
    String? currentProfileImageUrl,
    String? code,
    required bool hasChangedCode,
    required String uid,
  }) async {
    try {
      String? newImageUrl = currentProfileImageUrl;

      if (imageFile != null) {
        newImageUrl = await uploadImageToFirebase(imageFile as XFile);
      }

      final Map<String, dynamic> updatedData = {
        'nickname': userName.trim(),
        'biography': bio.trim(),
        'profileImageUrl': newImageUrl,
      };

      if (!hasChangedCode && code != null && code.isNotEmpty) {
        final int? newCode = int.tryParse(code.trim());
        if (newCode != null && newCode >= 100000 && newCode <= 999999) {
          final duplicate =
              await firestore
                  .collection("users")
                  .where("randomNumber", isEqualTo: newCode)
                  .get();
          if (duplicate.docs.isEmpty) {
            updatedData['randomNumber'] = newCode;
            updatedData['codeChanged'] = true;
          } else {
            throw Exception('This code is already in use.');
          }
        } else {
          throw Exception('Enter a valid 6-digit number.');
        }
      }

      await firestore.collection('users').doc(uid).update(updatedData);
    } catch (e) {
      rethrow;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> _saveUserToFirestoreWithTransaction(
    String uid,
    String nickname,
    String email,
  ) async {
    try {
      await firestore.runTransaction((transaction) async {
        DocumentReference counterDoc = firestore
            .collection('metadata')
            .doc('userCount');

        DocumentSnapshot snapshot = await transaction.get(counterDoc);
        int currentCount = snapshot.exists ? snapshot.get('count') : 0;

        String orderString = _formatRegistrationNumber(currentCount + 1);
        int randomCode = await generateRandomCode();

        transaction.set(firestore.collection("users").doc(uid), {
          "biography": "",
          "email": email,
          "followers": 0,
          "followings": 0,
          "nickname": nickname,
          "order": orderString,
          "randomNumber": randomCode,
          "randomColor": Random().nextInt(0xffffff),
        });

        transaction.update(counterDoc, {'count': currentCount + 1});
      });

      log("User registered successfully.");
    } catch (e) {
      log("Error saving user to Firestore: $e");
    }
  }

  /////////////////////////////////////////////////////////////////////////////

  Future<void> sendEmailVerification(User user, BuildContext context) async {
    try {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification email has been sent.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending verification email: $e")),
      );
    }
  }

  /////////////////////////////////////////////////////////////////////////////

  String _formatRegistrationNumber(int number) {
    if (number % 10 == 1 && number % 100 != 11) return "${number}ST";
    if (number % 10 == 2 && number % 100 != 12) return "${number}ND";
    if (number % 10 == 3 && number % 100 != 13) return "${number}RD";
    return "${number}TH";
  }

  ///////////////////////////////////////////////////////////////////////////

  Future<int> generateRandomCode() async {
    int newCode;
    bool isUnique = false;

    do {
      newCode = 100000 + Random().nextInt(900000);

      QuerySnapshot query =
          await firestore
              .collection("users")
              .where("randomNumber", isEqualTo: newCode)
              .get();

      if (query.docs.isEmpty) {
        isUnique = true;
      }
    } while (!isUnique);

    return newCode;
  }

  /////////////////////////////////////////////////////////////////////////////

  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }
}
