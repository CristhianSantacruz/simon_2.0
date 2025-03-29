import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/screens/articles.dart';

import '../main.dart';
import '../models/article_model.dart';
import '../utils/colors.dart';
import 'article_component.dart';

class ArticleWidget extends StatefulWidget {
  final ArticleResponse articleResponseData;

  ArticleWidget({required this.articleResponseData});

  @override
  State<ArticleWidget> createState() => _ArticleWidgetState();
}

class _ArticleWidgetState extends State<ArticleWidget> {
  @override
  Widget build(BuildContext context) { 
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.articleResponseData.title.validate(),
              style: primarytextStyle(
                color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor,
              ),
            ).expand(),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                ArticleListScreen(
                  articleList: widget.articleResponseData.articleList.validate(),
                  title: widget.articleResponseData.title.validate(),
                ).launch(context);
              },
              icon: const Icon(Icons.arrow_forward_outlined, color: simon_finalPrimaryColor,size: 35,),
            ),
          ],
        ).paddingOnly(left: 16, right: 16, top: 0,bottom: 0),
       HorizontalList(
            spacing: 16,
            itemCount: widget.articleResponseData.articleList.validate().length,
            itemBuilder: (context, index) {
              final article = widget.articleResponseData.articleList.validate()[index];
              return ArticleComponent(
                articleResponseData: article,
                width: size.width * 0.30,
                height: size.height * 0.15,
              );
            },
          ).paddingOnly(bottom: 0),
      ],
    );
  }
}

/*SvgPicture.asset(
              notification_icon,
              color:
                  appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor,
              width: 22,
              height: 22,
            ).onTap(() {
              NotificationScreen().launch(context);
            }), */