import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/PuB/widgets/poolservice.dart';
import 'package:hog/TailorApp/Home/Api/publishservice.dart';

class PatronizeForm extends StatefulWidget {
  final String publishedId;
  const PatronizeForm({super.key, required this.publishedId});

  @override
  State<PatronizeForm> createState() => _PatronizeFormState();
}

class _PatronizeFormState extends State<PatronizeForm> {
  final _formKey = GlobalKey<FormState>();
  final specialInstructionsController = TextEditingController();
  final Map<String, TextEditingController> measurementControllers = {};

  final List<String> measurementFields = [
    "Chest",
    "Waist",
    "Hip",
    "Length",
    "Shoulder",
    "Arm Length",
    "Around Arm",
    "Wrist",
    "Collar Front",
    "Collar Back",
    "Arm Type"
  ];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var field in measurementFields) {
      measurementControllers[field] = TextEditingController();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final measurement = measurementControllers.map((key, controller) {
      if (key == "Arm Type") return MapEntry("armType", controller.text);
      return MapEntry(key.replaceAll(" ", "").toLowerCase(),
          double.tryParse(controller.text) ?? 0);
    });

    setState(() => isLoading = true);

    try {
      await PublishedService().patronizePublished(
        publishedId: widget.publishedId,
        measurement: measurement,
        specialInstructions: specialInstructionsController.text,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Order placed successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Place Order",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              TextFormField(
                controller: specialInstructionsController,
                decoration: const InputDecoration(
                  labelText: "Special Instructions",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              const Text("Measurements",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ...measurementFields.map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: measurementControllers[field],
                      decoration: InputDecoration(
                        labelText: field,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Icon(Icons.check),
                label: Text(isLoading ? "Submitting..." : "Submit Order"),
                onPressed: isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
