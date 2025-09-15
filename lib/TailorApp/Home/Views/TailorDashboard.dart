import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/TailorApp/Home/Model/materialModel.dart';
import 'package:hog/TailorApp/Widgets/DetailsTaiioesheet.dart';
import 'package:hog/TailorApp/Widgets/MaterialCard.dart';
import 'package:hog/TailorApp/Widgets/tailorAppBar.dart';
import 'package:hog/components/texts.dart';



class Tailordashboard extends StatefulWidget {
  const Tailordashboard({super.key});

  @override
  State<Tailordashboard> createState() => _TailordashboardState();
}

class _TailordashboardState extends State<Tailordashboard> {
  late Future<TailorMaterialResponse> _materialsFuture;

  @override
  void initState() {
    super.initState();
    _materialsFuture = _fetchMaterials();
  }

  Future<TailorMaterialResponse> _fetchMaterials() async {
    final token = await SecurePrefs.getToken();
    return TailorHomeService().fetchTailorMaterials(token ?? "");
  }

  Future<void> _refreshMaterials() async {
    setState(() {
      _materialsFuture = _fetchMaterials();
    });
    await _materialsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: TailorAppBar(
        title: "Tailor Materials",
        onRefresh: _refreshMaterials,
      ),
      body: SafeArea(
        child: FutureBuilder<TailorMaterialResponse>(
          future: _materialsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText("❌ Error: ${snapshot.error}"),
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return const Center(child: CustomText("No materials found"));
            }

            final materials = snapshot.data!.data;

            return RefreshIndicator(
              onRefresh: _refreshMaterials,
              color: Colors.purple,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 600;

                  return isWide
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 4 / 3,
                          ),
                          itemCount: materials.length,
                          itemBuilder: (context, index) => TailorMaterialCard(
                            material: materials[index],
                            onTap: () =>
                                _showMaterialDetails(context, materials[index]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: materials.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TailorMaterialCard(
                              material: materials[index],
                              onTap: () =>
                                  _showMaterialDetails(context, materials[index]),
                            ),
                          ),
                        );
                },
              ),
            );
          },
        ),
      ),
    );
  }

    /// Modal bottom sheet for details
  void _showMaterialDetails(BuildContext context, TailorMaterialItem material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TailorMaterialDetailSheet(material: material),
    );
  }
}