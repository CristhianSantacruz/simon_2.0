import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simon_final/models/car_brand_model.dart';
import 'package:simon_final/models/color_model.dart';
import 'package:simon_final/models/type_vehicle_model.dart';
import 'package:simon_final/models/vehicle_document_user.dart';
import 'package:simon_final/models/vehicle_model.dart';
import 'package:simon_final/models/vehicle_user_model.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';
import 'package:simon_final/utils/messages_toast.dart';


class VehiclesUserServices {
  final String baseUrl = ApiRoutes.baseUrl;
  final String vehicleEndpoint = ApiRoutes.vehicleEndpoint;
  final String getVehicleDocumentType = ApiRoutes.getVehicleDocumentType;
  final String uploadVehicleDocumentEndpoint = ApiRoutes.uploadVehicleDocument;
  final String getModelsCar = ApiRoutes.getModels;
  final String getBrandsCar = ApiRoutes.getBrands;
  final String getVehicleTypeCar = ApiRoutes.getVehicleType;
  final String getColorsCar = ApiRoutes.getColors;

    final dio = DioClient().dio;

  Future<List<VehicleModelUser>> getVehiclesByUserId(int userId,int profileId) async {
    try {
      final response = await dio.get('$baseUrl$vehicleEndpoint/$userId',queryParameters: {
        "profile_id": profileId
      } );
      if (response.statusCode == 200) {
        Map<String, dynamic> body = response.data;
        List<dynamic> vehicles = body['data']['userVehicles'];
        vehicles.map((item) =>debugPrint(VehicleModelUser.fromJson(item).toString()))
            .toList();
        vehicles.map((item) => debugPrint("Vechiulo"));
        return vehicles.map((item) => VehicleModelUser.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load vehicles. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to load vehicles: ${e.message}');
    }
  }
Future<String> createVehicle(VehicleModelUser vehicle,int profileId) async {
  try {
     final Map<String, dynamic> data = vehicle.toJson();
     data["profile_id"] = profileId;

     debugPrint("CREACION DEL VEHICULO");
     debugPrint(data.toString());
    final response = await dio.post('$baseUrl$vehicleEndpoint', data: data);
      if (response.statusCode == 201 && response.data['status'] == true) {
          Map<String, dynamic> body = response.data;
          String message = body['message'] ?? 'Vehículo registrado correctamente';
          return message; // Retorna el mensaje de éxito
        }
    else if (response.statusCode == 400 && response.data['status'] == false) {
      Map<String, dynamic> body = response.data;
      if (body.containsKey('error')) {
        Map<String, dynamic> error = body['error'];
        String errorMessage = '';

        error.forEach((key, value) {
          errorMessage += '$key: ${value.join(', ')}\n';
        });
        MessagesToast.showMessageError('$errorMessage');
        throw Exception('Faile to create 1 $errorMessage');
      } else {
        throw Exception('Failed to create vehicle. Unspecified error.');
      }
    } else {
      throw Exception('Failed to create vehicle. Status code: ${response.statusCode}');
    }
  } on DioException catch (e) {
    throw Exception('Failed to create vehicle: ${e.message}');
  }
}

  Future<List<VehicleDocumentTypeModel>> getVehicleDocumentTypes(
      int idVehicle, int userId,int profileId) async {
    try {
      final response = await dio.get('$baseUrl$getVehicleDocumentType', data: {
        'user_id': userId,
        'profile_id': profileId,
        'vehicle_id': idVehicle,
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> body = response.data;
        List<dynamic> documents = body['data']['vehicleDocumentTypes'];
        return documents
            .map((item) => VehicleDocumentTypeModel.fromJson(item))
            .toList();
      } else {
        throw Exception('${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load documents: ${e.message}');
    }
  }

  Future<String> updateVehicle(VehicleModelUser vehicle,int profileId) async {
    debugPrint("Metodo updateVehicle");

    Map<String, dynamic> data = vehicle.toJson();
    data["profile_id"] = profileId;
    try {
      final response = await dio.put('$baseUrl$vehicleEndpoint', data: data);
      if (response.statusCode == 200) {
        Map<String, dynamic> body = response.data;
        return body['message'];
      } else {
        throw Exception(
            'Failed to update vehicle. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint("Error del servicio de updateVehicle ${e.message}");
      throw Exception('Failed to update vehicle: ${e.message}');
    }
  }

  Future<String> deleteVehicleById(int idVehicle) async {
    try {
      final response = await dio.delete('$baseUrl$vehicleEndpoint/$idVehicle');
      if (response.statusCode == 200 && response.data['status'] == true) {
        Map<String, dynamic> body = response.data;
        return body['message'];
      } else {
        return "Vehiculo no encontrado";
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete vehicle : ${e.message}');
    }
  }

  Future<void> uploadVehiculeDocument(
      String nameDocument,
      String vehicleDocumentFilePath,
      String? secondvehicleDocumentFilePath,
      int userId,
      int vehicleId,
      int profileId,
      int vehicleDocumentTypeId) async {
    debugPrint("Metodo uploadVehiculeDocument");
    try {
      Map<String, dynamic> formDataMap = {
        'name': nameDocument,
        'user_id': userId,
        'vehicle_id': vehicleId,
        'profile_id': profileId,
        'vehicle_document_types_id': vehicleDocumentTypeId,
        'file': await MultipartFile.fromFile(vehicleDocumentFilePath,
            filename: nameDocument),
      };

      if (secondvehicleDocumentFilePath != null &&
          secondvehicleDocumentFilePath.isNotEmpty) {
        formDataMap['file2'] = await MultipartFile.fromFile(
            secondvehicleDocumentFilePath,
            filename: nameDocument);
      }
      ;

      FormData formData = FormData.fromMap(formDataMap);
      // Realiza la solicitud POST
      Response response = await dio.post(
        '$baseUrl$uploadVehicleDocumentEndpoint',
        data: formData,
      );
      debugPrint("response.data: ${response.data}");
      debugPrint("El user id es $userId");
      if (response.statusCode == 200) {
        final message = response.data['message'];
        return;
      } else {
        throw Exception(
            'Failed to load documents. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error subir documento al enviar la solicitud: $e");
      MessagesToast.showMessageError("Error al subir el documento");
    }
  }

  Future<List<VehicleModel>> getModels() async {
    try {
      final response = await dio.get("$baseUrl$getModelsCar");
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> models = response.data['data']['vehicleModels'];
        return models.map((model) => VehicleModel.fromJson(model)).toList();
      }
    } on DioException catch (e) {
      throw Exception('Fallo al cargar los modelos de vehiculo: ${e.message}');
    }
    throw Exception("Fallo al cargar las profesiones");
  }

  Future<List<CarBrandModel>> getBrands() async {
    try {
      final response = await dio.get("$baseUrl$getBrandsCar");
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> brands = response.data['data']['carBrands'];
        // debugPrint("Mis marcas ${brands.toString()}");
        return brands.map((brand) => CarBrandModel.fromJson(brand)).toList();
      }
    } on DioException catch (e) {
      throw Exception("Fallo al cargar las marcas del documento ${e.message}");
    }
    throw Exception("Fallo al cargar las marcas");
  }

  Future<List<TypeVehicleModel>> getVehicleType() async {
    try {
      final response = await dio.get("$baseUrl$getVehicleTypeCar");
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> types = response.data['data']['vehicleTypes'];
        //  debugPrint("Mis tipos ${types.toString()}");
        return types.map((type) => TypeVehicleModel.fromJson(type)).toList();
      }
    } on DioException catch (e) {
      throw Exception("Fallo al cargar los tipos de vehiculo ${e.message}");
    }
    throw Exception("Fallo al cargar los tipos de vehiculo");
  }

  Future<List<ColorModel>> getColors() async {
    try {
      final response = await dio.get("$baseUrl$getColorsCar");
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> colors = response.data['data']['colors'];
        return colors.map((color) => ColorModel.fromJson(color)).toList();
      }
    } on DioException catch (e) {
      throw Exception("Fallo al cargar los colores ${e.message}");
    }
    throw Exception("Fallo al cargar los colores");
  }

Future<bool> deleteDocumentUpload(int vehicleDocumentId) async {
  debugPrint("Metodo deleteDocumentUpload");
  try {
    Response response = await dio.delete(
      '$baseUrl/vehicle-documents/$vehicleDocumentId',
    );

    if (response.statusCode == 200) {
      debugPrint("Se elimino correctamente");
      return true;
    } else {
       debugPrint("No se elimino correctamente");
      throw Exception('Failed to delete document. Status code: ${response.statusCode}');
    }
  } on DioException catch (e) {
     debugPrint("No se elimino correctamente 2");
    throw Exception('Fallo al intentar eliminar el documento: ${e.message}');
  }

}

}
