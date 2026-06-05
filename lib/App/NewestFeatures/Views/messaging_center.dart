import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/NewestFeatures/Api/newest_feature_service.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class MessagingCenter extends StatefulWidget {
  const MessagingCenter({super.key});

  @override
  State<MessagingCenter> createState() => _MessagingCenterState();
}

class _MessagingCenterState extends State<MessagingCenter> {
  late Future<ApiResult> _future;
  late Future<ApiResult> _eligibleThreadsFuture;
  Map<String, dynamic>? _selectedThread;
  String _topic = 'measurement';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = NewestFeatureService.getConversations();
    _eligibleThreadsFuture = NewestFeatureService.getEligibleMessageThreads();
  }

  Future<void> _createConversation() async {
    final selected = _selectedThread;
    if (selected == null) {
      _showResult(ApiResult.failure('Choose an accepted quotation first.'));
      return;
    }

    setState(() => _saving = true);
    final result = await NewestFeatureService.createConversation({
      'threadId': _recordId(selected, preferredKey: 'threadId'),
      'topic': _topic,
    });
    if (!mounted) return;
    setState(() {
      _saving = false;
      _future = NewestFeatureService.getConversations();
    });
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
    return FutureBuilder<ApiResult>(
      future: _future,
      builder: (context, snapshot) {
        final conversations =
            snapshot.hasData
                ? apiList(snapshot.data!.data)
                : const <Map<String, dynamic>>[];
        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _future = NewestFeatureService.getConversations());
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
                      'Order messaging',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    const CustomText(
                      'Only accepted quotation relationships can start a chat. Images and voice notes are supported. Video sharing and contact details are blocked by backend policy.',
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<ApiResult>(
                      future: _eligibleThreadsFuture,
                      builder: (context, orderSnapshot) {
                        final threads =
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
                        return _ThreadSelector(
                          threads: threads,
                          selected: _selectedThread,
                          emptyText:
                              'No accepted quotations yet. Chat opens after both sides agree on a quotation.',
                          onSelected:
                              (thread) =>
                                  setState(() => _selectedThread = thread),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _topic,
                      decoration: const InputDecoration(labelText: 'Topic'),
                      items: const [
                        DropdownMenuItem(
                          value: 'measurement',
                          child: Text('Measurement'),
                        ),
                        DropdownMenuItem(value: 'quote', child: Text('Quote')),
                        DropdownMenuItem(
                          value: 'delivery',
                          child: Text('Delivery'),
                        ),
                      ],
                      onChanged:
                          (value) =>
                              setState(() => _topic = value ?? 'measurement'),
                    ),
                    CustomButton(
                      title: 'Start conversation',
                      isLoading: _saving,
                      onPressed:
                          _saving || _selectedThread == null
                              ? null
                              : _createConversation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const CustomText(
                'Conversations',
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
              else if (conversations.isEmpty)
                _Panel(
                  child: const CustomText(
                    'No conversations yet.',
                    color: AppColors.subtext,
                  ),
                )
              else
                ...conversations.map(
                  (conversation) =>
                      _ConversationCard(conversation: conversation),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ThreadSelector extends StatelessWidget {
  final List<Map<String, dynamic>> threads;
  final Map<String, dynamic>? selected;
  final ValueChanged<Map<String, dynamic>> onSelected;
  final String emptyText;

  const _ThreadSelector({
    required this.threads,
    required this.selected,
    required this.onSelected,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: CustomText(
          emptyText,
          color: AppColors.subtext,
          textAlign: TextAlign.left,
        ),
      );
    }

    return Column(
      children:
          threads.map((thread) {
            final selectedId =
                selected == null
                    ? ''
                    : _recordId(selected!, preferredKey: 'threadId');
            final currentId = _recordId(thread, preferredKey: 'threadId');
            final isSelected = selectedId == currentId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelected(thread),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentSoft : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.chat_bubble_outline_rounded,
                        color:
                            isSelected ? AppColors.accent : AppColors.subtext,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              thread['title']?.toString() ?? 'Conversation',
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 4),
                            CustomText(
                              thread['subtitle']?.toString() ??
                                  thread['status']?.toString() ??
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
          }).toList(),
    );
  }
}

class MessageThread extends StatefulWidget {
  final String conversationId;

  const MessageThread({super.key, required this.conversationId});

  @override
  State<MessageThread> createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  late Future<ApiResult> _future;
  final _message = TextEditingController();
  File? _attachment;
  final _picker = ImagePicker();
  String? _currentUserId;
  String? _currentUserRole;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _future = NewestFeatureService.getMessages(widget.conversationId);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final values = await Future.wait([
      SecurePrefs.getUserId(),
      SecurePrefs.getUserRole(),
    ]);
    if (!mounted) return;
    setState(() {
      _currentUserId = values[0];
      _currentUserRole = values[1];
    });
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _attachment = File(picked.path));
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final file = _attachment;
    final content = _message.text.trim();
    final result =
        file == null
            ? await NewestFeatureService.sendMessage(widget.conversationId, {
              'topic': 'quote',
              'content': content,
            })
            : await NewestFeatureService.sendMessageFiles(
              widget.conversationId,
              topic: 'quote',
              content: content,
              files: [file],
            );
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (result.success) {
        _message.clear();
        _attachment = null;
      }
      _future = NewestFeatureService.getMessages(widget.conversationId);
    });
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(result.success ? result.message : result.message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Conversation'),
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<ApiResult>(
              future: _future,
              builder: (context, snapshot) {
                final messages =
                    snapshot.hasData
                        ? apiList(snapshot.data!.data)
                        : const <Map<String, dynamic>>[];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (messages.isEmpty) {
                  return const Center(child: CustomText('No messages yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(
                      message: message,
                      currentUserId: _currentUserId,
                      currentUserRole: _currentUserRole,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  _AttachmentPicker(
                    file: _attachment,
                    onPick: _pickAttachment,
                    onClear: () => setState(() => _attachment = null),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _message,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Message the designer',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: _sending ? null : _send,
                        icon:
                            _sending
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final Map<String, dynamic> conversation;

  const _ConversationCard({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final id = conversation['_id']?.toString() ?? '';
    final title = _conversationTitle(conversation);
    final preview = _conversationPreview(conversation);
    return InkWell(
      onTap:
          id.isEmpty
              ? null
              : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MessageThread(conversationId: id),
                ),
              ),
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
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.accent,
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
                    preview,
                    fontSize: 12,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.subtext),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final String? currentUserId;
  final String? currentUserRole;

  const _MessageBubble({
    required this.message,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  Widget build(BuildContext context) {
    final content = message['content']?.toString() ?? '';
    final isMine = _isMyMessage(message, currentUserId, currentUserRole);
    final senderName = _messageSenderName(message);
    final deliveryStatus = _visibleDeliveryStatus(message['deliveryStatus']);
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.accentSoft : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 18),
          ),
          border: Border.all(
            color:
                isMine
                    ? AppColors.accent.withValues(alpha: 0.22)
                    : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine && senderName != null) ...[
              CustomText(
                senderName,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 5),
            ],
            CustomText(
              content.isEmpty ? 'Attachment message' : content,
              textAlign: TextAlign.left,
            ),
            if (isMine && deliveryStatus != null) ...[
              const SizedBox(height: 6),
              CustomText(
                deliveryStatus,
                fontSize: 11,
                color: AppColors.subtext,
                textAlign: TextAlign.left,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AttachmentPicker extends StatelessWidget {
  final File? file;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _AttachmentPicker({
    required this.file,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final selected = file != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPick,
              icon: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.add_photo_alternate_outlined,
              ),
              label: Text(
                selected
                    ? file!.path.split(Platform.pathSeparator).last
                    : 'Attach image',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Remove attachment',
            ),
          ],
        ],
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

String _recordId(Map<String, dynamic> record, {String? preferredKey}) {
  if (preferredKey != null && record[preferredKey] != null) {
    return record[preferredKey].toString();
  }
  return record['_id']?.toString() ?? record['id']?.toString() ?? '';
}

String _conversationTitle(Map<String, dynamic> conversation) {
  for (final key in [
    'title',
    'participantName',
    'designerName',
    'customerName',
  ]) {
    final value = conversation[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }

  for (final key in [
    'otherParticipant',
    'participant',
    'designer',
    'customer',
  ]) {
    final value = conversation[key];
    if (value is Map) {
      final record = Map<String, dynamic>.from(value);
      for (final nameKey in ['name', 'fullName', 'businessName', 'username']) {
        final name = record[nameKey]?.toString().trim();
        if (name != null && name.isNotEmpty) return name;
      }
    }
  }

  return 'Conversation';
}

String _conversationPreview(Map<String, dynamic> conversation) {
  for (final key in ['latestMessage', 'lastMessage', 'preview']) {
    final value = conversation[key];
    if (value is Map) {
      final content = value['content']?.toString().trim();
      if (content != null && content.isNotEmpty) return content;
    }
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  }

  final topic = conversation['topic']?.toString().trim();
  if (topic != null && topic.isNotEmpty) {
    return '${topic[0].toUpperCase()}${topic.substring(1)} conversation';
  }
  return 'Tap to open chat';
}

bool _isMyMessage(
  Map<String, dynamic> message,
  String? currentUserId,
  String? currentUserRole,
) {
  if (message['isMine'] == true || message['isCurrentUser'] == true) {
    return true;
  }

  final senderId =
      message['senderId']?.toString() ??
      message['userId']?.toString() ??
      _nestedId(message['sender']) ??
      _nestedId(message['user']);
  if (currentUserId != null && senderId != null) {
    return senderId == currentUserId;
  }

  final senderType = message['senderType']?.toString().trim().toLowerCase();
  final role = currentUserRole?.trim().toLowerCase();
  if (senderType != null && role != null) {
    final isCustomerSender = const {
      'customer',
      'user',
      'buyer',
    }.contains(senderType);
    final isDesignerSender = const {
      'tailor',
      'designer',
      'vendor',
      'seller',
    }.contains(senderType);
    if (role == 'tailor') return isDesignerSender;
    if (role == 'user' || role == 'customer') return isCustomerSender;
  }
  return false;
}

String? _nestedId(dynamic value) {
  if (value is! Map) return null;
  return value['_id']?.toString() ?? value['id']?.toString();
}

String? _messageSenderName(Map<String, dynamic> message) {
  for (final key in ['senderName', 'name']) {
    final value = message[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  final sender = message['sender'];
  if (sender is Map) {
    for (final key in ['name', 'fullName', 'businessName', 'username']) {
      final value = sender[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
  }
  return null;
}

String? _visibleDeliveryStatus(dynamic rawStatus) {
  final status = rawStatus?.toString().trim().toLowerCase();
  if (status == 'sent' || status == 'delivered' || status == 'read') {
    return status;
  }
  return null;
}
