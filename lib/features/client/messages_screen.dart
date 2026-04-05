import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/controller/client/chat_controller.dart';
import 'package:photopia/data/models/chat_response_model.dart';
import 'package:photopia/features/client/widgets/message_list_item.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:photopia/features/client/chat_screen.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthController.isLoggedIn) {
        context.read<ChatController>().getChats();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: Consumer<ChatController>(
                builder: (context, chatController, child) {
                  if (chatController.isLoading) {
                    return _buildShimmerList();
                  }

                  if (chatController.chats.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () => chatController.getChats(),
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    child: _buildConversationList(chatController.chats),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 0.6.sh,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64.sp,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Messages Yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                "When you start a conversation, it will appear here. Start exploring to connect!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 10.h),
      child: Row(
        children: [
          Image.asset(
            'assets/images/message_icon.png',
            width: 28.sp.clamp(24, 32),
            height: 28.sp.clamp(24, 32),
            color: Colors.black,
          ),
          SizedBox(width: 12.w),
          Text(
            'Messages',
            style: TextStyle(
              fontSize: 20.sp.clamp(20, 22),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Container(
        height: 40.h.clamp(40, 45),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12).r,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: TextField(
          controller: _searchController,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            isCollapsed: true,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp.clamp(14, 16),
            ),
            prefixIcon: Icon(Icons.search,
                color: Colors.grey, size: 20.sp.clamp(18, 24)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList(List<ChatRoom> chats) {
    final currentUserId = AuthController.userId;
    
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chatRoom = chats[index];
        final conversation = chatRoom.toConversation(currentUserId);

        return MessageListItem(
          conversation: conversation,
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(conversation: conversation),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (context, index) => const MessageListItemSkeleton(),
    );
  }
}
