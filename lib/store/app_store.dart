import 'package:flutter/material.dart';
import 'package:simon_final/models/user_model.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

part 'app_store.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  _AppStore() {
    _loadDarkModePreference();
  }

  @observable
  bool isDarkMode = false;

  @action
  Future<void> setDarkMode(bool val) async {
    isDarkMode = val;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = textSecondaryColor;
      defaultLoaderBgColorGlobal = scaffoldDarkColor;
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;
      defaultLoaderBgColorGlobal = Colors.white;
    }

    _saveDarkModePreference(isDarkMode);
  }

  _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode = (prefs.getBool('isDarkMode') ?? false);
  }

  _saveDarkModePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  Future<void> saveUser(UserModel user) async {
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
    await prefs.setString('userBirthDate', user.birthDate ?? "Sin fecha de nacimiento");
    await prefs.setInt("profession_id", user.professionId ?? 0);
    await prefs.setString("nombramiento", user.nombramiento ?? "Sin nombramiento");
    await prefs.setInt('userApproved', user.approved ?? 0);
    await prefs.setInt('userVerified', user.verified ?? 0);
    await prefs.setString('userVerificationToken', user.verificationToken ?? "Sin token");
    await prefs.setInt('userTwoFactor', user.twoFactor ?? 0);
  }
  

  Future<UserModel> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return UserModel(
      id: prefs.getInt('userId') ?? 0,
      name: prefs.getString('userName') ?? "Sin nombre",
      email: prefs.getString('userEmail') ?? "Sin email",
      lastName: prefs.getString('userLastName') ?? "Sin apellido",
      typeIdentification: prefs.getString('userTypeIdentification') ?? "Sin tipo",
      maritalStatus: prefs.getString('userMaritalStatus') ?? "Sin estado civil",
      identification:prefs.getString('userIdentification') ?? "Sin identificación",
      profession: prefs.getString('userProfession') ?? "Sin profesión",
      phone: prefs.getString('userPhone') ?? "Sin teléfono",
      birthDate: prefs.getString('userBirthDate') ?? "Sin fecha de nacimiento",
      approved: prefs.getInt('userApproved') ?? 0,
      verified: prefs.getInt('userVerified') ?? 0,
      verificationToken:prefs.getString('userVerificationToken') ?? "Sin token",
      twoFactor: prefs.getInt('userTwoFactor') ?? 0,
      professionId: prefs.getInt("profession_id") ?? 0,
      nombramiento: prefs.getString("nombramiento") ?? "Sin nombramiento",
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
