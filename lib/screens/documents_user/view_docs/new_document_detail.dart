import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simon_final/components/simon/alert_dialog.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/user_generated_document.dart';
import 'package:simon_final/screens/documents_user/pdf_view_document.dart';
import 'package:simon_final/screens/modals/show_comments_modal.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/user_generated_document_service.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:simon_final/screens/services_user/templates/payment_webview.dart';

class NewDocumentDetail extends StatefulWidget {
  final int documentId;
  final bool? firstAlert;
  const NewDocumentDetail(
      {super.key, required this.documentId, this.firstAlert = false});

  @override
  State<NewDocumentDetail> createState() => _NewDocumentDetailState();
}

class _NewDocumentDetailState extends State<NewDocumentDetail> {
  String documentFilePath = '';
  String dateCreated = '';
  Map<String, String> filesAsociadtedMap = {};
  Map<String, String> sectionFieldsMapData = {};
  bool contentSigneUrl = false;
  late UserGeneratedDocumentModel document;
  final UserGeneratedDocumentService _userGeneratedDocumentService =
      UserGeneratedDocumentService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocumentData();
  }

  void extractData(UserGeneratedDocumentModel document) {
    for (var section in document.generatedDocumentSections) {
      for (var field in section.documentSectionFields) {
        if (field.fieldType == "file" && field.fileUpload != null) {
          filesAsociadtedMap[field.fieldLabel] = field.fileUpload!;
        } else if (field.modeloData != null) {
          if (field.modeloData is EntityModelData) {
            EntityModelData entity = field.modeloData as EntityModelData;
            sectionFieldsMapData[field.fieldLabel] =
                "${entity.entityType} ${entity.name}";
          } else if (field.modeloData is VehicleModelData) {
            VehicleModelData vehicle = field.modeloData as VehicleModelData;
            sectionFieldsMapData[field.fieldLabel] =
                "${vehicle.brand} ${vehicle.plateNumber}";
          }
        } else {
          sectionFieldsMapData[field.fieldLabel] = field.fieldValue;
        }
      }
    }
  }

  void showAlerEmailSignature(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            iconData: Icons.info,
            title: "Firma",
            content:
                "Te enviaremos un correo con un enlace para completar la firma del documento. Revisa tu correo electrónico.",
            onPressedRoute: () {
              Navigator.pop(context);
              showAlertViewSpam();
            },
          );
        });
  }

  void showAlertViewSpam() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const CustomAlertDialog(
            iconData: Icons.info,
            title: "!Importante!",
            content: "Recuerda revisar la bandeja de SPAM",
          );
        });
  }

  Future<void> _loadDocumentData() async {
    try {
      UserGeneratedDocumentModel document = await _userGeneratedDocumentService
          .showUserGeneratedDocumentById(widget.documentId);
      setState(() {
        this.document = document;
        documentFilePath = document.originalUrl.split("/").last;
        dateCreated = DateFormat('yyyy/MM/dd').format(document.createdAt!);
        contentSigneUrl =
            document.signedUrl != null && document.signedUrl!.isNotEmpty;
        extractData(document);
        this._isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if ((widget.firstAlert == true || contentSigneUrl == false) &&
            document.payment.status.toLowerCase() != "pending") {
          showAlerEmailSignature(context);
        }
      });
    } catch (e) {
      debugPrint("Error al cargar los datos del documento: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: appStore.isDarkMode ? scaffoldDarkColor: simonGris,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Detalles de Impugnacion",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
          ),
          centerTitle: true,
          surfaceTintColor: appStore.isDarkMode ?  scaffoldDarkColor : simonGris,
          backgroundColor: appStore.isDarkMode ?  scaffoldDarkColor : simonGris,
          elevation: 0, // Sin sombra
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _isLoading
            ? const Center(child: LoaderAppIcon())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusDocument(size, context),
                    
                    if (document.payment.status.toLowerCase() == "pending")
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentWebView(
                                  url: document.paymentUrl ?? ""),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              simonNaranja, // Color de fondo del botón
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight
                                  .bold), // Estilo de texto más elegante
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.payment,
                              color: Colors.white,
                              size: 25,
                            ),
                            5.width,
                            const Text(
                              "Pagar Ahora",
                              style: TextStyle(
                                  color: Colors.white), // Texto blanco
                            ),
                          ],
                        ),
                      ).paddingSymmetric(horizontal: 5),
                    // parte de informaciono Principal
                    Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                        ),
                        color: appStore.isDarkMode ? simonGris : Colors.white,
                        elevation: 2,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Informacion Personal",
                                    style: primarytextStyle(
                                        color: appStore.isDarkMode ? Colors.black : Colors.black, size: 17),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color.fromARGB(255, 163, 165, 170),
                              ),

                              //Rows
                              ...buildSectionRows(sectionFieldsMapData),
                            ],
                          ),
                        )),

                    //parte de documento generados

                    _documentGeneratedContainer(
                        isPayment: !(document.payment.status.toLowerCase() ==
                            "pending"),
                        document: document,
                        size: size,
                        widget: widget,
                        documentFilePath: documentFilePath,
                        dateCreated: dateCreated),
                    
                   /* if (document.payment.status.toLowerCase() == "pending")
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentWebView(
                                    url: document.paymentUrl ?? ""),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                simonNaranja, // Color de fondo del botón
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(DEFAULT_RADIUS),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 6),
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight
                                    .bold), // Estilo de texto más elegante
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payment,
                                color: Colors.white,
                                size: 25,
                              ),
                              5.width,
                              Text(
                                "Pagar Ahora",
                                style: TextStyle(
                                    color: Colors.white), // Texto blanco
                              ),
                            ],
                          ),
                        ),
                      ),*/
                    //parte de estado de firmas
                    _SignatureContainer(
                        size: size,
                        contentSigneUrl: contentSigneUrl,
                        widget: widget,
                        document: document),

                    // parte de archivos asociados
                    10.height,
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
                        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Archivos asociados",
                            style:
                                primarytextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black, size: 17),
                          ),
                          10.height,
                          if (filesAsociadtedMap.isNotEmpty)
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: size.height *
                                    0.5, // Limita la altura máxima
                              ),
                              child: ListView(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                children:
                                    filesAsociadtedMap.entries.map((entry) {
                                  String fileLabel = entry.key;
                                  String fileUrl = entry.value;
                                  String fileName = fileUrl.split('/').last;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: simon_finalSecondaryColor,
                                      borderRadius:
                                          BorderRadius.circular(DEFAULT_RADIUS),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _launchURL(fileUrl);
                                          },
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.insert_drive_file,
                                                color: simon_finalPrimaryColor,
                                                size: 20,
                                              ),
                                              5.width,
                                              // Se usa Expanded para evitar desbordes
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: size.width *
                                                        0.5, // Limita el ancho
                                                    child: Text(
                                                      fileLabel,
                                                      style: primarytextStyle(
                                                          color: Colors.black,
                                                          size: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: size.width *
                                                        0.5, // Limita el ancho
                                                    child: Text(
                                                      fileName,
                                                      style: primarytextStyle(
                                                          color: Colors.black54,
                                                          size: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(), // Empuja el ícono a la derecha
                                        IconButton(
                                          onPressed: () {
                                            _launchURL(fileUrl);
                                          },
                                          icon: const Icon(
                                            Icons.launch,
                                            color: simon_finalPrimaryColor,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ).paddingOnly(left: 16, right: 16, top: 10, bottom: 10),
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onPressed: () {
            ShowCommentsModal.showCommentsModal(context, document.id);
          },
          backgroundColor: simon_finalPrimaryColor,
          child:  Center(
            child: Stack(
              children: [
                const Icon(
                  FontAwesomeIcons.solidComment,
                  size: 21,
                  color: Colors.white,
                ),
                Positioned(
                    right: 0,
                    top: -10,
                    child: Flash(
                      infinite: true,
                      duration: const Duration(seconds: 2),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Center(
                          child: const Text(
                            "",
                            style: TextStyle(
                                color: Color.fromARGB(255, 117, 109, 109),
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ).paddingAll(3),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ));
  }

  Card _buildStatusDocument(Size size, BuildContext context) {
    return Card(
       color: document.documentStatuses.completed == 1 ? simonVerde : simon_finalPrimaryColor.withOpacity(0.8),
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(10),
       ), // Color de fondo,
      child: Container(
        width: double.infinity,
        
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    document.documentStatuses.name,
                    overflow: TextOverflow.ellipsis,
                    style: primarytextStyle(
                      color: document.documentStatuses.completed == 1
                          ? Colors.black
                          : Colors.white,
                      size: 16,
                    ),
                  ).center(),
                ),
              ],
            ),
           
          ],
        ),
      ),
    );
  }
}

class _SignatureContainer extends StatelessWidget {
  const _SignatureContainer({
    required this.size,
    required this.contentSigneUrl,
    required this.widget,
    required this.document,
  });

  final Size size;
  final bool contentSigneUrl;
  final NewDocumentDetail widget;
  final UserGeneratedDocumentModel document;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: appStore.isDarkMode ? simonGris : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
      ),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    "Estado de firma",
                    style: primarytextStyle(color: appStore.isDarkMode ?Colors.black : Colors.black, size: 16),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                      style: contentSigneUrl
                          ? buttonStylePrimary(context)
                          : buttonStyleSeconday(context),
                      onPressed: () {
                        if (contentSigneUrl) {
                          _launchURL(document.signedUrl!);
                          /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PDFViewDocumentScreen(
                                        name: "Documento Firmado",
                                        urlDocument: document.signedUrl!,
                                      )));*/
                        }
                      },
                      child: Text(
                        contentSigneUrl ? "Documento Firmado" : "Pendiente",
                        style: primarytextStyle(
                            color:
                                contentSigneUrl ? Colors.white : simonNaranja,
                            size: 13),
                      )),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(FontAwesomeIcons.signature,
                      size: 20, color: simon_finalPrimaryColor),
                ),
                5.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Documento firmado",
                      style: primarytextStyle(color: appStore.isDarkMode ? Colors.black : Colors.black, size: 15),
                    ),
                    Text( 
                      contentSigneUrl
                          ? "Documento firmado correctamente"
                          : "Esperando el proceso de firma",
                      style: primarytextStyle(color: resendColor, size: 13),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _documentGeneratedContainer extends StatelessWidget {
  const _documentGeneratedContainer({
    required this.size,
    required this.widget,
    required this.documentFilePath,
    required this.dateCreated,
    required this.document,
    required this.isPayment,
  });

  final Size size;
  final NewDocumentDetail widget;
  final String documentFilePath;
  final String dateCreated;
  final UserGeneratedDocumentModel document;
  final bool isPayment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          color:  appStore.isDarkMode ? simonGris: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
          ),
          elevation: 2,
          child: Container(
            width: constraints.maxWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "PDF Generado",
                        style: primarytextStyle(color:  Colors.black, size: 17),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        style: isPayment
                            ? buttonStylePrimary(context)
                            : buttonStyleSeconday(context),
                        onPressed: isPayment
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PDFViewDocumentScreen(
                                      name: "Documento Generado",
                                      urlDocument: document.originalUrl,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Text("Ver Documento",style: TextStyle(color: isPayment ? Colors.white : Colors.black45),),
                      ),
                    ),
                  ],
                ),
                
              ],
            ),
          ),
        );
      },
    );
  }
}

List<Widget> buildSectionRows(Map<String, String> sectionFieldsMap) {
  return sectionFieldsMap.entries.map((entry) {
    return RowInfo(
      title: "${entry.key}", // Agrega ":" al final del título
      data: entry.value,
    );
  }).toList();
}

class RowInfo extends StatelessWidget {
  final String title;
  final String data;

  RowInfo({
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$title:",
          style: primarytextStyle(
            color: appStore.isDarkMode ? resendColor : resendColor,
            size: 16,
          ),
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
             crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (title == "Vehiculo")
                const Icon(
                  FontAwesomeIcons.car,
                  color: simon_finalPrimaryColor,
                  size: 27,
                ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  data,
                  style: primarytextStyle(
                    color: appStore.isDarkMode ? Colors.black : Colors.black,
                    size: 16,
                  ),
                  overflow: TextOverflow.ellipsis, // Corta el texto si es muy largo
                  maxLines: 1, // Mantiene el texto en una sola línea
                ),
              ),
            ],
          ),
        ),
      ],
    ).paddingOnly(bottom: 10);
  }
}

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

void showContactDialog(BuildContext context, EntityModelData entityModelData) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        title: "Contacto",
        content:
            "Telefono: ${entityModelData.contactPhone}\nCorreo: ${entityModelData.contactEmail}",
        iconData: Icons.contact_mail,
      );
    },
  );
}
