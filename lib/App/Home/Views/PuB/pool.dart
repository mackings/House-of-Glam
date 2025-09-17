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
        title:
            const CustomText("Design Boards", color: Colors.white, fontSize: 18),
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
                child:
                    CustomText("No published works yet", color: Colors.black),
              );
            }

            final works = snapshot.data!.data;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: works.length,
              itemBuilder: (_, index) => WorkCard(work: works[index]),
            );
          },
        ),
      ),
    );
  }
}