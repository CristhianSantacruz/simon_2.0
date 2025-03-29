import 'package:flutter/material.dart';
import 'package:simon_final/utils/colors.dart';

class CustomCircularProgress extends StatelessWidget {
  final Color containerColor; 
  final Color progressColor; 
  final double size; 
  final Color? backgroundColor;

  const CustomCircularProgress({
    Key? key,
    this.containerColor = simon_finalPrimaryColor, 
    this.progressColor = Colors.white, 
    this.size = 80 ,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: backgroundColor ?? Colors.transparent,
        body: Center(
          child: Container(
            width: size, // Ancho del contenedor
            height: size, // Alto del contenedor
            decoration: BoxDecoration(
              color: containerColor, // Color de fondo del contenedor
              borderRadius: BorderRadius.circular(15), // Bordes redondeados
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(progressColor), // Color del progreso
                strokeWidth: 4, // Grosor del indicador
              ),
            ),
          ),
        ),
      ),
    );
  }
}