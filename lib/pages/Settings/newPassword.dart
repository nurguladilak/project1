import 'package:flutter/material.dart';
import 'package:social_media/components/button.dart';
import 'package:social_media/components/color.dart';
import 'package:social_media/components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<NewPasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String errorMessage = "";

  Future<void> changePassword() async {
    setState(() {
      errorMessage = "";
    });

    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = "All fields are required!";
      });
      return;
    }

    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      setState(() {
        errorMessage = "Passwords do not match!";
      });
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPasswordController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully!")),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
      });
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    TextField1(
                      controller: currentPasswordController,
                      hintText: 'Current Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField1(
                      controller: newPasswordController,
                      hintText: 'New Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField1(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontFamily: 'Mania',
                            fontSize: 15,
                            color: AppColors.milk,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Button1(text: 'CHANGE PASSWORD', onTap: changePassword),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
