import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/NewestFeatures/Api/newest_feature_service.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class DesignerGrowthHub extends StatefulWidget {
  const DesignerGrowthHub({super.key});

  @override
  State<DesignerGrowthHub> createState() => _DesignerGrowthHubState();
}

class _DesignerGrowthHubState extends State<DesignerGrowthHub> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: const Text('Designer Tools'),
          backgroundColor: AppColors.canvas,
          surfaceTintColor: Colors.transparent,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Portfolio'),
              Tab(text: 'Measurements'),
              Tab(text: 'Workflow'),
              Tab(text: 'Media'),
              Tab(text: 'Analytics'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PortfolioManagerTab(),
            DesignerMeasurementsTab(),
            DesignerWorkflowTab(),
            ListingMediaManagerTab(),
            DesignerAnalyticsTab(),
            DesignerReviewResponseTab(),
          ],
        ),
      ),
    );
  }
}

class PortfolioManagerTab extends StatefulWidget {
  const PortfolioManagerTab({super.key});

  @override
  State<PortfolioManagerTab> createState() => _PortfolioManagerTabState();
}

class _PortfolioManagerTabState extends State<PortfolioManagerTab> {
  final _caption = TextEditingController();
  final _otherCategory = TextEditingController();
  File? _image;
  final _picker = ImagePicker();
  String _category = 'nativeWear';
  bool _saving = false;

  @override
  void dispose() {
    _caption.dispose();
    _otherCategory.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _image = File(picked.path));
  }

  Future<void> _save() async {
    final image = _image;
    if (image == null) {
      _showResult(context, ApiResult.failure('Choose a portfolio image.'));
      return;
    }
    final category =
        _category == 'other' ? _otherCategory.text.trim() : _category;
    if (category.isEmpty) {
      _showResult(context, ApiResult.failure('Specify the work section.'));
      return;
    }
    setState(() => _saving = true);
    final result = await NewestFeatureService.updatePortfolioFiles(
      images: [image],
      captions: [_caption.text.trim()],
      categories: [category],
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (result.success) _image = null;
    });
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
                'Portfolio gallery',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              const CustomText(
                'Add categorized work samples for bridal, native wear, corporate, casual, menswear, and womenswear.',
                color: AppColors.subtext,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Work section'),
                items: const [
                  DropdownMenuItem(value: 'bridal', child: Text('Bridal')),
                  DropdownMenuItem(
                    value: 'nativeWear',
                    child: Text('Native wear'),
                  ),
                  DropdownMenuItem(
                    value: 'corporate',
                    child: Text('Corporate'),
                  ),
                  DropdownMenuItem(value: 'casual', child: Text('Casual')),
                  DropdownMenuItem(value: 'menswear', child: Text('Menswear')),
                  DropdownMenuItem(
                    value: 'womenswear',
                    child: Text('Womenswear'),
                  ),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged:
                    (value) =>
                        setState(() => _category = value ?? 'nativeWear'),
              ),
              if (_category == 'other')
                CustomTextField(
                  title: 'Specify work section',
                  hintText: 'e.g. Children\'s wear',
                  fieldKey: 'portfolio_other_category',
                  controller: _otherCategory,
                ),
              _FilePickerRow(
                title: 'Portfolio image',
                file: _image,
                onPick: _pickImage,
              ),
              CustomTextField(
                title: 'Caption',
                hintText: 'Beaded bridal dress',
                fieldKey: 'portfolio_caption',
                controller: _caption,
              ),
              CustomButton(
                title: 'Update portfolio',
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DesignerMeasurementsTab extends StatefulWidget {
  const DesignerMeasurementsTab({super.key});

  @override
  State<DesignerMeasurementsTab> createState() =>
      _DesignerMeasurementsTabState();
}

class _DesignerMeasurementsTabState extends State<DesignerMeasurementsTab> {
  late Future<ApiResult> _future;
  late Future<ApiResult> _targetsFuture;
  Map<String, dynamic>? _selectedTarget;
  final _fields = TextEditingController(text: 'neck, inseam, agbadaLength');
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = NewestFeatureService.getMeasurementRequests();
    _targetsFuture = NewestFeatureService.getMeasurementRequestTargets();
  }

  @override
  void dispose() {
    _fields.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    final target = _selectedTarget;
    if (target == null) {
      _showResult(
        context,
        ApiResult.failure('Choose a measurement request target.'),
      );
      return;
    }
    setState(() => _saving = true);
    final result = await NewestFeatureService.requestMeasurementsForTarget(
      _recordId(target, preferredKey: 'measurementTargetId'),
      {
        'requestedFields':
            _fields.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
        'note': _note.text.trim(),
      },
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _future = NewestFeatureService.getMeasurementRequests();
    });
    _showResult(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult>(
      future: _future,
      builder: (context, snapshot) {
        final requests =
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
                    'Request more measurements',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<ApiResult>(
                    future: _targetsFuture,
                    builder: (context, targetSnapshot) {
                      final targets =
                          targetSnapshot.hasData
                              ? apiList(targetSnapshot.data!.data)
                              : const <Map<String, dynamic>>[];
                      if (targetSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _TargetChooser(
                        title: 'Choose customer/order',
                        records: targets,
                        selected: _selectedTarget,
                        idKey: 'measurementTargetId',
                        emptyText: 'No measurement request targets yet.',
                        onSelected:
                            (target) =>
                                setState(() => _selectedTarget = target),
                      );
                    },
                  ),
                  CustomTextField(
                    title: 'Requested fields',
                    hintText: 'neck, inseam',
                    fieldKey: 'measure_fields',
                    controller: _fields,
                  ),
                  CustomTextField(
                    title: 'Note',
                    hintText: 'Please add neck and native length',
                    fieldKey: 'measure_note',
                    controller: _note,
                  ),
                  CustomButton(
                    title: 'Send request',
                    isLoading: _saving,
                    onPressed:
                        _saving || _selectedTarget == null ? null : _request,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ListSection(
              title: 'Requests',
              isLoading: snapshot.connectionState == ConnectionState.waiting,
              items: requests,
              emptyText: 'No measurement requests yet.',
              icon: Icons.straighten_rounded,
            ),
          ],
        );
      },
    );
  }
}

class DesignerWorkflowTab extends StatefulWidget {
  const DesignerWorkflowTab({super.key});

  @override
  State<DesignerWorkflowTab> createState() => _DesignerWorkflowTabState();
}

class _DesignerWorkflowTabState extends State<DesignerWorkflowTab> {
  final _note = TextEditingController();
  final _estimatedDate = TextEditingController();
  late Future<ApiResult> _threadsFuture;
  Map<String, dynamic>? _selectedThread;
  String _status = 'in_production';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _threadsFuture = NewestFeatureService.getEligibleMessageThreads();
  }

  @override
  void dispose() {
    _note.dispose();
    _estimatedDate.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final thread = _selectedThread;
    if (thread == null) {
      _showResult(context, ApiResult.failure('Choose an agreed order thread.'));
      return;
    }
    setState(() => _saving = true);
    final result = await NewestFeatureService.updateWorkflow({
      'orderType': thread['threadType']?.toString() ?? 'customRequest',
      'orderId': _recordId(thread, preferredKey: 'threadId'),
      'status': _status,
      'note': _note.text.trim(),
      if (_estimatedDate.text.trim().isNotEmpty)
        'estimatedCompletionDate': _estimatedDate.text.trim(),
      if (_status == 'delayed') 'delayReason': _note.text.trim(),
    });
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
                'Production timeline',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              FutureBuilder<ApiResult>(
                future: _threadsFuture,
                builder: (context, snapshot) {
                  final threads =
                      snapshot.hasData
                          ? apiList(snapshot.data!.data)
                          : const <Map<String, dynamic>>[];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _TargetChooser(
                    title: 'Choose agreed order',
                    records: threads,
                    selected: _selectedThread,
                    idKey: 'threadId',
                    emptyText:
                        'No agreed order threads yet. Workflow updates are available after quote agreement.',
                    onSelected:
                        (thread) => setState(() => _selectedThread = thread),
                  );
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items:
                    const [
                          'quote_received',
                          'accepted',
                          'in_production',
                          'ready',
                          'shipped',
                          'delivered',
                          'delayed',
                          'cancelled',
                        ]
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) =>
                        setState(() => _status = value ?? 'in_production'),
              ),
              CustomTextField(
                title: 'Estimated completion date',
                hintText: '2026-06-01T00:00:00.000Z',
                fieldKey: 'workflow_date',
                controller: _estimatedDate,
              ),
              CustomTextField(
                title: 'Update note',
                hintText: 'Cutting and stitching started',
                fieldKey: 'workflow_note',
                controller: _note,
              ),
              CustomButton(
                title: 'Update timeline',
                isLoading: _saving,
                onPressed: _saving ? null : _update,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ListingMediaManagerTab extends StatefulWidget {
  const ListingMediaManagerTab({super.key});

  @override
  State<ListingMediaManagerTab> createState() => _ListingMediaManagerTabState();
}

class _ListingMediaManagerTabState extends State<ListingMediaManagerTab> {
  late Future<ApiResult> _listingsFuture;
  Map<String, dynamic>? _selectedListing;
  final List<File> _mediaFiles = [];
  final List<String> _mediaSlots = [];
  final _picker = ImagePicker();
  String _slot = 'zoomImages';
  String _gender = 'male';
  String _occasion = 'native';
  String _fabric = 'silk';
  String _availability = 'available';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _listingsFuture = NewestFeatureService.getListings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _mediaFiles.add(File(picked.path));
      _mediaSlots.add(_slot);
    });
  }

  Future<void> _save() async {
    final listing = _selectedListing;
    if (listing == null) {
      _showResult(context, ApiResult.failure('Choose a listing first.'));
      return;
    }
    if (_mediaFiles.isEmpty) {
      _showResult(
        context,
        ApiResult.failure('Choose at least one media file.'),
      );
      return;
    }
    setState(() => _saving = true);
    final result = await NewestFeatureService.updateListingRichMediaFiles(
      _recordId(listing),
      images: _mediaFiles,
      mediaSlots: _mediaSlots,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (result.success) {
        _mediaFiles.clear();
        _mediaSlots.clear();
      }
    });
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
                'Listing rich media',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              const CustomText(
                'Add images from your device and choose where each file should appear. Product videos are supported by the backend, but this mobile picker currently sends images only.',
                color: AppColors.subtext,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              FutureBuilder<ApiResult>(
                future: _listingsFuture,
                builder: (context, snapshot) {
                  final listings =
                      snapshot.hasData
                          ? apiList(snapshot.data!.data)
                          : const <Map<String, dynamic>>[];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _TargetChooser(
                    title: 'Choose listing',
                    records: listings,
                    selected: _selectedListing,
                    idKey: '_id',
                    emptyText: 'No listings available yet.',
                    onSelected:
                        (listing) => setState(() => _selectedListing = listing),
                  );
                },
              ),
              _SmallDropdown(
                label: 'Gender',
                value: _gender,
                values: const ['male', 'female', 'unisex'],
                onChanged: (v) => setState(() => _gender = v ?? 'male'),
              ),
              _SmallDropdown(
                label: 'Occasion',
                value: _occasion,
                values: const ['native', 'bridal', 'corporate', 'casual'],
                onChanged: (v) => setState(() => _occasion = v ?? 'native'),
              ),
              _SmallDropdown(
                label: 'Fabric',
                value: _fabric,
                values: const ['silk', 'lace', 'ankara', 'aso oke', 'cotton'],
                onChanged: (v) => setState(() => _fabric = v ?? 'silk'),
              ),
              _SmallDropdown(
                label: 'Availability',
                value: _availability,
                values: const ['available', 'unavailable'],
                onChanged:
                    (v) => setState(() => _availability = v ?? 'available'),
              ),
              _SmallDropdown(
                label: 'Media slot',
                value: _slot,
                values: const [
                  'fabricCloseups',
                  'zoomImages',
                  'beforeAfterShowcases',
                  'styledLookPreviews',
                  'videoPreviews',
                ],
                onChanged: (v) => setState(() => _slot = v ?? 'zoomImages'),
              ),
              _FilePickerRow(
                title:
                    _mediaFiles.isEmpty
                        ? 'Add listing media'
                        : '${_mediaFiles.length} file(s) ready',
                file: _mediaFiles.isEmpty ? null : _mediaFiles.last,
                onPick: _pickMedia,
              ),
              CustomButton(
                title: 'Update media',
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  const _SmallDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items:
            values
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class DesignerAnalyticsTab extends StatefulWidget {
  const DesignerAnalyticsTab({super.key});

  @override
  State<DesignerAnalyticsTab> createState() => _DesignerAnalyticsTabState();
}

class _DesignerAnalyticsTabState extends State<DesignerAnalyticsTab> {
  late Future<ApiResult> _future;
  late Future<ApiResult> _escrowWalletFuture;
  late Future<ApiResult> _listingsFuture;
  Map<String, dynamic>? _selectedListing;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = NewestFeatureService.getDesignerAnalytics();
    _escrowWalletFuture = NewestFeatureService.getDesignerEscrowWallet();
    _listingsFuture = NewestFeatureService.getListings();
  }

  Future<void> _feature(bool value) async {
    final listing = _selectedListing;
    if (listing == null) {
      _showResult(context, ApiResult.failure('Choose a listing first.'));
      return;
    }
    setState(() => _saving = true);
    final result = await NewestFeatureService.featureListing(
      _recordId(listing),
      value,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    _showResult(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult>(
      future: _future,
      builder: (context, snapshot) {
        final data =
            snapshot.hasData
                ? apiMap(snapshot.data!.data)
                : const <String, dynamic>{};
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Growth metrics',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (data.isEmpty)
                    const CustomText(
                      'No analytics available yet.',
                      color: AppColors.subtext,
                    )
                  else
                    ...data.entries
                        .take(8)
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    entry.value.toString(),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FutureBuilder<ApiResult>(
              future: _escrowWalletFuture,
              builder: (context, walletSnapshot) {
                final wallet =
                    walletSnapshot.hasData
                        ? apiMap(walletSnapshot.data!.data)
                        : const <String, dynamic>{};
                final summary = apiMap(wallet['summary']);
                return _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                        'Escrow wallet',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      const CustomText(
                        'Paid deposit and balance milestones appear here as held funds. They become wallet payout balance only after release.',
                        color: AppColors.subtext,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 12),
                      if (walletSnapshot.connectionState ==
                          ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (summary.isEmpty)
                        const CustomText(
                          'No escrow wallet activity yet.',
                          color: AppColors.subtext,
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _MetricPill(
                              label: 'Pending escrow',
                              value: summary['pendingEscrow'],
                            ),
                            _MetricPill(
                              label: 'Released',
                              value: summary['released'],
                            ),
                            _MetricPill(
                              label: 'Refunded',
                              value: summary['refunded'],
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Featured listing',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  FutureBuilder<ApiResult>(
                    future: _listingsFuture,
                    builder: (context, snapshot) {
                      final listings =
                          snapshot.hasData
                              ? apiList(snapshot.data!.data)
                              : const <Map<String, dynamic>>[];
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _TargetChooser(
                        title: 'Choose listing',
                        records: listings,
                        selected: _selectedListing,
                        idKey: '_id',
                        emptyText: 'No listings available yet.',
                        onSelected:
                            (listing) =>
                                setState(() => _selectedListing = listing),
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          title: 'Remove feature',
                          isOutlined: true,
                          isLoading: _saving,
                          onPressed: _saving ? null : () => _feature(false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          title: 'Feature listing',
                          isLoading: _saving,
                          onPressed: _saving ? null : () => _feature(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class DesignerReviewResponseTab extends StatefulWidget {
  const DesignerReviewResponseTab({super.key});

  @override
  State<DesignerReviewResponseTab> createState() =>
      _DesignerReviewResponseTabState();
}

class _DesignerReviewResponseTabState extends State<DesignerReviewResponseTab> {
  late Future<ApiResult> _reviewsFuture;
  Map<String, dynamic>? _selectedReview;
  final _response = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _loadReviews();
  }

  @override
  void dispose() {
    _response.dispose();
    super.dispose();
  }

  Future<ApiResult> _loadReviews() async {
    final userId = await SecurePrefs.getUserId();
    if (userId == null || userId.isEmpty) {
      return ApiResult.failure('Designer profile not found on this device.');
    }
    return NewestFeatureService.getDesignerReviews(userId);
  }

  Future<void> _submit() async {
    final review = _selectedReview;
    if (review == null) {
      _showResult(context, ApiResult.failure('Choose a review first.'));
      return;
    }
    setState(() => _saving = true);
    final result = await NewestFeatureService.respondToReview(
      _recordId(review),
      _response.text.trim(),
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
                'Respond to customer review',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.left,
              ),
              FutureBuilder<ApiResult>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  final reviews =
                      snapshot.hasData
                          ? apiList(snapshot.data!.data)
                          : const <Map<String, dynamic>>[];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _TargetChooser(
                    title: 'Choose review',
                    records: reviews,
                    selected: _selectedReview,
                    idKey: '_id',
                    emptyText: 'No designer reviews available yet.',
                    onSelected:
                        (review) => setState(() => _selectedReview = review),
                  );
                },
              ),
              CustomTextField(
                title: 'Response',
                hintText:
                    'Thank you. It was a pleasure working on this outfit.',
                fieldKey: 'review_response_text',
                controller: _response,
              ),
              CustomButton(
                title: 'Send response',
                isLoading: _saving,
                onPressed: _saving ? null : _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final dynamic value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label,
            fontSize: 12,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 6),
          CustomText(
            '${value ?? 0}',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.left,
          ),
        ],
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

class _TargetChooser extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> records;
  final Map<String, dynamic>? selected;
  final String idKey;
  final String emptyText;
  final ValueChanged<Map<String, dynamic>> onSelected;

  const _TargetChooser({
    required this.title,
    required this.records,
    required this.selected,
    required this.idKey,
    required this.emptyText,
    required this.onSelected,
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
          ...records.map((record) {
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              _recordTitle(record),
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 3),
                            CustomText(
                              record['subtitle']?.toString() ??
                                  record['status']?.toString() ??
                                  '',
                              fontSize: 12,
                              color: AppColors.subtext,
                              textAlign: TextAlign.left,
                            ),
                          ],
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
        item['_id']?.toString() ??
        'Record';
    final subtitle =
        item['note']?.toString() ??
        item['status']?.toString() ??
        item['message']?.toString() ??
        'Designer workflow record';
    final id = item['_id']?.toString();

    return Container(
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
                if (id != null) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    id,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.subtext,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
                          : 'Choose from camera roll',
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
  return record['_id']?.toString() ??
      record['id']?.toString() ??
      record['requestId']?.toString() ??
      '';
}

String _recordTitle(Map<String, dynamic> record) {
  return record['title']?.toString() ??
      record['customerName']?.toString() ??
      record['businessName']?.toString() ??
      record['fullName']?.toString() ??
      record['name']?.toString() ??
      'Record';
}
