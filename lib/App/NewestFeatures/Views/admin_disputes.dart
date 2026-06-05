import 'package:flutter/material.dart';
import 'package:hog/App/NewestFeatures/Api/newest_feature_service.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class AdminDisputes extends StatefulWidget {
  const AdminDisputes({super.key});

  @override
  State<AdminDisputes> createState() => _AdminDisputesState();
}

class _AdminDisputesState extends State<AdminDisputes> {
  late Future<ApiResult> _future;
  final _disputeId = TextEditingController();
  final _resolution = TextEditingController();
  final _adminNote = TextEditingController();
  final _escrowId = TextEditingController();
  final _escrowAmount = TextEditingController();
  final _escrowNote = TextEditingController();
  String _status = 'resolved';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = NewestFeatureService.getAdminDisputes();
  }

  @override
  void dispose() {
    _disputeId.dispose();
    _resolution.dispose();
    _adminNote.dispose();
    _escrowId.dispose();
    _escrowAmount.dispose();
    _escrowNote.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    setState(() => _saving = true);
    final result =
        await NewestFeatureService.updateAdminDispute(_disputeId.text.trim(), {
          'status': _status,
          'resolution': _resolution.text.trim(),
          'adminNote': _adminNote.text.trim(),
        });
    if (!mounted) return;
    setState(() {
      _saving = false;
      _future = NewestFeatureService.getAdminDisputes();
    });
    _showResult(result);
  }

  Future<void> _releaseEscrow() async {
    setState(() => _saving = true);
    final result =
        await NewestFeatureService.releaseEscrow(_escrowId.text.trim(), {
          'amount': double.tryParse(_escrowAmount.text.trim()) ?? 0,
          'adminNote': _escrowNote.text.trim(),
        });
    if (!mounted) return;
    setState(() => _saving = false);
    _showResult(result);
  }

  Future<void> _refundEscrow() async {
    setState(() => _saving = true);
    final result =
        await NewestFeatureService.refundEscrow(_escrowId.text.trim(), {
          'amount': double.tryParse(_escrowAmount.text.trim()) ?? 0,
          'adminNote': _escrowNote.text.trim(),
        });
    if (!mounted) return;
    setState(() => _saving = false);
    _showResult(result);
  }

  void _showResult(ApiResult result) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Dispute Resolution'),
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<ApiResult>(
        future: _future,
        builder: (context, snapshot) {
          final disputes =
              snapshot.hasData
                  ? apiList(snapshot.data!.data)
                  : const <Map<String, dynamic>>[];
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _future = NewestFeatureService.getAdminDisputes());
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                        'Resolve ticket',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: 'open', child: Text('Open')),
                          DropdownMenuItem(
                            value: 'in_review',
                            child: Text('In review'),
                          ),
                          DropdownMenuItem(
                            value: 'resolved',
                            child: Text('Resolved'),
                          ),
                          DropdownMenuItem(
                            value: 'rejected',
                            child: Text('Rejected'),
                          ),
                        ],
                        onChanged:
                            (value) =>
                                setState(() => _status = value ?? 'resolved'),
                      ),
                      CustomTextField(
                        title: 'Dispute ID',
                        hintText: 'Paste dispute ID',
                        fieldKey: 'admin_dispute_id',
                        controller: _disputeId,
                      ),
                      CustomTextField(
                        title: 'Resolution',
                        hintText: 'Designer agreed to revise sleeve length.',
                        fieldKey: 'admin_dispute_resolution',
                        controller: _resolution,
                      ),
                      CustomTextField(
                        title: 'Admin note',
                        hintText: 'Internal decision note',
                        fieldKey: 'admin_dispute_note',
                        controller: _adminNote,
                      ),
                      CustomButton(
                        title: 'Update dispute',
                        isLoading: _saving,
                        onPressed: _saving ? null : _update,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                        'Escrow intervention',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      const CustomText(
                        'Release held payment after delivery confirmation, or refund after dispute review.',
                        color: AppColors.subtext,
                        textAlign: TextAlign.left,
                      ),
                      CustomTextField(
                        title: 'Escrow ID',
                        hintText: 'Payment protection record ID',
                        fieldKey: 'admin_escrow_id',
                        controller: _escrowId,
                      ),
                      CustomTextField(
                        title: 'Amount',
                        hintText: '100000',
                        fieldKey: 'admin_escrow_amount',
                        controller: _escrowAmount,
                        keyboardType: TextInputType.number,
                      ),
                      CustomTextField(
                        title: 'Admin note',
                        hintText: 'Delivery confirmed or refund approved',
                        fieldKey: 'admin_escrow_note',
                        controller: _escrowNote,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              title: 'Refund',
                              isOutlined: true,
                              isLoading: _saving,
                              onPressed: _saving ? null : _refundEscrow,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomButton(
                              title: 'Release',
                              isLoading: _saving,
                              onPressed: _saving ? null : _releaseEscrow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const CustomText(
                  'Admin queue',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (disputes.isEmpty)
                  _EmptyDisputeCard()
                else
                  ...disputes.map(
                    (item) => _DisputeCard(
                      item: item,
                      onTap: () {
                        _disputeId.text = item['_id']?.toString() ?? '';
                        _resolution.text = item['resolution']?.toString() ?? '';
                        _adminNote.text = item['adminNote']?.toString() ?? '';
                        setState(() {
                          _status = item['status']?.toString() ?? _status;
                        });
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _DisputeCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title =
        item['title']?.toString() ?? item['category']?.toString() ?? 'Dispute';
    final status = item['status']?.toString() ?? 'open';
    final id = item['_id']?.toString();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    title,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                ),
                Chip(label: Text(status)),
              ],
            ),
            if (item['description'] != null) ...[
              const SizedBox(height: 6),
              CustomText(
                item['description'].toString(),
                fontSize: 12,
                color: AppColors.subtext,
                textAlign: TextAlign.left,
              ),
            ],
            if (id != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                id,
                style: const TextStyle(fontSize: 11, color: AppColors.subtext),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyDisputeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const CustomText(
        'No disputes are waiting for admin action.',
        color: AppColors.subtext,
      ),
    );
  }
}
