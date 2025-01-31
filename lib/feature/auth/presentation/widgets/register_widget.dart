import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/feature/auth/presentation/widgets/button_widget.dart';
import 'package:meechat/feature/auth/presentation/widgets/form.dart';
import 'package:meechat/feature/auth/presentation/widgets/input_widget.dart';
import 'package:meechat/utils/styles.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lasttNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordObsecure;
  final VoidCallback onPasswordSuffixTap;
  final bool isValidForm;
  final VoidCallback onRegister;
  final bool isLoadingRegister;

  const RegisterForm({
    super.key,
    required this.firstNameController,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordObsecure,
    required this.onPasswordSuffixTap,
    required this.isValidForm,
    required this.onRegister,
    required this.lasttNameController,
    this.isLoadingRegister = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar',
                style: titleTextStyle,
              ),
              FormWidget(
                childern: [
                  CustomTextFormField(
                    hintText: 'Input Nama Depan',
                    label: 'Nama Depan',
                    isRequired: true,
                    controller: firstNameController,
                  ),
                  CustomTextFormField(
                    hintText: 'Input Nama Belakang',
                    label: 'Nama Belakang',
                    isRequired: true,
                    controller: lasttNameController,
                  ),
                  CustomTextFormField(
                    hintText: 'Contoh: johndee@gmail.com',
                    label: 'Email',
                    isRequired: true,
                    controller: emailController,
                  ),
                  CustomTextFormField(
                    hintText: 'Buat Password',
                    label: 'Buat Password',
                    isRequired: true,
                    isObsecure: isPasswordObsecure,
                    controller: passwordController,
                    onTap: onPasswordSuffixTap,
                  ),
                ],
              ),
              CustomButton(
                onTap: onRegister,
                label: 'Daftar',
                isDisable: !isValidForm,
                isLoading: isLoadingRegister,
              ),
              SizedBox(
                height: 20,
              ),
              const LoginButton()
            ],
          ),
        ]),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({
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
            'Sudah punya akun? ',
            style: blackTextStyle.copyWith(fontWeight: FontWeight.w400),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              'Masuk di sini',
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
