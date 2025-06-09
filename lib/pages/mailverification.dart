import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/appBar.dart';
import '../components/button.dart';
import '../components/color.dart';
import 'login.dart';

class MailVerificationPage extends StatefulWidget {
  const MailVerificationPage({super.key});

  @override
  State<MailVerificationPage> createState() => _MailVerificationPageState();
}

class _MailVerificationPageState extends State<MailVerificationPage> {
  bool isVerified = false;
  bool isSending = false;
  late final User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _checkVerificationLoop();
  }

  Future<void> _checkVerificationLoop() async {
    while (!isVerified) {
      await Future.delayed(const Duration(seconds: 10));
      await currentUser?.reload();
      setState(() {
        isVerified = currentUser?.emailVerified ?? false;
      });

      if (isVerified && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => isSending = true);
    try {
      await currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email has been resent.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color24,
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Text(
                  "Verification email has been sent! Please check your email.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Mania',
                    color: AppColors.color7,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "After verifying your email, this screen will close automatically.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Mania',
                    color: AppColors.color21,
                  ),
                ),
                const SizedBox(height: 50),

                Button1(
                  text: isSending ? 'Sending...' : 'RESEND',
                  width: 180,
                  onTap: isSending ? null : _resendVerificationEmail,
                  backgroundColor: AppColors.purp,
                  textColor: AppColors.brownies,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
