import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/PuB/widgets/imageEnlarge.dart';
import 'package:hog/TailorApp/Home/Model/PublishedModel.dart';
import 'package:hog/components/texts.dart';



class UserInfo extends StatelessWidget {
  final TailorUser user;

  const UserInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (user.image != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImage(
                    imageUrl: user.image!,
                    tag: "user_${user.id}",
                  ),
                ),
              );
            }
          },
          child: Hero(
            tag: "user_${user.id}",
            child: CircleAvatar(
              radius: 22,
              backgroundImage:
                  user.image != null ? NetworkImage(user.image!) : null,
              backgroundColor: Colors.purple[100],
              child: user.image == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              user.fullName,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            if (user.address != null)
              CustomText(
                user.address!,
                fontSize: 12,
                color: Colors.black54,
              ),
          ],
        ),
      ],
    );
  }
}