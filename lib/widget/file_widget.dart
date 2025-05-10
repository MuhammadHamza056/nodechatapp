import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutternode/constant/baseurl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileMessageWidget extends StatelessWidget {
  final String fileName;
  final String fileUrl;
  final bool isMe;

  const FileMessageWidget({
    super.key,
    required this.fileName,
    required this.fileUrl,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final filePath = fileUrl.replaceFirst('/uploads/', '');
    final downloadUrl = '$imageUrl/users/download/$filePath';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📄 File',
          style: TextStyle(
            color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey[700],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[400] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFileIcon(fileName),
                color: isMe ? Colors.white : Colors.blue,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  fileName,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.download,
                  color: isMe ? Colors.white : Colors.blue,
                ),
                onPressed: () => downloadFile(context, downloadUrl, fileName),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  // // File download handler
  Future<void> downloadFile(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    try {
      // REQUEST PERMISSIONS
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.request().isGranted) {
          // FOR ANDROID 11+
        } else if (await Permission.storage.request().isGranted) {
          // FOR OLDER VERSIONS
        } else {
          return;
        }
      } else if (Platform.isIOS) {
        // IOS PERMISSIONS IF NEEDED
      }

      // GET DIRECTORY - BETTER TO USE DOWNLOADS DIRECTORY
      final dir =
          Platform.isAndroid
              ? await getDownloadsDirectory()
              : await getApplicationDocumentsDirectory();

      if (dir == null) {
        EasyLoading.showError('Could not access storage');
        return;
      }

      final file = File('${dir.path}/$fileName');

      var dio = Dio();
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            EasyLoading.showProgress(
              received / total,
              status: 'Downloading... ($progress%)',
            );
          }
        },
      );

      await file.writeAsBytes(response.data);
      EasyLoading.showSuccess('Download complete');

      if (await file.exists()) {
        await OpenFile.open(file.path);
      }
    } catch (e) {
      debugPrint(e.toString());
      EasyLoading.showError('Failed: ${e.toString()}');
    }
  }
}
