import 'package:flutter/material.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/feature/auth/presentation/widgets/login_widget.dart';
import 'package:meechat/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController(text: '');
  final TextEditingController passwordController =
      TextEditingController(text: '');
  bool isPasswordObsecure = true;
  bool isValidForm = false;

  final FirebaseService _firebaseService = FirebaseService();

  // handle empty field
  @override
  void initState() {
    super.initState();

    emailController.addListener(() => updateFormStatus());
    passwordController.addListener(() => updateFormStatus());
  }

  void updateFormStatus() {
    setState(() {
      isValidForm =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  // Handle eye
  void onPasswordSuffixTap() {
    setState(() {
      isPasswordObsecure = !isPasswordObsecure;
    });
  }

  void _onLogin(context) async {
    try {
      await _firebaseService.signInWithEmailPassword(
          emailController.text, passwordController.text);
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.main, (route) => false);
      await _firebaseService.setupFCM();
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('$e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LoginForm(
              emailController: emailController,
              passwordController: passwordController,
              isPasswordObsecure: isPasswordObsecure,
              onPasswordSuffixTap: onPasswordSuffixTap,
              isValidForm: isValidForm,
              onLogin: () {
                _onLogin(context);
              },
            ),
            const RegisterButton(),
          ],
        ),
      ),
    );
  }
}
