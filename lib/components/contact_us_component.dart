import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../utils/colors.dart';

class ContactusWidget extends StatelessWidget {
  final IconData? icon;
  final String text;
  final String? url;

  ContactusWidget({this.icon, required this.text,this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(url != null){
          _launchURL(url!);
        }
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(16)),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            16.width,
            Icon(icon, color: simon_finalPrimaryColor),
            16.width,
            Text(text, style: TextStyle(color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor)),
          ],
        ),
      ).paddingSymmetric(vertical: 16, horizontal: 16),
    );
  }
}

void _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'No se puede abrir $url';
  }
}
