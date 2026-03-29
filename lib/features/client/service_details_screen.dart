import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/book_now_SelectPackage_screen.dart';
import 'package:photopia/features/client/provider_profile_screen.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/utils/guest_dialog_helper.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/favorites_controller.dart';
import 'package:photopia/controller/client/service_list_controller.dart';
import 'package:photopia/core/widgets/video_player_screen.dart';
import 'package:photopia/data/models/conversation_model.dart';
import 'package:photopia/features/client/chat_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.service['id'] ?? widget.service['_id'];
      if (id != null) {
        context.read<ServiceListController>().getServiceById(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Scrollable Content
          Consumer<ServiceListController>(
            builder: (context, controller, child) {
              final serviceDetail = controller.serviceDetail;
              final isLoading = controller.isLoading;

              final String title = serviceDetail?.title ?? widget.service['title'] ?? 'Service Details';
              final String description = serviceDetail?.description ?? 'No description available.';
              final List<String> equipment = serviceDetail?.equipment ?? [];
              final List<dynamic> gallery = serviceDetail?.gallery ?? [];
              final String coverMedia = serviceDetail?.coverMedia ?? widget.service['coverMedia'] ?? widget.service['imageUrl'] ?? '';
              final String providerName = serviceDetail?.providerId?.name ?? widget.service['subtitle'] ?? 'Professional';
              final String providerAvatar = serviceDetail?.providerId?.profile ?? 'assets/images/img6.png';
              final double rating = serviceDetail?.rating ?? (widget.service['rating'] ?? 0.0).toDouble();
              final int reviews = serviceDetail?.reviews ?? widget.service['reviews'] ?? 0;
              final List<String> tags = serviceDetail?.category != null ? [serviceDetail!.category!.name!] : (widget.service['tags'] as List<String>? ?? []);

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopMedia(coverMedia, gallery, isLoading),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.h),
                              Text(title, style: TextStyle(fontSize: 20.sp.clamp(20, 22), fontWeight: FontWeight.bold, color: Colors.black)),
                              SizedBox(height: 20.h),
                              Text('Provider', style: TextStyle(fontSize: 14.sp.clamp(14, 16), fontWeight: FontWeight.bold, color: Colors.black)),
                              SizedBox(height: 12.h),
                              _buildProviderCard(providerName, providerAvatar, rating, reviews),
                              SizedBox(height: 18.h),
                              _buildActionButtons(
                                providerId: serviceDetail?.providerId?.sId ?? (widget.service['providerId'] is Map ? widget.service['providerId']['_id'] : widget.service['providerId'])?.toString() ?? '',
                                name: providerName,
                                profile: providerAvatar,
                              ),
                              SizedBox(height: 20.h),
                              _buildStatsRow(
                                responseTime: serviceDetail?.responseTime ?? widget.service['responseTime']?.toString(),
                                completedProjects: serviceDetail?.completedProjects ?? widget.service['completedProjects'],
                              ),
                              SizedBox(height: 25.h),
                              _buildSectionTitle('About'),
                              SizedBox(height: 8.h),
                              Text(description, style: TextStyle(fontSize: 13.sp.clamp(13, 14), color: Colors.black87, height: 1.5)),
                              if (equipment.isNotEmpty) ...[
                                SizedBox(height: 25.h),
                                Row(children: [Icon(Icons.camera_alt_outlined, size: 20.sp, color: Colors.black87), SizedBox(width: 8.w), _buildSectionTitle('Equipment')]),
                                SizedBox(height: 12.h),
                                _buildEquipmentTags(equipment),
                              ],
                              if (gallery.isNotEmpty) ...[
                                SizedBox(height: 25.h),
                                _buildSectionTitle('Portfolio'),
                                SizedBox(height: 12.h),
                                _buildPortfolioGrid(gallery),
                              ],
                              SizedBox(height: 25.h),
                              _buildBottomTags(tags),
                              SizedBox(height: 120.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomBar(
                      providerId: serviceDetail?.providerId?.sId ?? (widget.service['providerId'] is Map ? widget.service['providerId']['_id'] : widget.service['providerId'])?.toString() ?? '',
                      name: providerName,
                      avatar: providerAvatar,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isVideo(String url) {
    final String lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi') || lower.endsWith('.mkv') || lower.endsWith('.webm');
  }

  Widget _buildTopMedia(String coverMedia, List<dynamic> gallery, bool isLoading) {
    final List<String> images = [];
    if (coverMedia.isNotEmpty) images.add(coverMedia);
    for (var item in gallery) {
      final String path = item.toString();
      if (path.isNotEmpty && !images.contains(path)) images.add(path);
    }
    final int safeIndex = _currentPage < images.length ? _currentPage : 0;

    return Stack(
      children: [
        Container(
          height: 380.h,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: images.length,
            itemBuilder: (context, index) => CustomNetworkImage(imageUrl: images[index], fit: BoxFit.cover),
          ),
        ),
        if (images.isNotEmpty && _isVideo(images[safeIndex]))
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: images[safeIndex]))),
                child: Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle), child: Icon(Icons.play_arrow, color: Colors.white, size: 30.sp)),
              ),
            ),
          ),
        Positioned(
          bottom: 20.h,
          left: 0,
          right: 0,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(images.length, (index) => Container(margin: EdgeInsets.symmetric(horizontal: 4.w), width: 8.w, height: 8.w, decoration: BoxDecoration(shape: BoxShape.circle, color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5))))),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.h,
          left: 20.w,
          right: 20.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: EdgeInsets.all(8.w), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.arrow_back, size: 20.sp, color: Colors.black)),
              ),
              Row(
                children: [
                  Consumer<FavoritesController>(
                    builder: (context, controller, child) {
                      bool isFavorite = controller.isPostFavorite(widget.service['_id'] ?? widget.service['id']);
                      return GestureDetector(
                        onTap: () {
                          if (!AuthController.isLoggedIn) {
                            GuestDialogHelper.showGuestDialog(context);
                            return;
                          }
                          controller.toggleFavorite(serviceId: widget.service['_id'] ?? widget.service['id'], optimisticData: widget.service);
                        },
                        child: Container(padding: EdgeInsets.all(8.w), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border, size: 20.sp, color: Colors.black)),
                      );
                    },
                  ),
                  SizedBox(width: 12.w),
                  Container(padding: EdgeInsets.all(8.w), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.flag_outlined, size: 20.sp, color: Colors.red)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(String name, String avatar, double rating, int reviews) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderProfileScreen(
              provider: {
                'name': name,
                'avatar': avatar,
                'id': widget.service['providerId'] is Map ? widget.service['providerId']['_id']?.toString() : widget.service['providerId']?.toString(),
                '_id': widget.service['providerId'] is Map ? widget.service['providerId']['_id']?.toString() : widget.service['providerId']?.toString(),
              },
            ),
          ),
        );
      },
      child: Row(
        children: [
          CircleAvatar(radius: 25.r, backgroundImage: avatar.startsWith('http') ? NetworkImage(avatar) as ImageProvider<Object> : AssetImage(avatar)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(fontSize: 15.sp.clamp(15, 16), fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(width: 8.w),
                    Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20).r), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.stars, color: Colors.orange, size: 10.sp), SizedBox(width: 4.w), Text('Premium', style: TextStyle(color: Colors.white, fontSize: 10.sp.clamp(10, 11), fontWeight: FontWeight.bold))])),
                  ],
                ),
                Row(children: [Icon(Icons.star, color: Colors.orange, size: 14.sp), SizedBox(width: 4.w), Text('${rating} (${reviews} reviews)', style: TextStyle(fontSize: 12.sp.clamp(12, 13), color: Colors.grey))]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons({required String providerId, required String name, required String profile}) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!AuthController.isLoggedIn) {
                GuestDialogHelper.showGuestDialog(context);
                return;
              }
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
                  builder: (context) => ChatScreen(conversation: conversation),
                ),
              );
            },
            child: Container(height: 48.h, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12).r), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.message_outlined, color: Colors.white, size: 18.sp), SizedBox(width: 8.w), Text('Message', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold))])),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProviderProfileScreen(provider: {'name': name, 'avatar': profile, 'id': providerId, '_id': providerId})));
            },
            child: Container(height: 48.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12).r, border: Border.all(color: Colors.black)), child: Center(child: Text('View Profile', style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold)))),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow({String? responseTime, dynamic completedProjects}) {
    return Row(
      children: [
        Expanded(child: _buildStatBox('Response Time', responseTime != null && responseTime.isNotEmpty ? responseTime : 'N/A')),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatBox('Completed Projects', completedProjects != null ? completedProjects.toString() : 'N/A')),
      ],
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(padding: EdgeInsets.all(15.w), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12).r, border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11.sp.clamp(11, 12), color: Colors.grey)), SizedBox(height: 4.h), Text(value, style: TextStyle(fontSize: 14.sp.clamp(14, 16), fontWeight: FontWeight.bold, color: Colors.black))]));
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 16.sp.clamp(16, 18), fontWeight: FontWeight.bold, color: Colors.black));
  }

  Widget _buildEquipmentTags(List<String> tags) {
    return Wrap(spacing: 8.w, runSpacing: 8.h, children: tags.map((tag) => Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(8).r), child: Text(tag, style: TextStyle(fontSize: 11.sp.clamp(11, 12), color: Colors.black87, fontWeight: FontWeight.w500)))).toList());
  }

  Widget _buildPortfolioGrid(List<dynamic> images) {
    return GridView.builder(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12.h, crossAxisSpacing: 12.w, childAspectRatio: 1), itemCount: images.length, itemBuilder: (context, index) => CustomNetworkImage(imageUrl: images[index].toString(), fit: BoxFit.cover, borderRadius: BorderRadius.circular(12).r));
  }

  Widget _buildBottomTags(List<String> tags) {
    return Wrap(spacing: 8.w, runSpacing: 8.h, children: tags.map((tag) => Container(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(20).r), child: Text(tag.startsWith('#') ? tag : '#$tag', style: TextStyle(fontSize: 12.sp.clamp(12, 13), color: Colors.black87, fontWeight: FontWeight.w600)))).toList());
  }

  Widget _buildBottomBar({required String providerId, required String name, required String avatar}) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 20.h),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (!AuthController.isLoggedIn) {
                GuestDialogHelper.showGuestDialog(context);
                return;
              }
              final conversation = Conversation(
                id: '',
                name: name,
                lastMessage: '',
                avatarUrl: avatar,
                lastMessageTime: DateTime.now(),
                unreadCount: 0,
                isOnline: false,
                status: MessageStatus.read,
                isTemporary: true,
                receiverId: providerId,
              );

              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(conversation: conversation),
                ),
              );
            },
            child: Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12).r), child: Image.asset('assets/images/message_icon.png', width: 24.sp.clamp(24, 24), height: 24.sp.clamp(24, 24), fit: BoxFit.contain)),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!AuthController.isLoggedIn) {
                  GuestDialogHelper.showGuestDialog(context);
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (context) => SelectPackageScreen(service: widget.service)));
              },
              child: Container(height: 50.h, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12).r), child: Center(child: Text('Book Now', style: TextStyle(color: Colors.white, fontSize: 14.sp.clamp(14, 16), fontWeight: FontWeight.bold)))),
            ),
          ),
        ],
      ),
    );
  }
}
