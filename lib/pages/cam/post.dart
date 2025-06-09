import 'package:flutter/material.dart';
import '../../components/color.dart';
import 'package:social_media/components/button.dart';

class SelectContentTypePage extends StatefulWidget {
  const SelectContentTypePage({super.key});

  @override
  _SelectContentTypePageState createState() => _SelectContentTypePageState();
}

class _SelectContentTypePageState extends State<SelectContentTypePage> {
  int selectedIndex = 0;

  List<String> options = ['Text', 'Picture', 'GIF', 'Video']; //'Drafts'];

  void navigateToSelectedPage() {
    switch (options[selectedIndex]) {
      case 'Text':
        Navigator.pushNamed(context, '/text');
        break;
      case 'Picture':
        Navigator.pushNamed(context, '/picture');
        break;
      case 'GIF':
        Navigator.pushNamed(context, '/gif');
        break;
      case 'Video':
        Navigator.pushNamed(context, '/video');
        break;
      //case 'Drafts':
      //Navigator.pushNamed(context, '/drafts');
      //break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color24,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 15,
              child: IconButton(
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      -1,
                      0,
                      0,
                      0,
                      255,
                      0,
                      -1,
                      0,
                      0,
                      255,
                      0,
                      0,
                      -1,
                      0,
                      255,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: Image.asset(
                      'assets/images/icons/arrow.png',
                      width: 30,
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < options.length; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = i;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20),

                            if (selectedIndex == i)
                              Image.asset(
                                'assets/images/icons/game.png',
                                width: 20,
                                height: 25,
                              )
                            else
                              const SizedBox(width: 32),

                            const SizedBox(width: 15),

                            Text(
                              options[i],
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Mania',
                                color:
                                    selectedIndex == i
                                        ? Colors.amber
                                        : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  Center(
                    child: Button1(
                      onTap: navigateToSelectedPage,
                      text: 'SELECT',
                      width: 180,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
