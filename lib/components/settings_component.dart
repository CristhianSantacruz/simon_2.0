
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/providers/vehicles_user_provider.dart';
import 'package:simon_final/screens/directions/directions_screen.dart';
import 'package:simon_final/screens/profiles/registered_profiles.dart';
//import 'package:simon_final/services/preferences_user.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
//import '../screens/settings_screen/about_us.dart';
import '../screens/settings_screen/help_center.dart';
//import '../screens/settings_screen/invite_friends.dart';
//import '../screens/settings_screen/notification.dart';
import '../screens/settings_screen/personal_info.dart';
//import '../screens/settings_screen/security.dart';
import '../utils/colors.dart';
import 'package:simon_final/screens/auth/new_sign_in.dart';

class SettingsComponent extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final String text;
  final bool showSwitch;
  final Widget? screen;

  final void Function(BuildContext)? onTap;

  const SettingsComponent({super.key, 
    required this.icon,
    required this.text,
    this.color,
    this.onTap,
    this.showSwitch = false,
    this.screen,
  });

  @override
  State<SettingsComponent> createState() => _SettingsComponentState();
}

class _SettingsComponentState extends State<SettingsComponent> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return GestureDetector(
        onTap: () => widget.onTap!(context),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  //padding: EdgeInsets.all(34),
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: simon_finalSecondaryColor),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      widget.icon,
                      color: simon_finalPrimaryColor,
                      size: 30,
                    ),
                  ),
                ),
                16.width,
                Text(
                  widget.text,
                  style: secondarytextStyle(
                      color: appStore.isDarkMode ? Colors.white : Colors.black),
                ).expand(),
                if (widget.showSwitch)
                  Switch.adaptive(
                    value: appStore.isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        appStore.setDarkMode(
                            value); // Manteniendo la lógica de cambio de tema
                      });
                      if (widget.screen != null) {
                        widget.screen!.launch(context);
                      }
                    },
                    activeTrackColor: simon_finalPrimaryColor,
                    inactiveTrackColor: context.scaffoldBackgroundColor,
                    activeColor: Colors.white,
                  )
              ],
            ),
            10.height,
          ],
        ),
      );
    });
  }
}

List<Widget> settingComponent(
        BuildContext context, int currentProfile, String phoneUser,int userId) =>
    [
      SettingsComponent(
          icon: Icons.person_outline,
          color: Colors.black,
          text: 'Información Personal',
          onTap: (context) {
            /*MessagesToast.showMessageInfo(
                "Los datos del usuario principal no se pueden editar");*/
            PersonalInfo(userId: userId,).launch(context);
          }),
      SettingsComponent(
          icon: Icons.location_on_outlined,
          text: "Direcciones",
          color: Colors.black,
          onTap: (context) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DirectionsUser()));
          }),
      SettingsComponent(
        icon: Icons.group_outlined,
        text: "Perfiles",
        color: Colors.black,
        onTap: (context) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const MyProfiles()));
        },
      ),
      /*SettingsComponent(
          icon: Icons.notifications_outlined,
          color: Colors.black,
          text: 'Notificación',
          onTap: (context) {
            NotificationSettings().launch(context);
          }),*/
      /*SettingsComponent(
          icon: Icons.security_outlined,
          color: Colors.black,
          text: 'Seguridad',
          onTap: (context) {
            SecuritySettings().launch(context);
          }),*/
      SettingsComponent(
          icon: appStore.isDarkMode
              ? Icons.dark_mode_outlined
              : Icons.dark_mode_outlined,
          color: Colors.black,
          text: 'Dark Mode',
          showSwitch: true),
      SettingsComponent(
          icon: Icons.people_outline,
          color: Colors.black,
          text: 'Invitar Amigos',
          onTap: (context) async {
            // _sendMessageToWhatsApp(phoneUser, "Unete a https://simonasistentelegal.com/");
            _shareMessage("Unete a https://simonasistentelegal.com/");
          }),
      SettingsComponent(
          icon: Icons.article_outlined,
          color: Colors.black,
          text: 'Centro de Ayuda',
          onTap: (context) {
            const HelpCenter().launch(context);
          }),
      SettingsComponent(
          icon: Icons.info_outline,
          color: Colors.black,
          text: 'Términos y condiciones',
          onTap: (context) {
            _launchURL(
                "https://simonasistentelegal.com/terminos-y-condiciones/");
          }),
      SettingsComponent(
          icon: Icons.logout_rounded,
          color: simon_finalPrimaryColor,
          text: 'Cerrar Sesión',
          onTap: (context) {
            context.read<UserProvider>().logout();
            context.read<VehicleProvider>().resetVehicleList();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const NewSignIn()),
              (Route<dynamic> route) => false,
            );
          }),
    ];

Future<void> _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication, // Abre el navegador externo
    );
  } else {
    throw 'No se puede abrir $url';
  }
}

Future<void> _shareMessage(String message) async {
  await Share.share(message);
}

