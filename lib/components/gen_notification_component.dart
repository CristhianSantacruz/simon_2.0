import 'package:flutter/material.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/notification_model.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class GenNotificationComponent extends StatelessWidget {
  final NotificationModel genNotificationData;

  GenNotificationComponent({required this.genNotificationData});

  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      title: genNotificationData.alertTitle ?? 'Notificación',
      text: genNotificationData.alertText ?? 'No hay texto',
      updatedAt: genNotificationData.updatedAt,
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String text;
  final DateTime updatedAt;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.text,
    required this.updatedAt,
  }) : super(key: key);

  String getFormattedDate(DateTime date) {
    final timeAgo = timeago.format(date, locale: 'es');
    final formattedTime = DateFormat('hh:mm a').format(date);
    return "$timeAgo · $formattedTime";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: simon_finalPrimaryColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment
                .start, // Alinea los elementos en la parte superior
            children: [
              const CircleAvatar(
                backgroundColor: simon_finalPrimaryColor,
                child: Icon(Icons.notifications, color: Colors.white),
              ),
              10.width,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: appStore.isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1, // Limita el título a una sola línea
                        overflow: TextOverflow
                            .ellipsis, // Agrega "..." si el texto es muy largo
                      ),
                      3.height,
                      Text(                       
                        text,
                        style: TextStyle(
                          color: appStore.isDarkMode ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.justify,
                      ).paddingRight(8),
                      10.height,
                      Text(
                        getFormattedDate(updatedAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ).paddingSymmetric(horizontal: 8),
    );
  }
}
