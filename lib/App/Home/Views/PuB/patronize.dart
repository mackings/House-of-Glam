import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/PuB/widgets/poolservice.dart';
import 'package:hog/TailorApp/Home/Api/publishservice.dart';
import 'package:hog/components/Tailors/dropdown.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';

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
    "Arm Type",
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
      return MapEntry(
        key.replaceAll(" ", "").toLowerCase(),
        double.tryParse(controller.text) ?? 0,
      );
    });

    setState(() => isLoading = true);

    try {
      await PublishedService().patronizePublished(
        publishedId: widget.publishedId,
        measurement: measurement,
        specialInstructions: specialInstructionsController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Order placed successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget buildMeasurementFields() {
    List<Widget> rows = [];
    for (var i = 0; i < measurementFields.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: MeasurementField(
                  label: measurementFields[i],
                  controller: measurementControllers[measurementFields[i]]!,
                ),
              ),
            ),
            if (i + 1 < measurementFields.length)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: MeasurementField(
                    label: measurementFields[i + 1],
                    controller:
                        measurementControllers[measurementFields[i + 1]]!,
                  ),
                ),
              ),
          ],
        ),
      );
      rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  @override
  void dispose() {
    specialInstructionsController.dispose();
    measurementControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.purple,
          title:  CustomText(
            "Patronize Work",
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CustomText("Special Instructions *",
                      //   color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                      // const Divider(),
                      CustomTextField(
                        title: "Special Instructions",
                        hintText: "e.g. Make it slim fit",
                        fieldKey: "specialInstructions",
                        controller: specialInstructionsController,
                      ),

                      const SizedBox(height: 20),
                      CustomText(
                        "Measurements *",
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      const Divider(),
                      buildMeasurementFields(),

                      const SizedBox(height: 40),
                      CustomButton(title: "Submit Order", onPressed: _submit),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
