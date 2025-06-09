import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import '../../../components/appBar.dart';
import '../../../components/color.dart';

class TextPreviewPage extends StatelessWidget {
  final String content;
  final TextStyle textStyle;
  final ValueChanged<String> onPost;

  const TextPreviewPage({
    super.key,
    required this.content,
    required this.textStyle,
    required this.onPost,
  });

  Future<void> _handlePost(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User is not logged in.")),
      );
      return;
    }

    final Timestamp now = Timestamp.now();

    final postData = {
      'userId': user.uid,
      'content': content,
      'createdAt': now,
      'type': 'text',
    };

    try {
      await FirebaseFirestore.instance.collection('posts').add(postData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Posted!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate =
        "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(
        2, '0')}.${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now
        .minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: AppColors.color24,
      appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(-1.0, 1.0),
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              -1, 0, 0, 0, 255,
              0, -1, 0, 0, 255,
              0, 0, -1, 0, 255,
              0, 0, 0, 1, 0,
            ]),
            child: Image.asset(
              'assets/images/icons/arrow.png',
              width: 30,
            ),
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
        title: const Text(
          "PREVIEW",
          style: TextStyle(
            fontFamily: 'Spooky',
            fontSize: 24,
            color: AppColors.color1,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 20),
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                final double maxContainerWidth = constraints.maxWidth -
                    48;
                const double lineHeight = 43;
                const double baseHeight = 35;
                const double maxHeightFactor = 0.5;

                final TextPainter textPainter = TextPainter(
                  text: TextSpan(
                    text: content,
                    style: const TextStyle(
                      fontFamily: 'Scyhler',
                      fontSize: 17,
                    ),
                  ),
                  textDirection: TextDirection.ltr,
                  maxLines: null,
                )
                  ..layout(maxWidth: maxContainerWidth);
                final int lineCount = (textPainter.size.height / lineHeight)
                    .ceil();
                final double calculatedHeight = baseHeight +
                    (lineCount * lineHeight);
                final double maxHeight = MediaQuery
                    .of(context)
                    .size
                    .height * maxHeightFactor;
                final double finalHeight = calculatedHeight.clamp(
                    baseHeight, maxHeight);
                return Center(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: finalHeight,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.star,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            content,
                            style: const TextStyle(
                              fontFamily: 'Scyhler',
                              color: Colors.white,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 16,
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            color: AppColors.color5,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Calculator',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: () => _handlePost(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coffee,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'GO!',
                  style: TextStyle(
                    fontFamily: 'Arcade',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
