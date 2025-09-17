import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/publishservice.dart';
import 'package:hog/TailorApp/Home/Model/PublishedModel.dart';
import 'package:hog/TailorApp/Home/Views/Publish.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';


class Myworks extends StatefulWidget {
  const Myworks({super.key});

  @override
  State<Myworks> createState() => _MyworksState();
}

class _MyworksState extends State<Myworks> {
  final _service = PublishedService();
  late Future<TailorPublishedResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllPublished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const CustomText("My works", color: Colors.white, fontSize: 18),
        actions: [
          GestureDetector(
            onTap: () {
              Nav.push(context, PublishMaterial());
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.upload_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<TailorPublishedResponse>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText("Error: ${snapshot.error}", color: Colors.red),
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return const Center(
                child: CustomText("No published works yet", color: Colors.black),
              );
            }

            final works = snapshot.data!.data;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: works.length,
              itemBuilder: (_, index) {
                final work = works[index];

// ✅ Format published date
String formattedDate = "Unknown date";
try {
  formattedDate = DateFormat("d MMMM y • h:mma").format(work.createdAt);
} catch (e) {
  debugPrint("Date format error: $e");
}


                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🖼 Image preview
                      if (work.sampleImage.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(
                            work.sampleImage.first,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & category
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  work.clothPublished,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                                const Icon(Icons.check_circle,
                                    color: Colors.purple, size: 20),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Attire type & brand
                            Row(
                              children: [
                                const Icon(Icons.category,
                                    size: 16, color: Colors.black54),
                                const SizedBox(width: 6),
                                CustomText(work.attireType,
                                    color: Colors.black87),
                                const Spacer(),
                                const Icon(Icons.shopping_bag,
                                    size: 16, color: Colors.black54),
                                const SizedBox(width: 6),
                                CustomText(work.brand, color: Colors.black87),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Color
                            Row(
                              children: [
                                const Icon(Icons.color_lens,
                                    size: 16, color: Colors.black54),
                                const SizedBox(width: 6),
                                CustomText(work.color, color: Colors.black87),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // 📅 Published date
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: Colors.black54),
                                const SizedBox(width: 6),
                                CustomText(
                                  formattedDate,
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // User details
                            if (work.user != null)
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: work.user!.image != null
                                        ? NetworkImage(work.user!.image!)
                                        : null,
                                    backgroundColor: Colors.purple[100],
                                    child: work.user!.image == null
                                        ? const Icon(Icons.person,
                                            color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        work.user!.fullName,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                      if (work.user!.address != null)
                                        CustomText(
                                          work.user!.address!,
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

