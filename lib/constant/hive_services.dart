
import 'package:hive_flutter/hive_flutter.dart';
class HiveService {
  static String userId = 'USERID';
  static String empId = 'EMPID';
  static String name = 'NAME';
  static String designation = 'DESIGNATION';
  static String userName = 'USERNAME';
  static String password = 'PASSWORD';
  static String tokken = 'TOKKEN';
  static String rememberMe = 'REMEMBERME';
  static String company = "COMPANY";
  static String login = "ISLOGIN";
  static String role = "ROLE";
  static String code = "CODE";
  static Box? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('SessionDetails');
  }

  static void putUserId(int value) {
    _box!.put(userId, value);
  }

  static void putUserLogin(bool value) {
    _box!.put(login, value);
  }

  static int getUserId() {
    return _box!.get(userId);
  }

  static void putName(String value) {
    _box!.put(name, value);
  }

  static String? getName() {
    return _box!.get(name);
  }

  static void putEmpId(String value) {
    _box!.put(empId, value);
  }

  static String? getEmpId() {
    return _box!.get(empId);
  }

  static void putDesignation(String value) {
    _box!.put(designation, value);
  }

  static String getDesignation() {
    return _box!.get(designation);
  }

  static void putUserName(String value) {
    _box!.put(userName, value);
  }

  static String getUserName() {
    return _box!.get(userName);
  }

  static void putPassword(String value) {
    _box!.put(password, value);
  }

  static String getPassword() {
    return _box!.get(password);
  }

  static void putTokken(String value) {
    _box!.put(tokken, value);
  }

  static String getTokken() {
    return _box!.get(tokken);
  }

  static void putCompany(String value) {
    _box!.put(company, value);
  }

  static String? getCompany() {
    return _box?.get(company);
  }

  static void putRole(String value) {
    _box!.put(role, value);
  }

  static String? getRole() {
    return _box?.get(role);
  }

  static void putCode(String value) {
    _box!.put(code, value);
  }

  static String? getCode() {
    return _box?.get(code);
  }

  static void putRemember(bool value) {
    _box!.put(rememberMe, value);
  }

  static bool getRemember() {
    return _box!.get(rememberMe) ?? false;
  }

  static bool getUserLogin() {
    return _box!.get(login) ?? false;
  }

  static deleteHive() async {
    // Clear the Hive data
    await _box!.clear();

    // Close the box
    await _box!.close();

    // Delete the box from disk
    await _box!.deleteFromDisk();
  }

  static deleteHiveData() async {
    _box!.put(userId, null);
    _box!.put(empId, null);
    _box!.put(name, null);
    _box!.put(designation, null);
    _box!.put(userName, null);
    _box!.put(password, null);
    _box!.put(tokken, null);
    _box!.put(company, null);
    _box!.put(rememberMe, false);
    _box!.put(login, false);
    _box!.put(code, null);
  }
}