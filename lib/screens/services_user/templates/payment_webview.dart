import 'package:simon_final/components/simon/alert_dialog.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/screens_export.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String url;

  const PaymentWebView({super.key, required this.url});

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint("Cargando: $url");
            _handleUrlChange(url);
          },
          onPageFinished: (String url) {
            _controller.runJavaScript("""
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, user-scalable=no';
                document.getElementsByTagName('head')[0].appendChild(meta);
              """);
            debugPrint("Página cargada: $url");
            setState(() {
              isLoading = false;
            });
            _handleUrlChange(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url))
      ..enableZoom(false); // Asegúrate de deshabilitar el zoom
  }

  void _handleUrlChange(String url) async {
    if (url.contains("/datafast/payment-status")) {
      await _showAlertMessage();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showAlertMessage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final documentsProvider =
        Provider.of<DocumentsGenerateProvider>(context, listen: false);

    try {
      await documentsProvider.getDocumentGenerates(
        userProvider.user.id,
        userProvider.currentProfile,
      );
      if (context.mounted) {
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              iconData: Icons.check_circle,
              textButton: "Entendido",
              withRedirection: false,
              title: "Pago Exitoso",
              content:
                  "El pago ha sido procesado con éxito. Para completar tu trámite, sigue las instrucciones enviadas a tu correo electrónico.",
              onPressedRoute: () {
                //Navigator.of(context).pop(); // Cierra el primer diálogo
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return CustomAlertDialog(
                      iconData: Icons.info,
                      textButton: "OK",
                      withRedirection: false,
                      title: "Confirmación",
                      content:
                          "Recuerda que el proceso no ha finalizado aún. En breve recibirás un enlace para continuar con la firma del documento.",
                      onPressedRoute: () {
                        Navigator.of(context).pop(); 
                        Navigator.of(context).pop();// Cierra el segundo diálogo
                      },
                    );
                  },
                );
              },
            );
          },
        );
      }
    } catch (e) {
      debugPrint("Error al obtener documentos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new,
              color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
        ),
        title: Text("Pago",
            style: primarytextStyle(
                size: 20,
                color:
                    appStore.isDarkMode ? scaffoldLightColor : Colors.black)),
        backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        surfaceTintColor:
            appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) const Center(child: LoaderAppIcon())
        ],
      ),
    );
  }
}
