import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photopia/core/widgets/custom_snacbar.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/client/widgets/auth_profile_image.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  static const String name = '/edit_profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;
  late TextEditingController _specialtyController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileController>().userProfile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _locationController = TextEditingController(text: profile?.location ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _descriptionController = TextEditingController(
      text: profile?.description ?? '',
    );
    _specialtyController = TextEditingController(
      text: profile?.specialty ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final targetPath =
          '${Directory.systemTemp.path}/temp_profile_img_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
            image.path,
            targetPath,
            quality: 80,
            minWidth: 1024,
            minHeight: 1024,
            autoCorrectionAngle: true,
          );

      setState(() {
        _selectedImage = File(compressedFile?.path ?? image.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<UserProfileController>();

    final success = await controller.updateProfile(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      email: _emailController.text.trim(),
      description: _descriptionController.text.trim(),
      specialty: _specialtyController.text.trim(),
      imagePath: _selectedImage?.path,
    );

    if (mounted) {
      if (success) {
        CustomSnackBar.show(
          context: context,
          message: 'Profile updated successfully!',
          isError: false,
        );
        Navigator.pop(context);
      } else {
        CustomSnackBar.show(
          context: context,
          message: controller.errorMessage ?? 'Update failed',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read<UserProfileController>().userProfile;
    final imageUrl = profile?.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp.clamp(20, 22),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<UserProfileController>(
        builder: (context, controller, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        _selectedImage != null
                            ? Container(
                                width: 120.w,
                                height: 120.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade200,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : AuthProfileImage(imageUrl: imageUrl, size: 120.w),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A1A1A),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                    icon: Icons.location_on_outlined,
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _specialtyController,
                    label: 'Specialty',
                    icon: Icons.star_border_outlined,
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: controller.isUpdateInProgress
                          ? null
                          : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15).r,
                        ),
                      ),
                      child: controller.isUpdateInProgress
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15).r,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15).r,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15).r,
          borderSide: const BorderSide(color: Colors.black),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: TextStyle(
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
