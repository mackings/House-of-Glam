import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/PuB/widgets/poolservice.dart';
import 'package:hog/TailorApp/Home/Api/publishservice.dart';
import 'package:hog/components/Tailors/dropdown.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

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
    for (final controller in measurementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: SafeArea(
        top: true,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              26,
              20,
              MediaQuery.of(context).viewInsets.bottom + 28,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "Patronize Work",
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 2),
                            CustomText(
                              "Add your measurements and any special instruction before placing the order.",
                              fontSize: 12,
                              color: AppColors.subtext,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF9F5FF), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.checkroom_rounded,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: CustomText(
                            "Use accurate body measurements so the designer can process the request correctly.",
                            fontSize: 13,
                            color: AppColors.subtext,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    title: "Special Instructions",
                    hintText: "e.g. Make it slim fit",
                    fieldKey: "specialInstructions",
                    controller: specialInstructionsController,
                  ),
                  const SizedBox(height: 18),
                  const CustomText(
                    "Measurements *",
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 6),
                  const CustomText(
                    "Fill in the available body measurements below.",
                    fontSize: 12,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 14),
                  buildMeasurementFields(),
                  const SizedBox(height: 28),
                  CustomButton(title: "Submit Order", onPressed: _submit),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
