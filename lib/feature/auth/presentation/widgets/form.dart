import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormWidget extends StatelessWidget {
  final List<Widget> childern;
  const FormWidget({super.key, required this.childern});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8.h,
      ),
      child: Column(
        children: childern,
      ),
    );
  }
}
