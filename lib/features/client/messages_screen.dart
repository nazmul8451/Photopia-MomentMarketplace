import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/data/models/conversation_model.dart';
import 'package:photopia/features/client/widgets/message_list_item.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:photopia/features/client/chat_screen.dart';
import 'dart:async';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final List<Conversation> _mockConversations = [
    Conversation(
      id: '1',
      name: 'Emma Wilson',
      lastMessage: 'Thank you! I can do the shoot on Saturday.',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      unreadCount: 3,
      isOnline: true,
      status: MessageStatus.read,
    ),
    Conversation(
      id: '2',
      name: 'Tech Media Studio',
      lastMessage: "I've sent you the quote for the corporate video.",
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: true,
      status: MessageStatus.read,
    ),
    Conversation(
      id: '3',
      name: 'Marco Silva',
      lastMessage: 'Perfect! Looking forward to working with you.',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
      isOnline: false,
      status: MessageStatus.read,
    ),
    Conversation(
      id: '4',
      name: 'Lucia Rossi',
      lastMessage: 'The portfolio is ready for review.',
      avatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: true,
      status: MessageStatus.delivered,
    ),
  ];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
              child: _isLoading
                  ? _buildShimmerList()
                  : _buildConversationList(),
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
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp.clamp(14, 16),
            ),
            prefixIcon:
                Icon(Icons.search, color: Colors.grey, size: 20.sp.clamp(18, 24)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _mockConversations.length,
      itemBuilder: (context, index) {
        return MessageListItem(
          conversation: _mockConversations[index],
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(conversation: _mockConversations[index]),
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
