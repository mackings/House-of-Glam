import 'dart:io';
import 'package:flutter/material.dart';

class MultiImagePicker extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAddImage;
  final Function(int) onRemoveImage;

  const MultiImagePicker({
    Key? key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...images.asMap().entries.map((entry) {
              int index = entry.key;
              File image = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(image, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => onRemoveImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
            if (images.length < 5)
              GestureDetector(
                onTap: onAddImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
