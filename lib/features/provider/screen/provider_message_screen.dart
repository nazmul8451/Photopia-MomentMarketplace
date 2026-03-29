import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/message_list_item.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:photopia/features/client/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/chat_controller.dart';
import 'package:photopia/controller/auth_controller.dart';

class ProviderMessageScreen extends StatefulWidget {
  const ProviderMessageScreen({super.key});

  @override
  State<ProviderMessageScreen> createState() => _ProviderMessageScreenState();
}

class _ProviderMessageScreenState extends State<ProviderMessageScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatController>().getChats();
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
                builder: (context, controller, child) {
                  if (controller.isLoading && controller.chats.isEmpty) {
                    return _buildShimmerList();
                  }

                  if (controller.errorMessage.isNotEmpty && controller.chats.isEmpty) {
                    return Center(child: Text(controller.errorMessage));
                  }

                  if (controller.chats.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.getChats(),
                    color: Colors.black,
                    child: _buildConversationList(controller),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp.clamp(14, 16),
            ),
            prefixIcon: Icon(Icons.search,
                color: Colors.grey, size: 20.sp.clamp(18, 24)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList(ChatController controller) {
    final chats = controller.chats;
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
