import 'package:flutter/material.dart';
import 'package:social_media/components/button.dart';
import 'package:social_media/components/color.dart';
import 'package:social_media/components/squaretile.dart';
import 'package:social_media/components/textfield.dart';
import 'package:social_media/pages/bar/account.dart';
import 'package:social_media/pages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/pages/authservice.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  /////////////////////////////////////////////////////////////////////////////

  Future<void> signUserIn(BuildContext context) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please verify your email before logging in."),
          ),
        );
        await firebaseAuth.signOut();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login successful!")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccountPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Account not found.")));
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontFamily: 'Mania',
                        fontSize: 20,
                        color: AppColors.milk,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Button1(
                    text: 'SIGN IN',
                    width: 200,
                    onTap: () => signUserIn(context),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1.0, color: AppColors.milk),
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
                        child: Divider(thickness: 1.0, color: AppColors.milk),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () async {
                      var user = await AuthService().signInWithGoogle();
                      if (user != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Google login successful!"),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountPage(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Google login failed!")),
                        );
                      }
                    },
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: SquareTile(imagePath: 'assets/images/google.png'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(
                          fontFamily: 'Mania',
                          fontSize: 20,
                          color: AppColors.lemon,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Button1(
                        text: 'REGISTER',
                        width: 230,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
