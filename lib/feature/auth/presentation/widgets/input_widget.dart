import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/utils/styles.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool isObsecure;
  final VoidCallback? onTap;
  final int? maxLines;
  final TextInputType keyboardType;
  final bool isRequired;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.controller,
    this.isObsecure = false,
    this.onTap,
    required this.label,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: blackTextStyle, // Gaya teks utama
                ),
                if (isRequired) // Tambahkan bintang merah jika isRequired = true
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red), // Warna merah untuk *
                  ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xffD0D0D0),
                  ),
                  borderRadius: BorderRadius.circular(16.r)),
              child: Row(
                children: [
                  // _buildPrefix(),
                  _buildTextFormField(),
                  onTap != null ? _buildObsecureCanceler() : const SizedBox(),
                ],
              )),
        ],
      ),
    );
  }

  // Widget _buildPrefix() {
  //   return Container(
  //     margin: EdgeInsets.only(right: 12.w),
  //     child: Icon(
  //       prefixIcons,
  //       size: 24.w,
  //       color: whiteColor.withOpacity(0.4),
  //     ),
  //   );
  // }

  Widget _buildTextFormField() {
    return Expanded(
      child: TextFormField(
        controller: controller,
        obscureText: isObsecure,
        style: blackTextStyle.copyWith(
          fontWeight: medium,
        ),
        maxLines: maxLines,
        decoration: InputDecoration.collapsed(
          hintText: hintText,
          // hintStyle: whiteTextStyle.copyWith(
          //     fontWeight: light, color: whiteColor.withOpacity(0.4)),
        ),
        keyboardType: keyboardType,
        inputFormatters: const [],
      ),
    );
  }

  Widget _buildObsecureCanceler() {
    return Container(
      margin: EdgeInsets.only(left: 12.w),
      child: InkWell(
        onTap: onTap,
        child: Icon(
          isObsecure
              ? Icons.visibility_off_rounded
              : Icons.remove_red_eye_rounded,
          color: const Color(0xff8A8A8A),
          size: 24.w,
        ),
      ),
    );
  }
}
