import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutternode/widget/full_iamge_view.dart'; // Update with your actual import path

class ImageMessageWidget extends StatelessWidget {
  final String fileUrl;
  final BuildContext context;
  final bool isMe;

  const ImageMessageWidget({
    super.key,
    required this.fileUrl,
    required this.context,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📷 Photo',
          style: TextStyle(
            color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey[700],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImage(imageUrl: fileUrl),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: fileUrl,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget: (context, url, error) {
                debugPrint('Image load error: $error');
                debugPrint('The error is: $fileUrl');
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error),
                      Text('Failed to load image\n$fileUrl'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
