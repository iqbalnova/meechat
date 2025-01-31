import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/feature/auth/presentation/widgets/button_widget.dart';
import 'package:meechat/feature/auth/presentation/widgets/form.dart';
import 'package:meechat/feature/auth/presentation/widgets/input_widget.dart';
import 'package:meechat/routes/app_routes.dart';
import 'package:meechat/utils/styles.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordObsecure;
  final VoidCallback onPasswordSuffixTap;
  final bool isValidForm;
  final VoidCallback onLogin;
  final bool isLoadingLogin;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordObsecure,
    required this.onPasswordSuffixTap,
    required this.isValidForm,
    required this.onLogin,
    this.isLoadingLogin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          Container(
            margin: EdgeInsets.only(top: 24.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masuk',
                  style: titleTextStyle,
                ),
                FormWidget(
                  childern: [
                    CustomTextFormField(
                      hintText: 'Contoh: johndee@gmail.com',
                      label: 'Email',
                      controller: emailController,
                    ),
                    CustomTextFormField(
                      hintText: 'Masukkan Password',
                      label: 'Password',
                      isObsecure: isPasswordObsecure,
                      controller: passwordController,
                      onTap: () {
                        onPasswordSuffixTap();
                      },
                    ),
                  ],
                ),
                CustomButton(
                  onTap: onLogin,
                  label: 'Masuk',
                  isDisable: !isValidForm,
                  isLoading: isLoadingLogin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Belum punya akun? ',
            style: blackTextStyle.copyWith(fontWeight: FontWeight.w400),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.register);
            },
            child: Text(
              'Daftar di sini',
              style: blackTextStyle.copyWith(
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}
