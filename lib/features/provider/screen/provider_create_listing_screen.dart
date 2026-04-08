import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _dailyHoursController = TextEditingController();
  
  // Dynamic Package controllers
  final List<PackageControllers> _packageControllers = [];

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
          _dailyHoursController.text = listing.pricingModel?.dailyHours?.toString() ?? '8';
        } else if (listing.pricingType == "PACKAGE") {
          _selectedPricingModel = 'By Service';
          if (listing.pricingModel?.packages != null && listing.pricingModel!.packages!.isNotEmpty) {
            _packageControllers.clear();
            for (var pkg in listing.pricingModel!.packages!) {
              _packageControllers.add(PackageControllers(
                name: pkg.name ?? '',
                price: pkg.price?.toString() ?? '',
                duration: pkg.duration?.toString() ?? '',
                description: pkg.description ?? '',
                includes: pkg.includes?.join(', ') ?? '',
              ));
            }
          } else {
            // Fallback for old listings
            _packageControllers.add(PackageControllers(
              name: 'Basic',
              price: listing.price?.toString() ?? '',
            ));
          }
        }
      }

      if (listing.gallery != null) {
        for (var img in listing.gallery!) {
          if (img is String) _existingNetworkImages.add(img);
        }
      }

      _serviceRadius = listing.location?.serviceRadiusKm?.toDouble() ?? 25.0;
    }
  }

  Future<void> _fetchCategories() async {
    final controller = Provider.of<ServiceController>(context, listen: false);
    final response = await controller.getCategories();
    if (mounted) {
      setState(() {
        _categories = response;
        _isLoadingCategories = false;
        if (widget.existingListing != null &&
            widget.existingListing!.category != null) {
          _selectedCategory = _categories.firstWhere(
              (c) => c.sId == widget.existingListing!.category!.sId,
              orElse: () => _categories.first);
        } else if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
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
    _dailyHoursController.dispose();
    for (var controller in _packageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 70, // Compresses image to 70% quality
      maxWidth: 1080,   // Limits width to 1080px for faster uploads
    );
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingNetworkImages.removeAt(index);
    });
  }

  bool _isFormValid() {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().length < 10 ||
        _locationController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty ||
        _selectedCategory == null) {
      return false;
    }

    if (_selectedImages.isEmpty && _existingNetworkImages.isEmpty) {
      return false;
    }

    // Pricing validation
    if (_selectedPricingModel == 'By Hour') {
      return _hourlyRateController.text.isNotEmpty;
    } else if (_selectedPricingModel == 'By Day') {
      return _dailyRateController.text.isNotEmpty && _dailyHoursController.text.isNotEmpty;
    } else if (_selectedPricingModel == 'By Service') {
      return _packageControllers.isNotEmpty && _packageControllers.any((p) => p.name.text.isNotEmpty && p.price.text.isNotEmpty);
    }

    return true;
  }

  Future<void> _publishListing() async {
    if (!_isFormValid()) return;
    
    final controller = Provider.of<ServiceController>(context, listen: false);
    controller.clearErrors(); // Clear old errors

    // Prepare service data
    final serviceData = Data(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      subCategory: _subCategoryController.text.trim(),
      tags: [_selectedServiceType],
      equipment: _equipment,
      pricingType: _selectedPricingModel == 'By Hour'
          ? "HOURLY"
          : _selectedPricingModel == 'By Day'
              ? "DAILY"
              : "PACKAGE",
      price: int.tryParse(
            _selectedPricingModel == 'By Hour'
                ? _hourlyRateController.text
                : _selectedPricingModel == 'By Day'
                ? _dailyRateController.text
                : (_packageControllers.isNotEmpty ? _packageControllers.first.price.text : '0'),
          ) ??
          0,
      currency: "EUR",
      // Fix: Duration must be an int according to Zod error "Expected number"
      duration: (int.tryParse(_durationController.text) ?? 1).toString(), 
      location: Location(
        country: _countryController.text.trim(),
        city: _locationController.text.trim(),
        address: _addressController.text.trim(),
        serviceRadiusKm: _serviceRadius.toInt(),
      ),
      gallery: _existingNetworkImages,
      isVerified: widget.existingListing?.isVerified ?? false,
    );

    // Setup pricing model for DAILY or PACKAGE
    if (_selectedPricingModel == 'By Day') {
      serviceData.pricingModel = PricingModel(
        type: "DAILY",
        dailyRate: double.tryParse(_dailyRateController.text),
        dailyHours: int.tryParse(_dailyHoursController.text),
      );
    } else if (_selectedPricingModel == 'By Service') {
      serviceData.pricingModel = PricingModel(
        type: "PACKAGE",
        packages: _packageControllers.where((p) => p.name.text.isNotEmpty).map((p) => Packages(
          name: p.name.text.trim(),
          price: int.tryParse(p.price.text) ?? 0,
          duration: int.tryParse(p.duration.text) ?? 1,
          description: p.description.text.trim(),
          includes: p.includes.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        )).toList(),
      );
    }

    bool success;
    if (widget.existingListing != null) {
      success = await controller.updateService(
          widget.existingListing!.sId!, serviceData, _selectedImages);
    } else {
      success = await controller.createService(serviceData, _selectedImages);
    }

    if (success && mounted) {
      CustomSnackBar.show(
        context: context,
        message: widget.existingListing != null
            ? "Service updated successfully"
            : "Service published successfully",
        isError: false,
      );
      Navigator.pop(context, true);
    } else if (mounted) {
       // Display error summary snackbar
       CustomSnackBar.show(
         context: context,
         message: controller.errorMessage ?? "Failed to publish listing",
         isError: true,
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool inProgress = context.watch<ServiceController>().inProgress;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                children: [
                  _buildSectionTitle('Basic Information'),
                  _buildLabel('Listing Title'),
                  _buildTextField(
                    _titleController, 
                    'e.g. Professional Portrait Shoot',
                    errorText: context.watch<ServiceController>().fieldErrors['title'],
                  ),
                  SizedBox(height: 15.h),
                  _buildLabel('Category'),
                  _buildCategoryDropdown(),
                  SizedBox(height: 15.h),
                  _buildLabel('Sub-Category'),
                  _buildTextField(
                    _subCategoryController, 
                    'e.g. Wedding, Event, Portrait',
                    errorText: context.watch<ServiceController>().fieldErrors['subCategory'],
                  ),
                  SizedBox(height: 15.h),
                  _buildLabel('Service Type'),
                  _buildServiceTypeDropdown(),
                  SizedBox(height: 15.h),
                  _buildLabel('Description'),
                  _buildTextField(
                    _descriptionController, 
                    'Tell clients about your service (min 10 characters)...', 
                    maxLines: 4,
                    errorText: _descriptionController.text.isNotEmpty && _descriptionController.text.length < 10 
                      ? 'Description must be at least 10 characters'
                      : context.watch<ServiceController>().fieldErrors['description'],
                  ),
                  
                  SizedBox(height: 30.h),
                  _buildSectionTitle('Pricing & Duration'),
                  _buildPricingToggle(),
                  SizedBox(height: 20.h),
                  _buildPricingFields(),
                  
                  SizedBox(height: 30.h),
                  _buildSectionTitle('Location & Radius'),
                  _buildLabel('Country'),
                  _buildTextField(_countryController, 'e.g. Germany'),
                  SizedBox(height: 15.h),
                  _buildLabel('City'),
                  _buildTextField(_locationController, 'e.g. Berlin'),
                  SizedBox(height: 15.h),
                  _buildLabel('Address'),
                  _buildTextField(
                    _addressController, 
                    'e.g. Street name, Number',
                    errorText: context.watch<ServiceController>().fieldErrors['location.address'],
                  ),
                  SizedBox(height: 15.h),
                  _buildLabel('Service Radius: ${_serviceRadius.toInt()} km'),
                  _buildRadiusSlider(),
                  _buildAcceptOutsideRadiusToggle(),
                  
                  SizedBox(height: 30.h),
                  _buildSectionTitle('More Details'),
                  _buildLabel('Duration (Hours)'),
                  _buildTextField(
                    _durationController, 
                    'e.g. 2',
                    errorText: context.watch<ServiceController>().fieldErrors['duration'],
                  ),
                  SizedBox(height: 15.h),
                  _buildLabel('Equipment (Optional)'),
                  _buildEquipmentInput(),
                  _buildEquipmentList(),
                  
                  SizedBox(height: 30.h),
                  _buildSectionTitle('Portfolio Photos'),
                  _buildPhotoUploadArea(),
                  _buildSelectedImagesGrid(),
                  
                  SizedBox(height: 40.h),
                  _buildFooterButtons(inProgress),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppTypography.h2,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTypography.bodySmall,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, String? errorText}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: errorText != null ? Colors.red : const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: (value) => setState(() {}), // Trigger rebuild for button validation
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: AppTypography.bodyLarge),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
              child: Text(
                errorText,
                style: TextStyle(color: Colors.red, fontSize: 12.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
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
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          onChanged: (Category? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          items: _categories.map<DropdownMenuItem<Category>>((Category value) {
            return DropdownMenuItem<Category>(
              value: value,
              child: Text(value.name ?? ''),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildServiceTypeDropdown() {
    // Assuming service types are fixed or from tags for now
    final serviceTypes = ['Photography', 'Videography', 'Video Editing', 'Wedding', 'Event', 'Portrait'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedServiceType,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          onChanged: (String? newValue) {
            setState(() {
              _selectedServiceType = newValue!;
            });
          },
          items: serviceTypes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPricingToggle() {
    final models = ['By Hour', 'By Day', 'By Service'];
    return Row(
      children: models.map((model) {
        bool isSelected = _selectedPricingModel == model;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPricingModel = model;
                if (model == 'By Service' && _packageControllers.isEmpty) {
                  _packageControllers.add(PackageControllers(name: 'Starter'));
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: model == models.last ? 0 : 8.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
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

  Widget _buildPricingFields() {
    if (_selectedPricingModel == 'By Hour') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Hourly Rate (EUR)'),
          _buildTextField(
            _hourlyRateController, 
            'e.g. 50',
            errorText: context.watch<ServiceController>().fieldErrors['price'],
          ),
        ],
      );
    } else if (_selectedPricingModel == 'By Day') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Daily Rate (EUR)'),
          _buildTextField(
            _dailyRateController, 
            'e.g. 350',
            errorText: context.watch<ServiceController>().fieldErrors['dailyRate'],
          ),
          SizedBox(height: 15.h),
          _buildLabel('Hours per Day'),
          _buildTextField(
            _dailyHoursController, 
            'e.g. 8',
            errorText: context.watch<ServiceController>().fieldErrors['dailyHours'],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._packageControllers.asMap().entries.map((entry) {
            int index = entry.key;
            PackageControllers controllers = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 20.h),
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Package ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (_packageControllers.length > 1)
                        GestureDetector(
                          onTap: () => setState(() => _packageControllers.removeAt(index).dispose()),
                          child: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _buildPackageField(controllers.name, 'Package Name (e.g. Basic)'),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(child: _buildPackageField(controllers.price, 'Price (EUR)', isNumber: true)),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildPackageField(controllers.duration, 'Duration (Hours)', isNumber: true)),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _buildPackageField(controllers.description, 'Description (Short)', maxLines: 2),
                  SizedBox(height: 10.h),
                  _buildPackageField(controllers.includes, 'Includes (comma separated)', maxLines: 2),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setState(() => _packageControllers.add(PackageControllers())),
            icon: const Icon(Icons.add),
            label: const Text('Add Another Package'),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ],
      );
    }
  }

  Widget _buildPackageField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (value) => setState(() {}), // Trigger rebuild for button validation
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: AppTypography.bodyMedium),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        ),
      ),
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

class PackageControllers {
  final TextEditingController name;
  final TextEditingController price;
  final TextEditingController duration;
  final TextEditingController description;
  final TextEditingController includes; // Comma separated for UI

  PackageControllers({
    String name = '',
    String price = '',
    String duration = '',
    String description = '',
    String includes = '',
  }) : name = TextEditingController(text: name),
       price = TextEditingController(text: price),
       duration = TextEditingController(text: duration),
       description = TextEditingController(text: description),
       includes = TextEditingController(text: includes);

  void dispose() {
    name.dispose();
    price.dispose();
    duration.dispose();
    description.dispose();
    includes.dispose();
  }
}
