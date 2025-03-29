import 'package:flutter/material.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/screens_export.dart';

class LegendsDocumentMessage extends StatelessWidget {
  const LegendsDocumentMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Center(
               child: SizedBox(
                height: 100, // Ajusta la altura según sea necesario
                child: Image.asset("assets/instructor.png"),
                         ),
             ),
            const SizedBox(height: 10),
            Text(
              "Instrucciones para el registro",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: appStore.isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              "Por favor, ingresa los nombres y apellidos tal cual como aparecen en tu cédula de identidad. Asegúrate de que los datos estén completos y sean exactos para evitar inconvenientes en el proceso.",
              style: TextStyle(fontSize: 14,color: appStore.isDarkMode ? Colors.white : Colors.black),
              textAlign: TextAlign.justify,
            
            ),
            const SizedBox(height: 10),
            Text(
              "Ejemplo:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: appStore.isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 5),
            Text(
              "Nombres: GABRIELA FERNANDA",
              style: TextStyle(fontSize: 14,color: appStore.isDarkMode ? Colors.white : Colors.black),
            ),
            Text(
              "Apellidos: CASTRO VELA",
              style: TextStyle(fontSize: 14,color: appStore.isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
                child: Image.network(
                  "https://cdn.ecuadorlegalonline.com/wp-content/uploads/2022/01/consulta-de-cedula.webp",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
