import 'dart:io'; // For File class if needed
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FileUploadService {
  static Future<void> sendFile(String chatId, String senderId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        String fileName = file.name;
        Uint8List fileBytes =
            file.bytes ?? await File(file.path!).readAsBytes();

        // Determine content type
        String contentType;
        if (fileName.toLowerCase().endsWith('.pdf')) {
          contentType = 'application/pdf';
        } else if (fileName.toLowerCase().endsWith('.png')) {
          contentType = 'image/png';
        } else if (fileName.toLowerCase().endsWith('.jpg') ||
            fileName.toLowerCase().endsWith('.jpeg')) {
          contentType = 'image/jpeg';
        } else if (fileName.toLowerCase().endsWith('.gif')) {
          contentType = 'image/gif';
        } else {
          EasyLoading.showError('Unsupported file type');
          return;
        }

        var dio = Dio();
        FormData formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(
            fileBytes,
            filename: fileName,
            contentType: DioMediaType.parse(contentType),
          ),
          "chatId": chatId,
          "senderId": senderId,
          "type":
              fileName.toLowerCase().endsWith('.pdf') ? 'document' : 'image',
        });

        var response = await dio.post(
          'http://172.17.2.20:3000/users/upload',
          data: formData,
          onSendProgress: (sent, total) {
            double progress = (sent / total) * 100;
            EasyLoading.showProgress(
              progress / 100,
              status: 'Uploading... ${progress.toStringAsFixed(1)}%',
            );
          },
        );
        debugPrint('this is the image :${response.data}');

        if (response.statusCode == 200) {
          EasyLoading.showSuccess('File uploaded successfully');
        } else {
          EasyLoading.showError(
            response.data['message'] ??
                'Upload failed with status ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      EasyLoading.showError(
        e is DioException
            ? e.response?.data['message'] ?? e.message
            : 'Upload failed',
      );
    }
  }
  
}
