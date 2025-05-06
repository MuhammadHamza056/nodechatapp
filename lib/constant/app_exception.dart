

import 'package:flutter_easyloading/flutter_easyloading.dart';

class AppException implements Exception {
  final String? message;
  final String? prefix;
  final String? url;

  AppException([this.message, this.prefix, this.url]);
}

class BadRequestException extends AppException {
  @override
  // ignore: overridden_fields
  final String? message,url;
  BadRequestException([this.message, this.url]);
   @override
  String toString() {
    EasyLoading.showError(message!);
    return "$message: $url";
  }
}

class FetchDataException extends AppException {
    @override
      // ignore: overridden_fields
      final String? message,url;
  FetchDataException({required this.message, this.url});
   @override
  String toString() {
        EasyLoading.showError(message!);
    return "$message: $url";
  }
}

class ApiNotRespondingException extends AppException {
      @override
        // ignore: overridden_fields
        final String? message,url;
  ApiNotRespondingException([this.message, this.url]);

   @override
  String toString() {
        EasyLoading.showError(message!);
    return "$message: $url";
  }
}

class UnAuthorizedException extends AppException {
 @override
  // ignore: overridden_fields
  final String? message,url;
  UnAuthorizedException([this.message, this.url]);

   @override
  String toString() {
        EasyLoading.showError(message!);
    return "$message: $url";
  }
}

class DuplicateException extends AppException {
 @override
  // ignore: overridden_fields
  final String? message,url;
  DuplicateException([this.message, this.url]);

   @override
  String toString() {
        EasyLoading.showError(message!);
    return "$message: $url";
  }
}

class Exception404 extends AppException {
 @override
  // ignore: overridden_fields
  final String? message,url;
  Exception404([this.message, this.url]);

   @override
  String toString() {
        EasyLoading.showError(message!);
    return "$message: $url";
}
}