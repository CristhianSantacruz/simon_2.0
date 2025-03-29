import 'package:animate_do/animate_do.dart';
import 'package:simon_final/components/simon/principal_alert_dialog.dart';
import 'package:simon_final/models/banner_model.dart';
import 'package:simon_final/screens/vehicles/vehicle_presentation_modal.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/user_check_requirements_service.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/images.dart';
import 'package:simon_final/components/article_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../main.dart';
import '../../models/article_model.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  List<ArticleResponse> articleList = getArticleResponse();
  final PageController _pageController = PageController(viewportFraction: 1);

  bool requiredDocuments = false;
  List<String> ListOfCarImg = [
    'assets/images/car1.png',
    'assets/images/car2.png',
    'assets/images/car3.png',
    // Agregar más imágenes según sea necesario.
  ];

  List<String> discountList = [
    "Special Discount 1",
    "Special Discount 2",
    "Special Discount 3",
    "Special Discount 4",
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<BannerProvider>(context, listen: false).fetchBanners();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    vehicleProvider
        .fetchVehicles(userProvider.user.id, userProvider.currentProfile)
        .then((_) {})
        .catchError((error) {
      debugPrint("Error al cargar vehículos: $error");
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserCheckRequirements(
          userProvider.user.id, userProvider.currentProfile);
    });
  }

  Future<void> getUserCheckRequirements(int userId, int profileId) async {
    final userCheckRequirementsService = UserCheckRequirementsService();
    try {
      final userCheckRequirements = await userCheckRequirementsService
          .getUserCheckRequirements(userId, profileId);
      debugPrint("Requisitos: ${userCheckRequirements.toJson()}");
      // sacar los datos
      if (userCheckRequirements.requirementsMet == true) {
        setState(() {
          this.requiredDocuments = false;
        });
        debugPrint("Todos los requerimientos estan completos");
        return;
      }

      List<String> missingItems = [];
      List<String> types = [];

      for (var item in userCheckRequirements.missingItems) {
        if (item.documents != null && item.documents!.isNotEmpty) {
          for (var document in item.documents!) {
            missingItems.add(document.documentName);
            types.add(document.documentName);
          }
        } else {
          types.add(item.type);
          missingItems.add(getTextRequirement(item.type));
        }
      }
      setState(() {
        this.requiredDocuments = true;
      });

      showRegisterDataDocuments(
          context,
          "Recuerda que para impugnar tus multas debes tener los siguientes documentos.",
          "Documentos Requeridos",
          missingItems,
          types);
    } catch (e) {
      debugPrint("Error al cargar requisitos: $e");
    }
  }

  String getTextRequirement(String types) {
    switch (types) {
      case "address":
        return "Direccion de Domicilio";
      case "vehicles":
        return "Vehiculo";
      case "vehicle_documents":
        return "Cargar matricula correspondiente";
      default:
        return "Documento";
    }
  }

  Future<bool> checkIfDocumentsRequired(int userId, int profileId) async {
    final userCheckRequirementsService = UserCheckRequirementsService();
    try {
      final userCheckRequirements = await userCheckRequirementsService
          .getUserCheckRequirements(userId, profileId);
      return userCheckRequirements.requirementsMet != true;
    } catch (e) {
      debugPrint("Error al verificar requisitos: $e");
      return false;
    }
  }

  void showRegisterDataDocuments(BuildContext context, String content,
      String titlte, List<String> requirements, List<String> types) {
    showDialog(
        context: context,
        barrierDismissible: true, //! recordar que debe ser obligatorio
        builder: (BuildContext context) {
          return PrincipalAlertDialog(
            iconData: Icons.info,
            content: content,
            title: titlte,
            requirements: requirements,
            types: types,
          );
        });
  }

  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final List<BannerModel> banners = context.watch<BannerProvider>().banners;
    final size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          appStore.isDarkMode ? Colors.transparent : Colors.transparent,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    ));
    return Observer(builder: (context) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30, left: 10, right: 10, top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<BannerProvider>(
              builder: (context, bannerProvider, child) {
                if (bannerProvider.banners.isEmpty) {
                  return SizedBox(
                    height: size.height * 0.18,
                    width: double.infinity,
                    child: const Center(
                        child: CircularProgressIndicator(
                      color: simon_finalPrimaryColor,
                    )),
                  );
                } else {
                  return _viewBanners(
                    pageController: _pageController,
                    banners: banners,
                    //carouselSliderController: _carouselController,
                  );
                }
              },
            ),
            Consumer<VehicleProvider>(
              builder: (context, vehicleProvider, child) {
                if (vehicleProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: simon_finalPrimaryColor,
                    ),
                  );
                } else if (vehicleProvider.vehicleList.isEmpty) {
                  return const SizedBox.shrink();
                } else {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: vehicleProvider.vehicleList.length,
                            itemBuilder: (context, index) {
                              final vehicle =
                                  vehicleProvider.vehicleList[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VehiclePresentationModel(
                                              vehicle: vehicle),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: simonGris,
                                    borderRadius:
                                        BorderRadius.circular(DEFAULT_RADIUS),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Stack(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              vehicle.plateNumber.length < 7
                                                  ? image_moto1
                                                  : image_auto_1,
                                              width: 60,
                                              height: 60,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${vehicle.plateNumber}",
                                            style: primaryTextStyle(
                                                color: Colors.black87),
                                          ),
                                          10.width,
                                          Flexible(
                                            child: Text(
                                              " ${vehicle.carBrand?.name ?? ''} ${vehicle.vehicleModel?.name ?? ''} ",
                                              style: primaryTextStyle(
                                                  color: Colors.black87),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      //2.height,
                                      Positioned(
                                        bottom: 8,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: SmoothPageIndicator(
                                            controller: _pageController,
                                            count: vehicleProvider
                                                .vehicleList.length,
                                            effect: const WormEffect(
                                              dotHeight: 8,
                                              dotWidth: 8,
                                              activeDotColor:
                                                  simon_finalPrimaryColor,
                                              dotColor: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ).paddingAll(0),
            4.width,
            FutureBuilder<bool>(
                future: checkIfDocumentsRequired(
                    userProvider.user.id, userProvider.currentProfile),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: simon_finalPrimaryColor,).center();
                  }
                  if (snapshot.hasError) {
                    return const SizedBox();
                  }

                  bool requiredDocuments = snapshot.data ?? false;
                  if (!requiredDocuments) return const SizedBox();

                  return GestureDetector(
                    onTap: () {
                      getUserCheckRequirements(
                          userProvider.user.id, userProvider.currentProfile);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: simonNaranja,
                        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flash(
                            infinite: true,
                            duration: const Duration(seconds: 3),
                            child: const Icon(Icons.upload_file_outlined,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Faltan documentos",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ).paddingSymmetric(horizontal: 10);
                }),
            ...articleList
                .map((e) => ArticleWidget(articleResponseData: e))
                .toList(),
          ],
        ),
      );
    });
  }
}

class CardPayment extends StatelessWidget {
  final int index;

  const CardPayment({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: simon_finalSecondaryColor, // Fondo blanco para las tarjetas
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
        // Ajusta el radio aquí
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          //style: ListTileStyle.drawer,
          leading: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.payment, color: simon_finalPrimaryColor),
          ),
          title: Text(
            "Pago #$index",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: appStore.isDarkMode
                    ? scaffoldDarkColor
                    : scaffoldDarkColor),
          ),
          subtitle: Text(
              "Fecha: ${DateTime.now().subtract(Duration(days: index * 10)).toLocal()}"),
          trailing: Text(
            "\$${(50 + index * 20).toStringAsFixed(2)}",
            style: const TextStyle(
                fontSize: 20,
                color: simon_finalPrimaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
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

class _viewBanners extends StatefulWidget {
  const _viewBanners({
    required PageController pageController,
    required this.banners,
    //required this.carouselSliderController,
  });

  final List<BannerModel> banners;

  @override
  State<_viewBanners> createState() => _viewBannersState();
}

class _viewBannersState extends State<_viewBanners> {
  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: SizedBox(
            height: size.height * 0.18,
            width: double.infinity,
            child: CarouselSlider.builder(
              itemCount: widget.banners.length,
              options: CarouselOptions(
                  height: size.height * 0.2,
                  autoPlay: true, // Autoplay habilitado
                  enlargeCenterPage:
                      true, // Hace que el banner central sea más grande
                  aspectRatio: 16 / 9, // Relación de aspecto
                  viewportFraction:
                      0.8, // Fracción del viewport que ocupa cada banner
                  initialPage: 0, // Página inicial
                  enableInfiniteScroll: true, // Scroll infinito
                  autoPlayInterval:
                      const Duration(seconds: 3), // Intervalo de autoplay
                  autoPlayAnimationDuration: const Duration(
                      milliseconds: 300), // Duración de la animación
                  autoPlayCurve: Curves.linear, // Curva de la animación
                  scrollDirection: Axis.horizontal, // Dirección del scroll
                  onPageChanged: (index, reason) {
                    setState(() {
                      activeIndex = index;
                    });
                  }),
              itemBuilder: (context, index, realIndex) {
                final banner = widget.banners[index];
                return GestureDetector(
                  onTap: () {
                    _launchURL(banner.redirect ?? "");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                0.1), // Color de la sombra con opacidad suave
                            offset: Offset(0,
                                3), // Desplazamiento de la sombra (hacia abajo)
                            blurRadius:
                                5, // Radio de difuminado para suavizar la sombra
                            spreadRadius: 2, // Expansión de la sombra
                          ),
                        ],
                        color: white_color,
                        //border: Border.all(color: Colors.black, width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(banner.photoUrl ?? ""),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        AnimatedSmoothIndicator(
            activeIndex: activeIndex,
            count: widget.banners.length, // Número total de páginas
            effect: ExpandingDotsEffect(
              activeDotColor:
                  appStore.isDarkMode ? Colors.white : simon_finalPrimaryColor,
              dotColor: const Color(0xFF35383E),
              dotHeight: 8,
              dotWidth: 12,
              expansionFactor: 3, // Controla cuánto se expande el punto activo
              spacing: 10,
            )).paddingOnly(top: 10, bottom: 5)
      ],
    );
  }
}
