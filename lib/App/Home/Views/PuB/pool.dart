import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/PuB/widgets/poolcard.dart';
import 'package:hog/TailorApp/Home/Api/publishservice.dart';
import 'package:hog/TailorApp/Home/Model/PublishedModel.dart';
import 'package:hog/components/texts.dart';



class Pool extends StatefulWidget {
  const Pool({super.key});

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
      filteredWorks = allWorks.where((work) {
        return work.clothPublished.toLowerCase().contains(lowerQuery) ||
               work.attireType.toLowerCase().contains(lowerQuery) ||
               work.brand.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: !isSearching
            ? const CustomText(
                "Check room",
                color: Colors.white,
                fontSize: 18,
              )
            : TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: "Search materials...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: _filterWorks,
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),color: Colors.white,
            onPressed: () {
              setState(() {
                if (isSearching) {
                  // Close search
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
              return const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
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
              padding: const EdgeInsets.all(12),
              itemCount: filteredWorks.length,
              itemBuilder: (_, index) => WorkCard(work: filteredWorks[index]),
            );
          },
        ),
      ),
    );
  }
}

