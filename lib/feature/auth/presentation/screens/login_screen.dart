import 'package:flutter/material.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/feature/auth/presentation/widgets/login_widget.dart';
import 'package:meechat/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController(text: '');
  final TextEditingController passwordController =
      TextEditingController(text: '');
  bool isPasswordObsecure = true;
  bool isValidForm = false;
  bool isLoading = false;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => updateFormStatus());
    passwordController.addListener(() => updateFormStatus());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void updateFormStatus() {
    setState(() {
      isValidForm =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  void onPasswordSuffixTap() {
    setState(() {
      isPasswordObsecure = !isPasswordObsecure;
    });
  }

  Future<void> _onLogin(context) async {
    if (isLoading) return; // Prevent multiple login attempts

    setState(() {
      isLoading = true;
    });

    try {
      await _firebaseService.signInWithEmailPassword(
        emailController.text,
        passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (route) => false,
      );

      await _firebaseService.setupFCM();
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing during loading
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
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
              isLoadingLogin: isLoading,
              onLogin: () => _onLogin(context),
            ),
            const RegisterButton(),
          ],
        ),
      ),
    );
  }
}
