import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/text_styles.dart';

import '../main.dart';
import '../utils/colors.dart';

class NotificationSwitch extends StatefulWidget {
  final String title;

  NotificationSwitch(this.title);

  @override
  _NotificationSwitchState createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<NotificationSwitch> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.title,
          style: TextStyle(color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
        ).expand(),
        Switch(
          value: isSwitched,
          onChanged: (value) {
            setState(() {
              isSwitched = value;
            });
          },
          activeTrackColor: simon_finalPrimaryColor,
          inactiveTrackColor: context.scaffoldBackgroundColor,
          activeColor: Colors.white,
        )
      ],
    );
  }
}

//Notification Screen
List<String> titles = [
  'Notifícame cuando...',
  'Cambie el estado de mi impugnación',
  'Mi impugnación sea aceptada',
  'Hay comentarios en mi artículo',
  'Alguien me mencionó en un comentario',
  'A alguien le gustó mi comentario',
  'Hay actividad en mi cuenta',
  'Divisor',
  'Sistema',
  'Sistema de la aplicación',
  'Guía y consejos',
  'Participar en una encuesta'
];


List<Widget> notificationSwitch = titles.map((title) {
  if (title == 'Divider') {
    return Divider(color: dividerDarkColor,
      thickness: appStore.isDarkMode ? 0.3 :0.2,
    );
  } else if (title == 'Noifícame cuando...' || title == 'System') {
    return Text(title, style: notifiTitleTextStyle());
  } else {
    return NotificationSwitch(title);
  }
}).toList();

//Security Screen
List<String> securityTitles = [
  'Recuerdame',
  'Biometric ID',
  'Face ID',
  'SMS Authenticator',
  'Google Authenticator'
];

List<Widget> securityScreen = securityTitles.map((title) => NotificationSwitch(title)).toList();
