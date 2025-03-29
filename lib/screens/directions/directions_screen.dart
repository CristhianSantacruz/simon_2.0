import 'package:simon_final/components/simon/custom_circular_progress.dart';
import 'package:simon_final/components/simon/empty_data_message.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/addres_model.dart';
import 'package:simon_final/screens/directions/update_direction_screen.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/address_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';

class DirectionsUser extends StatefulWidget {
  const DirectionsUser({super.key});

  @override
  State<DirectionsUser> createState() => _DirectionsUserState();
}

class _DirectionsUserState extends State<DirectionsUser>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<AddressModel> addresses = [];
  final _addresService = AddressServices();
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _loadAddresses(userProvider.user.id, userProvider.currentProfile);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses(int userId, int profileId) async {
    try {
      List<AddressModel> fetchedAddresses =
          await _addresService.getAddressByUser(userId, profileId);
      setState(() {
        addresses = fetchedAddresses;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error al cargar las direcciones del servicio: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteDirectionById(int addressId, int userId) async {
    try {
      String message = await _addresService.deleteAdressById(addressId);
      toast(
        message,
        bgColor: simon_finalPrimaryColor,
        textColor: white_color,
        gravity: ToastGravity.TOP,
      );
      Future.delayed(const Duration(seconds: 1), () {
        //Navigator.pop(context);
        Navigator.pushReplacementNamed(context, Routes.directions);
      });
    } catch (e) {
      toast(
        "Error al borrar la dirección",
        bgColor: Colors.red,
        textColor: white_color,
        gravity: ToastGravity.TOP,
      );
      debugPrint("Error al borrar la dirección: $e");
    }
  }

  List<AddressModel> _filterAddressesByType(String type) {
    return addresses.where((address) => address.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filterAddressTypeADDRESS =
        _filterAddressesByType(TypeAdressModel.ADDRESS.name);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: appStore.isDarkMode
            ? scaffoldDarkColor
            : context.scaffoldBackgroundColor,
        iconTheme: IconThemeData(
            color:
                appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
        backgroundColor: appStore.isDarkMode
            ? scaffoldDarkColor
            : context.scaffoldBackgroundColor,
        title: Text('Direcciones',
            style: primarytextStyle(
                color: appStore.isDarkMode ? Colors.white : Colors.black)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: _isLoading
          ? const CustomCircularProgress()
          : Column(
              children: [
                // Sección de Direcciones Domiciliarias

                filterAddressTypeADDRESS.isNotEmpty
                    ? Container(
                        child: DirectionUserCard(
                          addresModel: filterAddressTypeADDRESS[0],
                          onPressedEdit: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateDirectionScreen(
                                        addressModel:
                                            filterAddressTypeADDRESS[0])));
                          },
                          onPressedDelete: () async {
                            // Mostrar diálogo de confirmación
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Confirmar eliminación"),
                                  content: const Text(
                                      "¿Estás seguro de que deseas eliminar esta dirección?"),
                                  actions: [
                                    TextButton(
                                      style: buttonStyleSeconday(context),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(false); // No confirmar
                                      },
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      style: buttonStylePrimary(context),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(true); // Confirmar
                                      },
                                      child: const Text(
                                        "Eliminar",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      //style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );

                            // Si el usuario confirma, eliminar la dirección
                            if (confirmDelete == true) {
                              await deleteDirectionById(
                                filterAddressTypeADDRESS[0].id!,
                                context.read<UserProvider>().user.id,
                              );
                              /*await _loadAddresses(
                              userProvider.user.id,
                              userProvider.currentProfile,
                            );*/
                            }
                          },
                        ),
                      )
                    : EmptyDataMessage(
                        title: "No tienes una dirección domiciliaria",
                        subtitle: "Añade una dirección",
                        iconData: Icons.add,
                        textButton: "Agregar Dirección",
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.addAddress);
                        },
                      ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(thickness: 2, height: 20, color: simon_finalPrimaryColor),
                ),

                // Sección de Direcciones de Facturación
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Direcciones de Facturación',
                    style: primarytextStyle(size: 16),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose, // Ocupa solo el espacio necesario
                  child: _buildAddressList(
                    type: TypeAdressModel.INVOICE.name,
                    title: 'Dirección de Facturación',
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppButton(
          elevation: 2,
          onTap: () {
            Navigator.pushNamed(context, Routes.addAddress);
          },
          color: simon_finalPrimaryColor,
          shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
          child: const Text('Agregar Una direccion',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildAddressList({required String type, required String title}) {
    final filteredAddresses = _filterAddressesByType(type);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return filteredAddresses.isNotEmpty
        ? Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: filteredAddresses.length,
                  itemBuilder: (context, index) {
                    return DirectionUserCard(
                      addresModel: filteredAddresses[index],
                      onPressedEdit: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UpdateDirectionScreen(
                                    addressModel: filteredAddresses[index])));
                      },
                      onPressedDelete: () async {
                        // Mostrar diálogo de confirmación
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirmar eliminación"),
                              content: const Text(
                                  "¿Estás seguro de que deseas eliminar esta dirección?"),
                              actions: [
                                TextButton(
                                  style: buttonStyleSeconday(context),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(false); // No confirmar
                                  },
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  style: buttonStylePrimary(context),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true); // Confirmar
                                  },
                                  child: const Text(
                                    "Eliminar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  //style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );

                        // Si el usuario confirma, eliminar la dirección
                        if (confirmDelete == true) {
                          await deleteDirectionById(
                            filteredAddresses[index].id!,
                            context.read<UserProvider>().user.id,
                          );
                          /*await _loadAddresses(
                              userProvider.user.id,
                              userProvider.currentProfile,
                            );*/
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          )
        : EmptyDataMessage(
            title:
                "No hay direcciones ${type == 'INVOICE' ? 'Facturación' : 'Domiciliaria'}",
            subtitle: "Añade una dirección",
            iconData: Icons.add,
            textButton: "Agregar Dirección",
            onPressed: () {
              Navigator.pushNamed(context, Routes.addAddress);
            },
          );
  }
}

class DirectionUserCard extends StatelessWidget {
  final AddressModel addresModel;
  final Function()? onPressedDelete;
  final Function()? onPressedEdit;
  const DirectionUserCard(
      {super.key,
      required this.addresModel,
      this.onPressedDelete,
      this.onPressedEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Card(
          elevation: 0,
          color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
            side: BorderSide(
                color:
                    appStore.isDarkMode ? Colors.white24 : Colors.grey.shade300,
                width: 1), // Borde sutil
          ),
          child: Container(
            padding: const EdgeInsets.all(16), // Añade un padding interno
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (addresModel.type == TypeAdressModel.ADDRESS.name)
                  Text(
                    "Dirección de Docimicilio",
                    style: primarytextStyle(size: 16, color: simon_finalPrimaryColor),
                  ),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: simon_finalPrimaryColor,
                      child: Icon(Icons.location_on, color: Colors.white),
                    ),
                    const SizedBox(
                        width: 16), // Espacio entre el ícono y el texto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addresModel.alias ?? addresModel.firstname,
                            style: primaryTextStyle(
                                size: 16, weight: FontWeight.w700),
                          ),
                          const SizedBox(
                              height:
                                  4), // Espacio entre el nombre y la dirección
                          Text(
                            addresModel.address,
                            style: primaryTextStyle(
                                size: 12, weight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onPressedEdit ?? () {},
                          icon: const Icon(Icons.edit_outlined,
                              color: simon_finalPrimaryColor, size: 30),
                        ),
                        //SizedBox(width: 2), // Espacio entre los íconos
                        IconButton(
                          onPressed: onPressedDelete ?? () {},
                          icon: const Icon(Icons.delete_outline,
                              color: simon_finalPrimaryColor, size: 30),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
