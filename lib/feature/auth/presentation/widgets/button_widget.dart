import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/utils/styles.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final bool isDisable;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.label,
    this.decoration,
    this.textStyle,
    this.isDisable = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisable ? null : onTap,
      child: Ink(
        width: double.infinity,
        height: 48.h,
        decoration: decoration ??
            BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDisable ? primaryColor.withOpacity(0.4) : primaryColor,
            ),
        child: Center(
          child: isLoading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Loading...',
                      style: textStyle ?? whiteTextStyle,
                    ),
                  ],
                )
              : Text(
                  label,
                  style: textStyle ?? whiteTextStyle,
                ),
        ),
      ),
    );
  }
}
