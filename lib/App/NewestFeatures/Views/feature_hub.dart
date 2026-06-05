import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/NewestFeatures/Api/newest_feature_service.dart';
import 'package:hog/App/NewestFeatures/Views/designer_profile_detail.dart';
import 'package:hog/App/NewestFeatures/Views/escrow_workspace.dart';
import 'package:hog/App/NewestFeatures/Views/messaging_center.dart';
import 'package:hog/App/NewestFeatures/Views/rich_media_viewer.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class FeatureHub extends StatefulWidget {
  const FeatureHub({super.key});

  @override
  State<FeatureHub> createState() => _FeatureHubState();
}

class _FeatureHubState extends State<FeatureHub> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: const Text('Style Studio'),
          backgroundColor: AppColors.canvas,
          surfaceTintColor: Colors.transparent,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Explore'),
              Tab(text: 'My Sizes'),
              Tab(text: 'Saved'),
              Tab(text: 'Custom'),
              Tab(text: 'Chats'),
              Tab(text: 'Protection'),
              Tab(text: 'Help'),
              Tab(text: 'Review'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DiscoveryTab(),
            MeasurementsTab(),
            MoodboardsTab(),
            CustomOrderTab(),
            MessagingCenter(),
            EscrowWorkspace(),
            SupportTab(),
            ReviewsTab(),
          ],
        ),
      ),
    );
  }
}

class DiscoveryTab extends StatefulWidget {
  final bool publicMode;

  const DiscoveryTab({super.key, this.publicMode = false});

  @override
  State<DiscoveryTab> createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends State<DiscoveryTab> {
  final _search = TextEditingController();
  String _gender = '';
  String _category = '';
  String _occasion = '';
  String _fabric = '';
  String _location = '';
  String _sort = 'latest';
  late Future<List<ApiResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<List<ApiResult>> _load() {
    final query = _query();
    if (widget.publicMode) {
      return Future.wait([
        NewestFeatureService.getPublicListings(query: query),
        NewestFeatureService.getPublicDesigners(query: _designerQuery()),
      ]);
    }
    return Future.wait([
      NewestFeatureService.getListings(query: query),
      NewestFeatureService.getDesigners(query: _designerQuery()),
    ]);
  }

  String _query() {
    final params = <String, String>{
      if (_search.text.trim().isNotEmpty) 'category': _search.text.trim(),
      if (_gender.isNotEmpty) 'gender': _gender,
      if (_category.isNotEmpty) 'category': _category,
      if (_occasion.isNotEmpty) 'occasion': _occasion,
      if (_fabric.isNotEmpty) 'fabric': _fabric,
      if (_location.isNotEmpty) 'location': _location,
      'sort': _sort,
    };
    final encoded = Uri(queryParameters: params).query;
    return encoded.isEmpty ? '' : '?$encoded';
  }

  String _designerQuery() {
    final params = <String, String>{
      if (_category.isNotEmpty) 'specialization': _category,
      if (_location.isNotEmpty) 'location': _location,
      'sort': _sort,
    };
    final encoded = Uri(queryParameters: params).query;
    return encoded.isEmpty ? '' : '?$encoded';
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApiResult>>(
      future: _future,
      builder: (context, snapshot) {
        final listings =
            snapshot.hasData
                ? apiList(snapshot.data![0].data)
                : const <Map<String, dynamic>>[];
        final designers =
            snapshot.hasData
                ? apiList(snapshot.data![1].data)
                : const <Map<String, dynamic>>[];

        return RefreshIndicator(
          onRefresh: () async {
            _refresh();
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      'Advanced discovery',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      title: '',
                      hintText: 'Search category or style',
                      fieldKey: 'discovery_search',
                      controller: _search,
                      prefixIcon: Icons.search_rounded,
                      isCompact: true,
                      onChanged: (_) => _refresh(),
                    ),
                    _WrapFields(
                      children: [
                        _ChoiceField(
                          label: 'Gender',
                          value: _gender,
                          values: const ['', 'female', 'male', 'unisex'],
                          onChanged: (v) => setState(() => _gender = v ?? ''),
                        ),
                        _ChoiceField(
                          label: 'Occasion',
                          value: _occasion,
                          values: const [
                            '',
                            'bridal',
                            'corporate',
                            'casual',
                            'native',
                          ],
                          onChanged: (v) => setState(() => _occasion = v ?? ''),
                        ),
                        _ChoiceField(
                          label: 'Fabric',
                          value: _fabric,
                          values: const [
                            '',
                            'silk',
                            'lace',
                            'ankara',
                            'aso oke',
                            'cotton',
                          ],
                          onChanged: (v) => setState(() => _fabric = v ?? ''),
                        ),
                        _ChoiceField(
                          label: 'Sort',
                          value: _sort,
                          values: const [
                            'latest',
                            'popular',
                            'trending',
                            'price_low',
                            'price_high',
                            'ratings',
                          ],
                          onChanged:
                              (v) => setState(() => _sort = v ?? 'latest'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            title: '',
                            hintText: 'Category/designer specialty',
                            fieldKey: 'discovery_category',
                            controller: TextEditingController(text: _category),
                            isCompact: true,
                            onChanged: (v) => _category = v,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            title: '',
                            hintText: 'Location',
                            fieldKey: 'discovery_location',
                            controller: TextEditingController(text: _location),
                            isCompact: true,
                            onChanged: (v) => _location = v,
                          ),
                        ),
                      ],
                    ),
                    CustomButton(title: 'Apply filters', onPressed: _refresh),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ListSection(
                title: 'Listings',
                isLoading: snapshot.connectionState == ConnectionState.waiting,
                items: listings,
                emptyText: 'No listings match these filters.',
                icon: Icons.checkroom_outlined,
              ),
              const SizedBox(height: 16),
              _ListSection(
                title: 'Designers',
                isLoading: snapshot.connectionState == ConnectionState.waiting,
                items: designers,
                emptyText: 'No designers match these filters.',
                icon: Icons.design_services_outlined,
              ),
            ],
          ),
        );
      },
    );
  }
}

class MeasurementsTab extends StatefulWidget {
  const MeasurementsTab({super.key});

  @override
  State<MeasurementsTab> createState() => _MeasurementsTabState();
}

class _MeasurementsTabState extends State<MeasurementsTab> {
  late Future<ApiResult> _future;
  final _profileName = TextEditingController(text: 'Native fit');
  final Map<String, TextEditingController> _fields = {
    'chest': TextEditingController(),
    'waist': TextEditingController(),
    'hip': TextEditingController(),
    'shoulder': TextEditingController(),
    'sleeveLength': TextEditingController(),
    'trouserLength': TextEditingController(),
    'agbadaLength': TextEditingController(),
    'capSize': TextEditingController(),
  };
  String _fitType = 'native';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = NewestFeatureService.getMeasurementProfiles();
  }

  @override
  void dispose() {
    _profileName.dispose();
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final body = {
      'profileName': _profileName.text.trim(),
      'fitType': _fitType,
      'measurements': {
        for (final entry in _fields.entries)
          if (!['agbadaLength', 'capSize'].contains(entry.key))
            entry.key: double.tryParse(entry.value.text.trim()) ?? 0,
        'native': {
          'agbadaLength':
              double.tryParse(_fields['agbadaLength']!.text.trim()) ?? 0,
          'capSize': double.tryParse(_fields['capSize']!.text.trim()) ?? 0,
        },
      },
      'isDefault': false,
    };
    final result = await NewestFeatureService.createMeasurementProfile(body);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _future = NewestFeatureService.getMeasurementProfiles();
    });
    _showResult(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult>(
      future: _future,
      builder: (context, snapshot) {
        final profiles =
            snapshot.hasData
                ? apiList(snapshot.data!.data)
                : const <Map<String, dynamic>>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Saved measurement profiles',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  const CustomText(
                    'Create casual, fitted, native, or custom fit records. Designers can request extra measurements from their project view.',
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    title: 'Profile name',
                    hintText: 'e.g. Native fit',
                    fieldKey: 'measurement_profile_name',
                    controller: _profileName,
                  ),
                  _ChoiceField(
                    label: 'Fit type',
                    value: _fitType,
                    values: const ['casual', 'fitted', 'native', 'custom'],
                    onChanged:
                        (value) => setState(() => _fitType = value ?? 'native'),
                  ),
                  const SizedBox(height: 12),
                  const _GuideStrip(),
                  const SizedBox(height: 14),
                  _MeasurementGrid(fields: _fields),
                  const SizedBox(height: 12),
                  CustomButton(
                    title: 'Save measurement profile',
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ListSection(
              title: 'History',
              isLoading: snapshot.connectionState == ConnectionState.waiting,
              items: profiles,
              emptyText: 'No saved measurement profiles yet.',
              icon: Icons.straighten_rounded,
            ),
          ],
        );
      },
    );
  }
}

class MoodboardsTab extends StatefulWidget {
  const MoodboardsTab({super.key});

  @override
  State<MoodboardsTab> createState() => _MoodboardsTabState();
}

class _MoodboardsTabState extends State<MoodboardsTab> {
  late Future<ApiResult> _future;
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _note = TextEditingController();
  File? _image;
  final _picker = ImagePicker();
  Map<String, dynamic>? _selectedMoodboard;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = NewestFeatureService.getMoodboards();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _image = File(picked.path));
  }

  Future<void> _create() async {
    setState(() => _saving = true);
    final result = await NewestFeatureService.createMoodboard({
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'visibility': 'private',
    });
    if (!mounted) return;
    setState(() {
      _saving = false;
      _future = NewestFeatureService.getMoodboards();
    });
    _showResult(context, result);
  }

  Future<void> _addItem() async {
    final moodboard = _selectedMoodboard;
    if (moodboard == null) {
      _showResult(context, ApiResult.failure('Choose a collection first.'));
      return;
    }
    final image = _image;
    if (image == null) {
      _showResult(
        context,
        ApiResult.failure('Choose an image from your device.'),
      );
      return;
    }
    setState(() => _saving = true);
    final result = await NewestFeatureService.addMoodboardImage(
      _recordId(moodboard),
      image: image,
      note: _note.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (result.success) _image = null;
      _future = NewestFeatureService.getMoodboards();
    });
    _showResult(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult>(
      future: _future,
      builder: (context, snapshot) {
        final moodboards =
            snapshot.hasData
                ? apiList(snapshot.data!.data)
                : const <Map<String, dynamic>>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Moodboards & wishlist',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  CustomTextField(
                    title: 'Name',
                    hintText: 'Wedding inspiration',
                    fieldKey: 'moodboard_name',
                    controller: _name,
                  ),
                  CustomTextField(
                    title: 'Description',
                    hintText: 'Looks for June event',
                    fieldKey: 'moodboard_description',
                    controller: _description,
                  ),
                  CustomButton(
                    title: 'Create collection',
                    isLoading: _saving,
                    onPressed: _saving ? null : _create,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Add inspiration image',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  _RecordChooser(
                    title: 'Choose collection',
                    records: moodboards,
                    selected: _selectedMoodboard,
                    emptyText: 'Create a collection before saving inspiration.',
                    onSelected:
                        (record) => setState(() => _selectedMoodboard = record),
                  ),
                  _FilePickerRow(
                    title: 'Inspiration image',
                    file: _image,
                    onPick: _pickImage,
                  ),
                  CustomTextField(
                    title: 'Note',
                    hintText: 'Inspired by sleeve detail',
                    fieldKey: 'moodboard_note',
                    controller: _note,
                  ),
                  CustomButton(
                    title: 'Save inspiration',
                    isLoading: _saving,
                    onPressed: _saving ? null : _addItem,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ListSection(
              title: 'Collections',
              isLoading: snapshot.connectionState == ConnectionState.waiting,
              items: moodboards,
              emptyText: 'No moodboards yet.',
              icon: Icons.collections_bookmark_outlined,
            ),
          ],
        );
      },
    );
  }
}

class CustomOrderTab extends StatefulWidget {
  const CustomOrderTab({super.key});

  @override
  State<CustomOrderTab> createState() => _CustomOrderTabState();
}

class _CustomOrderTabState extends State<CustomOrderTab> {
  final _styleNotes = TextEditingController();
  final _fabric = TextEditingController();
  final _timeline = TextEditingController();
  final _requestId = TextEditingController();
  final _revisionNote = TextEditingController();
  late Future<List<ApiResult>> _setupFuture;
  Map<String, dynamic>? _selectedDesigner;
  Map<String, dynamic>? _selectedMeasurementProfile;
  File? _inspirationImage;
  final _picker = ImagePicker();
  bool _saving = false;
  Map<String, dynamic> _lastWorkflow = const {};
  Map<String, dynamic> _lastEscrow = const {};

  @override
  void initState() {
    super.initState();
    _setupFuture = Future.wait([
      NewestFeatureService.getDesigners(),
      NewestFeatureService.getMeasurementProfiles(),
    ]);
  }

  @override
  void dispose() {
    for (final c in [
      _styleNotes,
      _fabric,
      _timeline,
      _requestId,
      _revisionNote,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickInspiration() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _inspirationImage = File(picked.path));
  }

  Future<void> _createRequest() async {
    final designer = _selectedDesigner;
    final profile = _selectedMeasurementProfile;
    if (designer == null || profile == null) {
      _showResult(
        context,
        ApiResult.failure('Choose a designer and measurement profile.'),
      );
      return;
    }

    final measurementProfileId = _recordId(profile);
    final vendorName = _vendorDisplayName(designer);

    setState(() => _saving = true);
    final fabricPreferences =
        _fabric.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final body = {
      'vendorName': vendorName,
      'measurementProfileId': measurementProfileId,
      'styleNotes': _styleNotes.text.trim(),
      'fabricPreferences': fabricPreferences,
      'deliveryTimelinePreference': _timeline.text.trim(),
    };
    final image = _inspirationImage;
    final result =
        image == null
            ? await NewestFeatureService.createCustomRequest(body)
            : await NewestFeatureService.createCustomRequestMultipart(
              fields: {
                'vendorName': vendorName,
                'measurementProfileId': measurementProfileId,
                'styleNotes': _styleNotes.text.trim(),
                'fabricPreferences': jsonEncode(fabricPreferences),
                'deliveryTimelinePreference': _timeline.text.trim(),
              },
              images: [image],
            );
    if (!mounted) return;
    final data = apiMap(result.data);
    final request =
        apiMap(data['request']).isEmpty ? data : apiMap(data['request']);
    setState(() {
      _saving = false;
      final requestId = _recordId(request);
      if (requestId.isNotEmpty) {
        _requestId.text = requestId;
      }
    });
    _showResult(context, result);
  }

  Future<void> _pay(String milestoneName) async {
    setState(() => _saving = true);
    final result = await NewestFeatureService.payCustomRequest(
      _requestId.text.trim(),
      milestoneName,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    _showResult(context, result);
  }

  Future<void> _acceptQuote() async {
    setState(() => _saving = true);
    final result = await NewestFeatureService.acceptQuote(
      _requestId.text.trim(),
    );
    if (!mounted) return;
    final data = apiMap(result.data);
    setState(() {
      _saving = false;
      _lastWorkflow = apiMap(data['workflow']);
      _lastEscrow = apiMap(data['escrow']);
    });
    _showResult(context, result);
  }

  Future<void> _requestRevision() async {
    setState(() => _saving = true);
    final result = await NewestFeatureService.createRevision(
      _requestId.text.trim(),
      _revisionNote.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    _showResult(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                'Full custom order request',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<ApiResult>>(
                future: _setupFuture,
                builder: (context, snapshot) {
                  final designers =
                      snapshot.hasData
                          ? apiList(snapshot.data![0].data)
                          : const <Map<String, dynamic>>[];
                  final profiles =
                      snapshot.hasData
                          ? apiList(snapshot.data![1].data)
                          : const <Map<String, dynamic>>[];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RecordChooser(
                        title: 'Choose designer',
                        records: designers,
                        selected: _selectedDesigner,
                        emptyText: 'No designers available yet.',
                        onSelected:
                            (record) =>
                                setState(() => _selectedDesigner = record),
                      ),
                      const SizedBox(height: 12),
                      _RecordChooser(
                        title: 'Attach measurements',
                        records: profiles,
                        selected: _selectedMeasurementProfile,
                        emptyText:
                            'Create a measurement profile before requesting a custom order.',
                        onSelected:
                            (record) => setState(
                              () => _selectedMeasurementProfile = record,
                            ),
                      ),
                    ],
                  );
                },
              ),
              _FilePickerRow(
                title: 'Inspiration image',
                file: _inspirationImage,
                onPick: _pickInspiration,
              ),
              CustomTextField(
                title: 'Style notes',
                hintText: 'Native agbada with subtle embroidery',
                fieldKey: 'custom_notes',
                controller: _styleNotes,
              ),
              CustomTextField(
                title: 'Fabric preferences',
                hintText: 'silk, aso oke',
                fieldKey: 'custom_fabric',
                controller: _fabric,
              ),
              CustomTextField(
                title: 'Timeline preference',
                hintText: 'Before June 1',
                fieldKey: 'custom_timeline',
                controller: _timeline,
              ),
              CustomButton(
                title: 'Send request',
                isLoading: _saving,
                onPressed: _saving ? null : _createRequest,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                'Quote approval & revision',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.left,
              ),
              if (_requestId.text.trim().isEmpty)
                const CustomText(
                  'Create a custom request first. Once the designer replies with a quote, this section will continue that same request automatically.',
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
              CustomTextField(
                title: 'Revision note',
                hintText: 'Please reduce embroidery and update quote',
                fieldKey: 'custom_revision',
                controller: _revisionNote,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      title: 'Request revision',
                      isOutlined: true,
                      isLoading: _saving,
                      onPressed:
                          _saving || _requestId.text.trim().isEmpty
                              ? null
                              : _requestRevision,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      title: 'Accept quote',
                      isLoading: _saving,
                      onPressed:
                          _saving || _requestId.text.trim().isEmpty
                              ? null
                              : _acceptQuote,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_lastWorkflow.isNotEmpty) ...[
          const SizedBox(height: 14),
          WorkflowTimelineCard(workflow: _lastWorkflow),
        ],
        if (_lastEscrow.isNotEmpty) ...[
          const SizedBox(height: 14),
          EscrowSummaryCard(escrow: _lastEscrow),
          const SizedBox(height: 10),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  'Protected payment',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                const CustomText(
                  'Pay deposit or balance from this request. The backend creates the internal payment reference and holds the money in escrow.',
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        title: 'Pay deposit',
                        isOutlined: true,
                        isLoading: _saving,
                        onPressed:
                            _saving || _requestId.text.trim().isEmpty
                                ? null
                                : () => _pay('deposit'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        title: 'Pay balance',
                        isLoading: _saving,
                        onPressed:
                            _saving || _requestId.text.trim().isEmpty
                                ? null
                                : () => _pay('balance'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class SupportTab extends StatefulWidget {
  const SupportTab({super.key});

  @override
  State<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  late Future<ApiResult> _future;
  late Future<ApiResult> _supportOrdersFuture;
  late Future<ApiResult> _supportChatsFuture;
  Map<String, dynamic>? _selectedSupportOrder;
  final _supportSubject = TextEditingController();
  final _supportMessage = TextEditingController();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _supportCategory = 'order';
  String _category = 'fit_issue';
  String _resolution = 'revision';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = NewestFeatureService.getMyDisputes();
    _supportOrdersFuture = NewestFeatureService.getSupportOrders();
    _supportChatsFuture = NewestFeatureService.getSupportConversations();
  }

  @override
  void dispose() {
    _supportSubject.dispose();
    _supportMessage.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _createSupportChat() async {
    setState(() => _saving = true);
    final result = await NewestFeatureService.createSupportConversation({
      'subject': _supportSubject.text.trim(),
      'category': _supportCategory,
      'content': _supportMessage.text.trim(),
    });
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (result.success) {
        _supportSubject.clear();
        _supportMessage.clear();
      }
      _supportChatsFuture = NewestFeatureService.getSupportConversations();
    });
    _showResult(context, result);
  }

  Future<void> _submit() async {
    final selected = _selectedSupportOrder;
    if (selected == null) {
      _showResult(context, ApiResult.failure('Choose the affected order.'));
      return;
    }
    setState(() => _saving = true);
    final result = await NewestFeatureService.createSupportTicketForTarget(
      _recordId(selected, preferredKey: 'supportTargetId'),
      {
        'category': _category,
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'evidence': const <String>[],
        'requestedResolution': _resolution,
      },
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _future = NewestFeatureService.getMyDisputes();
    });
    _showResult(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult>(
      future: _future,
      builder: (context, snapshot) {
        final disputes =
            snapshot.hasData
                ? apiList(snapshot.data!.data)
                : const <Map<String, dynamic>>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Chat with Support',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  const CustomText(
                    'Create a support conversation for order, payment, listing, or account help. Attachments are sent from the device in the chat flow.',
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                  _ChoiceField(
                    label: 'Category',
                    value: _supportCategory,
                    values: const ['order', 'payment', 'listing', 'account'],
                    onChanged:
                        (v) => setState(() => _supportCategory = v ?? 'order'),
                  ),
                  CustomTextField(
                    title: 'Subject',
                    hintText: 'Need help with my custom order',
                    fieldKey: 'support_subject',
                    controller: _supportSubject,
                  ),
                  CustomTextField(
                    title: 'Message',
                    hintText: 'Please help review the latest order update.',
                    fieldKey: 'support_content',
                    controller: _supportMessage,
                  ),
                  CustomButton(
                    title: 'Start support chat',
                    isLoading: _saving,
                    onPressed: _saving ? null : _createSupportChat,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<ApiResult>(
              future: _supportChatsFuture,
              builder: (context, chatSnapshot) {
                final chats =
                    chatSnapshot.hasData
                        ? apiList(chatSnapshot.data!.data)
                        : const <Map<String, dynamic>>[];
                return _ListSection(
                  title: 'Support chats',
                  isLoading:
                      chatSnapshot.connectionState == ConnectionState.waiting,
                  items: chats,
                  emptyText: 'No support chats yet.',
                  icon: Icons.support_agent_rounded,
                );
              },
            ),
            const SizedBox(height: 16),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Report an issue',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<ApiResult>(
                    future: _supportOrdersFuture,
                    builder: (context, orderSnapshot) {
                      final orders =
                          orderSnapshot.hasData
                              ? apiList(orderSnapshot.data!.data)
                              : const <Map<String, dynamic>>[];
                      if (orderSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _RecordChooser(
                        title: 'Choose order',
                        records: orders,
                        selected: _selectedSupportOrder,
                        idKey: 'supportTargetId',
                        emptyText:
                            'No accepted orders yet. Support tickets are linked to a real order automatically.',
                        onSelected:
                            (order) =>
                                setState(() => _selectedSupportOrder = order),
                      );
                    },
                  ),
                  _ChoiceField(
                    label: 'Issue type',
                    value: _category,
                    values: const [
                      'fit_issue',
                      'delivery_issue',
                      'material_quality',
                      'payment_issue',
                    ],
                    onChanged:
                        (v) => setState(() => _category = v ?? 'fit_issue'),
                  ),
                  _ChoiceField(
                    label: 'Requested resolution',
                    value: _resolution,
                    values: const [
                      'revision',
                      'refund',
                      'partial_refund',
                      'admin_review',
                    ],
                    onChanged:
                        (v) => setState(() => _resolution = v ?? 'revision'),
                  ),
                  CustomTextField(
                    title: 'Title',
                    hintText: 'Sleeve length is incorrect',
                    fieldKey: 'dispute_title',
                    controller: _title,
                  ),
                  CustomTextField(
                    title: 'Description',
                    hintText: 'Describe what happened',
                    fieldKey: 'dispute_description',
                    controller: _description,
                  ),
                  CustomButton(
                    title: 'Submit ticket',
                    isLoading: _saving,
                    onPressed:
                        _saving || _selectedSupportOrder == null
                            ? null
                            : _submit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ListSection(
              title: 'My tickets',
              isLoading: snapshot.connectionState == ConnectionState.waiting,
              items: disputes,
              emptyText: 'No support tickets yet.',
              icon: Icons.support_agent_rounded,
            ),
          ],
        );
      },
    );
  }
}

class ReviewsTab extends StatefulWidget {
  const ReviewsTab({super.key});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  late Future<ApiResult> _reviewableOrdersFuture;
  Map<String, dynamic>? _selectedReviewOrder;
  final _comment = TextEditingController();
  double _rating = 5;
  final Map<String, double> _categoryRatings = {
    'fitAccuracy': 5,
    'communication': 5,
    'deliveryReliability': 5,
    'materialQuality': 5,
    'overallExperience': 5,
  };
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _reviewableOrdersFuture = NewestFeatureService.getReviewableOrders();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final selected = _selectedReviewOrder;
    if (selected == null) {
      _showResult(
        context,
        ApiResult.failure('Choose a completed payment order.'),
      );
      return;
    }
    setState(() => _saving = true);
    final score = _rating.round();
    final result = await NewestFeatureService.createReviewForTarget(
      _recordId(selected, preferredKey: 'reviewTargetId'),
      {
        'rating': score,
        'categories': {
          for (final entry in _categoryRatings.entries)
            entry.key: entry.value.round(),
        },
        'comment': _comment.text.trim(),
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    _showResult(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                'Verified purchase review',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              FutureBuilder<ApiResult>(
                future: _reviewableOrdersFuture,
                builder: (context, orderSnapshot) {
                  final orders =
                      orderSnapshot.hasData
                          ? apiList(orderSnapshot.data!.data)
                          : const <Map<String, dynamic>>[];
                  if (orderSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _RecordChooser(
                    title: 'Choose order',
                    records: orders,
                    selected: _selectedReviewOrder,
                    idKey: 'reviewTargetId',
                    emptyText:
                        'No paid orders are eligible for review yet. Reviews are verified-purchase only.',
                    onSelected:
                        (order) => setState(() => _selectedReviewOrder = order),
                  );
                },
              ),
              Slider(
                value: _rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: '${_rating.round()} stars',
                onChanged: (value) => setState(() => _rating = value),
              ),
              ..._categoryRatings.entries.map(
                (entry) => _RatingSlider(
                  label: _reviewLabel(entry.key),
                  value: entry.value,
                  onChanged:
                      (value) => setState(() {
                        _categoryRatings[entry.key] = value;
                      }),
                ),
              ),
              CustomTextField(
                title: 'Written review',
                hintText: 'The fit was accurate and delivery was smooth',
                fieldKey: 'review_comment',
                controller: _comment,
              ),
              CustomButton(
                title: 'Submit review',
                isLoading: _saving,
                onPressed:
                    _saving || _selectedReviewOrder == null ? null : _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _reviewLabel(String key) {
    switch (key) {
      case 'fitAccuracy':
        return 'Fit accuracy';
      case 'deliveryReliability':
        return 'Delivery reliability';
      case 'materialQuality':
        return 'Material quality';
      case 'overallExperience':
        return 'Overall experience';
      default:
        return '${key[0].toUpperCase()}${key.substring(1)}';
    }
  }
}

class _RatingSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _RatingSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text('${value.round()} / 5'),
            ],
          ),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            label: '${value.round()}',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _MeasurementGrid extends StatelessWidget {
  final Map<String, TextEditingController> fields;

  const _MeasurementGrid({required this.fields});

  @override
  Widget build(BuildContext context) {
    final entries = fields.entries.toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 520 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.45,
          ),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return TextField(
              controller: entry.value,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: _label(entry.key),
                suffixText: 'in',
              ),
            );
          },
        );
      },
    );
  }

  String _label(String value) {
    return value
        .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m.group(0)}')
        .replaceFirstMapped(
          RegExp(r'^[a-z]'),
          (m) => m.group(0)!.toUpperCase(),
        );
  }
}

class _GuideStrip extends StatelessWidget {
  const _GuideStrip();

  @override
  Widget build(BuildContext context) {
    const guides = [
      (Icons.straighten_rounded, 'Visual guides'),
      (Icons.image_outlined, 'Diagrams'),
      (Icons.play_circle_outline_rounded, 'Video instructions'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          guides
              .map(
                (guide) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(guide.$1, size: 16, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        guide.$2,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _FilePickerRow extends StatelessWidget {
  final String title;
  final File? file;
  final VoidCallback onPick;

  const _FilePickerRow({
    required this.title,
    required this.file,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final selected = file != null;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentSoft : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.add_photo_alternate_outlined,
                color: selected ? AppColors.accent : AppColors.subtext,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selected
                          ? file!.path.split(Platform.pathSeparator).last
                          : 'Choose from camera roll or files',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtext,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.subtext),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final String emptyText;
  final IconData icon;

  const _ListSection({
    required this.title,
    required this.isLoading,
    required this.items,
    required this.emptyText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 10),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (items.isEmpty)
          _Panel(child: CustomText(emptyText, color: AppColors.subtext))
        else
          ...items.map((item) => _DataCard(item: item, icon: icon)),
      ],
    );
  }
}

class _RecordChooser extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> records;
  final Map<String, dynamic>? selected;
  final ValueChanged<Map<String, dynamic>> onSelected;
  final String emptyText;
  final String? idKey;

  const _RecordChooser({
    required this.title,
    required this.records,
    required this.selected,
    required this.onSelected,
    required this.emptyText,
    this.idKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title,
          fontWeight: FontWeight.w800,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 8),
        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: CustomText(
              emptyText,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
          )
        else
          ...records.take(6).map((record) {
            final selectedId =
                selected == null
                    ? ''
                    : _recordId(selected!, preferredKey: idKey);
            final currentId = _recordId(record, preferredKey: idKey);
            final isSelected = selectedId == currentId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => onSelected(record),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentSoft : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color:
                            isSelected ? AppColors.accent : AppColors.subtext,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomText(
                          _recordTitle(record),
                          fontWeight: FontWeight.w700,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _DataCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final IconData icon;

  const _DataCard({required this.item, required this.icon});

  @override
  Widget build(BuildContext context) {
    final title =
        item['title']?.toString() ??
        item['name']?.toString() ??
        item['profileName']?.toString() ??
        item['businessName']?.toString() ??
        item['fullName']?.toString() ??
        item['_id']?.toString() ??
        'Record';
    final subtitle =
        item['description']?.toString() ??
        item['status']?.toString() ??
        item['fitType']?.toString() ??
        item['bio']?.toString() ??
        item['message']?.toString() ??
        'Tap related workflow actions to continue.';
    final id = item['_id']?.toString();
    final canOpenMedia = _hasListingMedia(item);
    final canOpenDesigner =
        icon == Icons.design_services_outlined && id != null;

    return InkWell(
      onTap:
          canOpenMedia
              ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RichMediaViewer(listing: item),
                ),
              )
              : canOpenDesigner
              ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => DesignerProfileDetail(
                        designerId: id,
                        initialData: item,
                      ),
                ),
              )
              : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    subtitle,
                    fontSize: 12,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            if (canOpenMedia && id != null)
              IconButton(
                tooltip: 'Save to moodboard',
                onPressed: () => _showSaveToMoodboard(context, id),
                icon: const Icon(Icons.bookmark_border_rounded),
              ),
            if (canOpenMedia || canOpenDesigner)
              const Icon(Icons.chevron_right_rounded, color: AppColors.subtext),
          ],
        ),
      ),
    );
  }

  void _showSaveToMoodboard(BuildContext context, String listingId) {
    final note = TextEditingController();
    Map<String, dynamic>? selectedMoodboard;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (sheetContext) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              18,
              20,
              MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  'Save listing',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 12),
                FutureBuilder<ApiResult>(
                  future: NewestFeatureService.getMoodboards(),
                  builder: (context, snapshot) {
                    final moodboards =
                        snapshot.hasData
                            ? apiList(snapshot.data!.data)
                            : const <Map<String, dynamic>>[];
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return StatefulBuilder(
                      builder:
                          (context, setSheetState) => _RecordChooser(
                            title: 'Choose collection',
                            records: moodboards,
                            selected: selectedMoodboard,
                            emptyText:
                                'Create a collection before saving listings.',
                            onSelected:
                                (record) => setSheetState(
                                  () => selectedMoodboard = record,
                                ),
                          ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: note,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    hintText: 'Inspired by this detail',
                  ),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  title: 'Save',
                  onPressed: () async {
                    final moodboard = selectedMoodboard;
                    if (moodboard == null) {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Choose a collection first.'),
                          ),
                        );
                      return;
                    }
                    final result = await NewestFeatureService.addMoodboardItem(
                      _recordId(moodboard),
                      {
                        'itemType': 'listing',
                        'note': note.text.trim(),
                        'inspiredBy': {
                          'itemType': 'listing',
                          'itemId': listingId,
                        },
                      },
                    );
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            result.success
                                ? result.message
                                : 'Failed: ${result.message}',
                          ),
                        ),
                      );
                  },
                ),
              ],
            ),
          ),
    ).whenComplete(() {
      note.dispose();
    });
  }

  bool _hasListingMedia(Map<String, dynamic> item) {
    final images = item['images'];
    if (images is List && images.isNotEmpty) return true;
    final media = item['media'];
    if (media is Map) {
      return [
        'zoomImages',
        'fabricCloseups',
        'videoPreviews',
        'beforeAfterShowcases',
        'styledLookPreviews',
      ].any((key) => media[key] is List && (media[key] as List).isNotEmpty);
    }
    return false;
  }
}

class _ChoiceField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  const _ChoiceField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedValue = values.contains(value) ? value : values.first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        initialValue: normalizedValue,
        decoration: InputDecoration(labelText: label),
        items:
            values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item.isEmpty ? 'Any' : item),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _WrapFields extends StatelessWidget {
  final List<Widget> children;

  const _WrapFields({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth > 520
                ? (constraints.maxWidth - 20) / 3
                : constraints.maxWidth;
        return Wrap(
          spacing: 10,
          runSpacing: 0,
          children:
              children
                  .map((child) => SizedBox(width: width, child: child))
                  .toList(),
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

void _showResult(BuildContext context, ApiResult result) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          result.success ? result.message : 'Failed: ${result.message}',
        ),
      ),
    );
}

String _recordId(Map<String, dynamic> record, {String? preferredKey}) {
  if (preferredKey != null && record[preferredKey] != null) {
    return record[preferredKey].toString();
  }
  return record['threadId']?.toString() ??
      record['reviewTargetId']?.toString() ??
      record['supportTargetId']?.toString() ??
      record['measurementTargetId']?.toString() ??
      record['requestId']?.toString() ??
      record['_id']?.toString() ??
      record['id']?.toString() ??
      record['designerId']?.toString() ??
      '';
}

String _vendorDisplayName(Map<String, dynamic> record) {
  final vendor = record['vendor'];
  if (vendor is Map) {
    final vendorMap = Map<String, dynamic>.from(vendor);
    final nestedName =
        vendorMap['businessName']?.toString() ??
        vendorMap['name']?.toString() ??
        vendorMap['username']?.toString();
    if (nestedName != null && nestedName.isNotEmpty) return nestedName;
  }
  return record['businessName']?.toString() ??
      record['designerUsername']?.toString() ??
      record['username']?.toString() ??
      record['fullName']?.toString() ??
      record['name']?.toString() ??
      _recordTitle(record);
}

String _recordTitle(Map<String, dynamic> record) {
  return record['businessName']?.toString() ??
      record['subtitle']?.toString() ??
      record['fullName']?.toString() ??
      record['profileName']?.toString() ??
      record['name']?.toString() ??
      record['title']?.toString() ??
      'Record';
}
