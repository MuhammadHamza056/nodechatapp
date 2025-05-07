import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/constant/base_client.dart';
import 'package:flutternode/constant/baseurl.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:flutternode/models/get_user_model.dart';
import 'package:flutternode/models/login_user_model.dart';

class ProviderClass extends ChangeNotifier {


  //TEXTEDIT CNOTORLLERS
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController textController = TextEditingController();

  //THESE ARE THE MODEL INSTANCES \
  GetUsersModel? getUsersModel;
  UserLoginModel? loginUser;

  bool obscureText = true;

  togglePasswordVisibility() {
    obscureText = !obscureText;
    notifyListeners();
  }

  //THIS IS SIGN UP FUNCTION
  Future<bool> signUp() async {
    EasyLoading.show(status: 'Registering...');
    try {
      Map<String, dynamic> payload = {
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      };

      var res = await BaseClients.post(
        baseUrl: baseUrl,
        api: "signup",
        payloadObj: payload,
      );
      res.body;
      return true;
    } catch (e) {
      EasyLoading.showError('Error: $e');
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  //THIS IS THE LOGIN FUNCTION
  Future<bool> login() async {
    EasyLoading.show(status: 'logging in..');
    try {
      var payload = {
        'email': emailController.text..trim(),
        'password': passwordController.text.trim(),
      };

      var res = await BaseClients.post(
        baseUrl: baseUrl,
        api: 'login',
        payloadObj: payload,
      );

      loginUser = userLoginModelFromJson(res.body);

      if (loginUser?.status == 200) {
        HiveService.putTokken(loginUser!.user!.id.toString());
        HiveService.putUserLogin(true);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      EasyLoading.showError(e.toString());
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  //THIS IS LOGOUT FUNCTION
  logOut() async {
    HiveService.deleteHiveData();
    notifyListeners();
  }

  //THIS IS FUNCTION TO GET ALL THE USERS
  getUsers() async {
    EasyLoading.show(status: 'Loading users...');
    try {
      final response = await BaseClients.get(
        baseUrl,
        'getUser?userId=${HiveService.getTokken()}',
      );

      getUsersModel = getUsersModelFromJson(response.body);

      if (getUsersModel?.data?.isEmpty ?? true) {
        throw Exception('No users found');
      }

      EasyLoading.showSuccess('Users loaded successfully');
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
      notifyListeners();
    }
  }

  clearValues() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
  }

  
}
