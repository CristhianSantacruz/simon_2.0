import 'package:flutter/material.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsScreen extends StatefulWidget {
  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _accepted = false; // Variable para el checkbox
  bool _isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint("Cargando: $url");
          },
          onPageFinished: (String url) {
            // Ajustar el viewport para dispositivos móviles
            _controller.runJavaScript("""
              var meta = document.createElement('meta');
              meta.name = 'viewport';
              meta.content = 'width=device-width, initial-scale=1.0, user-scalable=no';
              document.getElementsByTagName('head')[0].appendChild(meta);
            """);
            debugPrint("Página cargada: $url");
             setState((){
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
          Uri.parse("https://simonasistentelegal.com/terminos-y-condiciones/"))
      ..enableZoom(false); // Deshabilitar el zoom
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Términos y Condiciones",style: primarytextStyle(size: 20),),
        centerTitle: true,
        backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
        iconTheme: IconThemeData(
            color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
        elevation: 0, // Evita que se cierre el título
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
         
          if (_isLoading)
            const Center(
              child: LoaderAppIcon()
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox para aceptar términos
            Row(
              children: [
                Checkbox(
                  activeColor: Colors.green,
                  value: _accepted,
                  onChanged: (bool? value) {
                    setState(() {
                      _accepted = value ?? false;
                    });
                  },
                ),
                const Expanded(child: Text("Acepto los términos y condiciones")),
              ],
            ),
            // Botón de Aceptar
            AppButton(
              width: double.infinity,
              elevation: 2,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: _accepted ? simon_finalPrimaryColor : Colors.grey,
              onTap: () {
                if (_accepted) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(
                "Aceptar",
                style: primarytextStyle(
                    size: 17, color: _accepted ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
