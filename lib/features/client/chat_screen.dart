import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/controller/client/chat_controller.dart';
import 'package:photopia/data/models/conversation_model.dart';
import 'package:photopia/data/models/chat_message_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _currentChatId;

  @override
  void initState() {
    super.initState();
    _currentChatId = widget.conversation.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentChatId.isNotEmpty) {
        // Passing receiverId to help with isMe logic
        context.read<ChatController>().getMessages(
          _currentChatId, 
          receiverId: widget.conversation.receiverId
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    final controller = context.read<ChatController>();
    _messageController.clear();

    bool success = false;
    if (_currentChatId.isEmpty && widget.conversation.isTemporary) {
      // First message for a new chat
      final String? newChatId = await controller.createChatAndSendMessage(
        widget.conversation.receiverId ?? '',
        text,
      );
      if (newChatId != null) {
        _currentChatId = newChatId;
        success = true;
      }
    } else {
      // Existing chat
      success = await controller.sendMessage(
        _currentChatId, 
        text, 
        receiverId: widget.conversation.receiverId
      );
    }

    if (success) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Consumer<ChatController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          return Column(
            children: [
              Expanded(
                child: controller.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
              ),
              _buildInputArea(controller.isLoading),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No messages yet',
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20.r.clamp(16, 24),
                backgroundImage: widget.conversation.avatarUrl.startsWith('assets/')
                    ? AssetImage(widget.conversation.avatarUrl) as ImageProvider
                    : NetworkImage(widget.conversation.avatarUrl),
              ),
              if (widget.conversation.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10.r.clamp(8, 12),
                    height: 10.r.clamp(8, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.conversation.name,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.sp.clamp(14, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.conversation.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11.sp.clamp(10, 13),
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(color: Colors.grey.withOpacity(0.1), height: 1.h),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // Standard logic for your reference: Me = Right, Other = Left
    final bool isLeft = !message.isMe; 

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 0.75.sw),
            padding: EdgeInsets.all(16.r.clamp(12, 20)),
            decoration: BoxDecoration(
              color: message.isMe ? const Color(0xFF1A1A1A) : const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16).r,
                topRight: Radius.circular(16).r,
                bottomLeft: Radius.circular(isLeft ? 0 : 16).r,
                bottomRight: Radius.circular(isLeft ? 16 : 0).r,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.type == ChatMessageType.file)
                  Container(
                    padding: EdgeInsets.all(12.r.clamp(10, 16)),
                    margin: EdgeInsets.only(bottom: 8.h),
                    decoration: BoxDecoration(
                      color: message.isMe ? Colors.white.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12).r,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
                          color: message.isMe ? Colors.white : Colors.black,
                          size: 20.sp.clamp(18, 24),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.fileName ?? 'File',
                                style: TextStyle(
                                  color: message.isMe ? Colors.white : Colors.black,
                                  fontSize: 13.sp.clamp(12, 16),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                message.fileSize ?? '',
                                style: TextStyle(
                                  color: message.isMe
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey,
                                  fontSize: 11.sp.clamp(10, 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  // Show text or a clear warning if it's missing (helps identifying backend issues)
                  message.text.trim().isEmpty ? "[No message content]" : message.text.trim(),
                  style: TextStyle(
                    color: message.isMe ? Colors.white : Colors.black,
                    fontSize: 14.sp.clamp(13, 18),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            DateFormat('hh:mm a').format(message.time),
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10.sp.clamp(10, 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isSending) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey, size: 24.sp.clamp(20, 28)),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              height: 48.h.clamp(40, 56),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24).r,
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !isSending,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp.clamp(13, 16)),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: isSending ? null : _handleSendMessage,
            child: Container(
              width: 48.r.clamp(40, 56),
              height: 48.r.clamp(40, 56),
              decoration: BoxDecoration(
                color: isSending ? Colors.grey : const Color(0xFF1A1A1A),
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(Icons.send_rounded, color: Colors.white, size: 22.sp.clamp(18, 26)),
            ),
          ),
        ],
      ),
    );
  }
}
