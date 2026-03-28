import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/widgets/custom_snacbar.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/controller/provider/service_controller.dart';
import 'package:photopia/data/models/provider_service_model.dart';
import 'package:provider/provider.dart';

class ProviderCreateListingScreen extends StatefulWidget {
  final Data? existingListing;
  const ProviderCreateListingScreen({super.key, this.existingListing});

  @override
  State<ProviderCreateListingScreen> createState() =>
      _ProviderCreateListingScreenState();
}

class _ProviderCreateListingScreenState
    extends State<ProviderCreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();

  // Pricing controllers
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _weekdayRateController = TextEditingController();
  final TextEditingController _weekendRateController = TextEditingController();
  final TextEditingController _dailyRateController = TextEditingController();
  final TextEditingController _weekendDailyRateController =
      TextEditingController();

  // Package controllers
  final TextEditingController _basicPackagePriceController =
      TextEditingController();
  final TextEditingController _standardPackagePriceController =
      TextEditingController();
  final TextEditingController _premiumPackagePriceController =
      TextEditingController();

  Category? _selectedCategory;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  String _selectedServiceType = 'Photography';
  String _selectedPricingModel = 'By Hour';
  double _serviceRadius = 25.0;
  bool _acceptOutsideRadius = false;
  final List<String> _equipment = [];
  final List<File> _selectedImages = [];
  final List<String> _existingNetworkImages = []; // Track original images URL
  List<String> _dynamicServiceTypes = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _populateExistingData();
  }

  void _populateExistingData() {
    if (widget.existingListing != null) {
      final listing = widget.existingListing!;
      _titleController.text = listing.title ?? '';
      _descriptionController.text = listing.description ?? '';
      _locationController.text = listing.location?.city ?? '';
      _addressController.text = listing.location?.address ?? '';
      _countryController.text = listing.location?.country ?? '';
      _subCategoryController.text = listing.subCategory ?? '';
      _durationController.text = listing.duration ?? '';

      if (listing.tags != null && listing.tags!.isNotEmpty) {
        _selectedServiceType = listing.tags!.first;
      }

      if (listing.equipment != null) {
        _equipment.addAll(listing.equipment!);
      }

      if (listing.pricingType != null) {
        if (listing.pricingType == "HOURLY") {
          _selectedPricingModel = 'By Hour';
          _hourlyRateController.text = listing.price?.toString() ?? '';
        } else if (listing.pricingType == "DAILY") {
          _selectedPricingModel = 'By Day';
          _dailyRateController.text = listing.price?.toString() ?? '';
        } else if (listing.pricingType == "PACKAGE") {
          _selectedPricingModel = 'By Service';
          if (listing.pricingModel?.packages != null) {
            for (var pkg in listing.pricingModel!.packages!) {
              if (pkg.name == 'Basic') {
                _basicPackagePriceController.text = pkg.price?.toString() ?? '';
              }
              if (pkg.name == 'Standard') {
                _standardPackagePriceController.text =
                    pkg.price?.toString() ?? '';
              }
              if (pkg.name == 'Premium') {
                _premiumPackagePriceController.text =
                    pkg.price?.toString() ?? '';
              }
            }
          } else {
            _basicPackagePriceController.text = listing.price?.toString() ?? '';
          }
        }
      }

      if (listing.location?.serviceRadiusKm != null) {
        _serviceRadius = listing.location!.serviceRadiusKm!.toDouble();
      }

      _acceptOutsideRadius = listing.allowOutsideRadius ?? false;

      // Populate existing images
      if (listing.coverMedia != null && listing.coverMedia!.isNotEmpty) {
        _existingNetworkImages.add(listing.coverMedia!);
      }
      if (listing.gallery != null) {
        // filter out nulls or duplicates
        for (var img in listing.gallery!) {
          if (img != null &&
              img.isNotEmpty &&
              !_existingNetworkImages.contains(img)) {
            _existingNetworkImages.add(img);
          }
        }
      }
    }
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    final controller = context.read<ServiceController>();
    final categories = await controller.getCategories();
    if (mounted) {
      setState(() {
        if (categories.isNotEmpty) {
          _categories = categories;

          // Extract unique service types from API categories
          final types = _categories
              .map((c) => c.serviceType)
              .where((st) => st != null && st.isNotEmpty)
              .cast<String>()
              .toSet()
              .toList();

          if (types.isNotEmpty) {
            _dynamicServiceTypes = types;
            // Set default if not editing
            if (widget.existingListing == null) {
              _selectedServiceType = _dynamicServiceTypes.first;
            }
          }
        } else {
          // Local fallback
          _categories = [
            Category(sId: "6967f8313c7a3a49e02c1fde", name: "Photography", serviceType: "photography"),
            Category(sId: "65e8a5b4f1a2b3c4d5e6f702", name: "Videography", serviceType: "videography"),
          ];
          _dynamicServiceTypes = ["photography", "videography"];
        }
        
        if (widget.existingListing != null &&
            widget.existingListing!.category != null) {
          final existingCatId =
              widget.existingListing!.category!.sId ??
              widget.existingListing!.category!.id;
          _selectedCategory = _categories.firstWhere(
            (c) => c.sId == existingCatId,
            orElse: () => _categories.first,
          );
          // Set service type from existing if found
          if (widget.existingListing!.serviceType != null) {
            _selectedServiceType = widget.existingListing!.serviceType!;
          }
        } else if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _subCategoryController.dispose();
    _durationController.dispose();
    _equipmentController.dispose();
    _hourlyRateController.dispose();
    _weekdayRateController.dispose();
    _weekendRateController.dispose();
    _dailyRateController.dispose();
    _weekendDailyRateController.dispose();
    _basicPackagePriceController.dispose();
    _standardPackagePriceController.dispose();
    _premiumPackagePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (images.isNotEmpty) {
      if (_selectedImages.length +
              _existingNetworkImages.length +
              images.length >
          10) {
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'You can only upload up to 10 images',
            isError: true,
          );
        }
        return;
      }

      // Fix EXIF orientation by compressing and stripping metadata
      List<File> processedImages = [];
      for (var xFile in images) {
        final tempDir = Directory.systemTemp;
        final targetPath =
            '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}.jpg';

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          xFile.path,
          targetPath,
          quality: 90,
          format: CompressFormat.jpeg,
        );

        if (compressedFile != null) {
          processedImages.add(File(compressedFile.path));
        } else {
          processedImages.add(File(xFile.path));
        }
      }

      setState(() {
        _selectedImages.addAll(processedImages);
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingNetworkImages.removeAt(index);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  bool _isFormValid() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _countryController.text.isEmpty ||
        (_selectedImages.isEmpty && _existingNetworkImages.isEmpty) ||
        _selectedCategory == null) {
      return false;
    }

    // Check pricing based on model
    if (_selectedPricingModel == 'By Hour') {
      return _hourlyRateController.text.isNotEmpty;
    } else if (_selectedPricingModel == 'By Day') {
      return _dailyRateController.text.isNotEmpty;
    } else if (_selectedPricingModel == 'By Service') {
      return _basicPackagePriceController.text.isNotEmpty;
    }

    return true;
  }

  Future<void> _publishListing() async {
    // Client-side validation for required fields
    if (!_isFormValid()) {
      CustomSnackBar.show(
        context: context,
        message: 'Please fill in all required fields and upload at least one photo',
        isError: true,
      );
      return;
    }

    // Specific length validation based on backend requirements
    if (_titleController.text.trim().length < 3) {
      CustomSnackBar.show(
        context: context,
        message: 'Title must be at least 3 characters',
        isError: true,
      );
      return;
    }

    if (_descriptionController.text.trim().length < 10) {
      CustomSnackBar.show(
        context: context,
        message: 'Description must be at least 10 characters',
        isError: true,
      );
      return;
    }

    final serviceData = Data(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      subCategory: _subCategoryController.text.trim(),
      tags: [_selectedServiceType],
      equipment: _equipment,
      price:
          int.tryParse(
            _selectedPricingModel == 'By Hour'
                ? _hourlyRateController.text
                : _selectedPricingModel == 'By Day'
                ? _dailyRateController.text
                : _basicPackagePriceController.text,
          ) ??
          0,
      currency: "EUR",
      pricingType: _selectedPricingModel == 'By Hour'
          ? "HOURLY"
          : _selectedPricingModel == 'By Day'
          ? "DAILY"
          : "PACKAGE",
      serviceType: _selectedServiceType.toLowerCase(), // e.g. 'photography'
      location: Location(
        type: "ONSITE",
        country: _countryController.text.trim(),
        city: _locationController.text.trim(),
        address: _addressController.text.trim(),
        serviceRadiusKm: _serviceRadius.toInt(),
      ),
      allowOutsideRadius: _acceptOutsideRadius,
      duration: _durationController.text.trim(),
      pricingRules: [], // Optional
      // Ensure all current images are in the list we pass to the controller
      coverMedia: _existingNetworkImages.isNotEmpty 
          ? _existingNetworkImages.first 
          : null,
      gallery: _existingNetworkImages.toList(), // Send FULL list as gallery to be safe
      status: "ACTIVE", 
      isActive: true,
      isVerified: widget.existingListing?.isVerified ?? false,
    );

    // Setup packages if SERVICE pricing
    if (_selectedPricingModel == 'By Service') {
      serviceData.pricingModel = PricingModel(
        type: "PACKAGE",
        packages: [
          if (_basicPackagePriceController.text.isNotEmpty)
            Packages(
              name: "Basic",
              price: int.tryParse(_basicPackagePriceController.text) ?? 0,
            ),
          if (_standardPackagePriceController.text.isNotEmpty)
            Packages(
              name: "Standard",
              price: int.tryParse(_standardPackagePriceController.text) ?? 0,
            ),
          if (_premiumPackagePriceController.text.isNotEmpty)
            Packages(
              name: "Premium",
              price: int.tryParse(_premiumPackagePriceController.text) ?? 0,
            ),
        ],
      );
    }

    final isEdit = widget.existingListing != null;
    final controller = context.read<ServiceController>();

    bool success;
    if (isEdit) {
      final listingId =
          widget.existingListing!.sId ?? widget.existingListing!.id ?? '';
      success = await controller.updateService(
        listingId,
        serviceData,
        _selectedImages.isNotEmpty ? _selectedImages : null,
      );
    } else {
      success = await controller.createService(serviceData, _selectedImages);
    }

    if (mounted) {
      if (success) {
        CustomSnackBar.show(
          context: context,
          message: isEdit
              ? 'Listing updated successfully!'
              : 'Listing published successfully!',
          isError: false,
        );
        Navigator.pop(context, true);
      } else {
        CustomSnackBar.show(
          context: context,
          message:
              controller.errorMessage ??
              (isEdit ? 'Update failed' : 'Publishing failed'),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingListing != null ? 'Edit Listing' : 'Create Listing',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTypography.h1,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<ServiceController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Listing Title'),
                  _buildTextField(
                    hintText: 'Event Photography',
                    controller: _titleController,
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('Category'),
                  _buildDropdown(),
                  SizedBox(height: 20.h),

                  _buildLabel('Sub-Category (Optional)'),
                  _buildTextField(
                    hintText: 'Wedding, Portrait, etc.',
                    controller: _subCategoryController,
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('Service Type'),
                  if (_dynamicServiceTypes.isEmpty)
                    const Text('No service types found')
                  else
                    ..._dynamicServiceTypes.map((type) => _buildRadioOption(type)).toList(),
                  SizedBox(height: 20.h),

                  _buildLabel('Pricing Model'),
                  _buildPricingToggle(),
                  SizedBox(height: 20.h),

                  if (_selectedPricingModel == 'By Service') ...[
                    _buildLabel('Basic Package (€)'),
                    _buildTextField(
                      hintText: '500',
                      controller: _basicPackagePriceController,
                    ),
                    SizedBox(height: 20.h),

                    _buildLabel('Standard Package (€)'),
                    _buildTextField(
                      hintText: '1200',
                      controller: _standardPackagePriceController,
                    ),
                    SizedBox(height: 20.h),

                    _buildLabel('Premium Package (€)'),
                    _buildTextField(
                      hintText: '2500',
                      controller: _premiumPackagePriceController,
                    ),
                    SizedBox(height: 20.h),
                  ] else ...[
                    _buildLabel(
                      '${_selectedPricingModel == 'By Day' ? 'Daily' : 'Weekday Hourly'} Rate (€)',
                    ),
                    _buildTextField(
                      hintText: _selectedPricingModel == 'By Day'
                          ? '800'
                          : '150',
                      controller: _selectedPricingModel == 'By Day'
                          ? _dailyRateController
                          : _hourlyRateController,
                    ),
                    SizedBox(height: 20.h),

                    _buildLabel(
                      '${_selectedPricingModel == 'By Day' ? 'Weekend Daily' : 'Weekend Hourly'} Rate (€)',
                    ),
                    _buildTextField(
                      hintText: _selectedPricingModel == 'By Day'
                          ? '1000'
                          : '180',
                      controller: _selectedPricingModel == 'By Day'
                          ? _weekendDailyRateController
                          : _weekendRateController,
                    ),
                    SizedBox(height: 20.h),
                  ],

                  _buildLabel('Description'),
                  _buildTextField(
                    hintText: 'Describe your service...',
                    maxLines: 4,
                    controller: _descriptionController,
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('Duration'),
                  _buildTextField(
                    hintText: '2 hours',
                    controller: _durationController,
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('Country'),
                  _buildTextField(
                    hintText: 'Enter Country (e.g. Germany)',
                    controller: _countryController,
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('City'),
                  _buildTextField(
                    hintText: 'Enter City',
                    controller: _locationController,
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('Street Address'),
                  _buildTextField(
                    hintText: 'Enter Street Address',
                    controller: _addressController,
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel(
                    'Service Radius: ${_serviceRadius.toInt()} miles',
                  ),
                  _buildRadiusSlider(),
                  SizedBox(height: 10.h),

                  _buildAcceptOutsideRadiusToggle(),
                  SizedBox(height: 20.h),

                  _buildLabel('Equipment'),
                  _buildEquipmentInput(),
                  if (_equipment.isNotEmpty) _buildEquipmentList(),
                  SizedBox(height: 20.h),

                  _buildLabel(
                    widget.existingListing != null
                        ? 'Photos (Max 10, existing kept if not removed)'
                        : 'Photos (Max 10)',
                  ),
                  _buildPhotoUploadArea(),
                  if (_existingNetworkImages.isNotEmpty ||
                      _selectedImages.isNotEmpty)
                    _buildSelectedImagesGrid(),
                  SizedBox(height: 30.h),

                  _buildFooterButtons(controller.inProgress),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppTypography.bodySmall,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: (maxLines == 1 && hintText.contains(RegExp(r'[0-9]')))
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: AppTypography.bodyLarge,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    if (_isLoadingCategories) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12.w),
            Text(
              'Loading categories...',
              style: TextStyle(fontSize: AppTypography.bodyLarge),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Text(
          'No categories found',
          style: TextStyle(
            fontSize: AppTypography.bodyLarge,
            color: Colors.red,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 24.sp,
            color: Colors.grey,
          ),
          items: _categories.map((Category cat) {
            return DropdownMenuItem<Category>(
              value: cat,
              child: Text(
                cat.name ?? "",
                style: TextStyle(fontSize: AppTypography.bodyLarge),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCategory = newValue;
              if (newValue?.serviceType != null && newValue!.serviceType!.isNotEmpty) {
                _selectedServiceType = newValue.serviceType!;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    bool isSelected = _selectedServiceType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedServiceType = value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[400]!,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Text(
              value,
              style: TextStyle(
                fontSize: AppTypography.bodyLarge,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingToggle() {
    return Row(
      children: ['By Hour', 'By Day', 'By Service'].map((model) {
        bool isSelected = _selectedPricingModel == model;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPricingModel = model),
            child: Container(
              margin: EdgeInsets.only(right: model == 'By Service' ? 0 : 8.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                model,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRadiusSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.black,
        inactiveTrackColor: const Color(0xFFF0F0F0),
        thumbColor: Colors.black,
        overlayColor: Colors.black.withOpacity(0.1),
        trackHeight: 4.h,
      ),
      child: Slider(
        min: 0,
        max: 100,
        value: _serviceRadius,
        onChanged: (val) => setState(() => _serviceRadius = val),
      ),
    );
  }

  Widget _buildAcceptOutsideRadiusToggle() {
    return GestureDetector(
      onTap: () => setState(() => _acceptOutsideRadius = !_acceptOutsideRadius),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _acceptOutsideRadius ? Colors.black : Colors.grey[400]!,
              ),
            ),
            child: _acceptOutsideRadius
                ? Center(
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accept orders from outside location radius',
                  style: TextStyle(
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Additional travel fees may apply for bookings outside your service radius',
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              controller: _equipmentController,
              decoration: InputDecoration(
                hintText: 'Canon EOS R5',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: AppTypography.bodyLarge,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () {
            if (_equipmentController.text.isNotEmpty) {
              setState(() {
                _equipment.add(_equipmentController.text.trim());
                _equipmentController.clear();
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppTypography.bodyLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentList() {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: _equipment.map((item) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: () => setState(() => _equipment.remove(item)),
                  child: Icon(Icons.close, size: 14.sp, color: Colors.black54),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhotoUploadArea() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 40.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12.h),
            Text(
              'Click to upload photos',
              style: TextStyle(
                fontSize: AppTypography.bodyLarge,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Select up to 5 high-quality images',
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImagesGrid() {
    // Combine existing and new for display
    final totalItems = _existingNetworkImages.length + _selectedImages.length;

    return Padding(
      padding: EdgeInsets.only(top: 15.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1,
        ),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          final isExisting = index < _existingNetworkImages.length;
          final String? existingUrl = isExisting
              ? (_existingNetworkImages[index].startsWith('http')
                    ? _existingNetworkImages[index]
                    : "${Urls.baseUrl}${_existingNetworkImages[index]}")
              : null;
          final File? newFile = !isExisting
              ? _selectedImages[index - _existingNetworkImages.length]
              : null;

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: isExisting
                    ? Image.network(
                        existingUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Image.file(
                        newFile!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    if (isExisting) {
                      _removeExistingImage(index);
                    } else {
                      _removeImage(index - _existingNetworkImages.length);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 16.sp),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFooterButtons(bool inProgress) {
    bool isReady = _isFormValid();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: inProgress ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, 50.h),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: AppTypography.bodyLarge,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: ElevatedButton(
                onPressed: (isReady && !inProgress) ? _publishListing : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReady
                      ? Colors.black
                      : const Color(0xFFD1D5DB),
                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                  minimumSize: Size(0, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                child: inProgress
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.existingListing != null ? 'Update' : 'Publish',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.bodyLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (!isReady && !inProgress) ...[
          SizedBox(height: 10.h),
          Center(
            child: Text(
              'Please complete all required fields to publish',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: AppTypography.bodySmall,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
