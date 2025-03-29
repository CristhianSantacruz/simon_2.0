import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/settings_notification_switch.dart';

import '../../components/text_styles.dart';
import '../../main.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_ios, color: Colors.black)),
          surfaceTintColor: appStore.isDarkMode ? scaffoldDarkColor : context.scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: appStore.isDarkMode ? Colors.white : Colors.black),
          centerTitle: true,
          title: Text(
            'Notification',
            style: primarytextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
          ),
          backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : context.scaffoldBackgroundColor,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: notificationSwitch,
          ),
        ),
      );
    });
  }
}
