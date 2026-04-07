import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/provider_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/favorites_controller.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/utils/guest_dialog_helper.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:photopia/features/client/chat_screen.dart';
import 'package:photopia/data/models/conversation_model.dart';
import 'package:photopia/data/models/chat_message_model.dart';
import 'package:photopia/core/widgets/subscription_badge.dart';

class ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16).r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              provider['profile'] != null || provider['avatar'] != null
                  ? CustomNetworkImage(
                      imageUrl: provider['profile'] ?? provider['avatar'] ?? '',
                      width: 60.r,
                      height: 60.r,
                      borderRadius: BorderRadius.circular(30).r,
                    )
                  : CircleAvatar(
                      radius: 30.r,
                      backgroundImage: const AssetImage(
                        'assets/images/img6.png',
                      ),
                    ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider['name'] ?? 'Emma Wilson',
                          style: TextStyle(
                            fontSize: 14.sp.clamp(14, 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SubscriptionBadge(
                          isSubscribed: provider['isSubscribed'] == true || provider['isPremium'] == true,
                          fontSize: 8.sp,
                          iconSize: 10.sp,
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        ),
                      ],
                    ),
                    Text(
                      provider['category'] ?? 'Wedding & Event Photography',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          provider['location'] ?? 'Barcelona, Spain',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 12.sp),
                            SizedBox(width: 4.w),
                            Text(
                              '${provider['rating'] ?? 4.9} (${provider['reviews'] ?? 127})',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Response: ${provider['responseTime'] ?? '95%'}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Consumer<FavoritesController>(
                          builder: (context, controller, child) {
                            String? providerId =
                                provider['_id'] ?? provider['id'];
                            bool isFavorite = controller.isProviderFavorite(
                              providerId,
                            );
                            return GestureDetector(
                              onTap: () {
                                if (!AuthController.isLoggedIn) {
                                  GuestDialogHelper.showGuestDialog(context);
                                  return;
                                }
                                controller.toggleFavorite(
                                  providerId: providerId,
                                  optimisticData: provider,
                                );
                              },
                              child: Icon(
                                isFavorite
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: Colors.black,
                                size: 20.sp,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (!AuthController.isLoggedIn) {
                      GuestDialogHelper.showGuestDialog(context);
                      return;
                    }

                    final String name = provider['name'] ?? 'Provider';
                    final String profile = provider['profile'] ?? provider['avatar'] ?? '';
                    final String providerId = (provider['_id'] ?? provider['id'] ?? '').toString();

                    final conversation = Conversation(
                      id: '',
                      name: name,
                      lastMessage: '',
                      avatarUrl: profile,
                      lastMessageTime: DateTime.now(),
                      unreadCount: 0,
                      isOnline: false,
                      status: MessageStatus.read,
                      isTemporary: true,
                      receiverId: providerId,
                    );

                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(conversation: conversation),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: const BorderSide(color: Color(0xFFE9ECEF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8).r,
                    ),
                    backgroundColor: const Color(0xFF1A1A1A),
                  ),
                  child: Text(
                    'Message',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProviderProfileScreen(provider: provider),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8).r,
                    ),
                    backgroundColor: const Color(0xFFF1F3F5),
                  ),
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
