import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simon_final/components/simon/custom_alert_dialog_with_actions.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/models/user_document_type_model.dart';
import 'package:simon_final/providers/documents_user.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/screens/documents_user/pdf_view_document.dart';
import 'package:simon_final/screens/legends_uploads_information/principal_page.dart';
import 'package:simon_final/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../main.dart';
import '../../../../utils/colors.dart';

class DocsAccountAssociatedScreen extends StatefulWidget {
  const DocsAccountAssociatedScreen({super.key});

  @override
  State<DocsAccountAssociatedScreen> createState() =>
      _DocsAccountAssociatedScreenState();
}

class _DocsAccountAssociatedScreenState
    extends State<DocsAccountAssociatedScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<DocumentUserProvider>(context, listen: false);
    final providerUser = Provider.of<UserProvider>(context, listen: false);
    provider.fetchDocumentsUsers(providerUser.user.id,providerUser.currentProfile);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Observer(
      builder: (context) {
        return Scaffold(
          backgroundColor:
              appStore.isDarkMode ? scaffoldDarkColor : white_color,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: appStore.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            surfaceTintColor:
                appStore.isDarkMode ? scaffoldDarkColor : white_color,
            iconTheme: IconThemeData(
              color: appStore.isDarkMode ? Colors.white : Colors.black,
            ),
            title: Text(
              textAlign: TextAlign.center,
              'Mis documentos',
              style: primarytextStyle(
                color: appStore.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: appStore.isDarkMode
                ? scaffoldDarkColor
                : context.scaffoldBackgroundColor,
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Consumer<DocumentUserProvider>(
              builder: (context, provider, child) {
                bool hasAllDocuments = provider.documentsUsers
                    .every((element) => element.userDocument != null);
                if (provider.isLoading) {
                  return const LoaderAppIcon();
                } else if (provider.documentsUsers.isEmpty) {
                  return const Center(
                    child: Text('No hay documentos disponibles.'),
                  );
                } else {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
                    child: Column(
                      children: [
                        // Lista de documentos
                        ...provider.documentsUsers.map((doc) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: _CardDocumentTypes(doc: doc))),

                        // Mensaje si no tiene todos los documentos
                        if (!hasAllDocuments)
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.folder,
                                size: 50,
                                color: resendColor,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Subir todos los documentos requeridos para realizar tus impugnaciones",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 14, color: resendColor),
                              ),
                            ],
                          ).paddingAll(16),

                        // Espacio final adicional
                        SizedBox(height: size.height * 0.05),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _CardDocumentTypes extends StatelessWidget {
  const _CardDocumentTypes({required this.doc});

  final UserDocumentTypeModel doc;
  @override
  Widget build(BuildContext context) {
    bool hasDocument = doc.userDocument != null;
    final providerUserDocument =
        Provider.of<DocumentUserProvider>(context, listen: false);
    final providerUserModel = Provider.of<UserProvider>(context, listen: false);

    return Card(
      elevation: hasDocument ? 4 : 6,
        color: hasDocument ? appStore.isDarkMode ? scaffoldDarkColor : Colors.white : simon_finalSecondaryColor,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: hasDocument ? appStore.isDarkMode ? scaffoldLightColor : simon_finalPrimaryColor : Colors.transparent),
          borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título con icono
                  Text(
                    overflow: TextOverflow.ellipsis,
                    doc.name,
                    style: primaryTextStyle(
                      size: 15,
                      weight: FontWeight.bold,
                      color: hasDocument ? appStore.isDarkMode ? scaffoldLightColor : Colors.black  : Colors.black,
                    ),
                   
                    maxLines: 1,
                  ),
                  

                  const SizedBox(height: 8),
                  hasDocument
                      ? Text(
                        overflow: TextOverflow.ellipsis,
                              "Archivo subido correctamente",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: appStore.isDarkMode ? Colors.white54 : Colors.black54,
                              ),
                            )
                      : const Text(
                          "Archivo no subido",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                hasDocument ? doc.userDocument!.mime_type== "image" ? Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(doc.userDocument!.originalUrl.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.check, color: Colors.green, size: 20),
                              Text("Parte Frontal subida",style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: appStore.isDarkMode ? Colors.white54 : Colors.black54,
                              ),),
                            ],
                          ),
                          if(doc.userDocument!.originalUrl2 != null && doc.userDocument!.originalUrl2!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.check, color: Colors.green, size: 20),
                              Text("Parte Trasera subida",style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: appStore.isDarkMode ? Colors.white54 : Colors.black54,
                              ),),
                            ],
                          ),
                        ],
                      )
                    ]
                  ) : Row(
                            children: [
                              const Icon(Icons.check, color: Colors.green, size: 20),
                              Text("Pdf subido",style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: appStore.isDarkMode ? Colors.white54 : Colors.black54,
                              ),),
                            ],
                          ) : const SizedBox.shrink(),
                ],
              ),
            ),
        
            2.width,
            // Botón de acción
            FilledButton(
              onPressed: () {
                if (hasDocument) {
                   if(doc.userDocument!.mime_type == "image"){
                    _showDocumentOptions(context, doc);
                  }else {
                    PDFViewDocumentScreen(name: doc.name, urlDocument: doc.userDocument!.originalUrl,iconDelete: true,onPressedDeleted: (){
                      debugPrint("Borrando documento  " );
                        showCustomAlertImpugnar(context, () {
                              providerUserDocument.deleteDocument(
                                  doc.userDocument!.id,
                                  providerUserModel.user.id,providerUserModel.currentProfile);
                              Navigator.pop(context);
                               Navigator.pop(context);
                            });
                    }).launch(context);
                  }
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrincipalUploadDocument(
                        types: [doc.name],
                        isOne: true,
                      ),
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    hasDocument ? simon_finalPrimaryColor : simonNaranja,
                foregroundColor: hasDocument ? Colors.white : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                  side: hasDocument
                      ? const BorderSide(color: simon_finalPrimaryColor, width: 2)
                      : BorderSide.none,
                ),
              ),
              child: Text(
                hasDocument ? " Ver Documento" : "Subir Documento",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo para documentos ya subidos
  void _showDocumentOptions(BuildContext context, UserDocumentTypeModel doc) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
               // side: const BorderSide(color: simon_finalPrimaryColor, width: 1),
              ),
              content: DocumentCard(doc: doc),
            ));
  }
}

void _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'No se pudo abrir $url';
  }
}

class DocumentCard extends StatelessWidget {
  final UserDocumentTypeModel doc;
  const DocumentCard({
    Key? key,
    required this.doc,
  });

  @override
  Widget build(BuildContext context) {
    final providerUserDocument =
        Provider.of<DocumentUserProvider>(context, listen: false);
    final providerUserModel = Provider.of<UserProvider>(context, listen: false);
    final nameDocument = doc.userDocument!.originalUrl.split('/').last;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          color: Colors.white,
          elevation: 0,
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: doc.userDocument!.mime_type == "image"
                  ? Column(
                      children: [
                        Text(doc.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text("Cargado correctamente"),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            const Text("Parte Frontal"),
                            Image.network(
                              doc.userDocument!.originalUrl,
                              width: 300,
                              height: 150,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error,
                                    color: simonNaranja); // Manejo de errores
                              },
                            ),
                          ],
                        ),
                        if (doc.userDocument!.originalUrl2 != null &&
                            doc.userDocument!.originalUrl2!.isNotEmpty)
                          Column(
                            children: [
                              const Text("Parte Trasera"),
                              Image.network(
                                doc.userDocument!.originalUrl2!,
                                width: 300,
                                height: 150,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error,
                                      color: simonNaranja); // Manejo de errores
                                },
                              ).paddingSymmetric(vertical: 3),
                            ],
                          ),
                        AppButton(
                          width: double.infinity,
                          elevation: 0,
                          onTap: () {
                            showCustomAlertImpugnar(context, () {
                              providerUserDocument.deleteDocument(
                                  doc.userDocument!.id,
                                  providerUserModel.user.id,providerUserModel.currentProfile);
                              Navigator.pop(context);
                               Navigator.pop(context);
                            });
                          },
                          color: simonNaranja,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(DEFAULT_RADIUS)),
                          child: const Text('Eliminar',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                        ).paddingSymmetric(vertical: 3)
                      ],
                    )
                  : Column(
                      children: [
                        Text(doc.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        doc.userDocument!.expirationDate != null &&
                                doc.userDocument!.expirationDate!.isNotEmpty
                            ? Text(
                                'Expira: ${doc.userDocument!.expirationDate}',
                                style: TextStyle(color: Colors.grey[600]))
                            : const Text("Archivo subido correctamente"),
                        const SizedBox(height: 10),
                        Card(
                          color: simonGris,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                          ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.picture_as_pdf,
                                      color: simon_finalPrimaryColor, size: 40),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "${nameDocument}",
                                      style: const TextStyle(fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new,
                                        color: simon_finalPrimaryColor),
                                    onPressed: () {
                                      _launchURL(doc.userDocument!.originalUrl);
                                      print('Abriendo el documento:');
                                    },
                                  ),
                                ],
                              ),
                            )),
                        AppButton(
                          width: double.infinity,
                          elevation: 0,
                          onTap: () {
                            showCustomAlertImpugnar(context, () {
                              providerUserDocument.deleteDocument(
                                  doc.userDocument!.id,
                                  providerUserModel.user.id,providerUserModel.currentProfile);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            });
                          },
                          color: simonNaranja,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(DEFAULT_RADIUS)),
                          child: const Text('Eliminar',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                        ).paddingSymmetric(vertical: 3)
                      ],
                    )),
        ),
      ],
    );
  }
}

void showCustomAlertImpugnar(BuildContext context, void Function()? onAccept) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return CustomAlertDialogWithActions(
        title: "Informacion",
        content:"Recuerda que estos documentos son necesario para un proceso de impugnación.",
        contentQuestion: "¿Deseas eliminar ahora?",
        onAccept: onAccept,
        onCancel: () {
          Navigator.pop(context);
          print("No presionado");
        },
      );
    },
  );
}
