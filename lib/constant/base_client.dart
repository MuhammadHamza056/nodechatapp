import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/constant/app_exception.dart';
import 'package:flutternode/constant/hive_services.dart';
import 'package:http/http.dart' as http;


class BaseClients {
  static const int timeduration = 60;

  //GET
  static Future<http.Response> get(String baseUrl, String api) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      //  'Authorization': 'bearearToken ${HiveService.getTokken()}'
    };
    var uri = Uri.parse(baseUrl + api);
    try {
      var response = await http
          .get(uri, headers: requestHeaders)
          .timeout(const Duration(seconds: timeduration));
      return _processResponse(response);
    } on SocketException {
     EasyLoading.showError("Api not responsding...");
      throw FetchDataException(
          message: 'No Internet connection', url: uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  //POST
  static Future<http.Response> post(
      {required String baseUrl,
      required String api,
      Map<String, dynamic>? payloadObj}) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      //   'Authorization': 'bearearToken ${HiveService.getTokken()}'
    };
    var uri = Uri.parse(baseUrl + api);

    try {
      var response = await http
          .post(uri, body: jsonEncode(payloadObj), headers: requestHeaders)
          .timeout(const Duration(seconds: timeduration));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException(
          message: 'No Internet connection', url: uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  static Future<http.Response> login(
      {required String baseUrl,
      required String api,
      Map<String, dynamic>? payloadObj}) async {
    Map<String, String> requestHeaders = {'Accept': 'application/json'};
    var uri = Uri.parse(baseUrl + api);
    try {
      var response = await http
          .post(uri, body: payloadObj, headers: requestHeaders)
          .timeout(const Duration(seconds: timeduration));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException(
          message: 'No Internet connection', url: uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  //DELETE
  static Future<http.Response> delete(
      String baseUrl, String api, dynamic payloadObj) async {
    var uri = Uri.parse(baseUrl + api);
    var payload = json.encode(payloadObj);
    try {
      var response = await http
          .delete(uri, body: payload)
          .timeout(const Duration(seconds: timeduration));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException(
          message: 'No Internet connection', url: uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  //PUT
  static Future<http.Response> put(
      String baseUrl, String api, Map<String, dynamic> payloadObj) async {
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'bearearToken ${HiveService.getTokken()}'
    };
    var uri = Uri.parse(baseUrl + api);

    try {
      var response = await http
          .put(uri, body: payloadObj, headers: requestHeaders)
          .timeout(const Duration(seconds: timeduration));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException(
          message: 'No Internet connection', url: uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  static http.Response _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        Map map = jsonDecode(response.body);
       EasyLoading.showSuccess(map["message"]);
        return response;

      case 201:
        Map map = jsonDecode(response.body);
       EasyLoading.showSuccess(map["message"]);
        return response;

      case 400:
        Map map = jsonDecode(response.body);
       EasyLoading.showInfo(map["message"]);

        throw BadRequestException(
            map["message"], response.request!.url.toString());
      case 401:
        Map map = jsonDecode(response.body);
       EasyLoading.showInfo(map["message"]);
        throw UnAuthorizedException(
            map["message"], response.request!.url.toString());
      case 403:
        Map map = jsonDecode(response.body);
       EasyLoading.showInfo(map["message"]);
        throw UnAuthorizedException(
            map["message"], response.request!.url.toString());
      case 409:
        Map map = jsonDecode(response.body);
       EasyLoading.showInfo(map["message"]);

        throw BadRequestException(
            map["message"], response.request!.url.toString());
      case 422:
        Map map = jsonDecode(response.body);
       EasyLoading.showInfo(map["message"]);
        throw BadRequestException(
            map["message"], response.request!.url.toString());
      case 500:
        Map map = jsonDecode(response.body);
       EasyLoading.showInfo(map["message"]);
        throw FetchDataException(
            message: map["message"], url: response.request!.url.toString());

      default:
        Map map = jsonDecode(response.body);
       EasyLoading.showInfo(map["message"]);
        throw FetchDataException(
          message: 'No Internet connection',
          url: response.request!.url.toString(),
        );
    }
  }
}
