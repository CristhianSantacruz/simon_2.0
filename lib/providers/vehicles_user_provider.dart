import 'package:simon_final/models/vehicle_user_model.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/vehicles_user_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/messages_toast.dart';

class VehicleProvider with ChangeNotifier {
  List<VehicleModelUser> _vehicleList = [];
  bool _isLoading = true;
  bool _error = false;

  List<VehicleModelUser> get vehicleList => _vehicleList;
  bool get isLoading => _isLoading;
  bool get error => _error;

  final VehiclesUserServices _vehicleService = VehiclesUserServices();

  Future<void> fetchVehicles(int userId,int profileId) async {
    try {
      List<VehicleModelUser> fetchedVehicles = await _vehicleService.getVehiclesByUserId(userId,profileId);
      _vehicleList = fetchedVehicles;
    } catch (e) {
      _error = true;
    }
    _isLoading = false;
    _error = false;
    notifyListeners();
  }

  Future<void> deleteVehicleById(int idVehicle, BuildContext context,final userId,final profileId) async {
    try {
      final message = await _vehicleService.deleteVehicleById(idVehicle);
      MessagesToast.showMessageSuccess(message);
      _vehicleList.removeWhere((vehicle) => vehicle.id == idVehicle);
      notifyListeners();
     if (_vehicleList.length > 1){
        await fetchVehicles(_vehicleList.first.userId,profileId); 
     }
    } on Exception catch (e) {
      toast(
        e.toString(),
        bgColor: Colors.red,
        textColor: white_color,
        gravity: ToastGravity.TOP,
      );
    }
  }
  Future<void> resetAndFetchVehicles(int userId, int newProfileId) async {
    _vehicleList = []; 
    _isLoading = true;
    _error = false;
    notifyListeners();

    await fetchVehicles(userId, newProfileId);
  }

  Future<void> resetVehicleList() async {
    _vehicleList = [];
    _isLoading = true;
    _error = false;
    notifyListeners();
  }

  
}


