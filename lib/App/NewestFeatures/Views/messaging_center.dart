import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/NewestFeatures/Api/newest_feature_service.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


class MessagingCenter extends StatefulWidget {
  const MessagingCenter({super.key});

  @override
  State<MessagingCenter> createState() => _MessagingCenterState();
}

class _MessagingCenterState extends State<MessagingCenter> {
  late Future<List<ApiResult>> _future;
  String? _openingThreadId;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userId = await SecurePrefs.getUserId();
    if (!mounted) return;
    setState(() => _currentUserId = userId);
  }

  Future<List<ApiResult>> _load() {
    return Future.wait([
      NewestFeatureService.getEligibleMessageThreads(),
      NewestFeatureService.getConversations(),
    ]);
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  Future<void> _openEligibleThread(Map<String, dynamic> thread) async {
    final threadId = _idFrom(thread, const ['threadId', 'orderId', '_id']);
    if (threadId.isEmpty || _openingThreadId != null) return;

    setState(() => _openingThreadId = threadId);
    final result = await NewestFeatureService.createConversation({
      'orderType': thread['threadType']?.toString() ?? 'customRequest',
      'threadId': threadId,
      'orderId': threadId,
      'topic': 'order',
    });
    if (!mounted) return;
    setState(() => _openingThreadId = null);

    if (!result.success) {
      _showMessage(result.message);
      return;
    }

    final conversation = apiMap(result.data);
    final conversationId = _idFrom(conversation, const [
      '_id',
      'conversationId',
      'id',
    ]);
    if (conversationId.isEmpty) {
      _showMessage('Conversation ID was not returned.');
      return;
    }

    await _openConversation(
      conversationId,
      title: _threadTitle(thread),
      imageUrl: _otherParticipantImage(thread, _currentUserId),
    );
  }

  Future<void> _openExistingConversation(
    Map<String, dynamic> conversation,
  ) async {
    final conversationId = _idFrom(conversation, const [
      'conversationId',
      '_id',
      'id',
    ]);
    if (conversationId.isEmpty) return;
    await _openConversation(
      conversationId,
      title: _threadTitle(conversation),
      imageUrl: _otherParticipantImage(conversation, _currentUserId),
    );
  }

  Future<void> _openContact(_ChatContact contact) async {
    final option = await showModalBottomSheet<_ChatOrderOption>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Avatar(title: contact.title, imageUrl: contact.imageUrl),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Choose the attire quotation to discuss',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.subtext),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: contact.orders.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final order = contact.orders[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE1F3EF),
                            child: Icon(
                              order.conversation == null
                                  ? Icons.receipt_long_outlined
                                  : Icons.forum_rounded,
                              color: const Color(0xFF128C7E),
                            ),
                          ),
                          title: Text(
                            order.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            order.conversation == null
                                ? 'Start order chat'
                                : 'Continue order chat',
                          ),
                          trailing:
                              _openingThreadId == order.threadId
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.pop(sheetContext, order),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
    if (!mounted || option == null) return;
    if (option.conversation != null) {
      await _openExistingConversation(option.conversation!);
    } else {
      await _openEligibleThread(option.thread);
    }
  }

  Future<void> _openConversation(
    String conversationId, {
    required String title,
    required String imageUrl,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MessageThread(
              conversationId: conversationId,
              title: title,
              imageUrl: imageUrl,
            ),
      ),
    );
    if (mounted) await _refresh();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApiResult>>(
      future: _future,
      builder: (context, snapshot) {
        final eligible =
            snapshot.hasData
                ? apiList(snapshot.data![0].data)
                : const <Map<String, dynamic>>[];
        final conversations =
            snapshot.hasData
                ? apiList(snapshot.data![1].data)
                : const <Map<String, dynamic>>[];
        final contacts = _groupChatsByContact(
          eligible: eligible,
          conversations: conversations,
          currentUserId: _currentUserId,
        );
        ApiResult? error;
        if (snapshot.hasData) {
          for (final result in snapshot.data!) {
            if (!result.success) {
              error = result;
              break;
            }
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              const _ChatsHeader(),
              if (error != null) ...[
                const SizedBox(height: 12),
                _MessageNotice(
                  message: error.message,
                  icon: Icons.error_outline_rounded,
                ),
              ],
              const SizedBox(height: 20),
              const _SectionLabel('Chats'),
              const SizedBox(height: 8),
              if (contacts.isEmpty)
                const _MessageNotice(
                  message:
                      'No chats yet. A person appears here after an offer or quotation is accepted.',
                  icon: Icons.forum_outlined,
                )
              else
                ...contacts.map(
                  (contact) => _ChatListTile(
                    title: contact.title,
                    subtitle:
                        contact.orders.length == 1
                            ? '1 attire quotation'
                            : '${contact.orders.length} attire quotations',
                    imageUrl: contact.imageUrl,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.subtext,
                    ),
                    onTap: () => _openContact(contact),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class MessageThread extends StatefulWidget {
  final String conversationId;
  final String title;
  final String imageUrl;

  const MessageThread({
    super.key,
    required this.conversationId,
    this.title = 'Conversation',
    this.imageUrl = '',
  });

  @override
  State<MessageThread> createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  final _message = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  final List<Map<String, dynamic>> _messages = [];
  Timer? _pollTimer;
  File? _attachment;
  String? _currentUserId;
  bool _sending = false;
  bool _loadingMessages = true;
  bool _polling = false;
  String? _messageError;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadMessages(silent: true);
    });
  }

  Future<void> _loadCurrentUser() async {
    final userId = await SecurePrefs.getUserId();
    if (!mounted) return;
    setState(() => _currentUserId = userId);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _message.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _loadMessages();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (_polling) return;
    _polling = true;
    if (!silent && mounted) {
      setState(() {
        _loadingMessages = true;
        _messageError = null;
      });
    }

    final result = await NewestFeatureService.getMessages(
      widget.conversationId,
    );
    _polling = false;
    if (!mounted) return;

    final incoming = apiList(result.data);
    final shouldScroll = incoming.length > _messages.length;
    setState(() {
      _loadingMessages = false;
      if (result.success) {
        _messages
          ..clear()
          ..addAll(incoming);
        _messageError = null;
      } else if (!silent) {
        _messageError = result.message;
      }
    });
    if (shouldScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _attachment = File(picked.path));
  }

  Future<void> _send() async {
    final content = _message.text.trim();
    final attachment = _attachment;
    if (content.isEmpty && attachment == null) return;
    final blockedReason = _blockedMessageReason(content);
    if (blockedReason != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(blockedReason)));
      return;
    }

    setState(() => _sending = true);
    final result =
        attachment == null
            ? await NewestFeatureService.sendMessage(widget.conversationId, {
              'content': content,
              'topic': 'order',
            })
            : await NewestFeatureService.sendMessageFiles(
              widget.conversationId,
              topic: 'order',
              content: content,
              files: [attachment],
            );
    if (!mounted) return;

    setState(() {
      _sending = false;
      if (result.success) {
        _message.clear();
        _attachment = null;
      }
    });
    if (result.success) await _loadMessages(silent: true);
    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            _Avatar(title: widget.title, imageUrl: widget.imageUrl, radius: 19),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Order chat',
                    style: TextStyle(fontSize: 11, color: AppColors.subtext),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh messages',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _loadingMessages
                    ? const Center(child: CircularProgressIndicator())
                    : _messageError != null
                    ? _ThreadEmptyState(
                      icon: Icons.error_outline_rounded,
                      message: _messageError!,
                      onRetry: _refresh,
                    )
                    : _messages.isEmpty
                    ? _ThreadEmptyState(
                      icon: Icons.lock_outline_rounded,
                      message:
                          'Discuss only the selected attire, measurements, fitting, production, and delivery progress.',
                      onRetry: _refresh,
                    )
                    : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
                        itemCount: _messages.length,
                        itemBuilder:
                            (context, index) => _MessageBubble(
                              message: _messages[index],
                              currentUserId: _currentUserId,
                            ),
                      ),
                    ),
          ),
          _MessageComposer(
            controller: _message,
            attachment: _attachment,
            sending: _sending,
            onPickImage: _pickImage,
            onClearAttachment: () => setState(() => _attachment = null),
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _ChatsHeader extends StatelessWidget {
  const _ChatsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Color(0xFFE1F3EF),
            child: Icon(Icons.forum_rounded, color: Color(0xFF128C7E)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'Order chats',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 3),
                CustomText(
                  'Chat becomes available after a quotation is accepted.',
                  fontSize: 12,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Widget trailing;
  final VoidCallback onTap;

  const _ChatListTile({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              _Avatar(title: title, imageUrl: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double radius;

  const _Avatar({
    required this.title,
    required this.imageUrl,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final initial = title.trim().isEmpty ? '?' : title.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE1F3EF),
      backgroundImage: imageUrl.isEmpty ? null : NetworkImage(imageUrl),
      child:
          imageUrl.isEmpty
              ? Text(
                initial,
                style: const TextStyle(
                  color: Color(0xFF128C7E),
                  fontWeight: FontWeight.w800,
                ),
              )
              : null,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final String? currentUserId;

  const _MessageBubble({required this.message, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isMine = _messageSenderId(message) == currentUserId;
    final content = message['content']?.toString().trim() ?? '';
    final blockedContent = _blockedMessageReason(content) != null;
    final attachments = _attachments(message);
    final time = _formatTime(message['createdAt']);
    final status = message['deliveryStatus']?.toString().toLowerCase() ?? '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: Radius.circular(isMine ? 8 : 2),
            bottomRight: Radius.circular(isMine ? 2 : 8),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...attachments.map(
              (attachment) => _MessageAttachment(attachment: attachment),
            ),
            if (content.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  left: 4,
                  right: 4,
                  top: attachments.isEmpty ? 0 : 6,
                ),
                child: Text(
                  blockedContent
                      ? 'Message hidden: contact and location details are not allowed.'
                      : content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: blockedContent ? AppColors.subtext : AppColors.ink,
                    fontStyle:
                        blockedContent ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.subtext,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 3),
                  Icon(
                    status == 'read'
                        ? Icons.done_all_rounded
                        : status == 'delivered'
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 15,
                    color:
                        status == 'read'
                            ? const Color(0xFF34B7F1)
                            : AppColors.subtext,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageAttachment extends StatelessWidget {
  final Map<String, dynamic> attachment;

  const _MessageAttachment({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final url =
        attachment['url']?.toString() ??
        attachment['fileUrl']?.toString() ??
        attachment['secureUrl']?.toString() ??
        '';
    final type =
        attachment['type']?.toString() ??
        attachment['messageType']?.toString() ??
        'image';

    if (type == 'voice') {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_fill_rounded, color: Color(0xFF128C7E)),
            SizedBox(width: 8),
            Text('Voice message'),
          ],
        ),
      );
    }
    if (url.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: 220,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => const SizedBox(
              width: 220,
              height: 100,
              child: Center(child: Icon(Icons.broken_image_outlined)),
            ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final File? attachment;
  final bool sending;
  final VoidCallback onPickImage;
  final VoidCallback onClearAttachment;
  final VoidCallback onSend;

  const _MessageComposer({
    required this.controller,
    required this.attachment,
    required this.sending,
    required this.onPickImage,
    required this.onClearAttachment,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xFFF0F2F5),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Column(
          children: [
            if (attachment != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        attachment!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Attire image ready to send')),
                    IconButton(
                      tooltip: 'Remove image',
                      onPressed: onClearAttachment,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Attach image',
                          onPressed: sending ? null : onPickImage,
                          icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.subtext,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 5,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Discuss this attire',
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Send',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF128C7E),
                    fixedSize: const Size(48, 48),
                  ),
                  onPressed: sending ? null : onSend,
                  icon:
                      sending
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageNotice extends StatelessWidget {
  final String message;
  final IconData icon;

  const _MessageNotice({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.subtext),
          const SizedBox(height: 8),
          CustomText(message, color: AppColors.subtext),
        ],
      ),
    );
  }
}

class _ThreadEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Future<void> Function() onRetry;

  const _ThreadEmptyState({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 160),
        Icon(icon, size: 38, color: AppColors.subtext),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: CustomText(message, color: AppColors.subtext),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF128C7E),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ChatContact {
  final String key;
  final String title;
  final String imageUrl;
  final List<_ChatOrderOption> orders;

  const _ChatContact({
    required this.key,
    required this.title,
    required this.imageUrl,
    required this.orders,
  });
}

class _ChatOrderOption {
  final String threadId;
  final Map<String, dynamic> thread;
  final Map<String, dynamic>? conversation;

  const _ChatOrderOption({
    required this.threadId,
    required this.thread,
    this.conversation,
  });

  String get subtitle =>
      thread['subtitle']?.toString().trim().isNotEmpty == true
          ? thread['subtitle'].toString()
          : conversation == null
          ? 'Accepted attire quotation'
          : _conversationPreview(conversation!);
}

List<_ChatContact> _groupChatsByContact({
  required List<Map<String, dynamic>> eligible,
  required List<Map<String, dynamic>> conversations,
  required String? currentUserId,
}) {
  final ordersByThread = <String, _ChatOrderOption>{};

  for (final thread in eligible) {
    final threadId = _idFrom(thread, const ['threadId', 'orderId', '_id']);
    if (threadId.isEmpty) continue;
    ordersByThread[threadId] = _ChatOrderOption(
      threadId: threadId,
      thread: thread,
    );
  }

  for (final conversation in conversations) {
    final threadId = _idFrom(conversation, const [
      'threadId',
      'orderId',
      '_id',
    ]);
    if (threadId.isEmpty) continue;
    final existing = ordersByThread[threadId];
    ordersByThread[threadId] = _ChatOrderOption(
      threadId: threadId,
      thread: existing?.thread ?? conversation,
      conversation: conversation,
    );
  }

  final grouped = <String, List<_ChatOrderOption>>{};
  for (final order in ordersByThread.values) {
    final participant = _otherParticipantRecord(order.thread, currentUserId);
    final participantId = _idFrom(participant, const ['_id', 'id']);
    final title = _threadTitle(order.thread);
    final key =
        participantId.isNotEmpty
            ? participantId
            : title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    grouped.putIfAbsent(key, () => []).add(order);
  }

  final contacts =
      grouped.entries.map((entry) {
        final orders = entry.value;
        final representative = orders.first.thread;
        orders.sort((a, b) => a.subtitle.compareTo(b.subtitle));
        return _ChatContact(
          key: entry.key,
          title: _threadTitle(representative),
          imageUrl: _otherParticipantImage(representative, currentUserId),
          orders: orders,
        );
      }).toList();
  contacts.sort((a, b) => a.title.compareTo(b.title));
  return contacts;
}

String _idFrom(Map<String, dynamic> record, List<String> keys) {
  for (final key in keys) {
    final value = record[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return '';
}

String _threadTitle(Map<String, dynamic> record) {
  final direct = record['title']?.toString().trim();
  if (direct != null && direct.isNotEmpty) return direct;
  final participants = apiMap(record['participants']);
  for (final key in const ['designer', 'customer']) {
    final participant = apiMap(participants[key]);
    final name = participant['fullName']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
  }
  return 'Order conversation';
}

Map<String, dynamic> _otherParticipantRecord(
  Map<String, dynamic> record,
  String? currentUserId,
) {
  if (currentUserId == null) return const {};
  final participants = apiMap(record['participants']);
  for (final key in const ['designer', 'customer']) {
    final participant = apiMap(participants[key]);
    final participantId = _idFrom(participant, const ['_id', 'id']);
    if (participant.isEmpty) continue;
    if (participantId != currentUserId) {
      return participant;
    }
  }
  return const {};
}

String _otherParticipantImage(
  Map<String, dynamic> record,
  String? currentUserId,
) {
  final direct =
      record['image']?.toString() ?? record['participantImage']?.toString();
  if (direct != null && direct.isNotEmpty) return direct;
  final participants = apiMap(record['participants']);
  for (final key in const ['designer', 'customer']) {
    final participant = apiMap(participants[key]);
    final participantId =
        participant['_id']?.toString() ?? participant['id']?.toString();
    if (currentUserId != null && participantId == currentUserId) continue;
    final image = participant['image']?.toString().trim();
    if (image != null && image.isNotEmpty) return image;
  }
  return '';
}

String _conversationPreview(Map<String, dynamic> conversation) {
  final lastMessage = conversation['lastMessage'];
  if (lastMessage is Map) {
    final content = lastMessage['content']?.toString().trim();
    if (content != null && content.isNotEmpty) return content;
  }
  final preview = conversation['preview']?.toString().trim();
  if (preview != null && preview.isNotEmpty) return preview;
  return 'Tap to open order chat';
}

String? _messageSenderId(Map<String, dynamic> message) {
  final senderId = message['senderId'];
  if (senderId is Map) {
    return senderId['_id']?.toString() ?? senderId['id']?.toString();
  }
  return senderId?.toString();
}

List<Map<String, dynamic>> _attachments(Map<String, dynamic> message) {
  final raw = message['attachments'];
  if (raw is! List) return const [];
  return raw.map((item) {
    if (item is Map) return Map<String, dynamic>.from(item);
    return <String, dynamic>{'url': item.toString(), 'type': 'image'};
  }).toList();
}

String _formatTime(dynamic value) {
  final parsed = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  return parsed == null ? '' : DateFormat('HH:mm').format(parsed);
}

String? _blockedMessageReason(String content) {
  if (content.trim().isEmpty) return null;
  final normalized = content.trim().toLowerCase();

  final linkPattern = RegExp(
    r'(https?://|www\.|(?:[a-z0-9-]+\.)+(?:com|net|org|io|co|ng|app|me)\b)',
    caseSensitive: false,
  );
  if (linkPattern.hasMatch(normalized)) {
    return 'Links are not allowed. Keep this chat strictly about the attire.';
  }

  final emailPattern = RegExp(
    r'\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}\b',
    caseSensitive: false,
  );
  if (emailPattern.hasMatch(normalized)) {
    return 'Email addresses are not allowed in order chats.';
  }

  final phonePattern = RegExp(r'(?<!\d)(?:\+?\d[\s().-]*){9,15}(?!\d)');
  if (phonePattern.hasMatch(normalized)) {
    return 'Phone numbers are not allowed in order chats.';
  }

  final socialPattern = RegExp(
    r'\b(whatsapp|telegram|instagram|facebook|snapchat|tiktok|twitter|x handle|dm me|contact me|call me|text me)\b',
    caseSensitive: false,
  );
  if (socialPattern.hasMatch(normalized) ||
      RegExp(r'(?<!\w)@[a-z0-9._]{3,}').hasMatch(normalized)) {
    return 'Social handles and off-platform contact details are not allowed.';
  }

  final locationPattern = RegExp(
    r'\b(my address|your address|home address|street|avenue|estate|junction|landmark|location|live at|come to|meet me|country|city|state|lga|postal code|zip code|nigeria|ghana|lagos|abuja|port harcourt|united kingdom|united states|usa|uk)\b',
    caseSensitive: false,
  );
  if (locationPattern.hasMatch(normalized)) {
    return 'Addresses and location details are not allowed in order chats.';
  }

  return null;
}
