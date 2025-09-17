import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/TailorApp/Widgets/tailorAssignedCard.dart';
import 'package:hog/TailorApp/Widgets/tailorModalsheetdetails.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class AssignedMaterials extends StatefulWidget {
  const AssignedMaterials({super.key});

  @override
  State<AssignedMaterials> createState() => _AssignedMaterialsState();
}

class _AssignedMaterialsState extends State<AssignedMaterials> {
  late Future<TailorAssignedMaterialsResponse> _futureAssignedMaterials;
  final TailorHomeService _service = TailorHomeService();

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _futureAssignedMaterials = _service.fetchAssignedMaterials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          "Assigned Materials",
          fontSize: 18,
          color: Colors.white,
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<TailorAssignedMaterialsResponse>(
          future: _futureAssignedMaterials,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText(
                  "❌ Error: ${snapshot.error}",
                  color: Colors.red,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.reviews.isEmpty) {
              return RefreshIndicator(
                onRefresh: _loadMaterials,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 200),
                    Center(
                      child: CustomText(
                        "No assigned materials found",
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            final materials = snapshot.data!.reviews;

            return RefreshIndicator(
              onRefresh: _loadMaterials,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final item = materials[index];
                  return TailorAssignedCard(
                    item: item,
                    onTap: () => showTailorMaterialDetails(context, item),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
