import 'package:flutter/material.dart';
import 'package:social_media/components/button.dart';
import 'package:social_media/components/color.dart';
import 'package:social_media/components/squaretile.dart';
import 'package:social_media/components/textfield.dart';
import 'package:social_media/pages/login.dart';
import 'package:social_media/pages/authservice.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nickNameController = TextEditingController();
  final AuthService _authService = AuthService();

  /////////////////////////////////////////////////////////////////////////////

  Future<void> registerUser(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String nickname = nickNameController.text.trim();
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match, please check again!'),
        ),
      );
      return;
    }

    if (nickname.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields completely.')),
      );
      return;
    }

    try {
      await _authService.signUpWithEmail(email, password, nickname, context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful! Please check your email."),
        ),
      );
      Navigator.pushReplacementNamed(context, "/verify");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  /////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue2,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  TextField1(
                    controller: nickNameController,
                    hintText: 'Nickname',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  TextField1(
                    controller: emailController,
                    obscureText: false,
                    hintText: 'E-mail',
                  ),
                  const SizedBox(height: 10),
                  TextField1(
                    controller: passwordController,
                    obscureText: true,
                    hintText: 'Password',
                  ),
                  const SizedBox(height: 10),
                  TextField1(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontFamily: 'Mania',
                          fontSize: 15,
                          color: AppColors.milk,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1.9, color: AppColors.milk),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            fontFamily: 'Mania',
                            fontSize: 20,
                            color: AppColors.milk,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 1.9, color: AppColors.milk),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: SquareTile(imagePath: 'assets/images/google.png'),
                  ),
                  const SizedBox(height: 35),
                  Button1(text: 'REGISTER', onTap: () => registerUser(context)),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
