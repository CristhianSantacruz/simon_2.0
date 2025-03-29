import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/text_styles.dart';
import '../../../main.dart';
class ShowMultasScreen extends StatelessWidget {
  const ShowMultasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new,
                    color: appStore.isDarkMode ? Colors.white : Colors.black)),
            surfaceTintColor: appStore.isDarkMode ? scaffoldDarkColor : context.scaffoldBackgroundColor,
            iconTheme: IconThemeData(color: appStore.isDarkMode ? Colors.white : Colors.black),
            title: Text(
              'Revisa tus mutlas',
              style: primarytextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
            ),
            backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : context.scaffoldBackgroundColor,
          ),
          body: Center(
            child: Text(
              'Pantalla de multas',
              style: primarytextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        );
      },
    );
  }
}
