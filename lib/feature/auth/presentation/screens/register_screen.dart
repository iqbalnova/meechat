import 'package:flutter/material.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/feature/auth/presentation/widgets/register_widget.dart';
import 'package:meechat/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameController =
      TextEditingController(text: '');
  final TextEditingController lastNameController =
      TextEditingController(text: '');
  final TextEditingController emailController = TextEditingController(text: '');
  final TextEditingController passwordController =
      TextEditingController(text: '');
  bool isPasswordObsecure = true;
  bool isValidForm = false;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();

    firstNameController.addListener(() => updateFormStatus());
    lastNameController.addListener(() => updateFormStatus());
    emailController.addListener(() => updateFormStatus());
    passwordController.addListener(() => updateFormStatus());
  }

  void updateFormStatus() {
    setState(() {
      isValidForm = firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void _onRegister(context) async {
    try {
      await _firebaseService.registerWithEmailPassword(
          emailController.text,
          passwordController.text,
          firstNameController.text,
          lastNameController.text);
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.main, (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        // backgroundColor: Colors.transparent,
        // elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            RegisterForm(
              firstNameController: firstNameController,
              lasttNameController: lastNameController,
              emailController: emailController,
              passwordController: passwordController,
              isPasswordObsecure: isPasswordObsecure,
              isValidForm: isValidForm,
              onPasswordSuffixTap: () {
                setState(() {
                  isPasswordObsecure = !isPasswordObsecure;
                });
              },
              onRegister: () {
                _onRegister(context);
              },
            ),
            const LoginButton(),
          ],
        ),
      ),
    );
  }
}
