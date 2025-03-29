
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/user_check_requirementes.dart';
import 'package:simon_final/providers/page_controller_provider.dart';
import 'package:simon_final/screens/legends_uploads_information/principal_upload_user_documentation.dart';
import 'package:simon_final/screens/legends_uploads_information/register_car_page.dart';
import 'package:simon_final/screens/legends_uploads_information/residency_registration.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/user_check_requirements_service.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';

class PrincipalUploadDocument extends StatefulWidget {
  final List<String> types;
  final bool? isOne;
  const PrincipalUploadDocument({super.key, required this.types, this.isOne});

  @override
  State<PrincipalUploadDocument> createState() =>
      _PrincipalUploadDocumentState();
}

class _PrincipalUploadDocumentState extends State<PrincipalUploadDocument> {
  final List<String> _stepTitles = [];
  int _totalPages = 0;
  List<bool> _completedSteps = [];
  final userCheckRequirements = UserCheckRequirementsService();
  final List<Document> documentsDynamic = [];
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _stepTitles.clear();
    _completedSteps.clear();
    documentsDynamic.clear();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    extractDocumentRequired(userProvider.user.id,userProvider.currentProfile).then((_) {
      _completedSteps = List.filled(_totalPages, false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pageControllerProvider = context.read<PageControllerProvider>();
        pageControllerProvider.setTotalPages(_totalPages);
      });
    });
    
  }



  String getTypeTitle(String type) {
    switch (type) {
      case "address":
        return "Domicilio";
      case "vehicles":
        return "Vehiculo";
      case "Cedula":
        return "Cedula";
      case "Certificado de Votación":
        return "Cert. Vota.";
      default:
        return "";
    }
  }

  Future<void> extractDocumentRequired(int userId,int profileId) async {
    final userCheckRequiriments = await userCheckRequirements.getUserCheckRequirements(userId,profileId);

    for (var item in userCheckRequiriments.missingItems) {
      switch (item.type) {
        case "address":
          _stepTitles.add("Domicilio");
          break;
        case "user_documents":
          if (item.documents != null) {
            for (var doc in item.documents!) {
              _stepTitles.add(getTypeTitle(doc.documentName));
              this.documentsDynamic.add(doc);
            }
          }
          break;
        case "vehicles":
          _stepTitles.add("Vehiculo");
          _stepTitles.add("Matricula");
          break;
      }
    }

    setState(() {
      _totalPages = _stepTitles.length;
       isInitialized = true; // Actualizar el total de páginas
    });

    // Imprimir después de actualizar el estado
    debugPrint("Pagina totale $_totalPages");
    debugPrint("Imprimir los _stepTitles ${_stepTitles.toString()}");
  }

  List<Widget> _buildStepWidgets() {
    return _stepTitles.map((title) {
      switch (title) {
        case "Domicilio": // Caso estático
          return ResidencyRegistration(isOne: widget.isOne);
        case "Vehiculo": // Caso estático
          return const RegisterCardUploadPage();
        case "Matricula": // Caso estático
          return const UploadUserDocumentation(name: "Matricula", idDocument: 1);
        default:
          final document = documentsDynamic.firstWhere(
            (doc) => getTypeTitle(doc.documentName) == title,
          );
          return UploadUserDocumentation(
            name: document.documentName, 
            idDocument: document.documentTypeId, 
            isOne: widget.isOne,
          );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pageControllerProvider = Provider.of<PageControllerProvider>(context);
    final currentPage = pageControllerProvider.currentPage;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            Provider.of<PageControllerProvider>(context, listen: false).reset();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: appStore.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          textAlign: TextAlign.center,
          'Completa tus datos',
          style: primarytextStyle(
            size: 18,
            color: appStore.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        surfaceTintColor: appStore.isDarkMode ? scaffoldDarkColor : white_color,
        iconTheme: IconThemeData(
          color: appStore.isDarkMode ? Colors.white : Colors.black,
        ),
        backgroundColor: appStore.isDarkMode
            ? scaffoldDarkColor
            : context.scaffoldBackgroundColor,
        actions: [
          const Icon(
            Icons.assignment,
            color: simon_finalPrimaryColor,
          ).center().paddingRight(16),
        ],
      ),
      body: Column(
        children: [
          // Barra de progreso
          LinearProgressIndicator(
            value: _totalPages == 0 ? 0 : (currentPage + 1) / _totalPages,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(simon_finalPrimaryColor),
            minHeight: 10,
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
          ).paddingSymmetric(horizontal: 16),
          const SizedBox(height: 8),

          // Números de paso
          SizedBox(
            height: size.height *
                0.08, // Altura fija para el contenedor de los pasos
            child: Center(
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Scroll horizontal
                itemCount: _totalPages, // Número de pasos
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (index <= currentPage) {
                        // pageControllerProvider.goToPage(index); // Retroceder
                      } else if (index == currentPage + 1) {
                        // pageControllerProvider.goToPage(index); // Avanzar al siguiente
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? simon_finalPrimaryColor
                                  : index <= currentPage
                                      ? simonVerde
                                      : simon_finalSecondaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  color: currentPage == index
                                      ? Colors.white
                                      : index <= currentPage
                                          ? Colors.black
                                          : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 4), // Espacio entre el círculo y el texto
                          Text(
                            _stepTitles[index],
                            style: TextStyle(
                              fontSize: 9,
                              color: currentPage == index
                                  ? appStore.isDarkMode ? scaffoldLightColor : Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ).paddingSymmetric(horizontal: 16),
          // PageView para las pantallas
          Expanded(
            child: this.isInitialized ? PageView(
              controller: pageControllerProvider.pageController,
              onPageChanged: (page) {
                if (page > currentPage) {
                  setState(() {
                    _completedSteps[currentPage] = true;
                  });
                }
                pageControllerProvider.goToPage(page);
              },
              //! No olvidar de poner que no se mueva manuealmente
              physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll manual
              children: _buildStepWidgets(),
            ) : const Center(child: LoaderAppIcon())
          ),
        ],
      ),
    );
  }
}
