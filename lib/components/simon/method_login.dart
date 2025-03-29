import 'package:flutter/material.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';


class MethodLogin extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Color? color;
  const MethodLogin({super.key, required this.text, required this.iconData, this.color=simon_finalPrimaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
        border: Border.all(color: simon_finalPrimaryColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData),
          5.width,
          Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w400))
        ],
      )
    );
  }
}