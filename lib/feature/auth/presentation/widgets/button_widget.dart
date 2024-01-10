import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/utils/styles.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final Decoration? decoration;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.label,
    this.decoration,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        width: double.infinity,
        height: 48.h,
        decoration: decoration ??
            BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: primaryColor,
            ),
        child: Center(
            child: Text(
          label,
          style: textStyle ?? whiteTextStyle,
        )),
      ),
    );
  }
}
