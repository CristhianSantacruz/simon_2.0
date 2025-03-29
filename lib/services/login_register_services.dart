

import 'package:simon_final/main.dart';
import 'package:simon_final/models/profile_modal.dart';
import 'package:simon_final/models/user_model.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/services/profiles_services.dart';
//import 'package:simon_final/services/preferences_user.dart';
import 'package:simon_final/utils/api_routes.dart';


class LoginService {
  static const String baseUrl = ApiRoutes.baseUrl;
  static const String LOGIN = ApiRoutes.login;
  static const String REGISTER = ApiRoutes.register;
  static const String PROFILE = ApiRoutes.profiles;

  final dio = DioClient().dio;
  final profileServices = ProfilesServices();

Future<Map<String, dynamic>> login(String email, String password,UserProvider userProvider) async {
  try {
    
    dio.options.validateStatus = (status) {
      return status! < 500; // Solo lanza excepciones para errores 5xx 
    };

    final response = await dio.post(
      '$baseUrl$LOGIN',
      data: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200 || response.data['status'] == true) {
       final user = UserModel.fromJson(response.data['user']);
       final userId = response.data['user']['id'];
       final profileResponse = await dio.get("$baseUrl$PROFILE?user_id=$userId");
       if (profileResponse.statusCode == 200 || profileResponse.data['status'] == true) {
         final profile = ProfileModel.fromJson(profileResponse.data['data']['profiles'].first);
         await userProvider.setUser(user,profile.id);
         await userProvider.setProfile(profile.id);
         await userProvider.setUserPrincipalData(user);
         await appStore.saveUser(user);
         return {'success': true, 'user': user};
       }else {
         return {'success': false, 'error': response.data['error'] ?? 'Error en el profile'};
       }
    }
    else if (response.statusCode == 404) {
      // Usuario no encontrado
      return {'success': false, 'error': response.data['error'] ?? 'No se encontró la URL'};
    } 
    else if(response.statusCode == 401){
      // Contrasenia incorrecta
      return {'success':false , 'error':response.data['error'] ?? 'No se encontro la URL'};
    }
    else {
      return {'success': false, 'error': 'Error desconocido'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Ocurrio un error en el servidor'};
  }
}

 Future<bool> uploadToken(String token,String userId) async {
  try {
     final response = await dio.post('$baseUrl/device-token', data: {'user_id': userId, 'token': token});
     if (response.statusCode == 200 && response.data['status'] == true) {
       return true;
     }
    return true;
  } catch (e) {
    return false;
  } 

}


Future<Map<String, dynamic>> register(String email, String password, String userName) async {
  try {
    
    dio.options.validateStatus = (status) {
      return status! < 500; // Solo lanza excepciones para errores 5xx 
    };

    final response = await dio.post(
      '$baseUrl$REGISTER',
      data: {
        'email': email,
        'password': password,
        'userName': userName,
      },
    );
    if (response.statusCode == 200) {
      return {'success': true, 'user': userName};
    }else {
      return {'success': false, 'error': response.data['error'] ?? 'No se encontró la URL'};
    }

 } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
}

