import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simon_final/components/simon/empty_data_message.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/models/user_generated_document.dart';
import 'package:simon_final/providers/documents_generated_providers.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/screens/documents_user/view_docs/new_document_detail.dart';
import 'package:simon_final/screens/services_user/templates/template_screen.dart';
import 'package:simon_final/utils/common.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:provider/provider.dart';
import '../../../../main.dart';
import '../../../../utils/colors.dart';

class DocsDocumentsGeneratedScreen extends StatefulWidget {
  const DocsDocumentsGeneratedScreen({super.key});

  @override
  State<DocsDocumentsGeneratedScreen> createState() =>
      _DocsGeneratedAssociatedScreenState();
}

class _DocsGeneratedAssociatedScreenState
    extends State<DocsDocumentsGeneratedScreen> {
  //traer los documentos generados por el usuario
  List<UserGeneratedDocumentModel> documentsGenerated = [];

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    getDocumentGeneratesProvider(userProvider.user.id,userProvider.currentProfile);
  }

  Future<void> getDocumentGeneratesProvider(int userId, int profileId) async {
    await context.read<DocumentsGenerateProvider>().getDocumentGenerates(userId,profileId);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new,
                    color: appStore.isDarkMode ? Colors.white : Colors.black)),
            surfaceTintColor: appStore.isDarkMode
                ? scaffoldDarkColor
                : context.scaffoldBackgroundColor,
            iconTheme: IconThemeData(
                color: appStore.isDarkMode ? Colors.white : Colors.black),
            title: Text(
              textAlign: TextAlign.center,
              'Mis impugnaciones',
              style: primarytextStyle(
                color: appStore.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: appStore.isDarkMode
                ? scaffoldDarkColor
                : context.scaffoldBackgroundColor,
          ),
          body: const DocsDocumentGeneratedFragment(),
        );
      },
    );
  }
}

class DocsDocumentGeneratedFragment extends StatelessWidget {
  const DocsDocumentGeneratedFragment({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    return Consumer<DocumentsGenerateProvider>(
      builder: (context, provider, child) {
        final documentsGenerated = provider.documentGenerates;

        if (provider.isLoading) {
          return const Center(
            child:LoaderAppIcon()
          );
        } else if (provider.error) {
          return const Center(
            child: Text(
              "Hubo un problema en traer los datos generados",
            ),
          );
        } else if (provider.documentGenerates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EmptyDataMessage(
                  iconData: Ionicons.document,
                  title: "No hay documentos generados",
                  subtitle:
                      "Crea tu documento de impugnación para ver un documento",
                  textButton: "Hacer impugnación",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TemplatesScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return RefreshIndicator(
            backgroundColor: simon_finalPrimaryColor,
            color: Colors.white,
            onRefresh: () async {
              await provider.getDocumentGenerates(userProvider.user.id,userProvider.currentProfile);
            },
            child:CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Acceso directo a los elementos en orden inverso sin crear lista adicional
              final document = documentsGenerated[documentsGenerated.length - 1 - index];
             return DocumentCardContainer(
                  document: document,
                  onPressedViewDetailsDocument: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NewDocumentDetail(documentId: document.id),
                      ),
                    );
                  },
                );
            },
            childCount: documentsGenerated.length,
            findChildIndexCallback: (key) {
              // Optimización para encontrar índices rápidamente
              final ValueKey<int> valueKey = key as ValueKey<int>;
              return documentsGenerated.length - 1 - documentsGenerated.indexWhere(
                (doc) => doc.id == valueKey.value
              );
            },
          ),
        ),
      ),
    ],
  ),
          );
        }
      },
    );
  }
}

class DocumentCardContainer extends StatelessWidget {
  final UserGeneratedDocumentModel document;
  final void Function()? onPressedViewDetailsDocument;

  const DocumentCardContainer(
      {super.key,
      required this.document,
      required this.onPressedViewDetailsDocument});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    String getFormattedDate(DateTime date) {
      final newDate =
          date.subtract(const Duration(hours: 5)); // Ajuste de zona horaria
      final formattedDate = DateFormat("MMM d, yyyy hh:mm a").format(newDate);
      return formattedDate.toUpperCase(); // Convertir "Jan" a "JAN"
    }

    // Método para mostrar el estado del documento con un estilo más limpio
    Widget _buildStatusContainer(UserGeneratedDocumentModel document) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: document.documentStatusesId == 4
              ? simonVerde // Verde claro para firmado
              : Colors.grey.withOpacity(0.1), // Naranja claro para otros estados
          borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
          border: Border.all(
            color: document.documentStatusesId == 4 ? simonVerde : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Text(
          document.documentStatusesId == 4 ? "Firmado" : document.documentStatuses.name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: document.documentStatusesId == 4 ? Colors.black : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return InkWell(
      onTap: onPressedViewDetailsDocument,
      borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
      splashColor: simon_finalPrimaryColor.withOpacity(0.1), // Efecto de toque suave
      child: Card(
        color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white, // Fondo blanco minimalista
        elevation: 2, // Sombra ligera para resaltar la tarjeta
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
          side: BorderSide(color: appStore.isDarkMode ? Colors.white24 : Colors.grey.shade300, width: 1), // Borde sutil
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del documento y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      document.templateName ?? '',
                      style:  TextStyle(
                        fontWeight: FontWeight.w600,
                        color: appStore.isDarkMode ? Colors.white : Colors.black87, // Color oscuro pero no negro puro
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusContainer(document),
                ],
              ),
              const SizedBox(height: 6),

              // ID del documento
              Text(
                "ID: DOC-${document.documentNumber}",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: simon_finalPrimaryColor, // Color gris suave
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
             
              // Fecha de creación
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getFormattedDate(document.createdAt!),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600, // Color gris más claro
                      fontSize: 13,
                    ),
                  ),
               document.payment.status.toLowerCase() == "pending" ?
               Row(
                children: [
                  Flash(infinite: true, duration: const Duration(seconds: 4),child: const Icon(Icons.circle,color: simonNaranja,size: 16,)),
                  const Text("Pago Pendiente",style: TextStyle(fontSize: 14,color: simonNaranja),),
                ],
              ) : const Row(
                children: [
                  Icon(Icons.circle,color: Colors.green,size: 16,),
                  Text("Pago Exitoso",style: TextStyle(fontSize: 14,color: Colors.green),),
                ],
              )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
