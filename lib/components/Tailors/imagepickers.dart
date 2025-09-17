import 'dart:io';
import 'package:flutter/material.dart';

class MultiImagePicker extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAddImage;

  const MultiImagePicker({
    super.key,
    required this.images,
    required this.onAddImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + 1,
        itemBuilder: (context, index) {
          if (index == images.length) {
            return GestureDetector(
              onTap: onAddImage,
              child: Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: const Center(
                  child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                ),
              ),
            );
          }
          final file = images[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}
