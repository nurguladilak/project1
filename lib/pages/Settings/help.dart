import 'package:flutter/material.dart';
import '../../components/appBar.dart';
import '../../components/color.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color24,
      appBar: CustomAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          HelpTile(
            title: "How can I create an account?",
            description:
                "Tap the 'Sign Up' button on the home screen and fill out the required information.",
          ),
          HelpTile(
            title: "How can I reset my password?",
            description:
                "On the login screen, tap 'Forgot Password' and follow the instructions.",
          ),
          HelpTile(
            title: "What is Two-Factor Authentication?",
            description:
                "An extra layer of security that requires not only your password but also a verification code.",
          ),
          HelpTile(
            title: "How do I share content?",
            description:
                "Go to the post screen and choose to share a text, image, video, or GIF.",
          ),
          HelpTile(
            title: "Who can see my profile?",
            description:
                "You can control visibility settings from your Privacy section under Security settings.",
          ),
          HelpTile(title: "How can I report a problem?", description: ""),
          HelpTile(
            title: "What does #?????? code mean?",
            description:
                "The #?????? code is a unique 6-digit identifier assigned to each user when they create an account. You can share this code with others so they can easily find and follow your profile without searching by nickname.",
          ),
        ],
      ),
    );
  }
}

class HelpTile extends StatelessWidget {
  final String title;
  final String description;

  const HelpTile({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: AppColors.star,
      collapsedBackgroundColor: AppColors.star,
      collapsedIconColor: Colors.white,
      iconColor: Colors.purpleAccent,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Pixellium',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            description,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
