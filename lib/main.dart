import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

//import 'package:social_media/components/pixelbox.dart';
import 'package:social_media/pages/bar/account.dart';

//import 'package:social_media/pages/login.dart';
import 'package:social_media/pages/cam/text.dart';
import 'package:social_media/pages/cam/picture.dart';
import 'package:social_media/pages/cam/GIF.dart';
import 'package:social_media/pages/cam/video.dart';

//import 'package:social_media/pages/cam/post.dart';
import 'package:social_media/metadata.dart';
import 'package:social_media/pages/mailverification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  await requestPermissions();
  await ensureMetadataExists();
  runApp(const MyApp());
}

Future<void> requestPermissions() async {
  try {
    var cameraStatus = await Permission.camera.request();
    var photosStatus = await Permission.photos.request();
    var storageStatus = await Permission.storage.request();

    if (cameraStatus.isPermanentlyDenied ||
        photosStatus.isPermanentlyDenied ||
        storageStatus.isPermanentlyDenied) {
      print("One or more permissions are permanently denied.");
    }
  } catch (e) {
    print("Error requesting permissions: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '*',
      debugShowCheckedModeBanner: false,
      home: const AccountPage(),
      routes: {
        '/text': (context) => TextPage(),
        '/picture': (context) => PicturePage(),
        '/gif': (context) => GIFPage(),
        '/video': (context) => VideoPage(),
        //'/drafts': (context) =>  DraftsPage(),
        '/verify': (context) => MailVerificationPage(),
      },
    );
  }
}
