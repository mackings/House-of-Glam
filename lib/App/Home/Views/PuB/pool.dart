import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/PuB/widgets/poolcard.dart';
import 'package:hog/TailorApp/Home/Api/publishservice.dart';
import 'package:hog/TailorApp/Home/Model/PublishedModel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class Pool extends StatefulWidget {
  final bool showBackButton;

  const Pool({super.key, this.showBackButton = true});

  @override
  State<Pool> createState() => _PoolState();
}

class _PoolState extends State<Pool> {
  final _service = PublishedService();
  late Future<TailorPublishedResponse> _future;

  List<TailorPublished> allWorks = [];
  List<TailorPublished> filteredWorks = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllPublished();
    _future.then((response) {
      setState(() {
        allWorks = response.data;
        filteredWorks = allWorks;
      });
    });
  }

  void _filterWorks(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredWorks =
          allWorks.where((work) {
            return work.clothPublished.toLowerCase().contains(lowerQuery) ||
                work.attireType.toLowerCase().contains(lowerQuery) ||
                work.brand.toLowerCase().contains(lowerQuery);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title:
            !isSearching
                ? const Text(
                  "Check Room",
                  style: TextStyle(fontWeight: FontWeight.w700),
                )
                : Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextField(
                    autofocus: true,
                    style: const TextStyle(color: AppColors.ink),
                    cursorColor: AppColors.accent,
                    decoration: const InputDecoration(
                      hintText: "Search published works...",
                      border: InputBorder.none,
                    ),
                    onChanged: _filterWorks,
                  ),
                ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            color: AppColors.ink,
            onPressed: () {
              setState(() {
                if (isSearching) {
                  isSearching = false;
                  filteredWorks = allWorks;
                } else {
                  isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<TailorPublishedResponse>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText(
                  "Error: ${snapshot.error}",
                  color: Colors.red,
                ),
              );
            } else if (filteredWorks.isEmpty) {
              return const Center(
                child: CustomText(
                  "No published works found",
                  color: Colors.black,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
              itemCount: filteredWorks.length + 1,
              itemBuilder: (_, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          "Discover Designs & Inspiration",
                          textAlign: TextAlign.left,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                        SizedBox(height: 6),
                        CustomText(
                          "Browse completed work and latest creations from designers.",
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  );
                }
                return WorkCard(work: filteredWorks[index - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}
