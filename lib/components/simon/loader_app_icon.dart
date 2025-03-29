import 'package:simon_final/screens_export.dart';

import 'package:flutter/material.dart';

class LoaderAppIcon extends StatelessWidget {
  const LoaderAppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white, // Fondo blanco del loader
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/Logo Simon_1.gif',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
