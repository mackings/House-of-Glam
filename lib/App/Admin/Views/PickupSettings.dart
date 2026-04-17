import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/DeliveryRservice.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/country_list.dart';
import 'package:hog/theme/app_theme.dart';

class PickupSettings extends StatefulWidget {
  const PickupSettings({super.key});

  @override
  State<PickupSettings> createState() => _PickupSettingsState();
}

class _PickupSettingsState extends State<PickupSettings> {
  final TextEditingController _stateCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  CountryOption? _selectedCountry = allCountries.firstWhere(
    (c) => c.isoCode == 'NG',
    orElse: () => allCountries.first,
  );

  bool _isSubmitting = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _hierarchy = [];

  @override
  void initState() {
    super.initState();
    _fetchHierarchy();
  }

  @override
  void dispose() {
    _stateCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchHierarchy() async {
    setState(() => _isLoading = true);
    final data = await DeliveryRateService.getPickupHierarchy();
    if (!mounted) return;
    setState(() {
      _hierarchy = data;
      _isLoading = false;
    });
  }

  String _normalize(String value) => value.trim().toLowerCase();

  Future<String?> _ensureCountryId(String countryName) async {
    Map<String, dynamic>?
    found = _hierarchy.cast<Map<String, dynamic>>().firstWhere(
      (c) => _normalize(c["name"]?.toString() ?? "") == _normalize(countryName),
      orElse: () => <String, dynamic>{},
    );

    if ((found["_id"]?.toString() ?? "").isNotEmpty) {
      return found["_id"].toString();
    }

    final created = await DeliveryRateService.createPickupCountry(
      name: countryName,
    );
    if (!created) return null;

    final refreshed = await DeliveryRateService.getPickupHierarchy();
    _hierarchy = refreshed;
    found = refreshed.cast<Map<String, dynamic>>().firstWhere(
      (c) => _normalize(c["name"]?.toString() ?? "") == _normalize(countryName),
      orElse: () => <String, dynamic>{},
    );
    final id = found["_id"]?.toString();
    return (id == null || id.isEmpty) ? null : id;
  }

  Future<String?> _ensureStateId({
    required String countryId,
    required String stateName,
  }) async {
    final country = _hierarchy.cast<Map<String, dynamic>>().firstWhere(
      (c) => c["_id"]?.toString() == countryId,
      orElse: () => <String, dynamic>{},
    );

    final states = List<Map<String, dynamic>>.from(
      country["states"] ?? const [],
    );
    Map<String, dynamic>? found = states.firstWhere(
      (s) => _normalize(s["name"]?.toString() ?? "") == _normalize(stateName),
      orElse: () => <String, dynamic>{},
    );

    if ((found["_id"]?.toString() ?? "").isNotEmpty) {
      return found["_id"].toString();
    }

    final created = await DeliveryRateService.createPickupState(
      countryId: countryId,
      name: stateName,
    );
    if (!created) return null;

    final refreshed = await DeliveryRateService.getPickupHierarchy();
    _hierarchy = refreshed;

    final refreshedCountry = refreshed.cast<Map<String, dynamic>>().firstWhere(
      (c) => c["_id"]?.toString() == countryId,
      orElse: () => <String, dynamic>{},
    );
    final refreshedStates = List<Map<String, dynamic>>.from(
      refreshedCountry["states"] ?? const [],
    );
    found = refreshedStates.firstWhere(
      (s) => _normalize(s["name"]?.toString() ?? "") == _normalize(stateName),
      orElse: () => <String, dynamic>{},
    );

    final id = found["_id"]?.toString();
    return (id == null || id.isEmpty) ? null : id;
  }

  Future<void> _saveSingleForm() async {
    final country = _selectedCountry;
    final state = _stateCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    if (country == null || state.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill country, state and address")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final countryId = await _ensureCountryId(country.name);
    if (countryId == null) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create/find country")),
      );
      return;
    }

    final stateId = await _ensureStateId(
      countryId: countryId,
      stateName: state,
    );
    if (stateId == null) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create/find state")),
      );
      return;
    }

    final locationName = "$state Pickup";
    final ok = await DeliveryRateService.createPickupLocation(
      countryId: countryId,
      stateId: stateId,
      name: locationName,
      address: address,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? "Pickup location saved successfully" : "Failed to save location",
        ),
      ),
    );

    if (ok) {
      _stateCtrl.clear();
      _addressCtrl.clear();
      await _fetchHierarchy();
    }
  }

  void _showExistingLocations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const CustomText(
                    "Existing Pickup Locations",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child:
                        _hierarchy.isEmpty
                            ? const Center(
                              child: CustomText(
                                "No locations added yet.",
                                color: Colors.black54,
                              ),
                            )
                            : ListView(
                              children:
                                  _hierarchy.map((country) {
                                    final states =
                                        List<Map<String, dynamic>>.from(
                                          country["states"] ?? const [],
                                        );
                                    return ExpansionTile(
                                      title: Text(
                                        country["name"]?.toString() ??
                                            "Country",
                                      ),
                                      children:
                                          states.map((state) {
                                            final locations =
                                                List<Map<String, dynamic>>.from(
                                                  state["locations"] ??
                                                      const [],
                                                );
                                            return ExpansionTile(
                                              title: Text(
                                                state["name"]?.toString() ??
                                                    "State",
                                              ),
                                              children:
                                                  locations
                                                      .map(
                                                        (loc) => ListTile(
                                                          dense: true,
                                                          title: Text(
                                                            loc["name"]
                                                                    ?.toString() ??
                                                                "Location",
                                                          ),
                                                          subtitle: Text(
                                                            loc["address"]
                                                                    ?.toString() ??
                                                                "",
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                            );
                                          }).toList(),
                                    );
                                  }).toList(),
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalStates = _hierarchy.fold<int>(
      0,
      (sum, country) =>
          sum +
          List<Map<String, dynamic>>.from(country["states"] ?? const []).length,
    );
    final totalLocations = _hierarchy.fold<int>(
      0,
      (sum, country) =>
          sum +
          List<Map<String, dynamic>>.from(country["states"] ?? const []).fold(
            0,
            (stateSum, state) =>
                stateSum +
                List<Map<String, dynamic>>.from(
                  state["locations"] ?? const [],
                ).length,
          ),
    );

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const CustomText(
          "Set Pickup Location",
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          IconButton(
            tooltip: "View Existing Locations",
            onPressed: _showExistingLocations,
            icon: const Icon(Icons.visibility_outlined, color: AppColors.ink),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF7F2FF), Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.place_outlined,
                                color: AppColors.accent,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: CustomText(
                                "$totalLocations saved",
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const CustomText(
                          "Pickup hierarchy",
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        const CustomText(
                          "Create country, state, and address pickup points that the order flow can reuse.",
                          fontSize: 13,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _PickupMetric(
                                label: "Countries",
                                value: "${_hierarchy.length}",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PickupMetric(
                                label: "States",
                                value: "$totalStates",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PickupMetric(
                                label: "Locations",
                                value: "$totalLocations",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          "Pickup Location Form",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 6),
                        const CustomText(
                          "Add a reusable pickup entry with a country, state, and full address.",
                          fontSize: 12,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<CountryOption>(
                          initialValue: _selectedCountry,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Country",
                            prefixIcon: Icon(Icons.public_rounded),
                          ),
                          items:
                              allCountries.map((country) {
                                return DropdownMenuItem<CountryOption>(
                                  value: country,
                                  child: Text(
                                    "${country.flagEmoji} ${country.name}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                          selectedItemBuilder:
                              (context) =>
                                  allCountries
                                      .map(
                                        (country) => Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${country.flagEmoji} ${country.name}",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      )
                                      .toList(),
                          onChanged:
                              (value) =>
                                  setState(() => _selectedCountry = value),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _stateCtrl,
                          decoration: const InputDecoration(
                            labelText: "State",
                            hintText: "e.g. Lagos",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _addressCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: "Address",
                            hintText:
                                "e.g. 12 Allen Avenue, Ikeja, Lagos, Nigeria",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _saveSingleForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              minimumSize: const Size(double.infinity, 54),
                            ),
                            child:
                                _isSubmitting
                                    ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      "Save Pickup Location",
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showExistingLocations,
                            icon: const Icon(Icons.list_alt_outlined),
                            label: const Text("View Added Locations"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              minimumSize: const Size(double.infinity, 52),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

class _PickupMetric extends StatelessWidget {
  final String label;
  final String value;

  const _PickupMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CustomText(
            value,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          const SizedBox(height: 2),
          CustomText(
            label,
            fontSize: 11,
            color: AppColors.subtext,
          ),
        ],
      ),
    );
  }
}
