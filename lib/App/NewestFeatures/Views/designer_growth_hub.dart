import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/NewestFeatures/Api/newest_feature_service.dart';
import 'package:hog/App/NewestFeatures/Views/messaging_center.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
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
              Tab(text: 'Chats'),
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
            MessagingCenter(),
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
  static const int _maxPortfolioImages = 10;

  final _caption = TextEditingController();
  final _otherCategory = TextEditingController();
  final List<File> _images = [];
  final _picker = ImagePicker();
  final Set<String> _busyPortfolioItemIds = {};
  List<Map<String, dynamic>> _portfolioItems = [];
  String _category = 'nativeWear';
  bool _saving = false;
  bool _loadingPortfolio = true;
  String? _portfolioError;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  @override
  void dispose() {
    _caption.dispose();
    _otherCategory.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = _maxPortfolioImages - _images.length;
    if (remaining == 0) {
      _showResult(
        context,
        ApiResult.failure(
          'You can upload up to $_maxPortfolioImages portfolio images at once.',
        ),
      );
      return;
    }

    final picked = await _picker.pickMultiImage(limit: remaining);
    if (picked.isEmpty || !mounted) return;
    setState(() {
      _images.addAll(picked.take(remaining).map((image) => File(image.path)));
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _loadPortfolio({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _loadingPortfolio = true;
        _portfolioError = null;
      });
    }

    final result = await NewestFeatureService.getOwnTailorProfile();
    if (!mounted) return;
    setState(() {
      _loadingPortfolio = false;
      if (result.success) {
        _portfolioItems = _portfolioItemsFrom(result.data);
        _portfolioError = null;
      } else {
        _portfolioError = result.message;
      }
    });
  }

  Future<void> _setVisibility(Map<String, dynamic> item, bool isVisible) async {
    final itemId = item['_id']?.toString() ?? item['id']?.toString() ?? '';
    if (itemId.isEmpty || _busyPortfolioItemIds.contains(itemId)) return;

    setState(() => _busyPortfolioItemIds.add(itemId));
    final result = await NewestFeatureService.updatePortfolioItemVisibility(
      itemId,
      isVisible,
    );
    if (!mounted) return;
    setState(() {
      _busyPortfolioItemIds.remove(itemId);
      if (result.success) {
        final updatedItems = _portfolioItemsFrom(result.data);
        if (updatedItems.isNotEmpty) {
          _portfolioItems = updatedItems;
        } else {
          final index = _portfolioItems.indexWhere(
            (portfolioItem) =>
                (portfolioItem['_id']?.toString() ??
                    portfolioItem['id']?.toString()) ==
                itemId,
          );
          if (index != -1) {
            _portfolioItems[index] = {
              ..._portfolioItems[index],
              'isVisible': isVisible,
            };
          }
        }
      }
    });
    _showResult(context, result);
  }

  Future<void> _editPortfolioItem(Map<String, dynamic> item) async {
    final itemId = item['_id']?.toString() ?? item['id']?.toString() ?? '';
    if (itemId.isEmpty || _busyPortfolioItemIds.contains(itemId)) return;

    final update = await showModalBottomSheet<_PortfolioItemUpdate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PortfolioItemEditor(item: item),
    );
    if (update == null || !mounted) return;

    setState(() => _busyPortfolioItemIds.add(itemId));
    final result = await NewestFeatureService.updatePortfolioItem(
      itemId,
      caption: update.caption,
      category: update.category,
      isVisible: update.isVisible,
      image: update.image,
    );
    if (!mounted) return;
    setState(() => _busyPortfolioItemIds.remove(itemId));
    _showResult(context, result);
    if (result.success) {
      await _loadPortfolio(showLoading: false);
    }
  }

  Future<void> _deletePortfolioItem(Map<String, dynamic> item) async {
    final itemId = item['_id']?.toString() ?? item['id']?.toString() ?? '';
    if (itemId.isEmpty || _busyPortfolioItemIds.contains(itemId)) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Delete portfolio item?',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  const CustomText(
                    'This permanently removes the image from your portfolio.',
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => Navigator.pop(sheetContext, true),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete portfolio item'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busyPortfolioItemIds.add(itemId));
    final result = await NewestFeatureService.deletePortfolioItem(itemId);
    if (!mounted) return;
    setState(() {
      _busyPortfolioItemIds.remove(itemId);
      if (result.success) {
        _portfolioItems.removeWhere(
          (portfolioItem) =>
              (portfolioItem['_id']?.toString() ??
                  portfolioItem['id']?.toString()) ==
              itemId,
        );
      }
    });
    _showResult(context, result);
  }

  Future<void> _save() async {
    if (_images.isEmpty) {
      _showResult(
        context,
        ApiResult.failure('Choose at least one portfolio image.'),
      );
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
      images: _images,
      captions: List.filled(_images.length, _caption.text.trim()),
      categories: List.filled(_images.length, category),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (result.success) _images.clear();
    });
    _showResult(context, result);
    if (result.success) {
      await _loadPortfolio(showLoading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _DesignerPortfolioGallery(
          items: _portfolioItems,
          isLoading: _loadingPortfolio,
          error: _portfolioError,
          busyItemIds: _busyPortfolioItemIds,
          onRefresh: _loadPortfolio,
          onVisibilityChanged: _setVisibility,
          onEdit: _editPortfolioItem,
          onDelete: _deletePortfolioItem,
        ),
        const SizedBox(height: 14),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                'Update portfolio',
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
              _PortfolioImagePicker(
                images: _images,
                maxImages: _maxPortfolioImages,
                onPick: _pickImages,
                onRemove: _removeImage,
              ),
              CustomTextField(
                title: 'Caption',
                hintText: 'Beaded bridal dress',
                fieldKey: 'portfolio_caption',
                controller: _caption,
              ),
              CustomButton(
                title: 'Add to portfolio',
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

List<Map<String, dynamic>> _portfolioItemsFrom(dynamic data) {
  if (data is! Map) return const [];
  final map = Map<String, dynamic>.from(data);
  final nested =
      map['tailor'] is Map
          ? Map<String, dynamic>.from(map['tailor'] as Map)
          : map['profile'] is Map
          ? Map<String, dynamic>.from(map['profile'] as Map)
          : map;
  final gallery = nested['portfolioGallery'];
  if (gallery is! List) return const [];
  return gallery
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

class _PortfolioItemUpdate {
  final String caption;
  final String category;
  final bool isVisible;
  final File? image;

  const _PortfolioItemUpdate({
    required this.caption,
    required this.category,
    required this.isVisible,
    this.image,
  });
}

class _PortfolioItemEditor extends StatefulWidget {
  final Map<String, dynamic> item;

  const _PortfolioItemEditor({required this.item});

  @override
  State<_PortfolioItemEditor> createState() => _PortfolioItemEditorState();
}

class _PortfolioItemEditorState extends State<_PortfolioItemEditor> {
  late final TextEditingController _caption;
  late final TextEditingController _category;
  final _picker = ImagePicker();
  File? _replacementImage;
  late bool _isVisible;
  String? _error;

  @override
  void initState() {
    super.initState();
    _caption = TextEditingController(
      text: widget.item['caption']?.toString() ?? '',
    );
    _category = TextEditingController(
      text: widget.item['category']?.toString() ?? '',
    );
    _isVisible = widget.item['isVisible'] != false;
  }

  @override
  void dispose() {
    _caption.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _pickReplacementImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => _replacementImage = File(picked.path));
  }

  void _submit() {
    final category = _category.text.trim();
    if (category.isEmpty) {
      setState(() => _error = 'Enter a work section.');
      return;
    }
    Navigator.pop(
      context,
      _PortfolioItemUpdate(
        caption: _caption.text.trim(),
        category: category,
        isVisible: _isVisible,
        image: _replacementImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingImage = widget.item['imageUrl']?.toString() ?? '';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: CustomText(
                      'Edit portfolio item',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: double.infinity,
                  height: 190,
                  child:
                      _replacementImage != null
                          ? Image.file(_replacementImage!, fit: BoxFit.cover)
                          : existingImage.isNotEmpty
                          ? Image.network(
                            existingImage,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const ColoredBox(
                                  color: AppColors.surfaceMuted,
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                          )
                          : const ColoredBox(
                            color: AppColors.surfaceMuted,
                            child: Icon(Icons.broken_image_outlined),
                          ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('replace_portfolio_image'),
                  onPressed: _pickReplacementImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    _replacementImage == null
                        ? 'Replace image'
                        : 'Choose another image',
                  ),
                ),
              ),
              TextField(
                key: const ValueKey('edit_portfolio_caption'),
                controller: _caption,
                decoration: const InputDecoration(labelText: 'Caption'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('edit_portfolio_category'),
                controller: _category,
                decoration: const InputDecoration(labelText: 'Work section'),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Visible on public profile',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  _isVisible
                      ? 'Customers can see this item.'
                      : 'Only you can see this item.',
                ),
                value: _isVisible,
                onChanged: (value) => setState(() => _isVisible = value),
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 12),
              CustomButton(title: 'Save changes', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesignerPortfolioGallery extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final String? error;
  final Set<String> busyItemIds;
  final Future<void> Function({bool showLoading}) onRefresh;
  final Future<void> Function(Map<String, dynamic>, bool) onVisibilityChanged;
  final Future<void> Function(Map<String, dynamic>) onEdit;
  final Future<void> Function(Map<String, dynamic>) onDelete;

  const _DesignerPortfolioGallery({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.busyItemIds,
    required this.onRefresh,
    required this.onVisibilityChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: CustomText(
                  'Your portfolio',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
              ),
              IconButton(
                tooltip: 'Refresh portfolio',
                onPressed: isLoading ? null : () => onRefresh(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const CustomText(
            'Hidden work remains visible to you but is removed from public designer profiles.',
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'Could not load your portfolio: $error',
                  color: Colors.redAccent,
                  textAlign: TextAlign.left,
                ),
                TextButton(
                  onPressed: () => onRefresh(),
                  child: const Text('Try again'),
                ),
              ],
            )
          else if (items.isEmpty)
            const CustomText(
              'No portfolio work added yet.',
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final itemId =
                    item['_id']?.toString() ?? item['id']?.toString() ?? '';
                final imageUrl = item['imageUrl']?.toString() ?? '';
                final caption = item['caption']?.toString() ?? '';
                final category = item['category']?.toString() ?? '';
                final isVisible = item['isVisible'] != false;
                final isBusy = busyItemIds.contains(itemId);

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imageUrl.isEmpty
                                ? const Center(
                                  child: Icon(Icons.broken_image_outlined),
                                )
                                : Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                        ),
                                      ),
                                ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Row(
                                children: [
                                  _PortfolioActionIcon(
                                    key: ValueKey(
                                      'edit_portfolio_item_$itemId',
                                    ),
                                    tooltip: 'Edit portfolio item',
                                    icon: Icons.edit_outlined,
                                    onPressed:
                                        isBusy ? null : () => onEdit(item),
                                  ),
                                  const SizedBox(width: 6),
                                  _PortfolioActionIcon(
                                    key: ValueKey(
                                      'delete_portfolio_item_$itemId',
                                    ),
                                    tooltip: 'Delete portfolio item',
                                    icon: Icons.delete_outline_rounded,
                                    foregroundColor: Colors.redAccent,
                                    onPressed:
                                        isBusy ? null : () => onDelete(item),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 6, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              caption.isEmpty ? 'Portfolio work' : caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (category.isNotEmpty)
                              Text(
                                category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.subtext,
                                  fontSize: 12,
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isVisible ? 'Visible' : 'Hidden',
                                    style: TextStyle(
                                      color:
                                          isVisible
                                              ? AppColors.accent
                                              : AppColors.subtext,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (isBusy)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  Switch.adaptive(
                                    key: ValueKey(
                                      'portfolio_visibility_$itemId',
                                    ),
                                    value: isVisible,
                                    onChanged:
                                        itemId.isEmpty
                                            ? null
                                            : (value) => onVisibilityChanged(
                                              item,
                                              value,
                                            ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PortfolioActionIcon extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  const _PortfolioActionIcon({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.foregroundColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: 19, color: foregroundColor),
      ),
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

  @override
  void initState() {
    super.initState();
    _future = NewestFeatureService.getDesignerCustomerMeasurementProfiles();
  }

  Future<void> _refresh() async {
    final future =
        NewestFeatureService.getDesignerCustomerMeasurementProfiles();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult>(
      future: _future,
      builder: (context, snapshot) {
        final customers =
            snapshot.hasData
                ? apiList(snapshot.data!.data)
                : const <Map<String, dynamic>>[];
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: CustomText(
                            'Customer measurements',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh measurements',
                          onPressed:
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? null
                                  : _refresh,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const CustomText(
                      'Saved Style Studio measurements appear here only for customers connected to you through a quotation, custom request, or marketplace purchase.',
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (snapshot.connectionState == ConnectionState.waiting)
                const _Panel(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (snapshot.hasData && !snapshot.data!.success)
                _Panel(
                  child: Column(
                    children: [
                      CustomText(
                        'Could not load customer measurements: ${snapshot.data!.message}',
                        color: Colors.redAccent,
                      ),
                      TextButton(
                        onPressed: _refresh,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                )
              else if (customers.isEmpty)
                const _Panel(
                  child: CustomText(
                    'No related customers have saved measurements yet.',
                    color: AppColors.subtext,
                  ),
                )
              else
                ...customers.map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CustomerMeasurementsCard(record: record),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomerMeasurementsCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const _CustomerMeasurementsCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final customer = apiMap(record['customer']);
    final relationship = apiMap(record['relationship']);
    final profiles =
        record['profiles'] is List
            ? (record['profiles'] as List)
                .whereType<Map>()
                .map((profile) => Map<String, dynamic>.from(profile))
                .toList()
            : const <Map<String, dynamic>>[];
    final name = customer['fullName']?.toString() ?? 'Customer';
    final imageUrl = customer['image']?.toString() ?? '';

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.accentSoft,
                backgroundImage:
                    imageUrl.isEmpty ? null : NetworkImage(imageUrl),
                child:
                    imageUrl.isEmpty
                        ? const Icon(Icons.person_outline_rounded)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      name,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                    CustomText(
                      '${profiles.length} saved profile${profiles.length == 1 ? '' : 's'}',
                      fontSize: 12,
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (relationship['hasCustomRequest'] == true)
                _RelationshipChip(
                  icon: Icons.request_quote_outlined,
                  label:
                      '${relationship['customRequestCount'] ?? 1} custom request',
                ),
              if (relationship['hasMarketplacePurchase'] == true)
                _RelationshipChip(
                  icon: Icons.shopping_bag_outlined,
                  label: '${relationship['purchaseCount'] ?? 1} purchase',
                ),
            ],
          ),
          if (profiles.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...profiles.map((profile) => _MeasurementProfileTile(profile)),
          ],
        ],
      ),
    );
  }
}

class _RelationshipChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RelationshipChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementProfileTile extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _MeasurementProfileTile(this.profile);

  @override
  Widget build(BuildContext context) {
    final measurements = apiMap(profile['measurements']);
    final values = _flattenMeasurements(measurements);
    final isDefault = profile['isDefault'] == true;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                profile['profileName']?.toString() ?? 'Measurement profile',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (isDefault)
              const _RelationshipChip(
                icon: Icons.check_circle_outline_rounded,
                label: 'Default',
              ),
          ],
        ),
        subtitle: Text(
          _measurementSubtitle(profile),
          style: const TextStyle(color: AppColors.subtext, fontSize: 12),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [
          if (values.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No measurement values saved.',
                style: TextStyle(color: AppColors.subtext),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  values.entries
                      .map(
                        (entry) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '${_measurementLabel(entry.key)}: ${entry.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _flattenMeasurements(
  Map<String, dynamic> measurements, [
  String prefix = '',
]) {
  final flattened = <String, dynamic>{};
  for (final entry in measurements.entries) {
    final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    if (entry.value is Map) {
      flattened.addAll(
        _flattenMeasurements(
          Map<String, dynamic>.from(entry.value as Map),
          key,
        ),
      );
    } else if (entry.value != null) {
      flattened[key] = entry.value;
    }
  }
  return flattened;
}

String _measurementLabel(String value) {
  final leaf = value.split('.').last;
  return leaf
      .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
      .replaceFirstMapped(
        RegExp(r'^[a-z]'),
        (match) => match.group(0)!.toUpperCase(),
      );
}

String _measurementSubtitle(Map<String, dynamic> profile) {
  final fitType = profile['fitType']?.toString();
  final updatedAt = profile['updatedAt']?.toString();
  if (fitType != null && updatedAt != null) {
    return '$fitType fit | Updated ${updatedAt.split('T').first}';
  }
  return fitType == null ? 'Saved measurements' : '$fitType fit';
}

class DesignerWorkflowTab extends StatefulWidget {
  const DesignerWorkflowTab({super.key});

  @override
  State<DesignerWorkflowTab> createState() => _DesignerWorkflowTabState();
}

class _DesignerWorkflowTabState extends State<DesignerWorkflowTab> {
  final Set<String> _updatingWorkflowIds = {};
  List<Map<String, dynamic>> _workflows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorkflows();
  }

  Future<void> _loadWorkflows({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final result = await NewestFeatureService.getDesignerWorkflows();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _workflows = apiList(result.data);
        _error = null;
      } else {
        _error = result.message;
      }
    });
  }

  Future<void> _addWorkflow() async {
    final createdWorkflow = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => _CreateWorkflowSheet(
            onSubmit: NewestFeatureService.createDesignerWorkflow,
          ),
    );
    if (createdWorkflow == null || !mounted) return;

    setState(() {
      _workflows.removeWhere(
        (workflow) =>
            _recordId(workflow) == _recordId(createdWorkflow) &&
            _recordId(createdWorkflow).isNotEmpty,
      );
      _workflows.insert(0, createdWorkflow);
    });
    _showResult(
      context,
      const ApiResult(
        success: true,
        message: 'Designer workflow created successfully',
        statusCode: 201,
      ),
    );
    await _loadWorkflows(showLoading: false);
  }

  Future<void> _updateWorkflow(Map<String, dynamic> workflow) async {
    final workflowId =
        workflow['_id']?.toString() ?? workflow['id']?.toString() ?? '';
    if (workflowId.isEmpty || _updatingWorkflowIds.contains(workflowId)) return;

    final body = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _UpdateWorkflowSheet(workflow: workflow),
    );
    if (body == null || !mounted) return;

    setState(() => _updatingWorkflowIds.add(workflowId));
    final result = await NewestFeatureService.updateDesignerWorkflowStatus(
      workflowId,
      body,
    );
    if (!mounted) return;
    setState(() => _updatingWorkflowIds.remove(workflowId));
    _showResult(context, result);
    if (result.success) await _loadWorkflows(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadWorkflows,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  'Production workflows',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                const CustomText(
                  'Track customer attire production and completion dates. Email reminders are sent near 7 days and 3 days before completion.',
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 14),
                CustomButton(
                  key: const ValueKey('add_designer_workflow'),
                  title: 'Add new workflow',
                  onPressed: _addWorkflow,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_loading)
            const _Panel(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_error != null)
            _Panel(
              child: Column(
                children: [
                  CustomText(
                    'Could not load workflows: $_error',
                    color: Colors.redAccent,
                  ),
                  TextButton(
                    onPressed: _loadWorkflows,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            )
          else if (_workflows.isEmpty)
            const _Panel(
              child: CustomText(
                'No production workflows yet.',
                color: AppColors.subtext,
              ),
            )
          else
            ..._workflows.map(
              (workflow) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WorkflowCard(
                  workflow: workflow,
                  isUpdating: _updatingWorkflowIds.contains(
                    workflow['_id']?.toString() ??
                        workflow['id']?.toString() ??
                        '',
                  ),
                  onUpdate: () => _updateWorkflow(workflow),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const _workflowStatuses = [
  'quote_received',
  'accepted',
  'not_started',
  'in_production',
  'ready',
  'shipped',
  'delivered',
  'delayed',
  'cancelled',
];

class _WorkflowCard extends StatelessWidget {
  final Map<String, dynamic> workflow;
  final bool isUpdating;
  final VoidCallback onUpdate;

  const _WorkflowCard({
    required this.workflow,
    required this.isUpdating,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        workflow['currentStatus']?.toString() ??
        workflow['status']?.toString() ??
        'not_started';
    final title =
        workflow['workflowTitle']?.toString() ??
        workflow['attireName']?.toString() ??
        'Production workflow';
    final customer = workflow['customerName']?.toString() ?? 'Customer';
    final attire = workflow['attireName']?.toString() ?? 'Attire not specified';
    final completion = _displayDate(
      workflow['estimatedCompletionDate']?.toString(),
    );
    final timeline =
        workflow['timeline'] is List
            ? (workflow['timeline'] as List)
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
            : const <Map<String, dynamic>>[];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 3),
                    CustomText(
                      '$customer | $attire',
                      color: AppColors.subtext,
                      fontSize: 12,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              _WorkflowStatusBadge(status: status),
            ],
          ),
          if (workflow['productionNotes']?.toString().trim().isNotEmpty ==
              true) ...[
            const SizedBox(height: 10),
            CustomText(
              workflow['productionNotes'].toString(),
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  completion == null
                      ? 'Completion date not set'
                      : 'Due $completion',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (timeline.isNotEmpty) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                'Timeline (${timeline.length})',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              children:
                  timeline.reversed
                      .take(5)
                      .map(
                        (item) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20,
                            color: AppColors.accent,
                          ),
                          title: Text(
                            _statusLabel(item['status']?.toString() ?? ''),
                          ),
                          subtitle: Text(
                            item['note']?.toString().trim().isEmpty == false
                                ? item['note'].toString()
                                : _displayDate(item['createdAt']?.toString()) ??
                                    '',
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
          const SizedBox(height: 10),
          CustomButton(
            title: 'Update status',
            isOutlined: true,
            isLoading: isUpdating,
            onPressed: isUpdating ? null : onUpdate,
          ),
        ],
      ),
    );
  }
}

class _WorkflowStatusBadge extends StatelessWidget {
  final String status;

  const _WorkflowStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CreateWorkflowSheet extends StatefulWidget {
  final Future<ApiResult> Function(Map<String, dynamic>) onSubmit;

  const _CreateWorkflowSheet({required this.onSubmit});

  @override
  State<_CreateWorkflowSheet> createState() => _CreateWorkflowSheetState();
}

class _CreateWorkflowSheetState extends State<_CreateWorkflowSheet> {
  final _customerName = TextEditingController();
  final _customerEmail = TextEditingController();
  final _attireName = TextEditingController();
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _note = TextEditingController(
    text: 'Production workflow created from Designer Studio',
  );
  DateTime? _completionDate;
  String _status = 'not_started';
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _customerName.dispose();
    _customerEmail.dispose();
    _attireName.dispose();
    _title.dispose();
    _notes.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _completionDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _completionDate = picked);
  }

  Future<void> _submit() async {
    if (_customerName.text.trim().isEmpty ||
        _attireName.text.trim().isEmpty ||
        _title.text.trim().isEmpty ||
        _completionDate == null) {
      setState(() {
        _error = 'Customer, attire, title, and completion date are required.';
      });
      return;
    }

    final body = <String, dynamic>{
      'customerName': _customerName.text.trim(),
      if (_customerEmail.text.trim().isNotEmpty)
        'customerEmail': _customerEmail.text.trim(),
      'attireName': _attireName.text.trim(),
      'workflowTitle': _title.text.trim(),
      'productionNotes': _notes.text.trim(),
      'estimatedCompletionDate': _apiDate(_completionDate!),
      'status': _status,
      'note': _note.text.trim(),
    };
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await widget.onSubmit(body);
    if (!mounted) return;
    if (!result.success) {
      setState(() {
        _saving = false;
        _error = result.message;
      });
      return;
    }

    final created = {
      ...body,
      ...apiMap(result.data),
      'currentStatus':
          apiMap(result.data)['currentStatus']?.toString() ?? _status,
    };
    Navigator.pop(context, created);
  }

  @override
  Widget build(BuildContext context) {
    return _WorkflowSheetShell(
      title: 'Add production workflow',
      children: [
        TextField(
          key: const ValueKey('workflow_customer_name'),
          controller: _customerName,
          decoration: const InputDecoration(labelText: 'Customer name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customerEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Customer email (optional)',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _attireName,
          decoration: const InputDecoration(labelText: 'Attire name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Workflow title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Production notes'),
        ),
        const SizedBox(height: 12),
        _WorkflowDateField(date: _completionDate, onTap: _pickDate),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _status,
          decoration: const InputDecoration(labelText: 'Starting status'),
          items:
              _workflowStatuses
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(_statusLabel(status)),
                    ),
                  )
                  .toList(),
          onChanged:
              (value) => setState(() => _status = value ?? 'not_started'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          decoration: const InputDecoration(labelText: 'Timeline note'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 18),
        CustomButton(
          title: 'Create workflow',
          isLoading: _saving,
          onPressed: _saving ? null : _submit,
        ),
      ],
    );
  }
}

class _UpdateWorkflowSheet extends StatefulWidget {
  final Map<String, dynamic> workflow;

  const _UpdateWorkflowSheet({required this.workflow});

  @override
  State<_UpdateWorkflowSheet> createState() => _UpdateWorkflowSheetState();
}

class _UpdateWorkflowSheetState extends State<_UpdateWorkflowSheet> {
  late final TextEditingController _note;
  late String _status;
  DateTime? _completionDate;

  @override
  void initState() {
    super.initState();
    _status =
        widget.workflow['currentStatus']?.toString() ??
        widget.workflow['status']?.toString() ??
        'not_started';
    _note = TextEditingController();
    _completionDate = DateTime.tryParse(
      widget.workflow['estimatedCompletionDate']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _completionDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _completionDate = picked);
  }

  void _submit() {
    Navigator.pop(context, {
      'status': _status,
      'note': _note.text.trim(),
      if (_completionDate != null)
        'estimatedCompletionDate': _apiDate(_completionDate!),
    });
  }

  @override
  Widget build(BuildContext context) {
    return _WorkflowSheetShell(
      title: 'Update workflow status',
      children: [
        DropdownButtonFormField<String>(
          initialValue:
              _workflowStatuses.contains(_status) ? _status : 'not_started',
          decoration: const InputDecoration(labelText: 'Status'),
          items:
              _workflowStatuses
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(_statusLabel(status)),
                    ),
                  )
                  .toList(),
          onChanged:
              (value) => setState(() => _status = value ?? 'not_started'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Update note',
            hintText: 'Fabric cutting completed',
          ),
        ),
        const SizedBox(height: 12),
        _WorkflowDateField(date: _completionDate, onTap: _pickDate),
        const SizedBox(height: 18),
        CustomButton(title: 'Save status update', onPressed: _submit),
      ],
    );
  }
}

class _WorkflowSheetShell extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _WorkflowSheetShell({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      title,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkflowDateField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _WorkflowDateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Estimated completion date',
          suffixIcon: Icon(Icons.calendar_month_outlined),
        ),
        child: Text(date == null ? 'Choose date' : _apiDate(date!)),
      ),
    );
  }
}

String _apiDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String? _displayDate(String? value) {
  if (value == null || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  return parsed == null ? value : _apiDate(parsed);
}

String _statusLabel(String status) {
  if (status.isEmpty) return 'Unknown';
  return status
      .split('_')
      .map(
        (part) =>
            part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
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
        final sales = apiMap(data['sales']);
        final listings = apiMap(data['listings']);
        final orders = apiMap(data['orders']);
        final engagement = apiMap(data['engagement']);
        final metrics = [
          _AnalyticsMetric(
            label: 'Total sales',
            value: sales['totalSales'],
            icon: Icons.payments_outlined,
            isMoney: true,
          ),
          _AnalyticsMetric(
            label: 'Transactions',
            value: _formatCount(sales['transactionCount']),
            icon: Icons.receipt_long_outlined,
          ),
          _AnalyticsMetric(
            label: 'Listings',
            value: _formatCount(listings['totalListings']),
            icon: Icons.checkroom_outlined,
          ),
          _AnalyticsMetric(
            label: 'Completed orders',
            value: _formatCount(orders['completedOrders']),
            icon: Icons.task_alt_rounded,
          ),
          _AnalyticsMetric(
            label: 'Reviews',
            value: _formatCount(engagement['reviewsCount']),
            icon: Icons.star_outline_rounded,
          ),
          _AnalyticsMetric(
            label: 'Conversations',
            value: _formatCount(engagement['conversationsCount']),
            icon: Icons.chat_bubble_outline_rounded,
          ),
        ];
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = (constraints.maxWidth - 10) / 2;
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children:
                              metrics
                                  .map(
                                    (metric) => SizedBox(
                                      width: width,
                                      child: _AnalyticsMetricCard(
                                        metric: metric,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        );
                      },
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
                final escrowOrders =
                    apiList(wallet['orders']).isNotEmpty
                        ? apiList(wallet['orders'])
                        : apiList(wallet['escrows']).isNotEmpty
                        ? apiList(wallet['escrows'])
                        : apiList(wallet['records']).isNotEmpty
                        ? apiList(wallet['records'])
                        : apiList(walletSnapshot.data?.data);
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
                      else if (walletSnapshot.hasError ||
                          (walletSnapshot.hasData &&
                              !walletSnapshot.data!.success))
                        _InlineApiError(
                          message:
                              walletSnapshot.data?.message ??
                              'Unable to load escrow wallet.',
                          statusCode: walletSnapshot.data?.statusCode ?? 0,
                          onRetry: () {
                            setState(() {
                              _escrowWalletFuture =
                                  NewestFeatureService.getDesignerEscrowWallet();
                            });
                          },
                        )
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
                              icon: Icons.hourglass_top_rounded,
                            ),
                            _MetricPill(
                              label: 'Released',
                              value: summary['released'],
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                            _MetricPill(
                              label: 'Refunded',
                              value: summary['refunded'],
                              icon: Icons.replay_rounded,
                            ),
                          ],
                        ),
                      if (escrowOrders.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const CustomText(
                          'Escrow orders',
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        ...escrowOrders.map(
                          (order) => _EscrowWalletOrderCard(order: order),
                        ),
                      ],
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
                  const SizedBox(height: 6),
                  const CustomText(
                    'Choose one of your listings to feature or remove from featured placement.',
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
                          onPressed:
                              _saving || _selectedListing == null
                                  ? null
                                  : () => _feature(false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          title: 'Feature listing',
                          isLoading: _saving,
                          onPressed:
                              _saving || _selectedListing == null
                                  ? null
                                  : () => _feature(true),
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
                  final result = snapshot.data;
                  final reviews =
                      result?.success == true
                          ? apiList(snapshot.data!.data)
                          : const <Map<String, dynamic>>[];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (result != null && !result.success) {
                    return _InlineApiError(
                      message: result.message,
                      statusCode: result.statusCode,
                      onRetry:
                          () => setState(() {
                            _reviewsFuture = _loadReviews();
                          }),
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

class _AnalyticsMetric {
  final String label;
  final dynamic value;
  final IconData icon;
  final bool isMoney;

  const _AnalyticsMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.isMoney = false,
  });
}

class _AnalyticsMetricCard extends StatelessWidget {
  final _AnalyticsMetric metric;

  const _AnalyticsMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(height: 12),
          if (metric.isMoney)
            _ConvertedCurrencyAmount(value: metric.value, fontSize: 18)
          else
            CustomText(
              metric.value.toString(),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.left,
            ),
          const SizedBox(height: 3),
          CustomText(
            metric.label,
            fontSize: 12,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final dynamic value;
  final IconData icon;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(height: 10),
          _ConvertedCurrencyAmount(value: value, fontSize: 17),
          const SizedBox(height: 4),
          CustomText(
            label,
            fontSize: 12,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _EscrowWalletOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _EscrowWalletOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final request = apiMap(order['request']);
    final customer = apiMap(order['customer']);
    final milestones = apiList(order['milestones']);
    final title =
        request['title']?.toString() ??
        order['title']?.toString() ??
        customer['fullName']?.toString() ??
        order['customerName']?.toString() ??
        _recordId(order);
    final status = order['status']?.toString() ?? 'pending';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_clock_outlined,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title.isEmpty ? 'Escrow order' : title,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 3),
                    CustomText(
                      'Status: $status',
                      fontSize: 12,
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (milestones.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  milestones.map((milestone) {
                    final name = milestone['name']?.toString() ?? 'milestone';
                    final amount = milestone['amount'];
                    final milestoneStatus =
                        milestone['status']?.toString() ?? 'pending';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: CustomText(
                        '$name: ${_formatCount(amount)} ($milestoneStatus)',
                        fontSize: 12,
                        textAlign: TextAlign.left,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConvertedCurrencyAmount extends StatelessWidget {
  final dynamic value;
  final double fontSize;

  const _ConvertedCurrencyAmount({required this.value, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final amountInNgn = _numericValue(value);
    return FutureBuilder<double>(
      future: CurrencyHelper.convertFromNGN(amountInNgn.round()),
      builder: (context, snapshot) {
        final formatted =
            snapshot.hasData
                ? CurrencyHelper.formatAmount(snapshot.data!)
                : '...';
        return CustomText(
          formatted,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          textAlign: TextAlign.left,
        );
      },
    );
  }
}

double _numericValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _formatCount(dynamic value) {
  final number = _numericValue(value);
  if (number == number.roundToDouble()) return number.toInt().toString();
  return number.toStringAsFixed(1);
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

class _InlineApiError extends StatelessWidget {
  final String message;
  final int statusCode;
  final VoidCallback onRetry;

  const _InlineApiError({
    required this.message,
    required this.statusCode,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = statusCode > 0 ? 'Status $statusCode' : 'Request failed';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.subtext),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  statusText,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 4),
                CustomText(
                  message.isEmpty ? 'Unable to load reviews.' : message,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioImagePicker extends StatelessWidget {
  final List<File> images;
  final int maxImages;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  const _PortfolioImagePicker({
    required this.images,
    required this.maxImages,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    images.isEmpty
                        ? AppColors.surfaceMuted
                        : AppColors.accentSoft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: images.isEmpty ? AppColors.border : AppColors.accent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color:
                        images.isEmpty ? AppColors.subtext : AppColors.accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          images.isEmpty
                              ? 'Choose portfolio images'
                              : '${images.length} of $maxImages images selected',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Select up to $maxImages images from your camera roll',
                          style: const TextStyle(
                            color: AppColors.subtext,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const ColoredBox(
                              color: AppColors.surfaceMuted,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.subtext,
                              ),
                            ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: IconButton(
                            key: ValueKey('remove_portfolio_image_$index'),
                            tooltip: 'Remove image',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onRemove(index),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
