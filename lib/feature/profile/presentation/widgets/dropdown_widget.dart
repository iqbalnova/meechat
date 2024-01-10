import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/utils/styles.dart';

class CustomDropdownFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const CustomDropdownFormField({
    Key? key,
    required this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: blackTextStyle,
          ),
          Container(
            margin: EdgeInsets.only(top: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xffD0D0D0),
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              onChanged: onChanged,
              items: items.map((
                item,
              ) {
                return DropdownMenuItem(
                  // key: UniqueKey(),
                  value: item,
                  child: Text(
                    item,
                    style: blackTextStyle,
                  ),
                );
              }).toList(),
              menuMaxHeight: 200,
              hint: Text(hintText,
                  style:
                      blackTextStyle.copyWith(color: const Color(0xff8A8A8A))),
              isExpanded: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
