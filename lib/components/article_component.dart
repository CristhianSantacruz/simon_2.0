import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simon_final/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/text_styles.dart';

import '../models/article_model.dart';
//import '../screens/article_detail.dart';
import '../utils/colors.dart';

class ArticleComponent extends StatefulWidget {
  final ArticleModel articleResponseData;
  final double? width;
  final double? height;
  // final Icon? iconRepresentation;

  const ArticleComponent(
      {super.key, required this.articleResponseData, this.width, this.height});

  @override
  State<ArticleComponent> createState() => _ArticleComponentState();
}

class _ArticleComponentState extends State<ArticleComponent> {
  //bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
  onTap: () {
    if (widget.articleResponseData.routeName != null &&
        widget.articleResponseData.routeName!.isNotEmpty) {
      Navigator.pushNamed(context, widget.articleResponseData.routeName!);
    }
  },
  child: Stack(
    children: [
      Card(
        color: appStore.isDarkMode ? simonGris : Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15),bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15)),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          width: widget.width,
          height: widget.height,
          decoration: const BoxDecoration(
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
             widget.articleResponseData.isImagePng == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),  // Asegura que el contorno sea redondo
                  child: Container(
                    width: widget.width! * 0.5,  
                    height: widget.width! * 0.5,  // Ajusta el tamaño del círculo
                    decoration:  BoxDecoration(
                      color: appStore.isDarkMode ?simon_finalPrimaryColor : simonGris,  // Color de fondo gris
                      shape: BoxShape.circle,  // Forma circular
                    ),
                    child: Center(
                      child: Image.asset(
                        widget.articleResponseData.imageAsset.validate(),
                        color:appStore.isDarkMode ? Colors.white : simon_finalPrimaryColor,
                        width: widget.width! * 0.28,  // Ajusta el tamaño de la imagen
                        height: widget.height! * 0.28,  // Ajusta el tamaño de la imagen
                        fit: BoxFit.contain,  // Asegura que la imagen se ajuste al círculo
                      ),
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(50),  // Asegura que el contorno sea redondo
                  child: Container(
                    width: widget.width! * 0.5,  // Ajusta el tamaño del círculo
                    height: widget.width! * 0.5,  // Ajusta el tamaño del círculo
                    decoration:  BoxDecoration(
                      color: appStore.isDarkMode ? simon_finalPrimaryColor : simonGris,
                      shape: BoxShape.circle,  // Forma circular
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        widget.articleResponseData.imageAsset.validate(),
                        color: appStore.isDarkMode ? Colors.white : simon_finalPrimaryColor,
                           
                        width: widget.width! * 0.28,  // Ajusta el tamaño de la imagen
                        height: widget.height! * 0.28,  // Ajusta el tamaño de la imagen
                        fit: BoxFit.contain,  // Asegura que la imagen se ajuste al círculo
                      ),
                    ),
                  ),
                ),
        
              Flexible(
                child: Text(
                  "${widget.articleResponseData.title.validate()}",
                  textAlign: TextAlign.center,
                  style: articletextStyle(color: appStore.isDarkMode ?Colors.black : Colors.black),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
       Positioned(
          top: 10,
          right: 8,
          child: Icon(
            Icons.arrow_forward_ios_sharp, // You can replace this with any icon you like
            color: appStore.isDarkMode ? scaffoldLightColor : simon_finalPrimaryColor, // Change the icon color as needed
            size: 15,
          ),
        ),
    ],
    
  ),
);
  }
}
