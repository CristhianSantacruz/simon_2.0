import 'package:flutter/material.dart';
import 'package:simon_final/models/profile_modal.dart';
import 'package:simon_final/models/user_model.dart';
import 'package:simon_final/models/user_model_register.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class UserProvider extends ChangeNotifier {

  
  UserModel _user = UserModel(
    id: 0,
    name: "Sin nombre",
    email: "Sin email",
    lastName: "Sin apellido",
    typeIdentification: "Sin tipo",
    maritalStatus: "Sin estado civil",
    identification: "Sin identificación",
    profession: "Sin profesión",
    phone: "Sin teléfono",
    birthDate: "Sin fecha de nacimiento",
    approved: 0,
    verified: 0,
    verificationToken: "Sin token",
    twoFactor: 0,
  );

  UserModel _userPrincipalData = UserModel(
    id: 0,
    name: "Sin nombre",
    email: "Sin email",
    lastName: "Sin apellido",
    typeIdentification: "Sin tipo",
    maritalStatus: "Sin estado civil",
    identification: "Sin identificación",
    profession: "Sin profesión",
    phone: "Sin teléfono",
    birthDate: "Sin fecha de nacimiento",
    approved: 0,
    sexo: "Sin sexo",
    verified: 0,
    verificationToken: "Sin token",
    twoFactor: 0,
  );

  int _profile = 0;

  UserModel get user => _user;
  UserModel get userPrincipalData => _userPrincipalData;

  int get currentProfile => _profile;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    _user = UserModel(
      id: prefs.getInt('userId') ?? 0,
      name: prefs.getString('userName') ?? "Sin nombre",
      email: prefs.getString('userEmail') ?? "Sin email",
      lastName: prefs.getString('userLastName') ?? "Sin apellido",
      typeIdentification:prefs.getString('userTypeIdentification') ?? "Sin tipo",
      maritalStatus: prefs.getString('userMaritalStatus') ?? "Sin estado civil",
      identification:prefs.getString('userIdentification') ?? "Sin identificación",
      profession: prefs.getString('userProfession') ?? "Sin profesión",
      phone: prefs.getString('userPhone') ?? "Sin teléfono",
      birthDate: prefs.getString('userBirthDate') ?? "Sin fecha de nacimiento",
      approved: prefs.getInt('userApproved') ?? 0,
      professionId: prefs.getInt("profession_id") ?? 0,
      nombramiento: prefs.getString("nombramiento") ?? "Sin nombramiento",
      verified: prefs.getInt('userVerified') ?? 0,
      verificationToken:prefs.getString('userVerificationToken') ?? "Sin token",
      twoFactor: prefs.getInt('userTwoFactor') ?? 0,
    );

    _profile = prefs.getInt("userProfile") ?? 0;

    notifyListeners(); // Notificar a los listeners del cambio de estado
  }

  Future<void> setUser(UserModel user, int profile) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('userId', user.id);
    await prefs.setString('userName', user.name);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('userLastName', user.lastName ?? "Sin apellido");
    await prefs.setString('userTypeIdentification', user.typeIdentification ?? "Sin tipo");
    await prefs.setString('userMaritalStatus', user.maritalStatus ?? "Sin estado civil");
    await prefs.setString('userIdentification', user.identification ?? "Sin identificación");
    await prefs.setString('userProfession', user.profession ?? "Sin profesión");
    await prefs.setString('userPhone', user.phone ?? "Sin teléfono");
    await prefs.setString( 'userBirthDate', user.birthDate ?? "Sin fecha de nacimiento");
    await prefs.setInt("proffesion_id", user.professionId ?? 0);
    await prefs.setString("nombramiento", user.nombramiento ?? "Sin nombramiento");
    await prefs.setInt('userApproved', user.approved ?? 0);
    await prefs.setInt('userVerified', user.verified ?? 0);
    await prefs.setString('userVerificationToken', user.verificationToken ?? "Sin token");
    await prefs.setInt('userTwoFactor', user.twoFactor ?? 0);
    await prefs.setInt("userProfile", profile);
    loadUser();
    

  }

  Future<void> setUserPrincipalData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userNamePrincipal', user.name);
    await prefs.setString('userEmailPrincipal', user.email);
    await prefs.setString('userLastNamePrincipal', user.lastName ?? "Sin apellido");
    await prefs.setString('userTypeIdentificationPrincipal', user.typeIdentification ?? "Sin tipo");
    await prefs.setString('userMaritalStatusPrincipal', user.maritalStatus ?? "Sin estado civil");
    await prefs.setString('userIdentificationPrincipal', user.identification ?? "Sin identificación");
    await prefs.setString('userPhonePrincipal', user.phone ?? "Sin teléfono");
    await prefs.setString( 'userBirthDatePrincipal', user.birthDate ?? "Sin fecha de nacimiento");
    await prefs.setInt("proffesion_idPrincipal", user.professionId ?? 0);
    await prefs.setString("nombramientoPrincipal", user.nombramiento ?? "Sin nombramiento");
    await prefs.setString("sexoPrincipal", user.sexo ?? "Sin sexo");
    _userPrincipalData = user;
    notifyListeners();
    loadUserPrincipalData();

  }

  Future<void> loadUserPrincipalData() async {
    final prefs = await SharedPreferences.getInstance();

    _userPrincipalData = UserModel(
      id: prefs.getInt('userId') ?? 0,
      name: prefs.getString('userNamePrincipal') ?? "Sin nombre",
      email: prefs.getString('userEmailPrincipal') ?? "Sin email",
      lastName: prefs.getString('userLastNamePrincipal') ?? "Sin apellido",
      typeIdentification:prefs.getString('userTypeIdentificationPrincipal') ?? "Sin tipo",
      maritalStatus: prefs.getString('userMaritalStatusPrincipal') ?? "Sin estado civil",
      identification:prefs.getString('userIdentificationPrincipal') ?? "Sin identificación",
      phone: prefs.getString('userPhonePrincipal') ?? "Sin teléfono",
      sexo: prefs.getString('sexoPrincipal') ?? "Sin sexo",
      birthDate: prefs.getString('userBirthDatePrincipal') ?? "Sin fecha de nacimiento",
      approved: prefs.getInt('userApproved') ?? 0,
      professionId: prefs.getInt("proffesion_idPrincipal") ?? 0,
      nombramiento: prefs.getString("nombramientoPrincipal") ?? "Sin nombramiento",
      verified: prefs.getInt('userVerified') ?? 0,
      verificationToken:prefs.getString('userVerificationToken') ?? "Sin token",
      twoFactor: prefs.getInt('userTwoFactor') ?? 0,
    );

    notifyListeners(); // Notificar a los listeners del cambio de estado
  }

  Future<void> setProfileData(int profile,ProfileModel profileUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("userProfile", profile);
    await prefs.setString("userName", profileUser.name);
    await prefs.setString("userEmail", profileUser.email);
    await prefs.setString("userLastName", profileUser.lastName );
    await prefs.setString("userTypeIdentification", profileUser.typeIdentification);
    await prefs.setString("userMaritalStatus", profileUser.maritalStatus );
    await prefs.setString("userIdentification", profileUser.identification );
    await prefs.setString("userPhone", profileUser.phone);
    await prefs.setString( "userBirthDate", profileUser.birthDate.year.toString().padLeft(4, '0'));
    await prefs.setInt("proffesion_id", profileUser.profileModelDefault);
    await prefs.setString("nombramiento", profileUser.nombramiento ?? "Sin nombramiento");
     loadUser();
  }

  Future<void> setProfile(int profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("userProfile", profile);
    _profile = profile;
    notifyListeners();
  }

  Future<void> updateUser(UserModelRegiser user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userName', user.name);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('userLastName', user.lastName );
    await prefs.setString('userTypeIdentification', user.typeIdentification);
    await prefs.setString('userMaritalStatus', user.maritalStatus );
    await prefs.setString('userIdentification', user.identification );
    await prefs.setString('userPhone', user.phone );
    await prefs.setString( 'userBirthDate', user.birthDate.toIso8601String());
    await prefs.setString("nombramiento", user.nombramiento ?? "Sin nombramiento");
  
    await loadUser();
  }

  Future<void> updateUserPrincipal(UserModelRegiser userRegister) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userNamePrincipal', userRegister.name);
    await prefs.setString('userLastNamePrincipal', userRegister.lastName ?? "Sin apellido");
    await prefs.setString('userTypeIdentificationPrincipal', userRegister.typeIdentification ?? "Sin tipo");
    await prefs.setString('userMaritalStatusPrincipal', userRegister.maritalStatus ?? "Sin estado civil");
    await prefs.setString('userIdentificationPrincipal', userRegister.identification ?? "Sin identificación");
    await prefs.setString('userPhonePrincipal', userRegister.phone ?? "Sin teléfono");
    await prefs.setString( 'userBirthDatePrincipal', DateFormat('yyyy-MM-dd').format(userRegister.birthDate));
    await prefs.setInt("proffesion_idPrincipal", userRegister.profession_id);
    await prefs.setString("nombramientoPrincipal", userRegister.nombramiento ?? "Sin nombramiento");
    await prefs.setString("sexoPrincipal", userRegister.sexo ?? "Sin sexo");
    loadUserPrincipalData();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = UserModel(
      id: 0,
      name: "Sin nombre",
      email: "Sin email",
      lastName: "Sin apellido",
      typeIdentification: "Sin tipo",
      maritalStatus: "Sin estado civil",
      identification: "Sin identificación",
      profession: "Sin profesión",
      phone: "Sin teléfono",
      birthDate: "Sin fecha de nacimiento",
      sexo: "Sin sexo",
      approved: 0,
      verified: 0,
      verificationToken: "Sin token",
      twoFactor: 0,
    );
    _userPrincipalData = UserModel(
      id: 0,
      name: "Sin nombre",
      email: "Sin email",
      lastName: "Sin apellido",
      typeIdentification: "Sin tipo",
      maritalStatus: "Sin estado civil",
      identification: "Sin identificación",
      profession: "Sin profesión",
      phone: "Sin teléfono",
      birthDate: "Sin fecha de nacimiento",
      approved: 0,
      sexo: "Sin sexo",
      verified: 0,
      verificationToken: "Sin token",
      twoFactor: 0,
    );

    _profile = 0;
    
    notifyListeners();
  }
}
