import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/widgets/custom_side_menu.dart';
import 'package:tripmate/features/profile/domain/entity/profile_entity.dart';
import 'package:tripmate/features/ride/presentation/view/submission_success_view.dart';
import 'package:tripmate/features/ride/presentation/view_model/rider_kyc_event.dart';
import 'package:tripmate/features/ride/presentation/view_model/rider_kyc_state.dart';
import 'package:tripmate/features/ride/presentation/view_model/rider_kyc_view_model.dart';

class RiderVerificationView extends StatefulWidget {
  final ProfileEntity? currentUser;

  const RiderVerificationView({super.key, this.currentUser});

  @override
  State<RiderVerificationView> createState() => _RiderVerificationViewState();
}

class _RiderVerificationViewState extends State<RiderVerificationView> {
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); 
  int _currentStep = 1;
  bool _isReadOnly = false;

  late TextEditingController _fullNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  
  late TextEditingController _licenseNumCtrl;
  late TextEditingController _licenseExpiryCtrl;
  late TextEditingController _licenseIssueCtrl;
  
  late TextEditingController _vehicleModelCtrl;
  late TextEditingController _vehicleYearCtrl;
  late TextEditingController _vehiclePlateCtrl;

  File? _profileImage;
  File? _citizenshipFront;
  File? _citizenshipBack;
  File? _licensePhoto;
  File? _selfieLicense;
  File? _vehiclePhoto;
  File? _billbookPage2;
  File? _billbookPage3;

  String? _netProfileImage;
  String? _netCitizenshipFront;
  String? _netCitizenshipBack;
  String? _netLicensePhoto;
  String? _netSelfieLicense;
  String? _netVehiclePhoto;
  String? _netBillbookPage2;
  String? _netBillbookPage3;

  final Color brown = const Color(0xFF8B4513);
  final Color beige = const Color(0xFFF9F5E9);
  final Color lightGrey = const Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    final user = widget.currentUser;
    final kyc = user?.kycDetails;

    _fullNameCtrl = TextEditingController(text: user?.fullName ?? "");
    _emailCtrl = TextEditingController(text: user?.email ?? "");
    _phoneCtrl = TextEditingController(text: user?.phone ?? "");
    _netProfileImage = user?.image;

    _licenseNumCtrl = TextEditingController(text: kyc?['licenseNumber'] ?? "");
    _licenseExpiryCtrl = TextEditingController(text: kyc?['licenseExpiryDate'] ?? "");
    _licenseIssueCtrl = TextEditingController(text: kyc?['licenseIssueDate'] ?? "");
    
    _vehicleModelCtrl = TextEditingController(text: kyc?['vehicleModel'] ?? "");
    _vehicleYearCtrl = TextEditingController(text: kyc?['vehicleProductionYear'] ?? "");
    _vehiclePlateCtrl = TextEditingController(text: kyc?['vehiclePlateNumber'] ?? "");

    // ✅ FETCH ALL NETWORK IMAGE PATHS
    _netCitizenshipFront = kyc?['citizenshipFront'];
    _netCitizenshipBack = kyc?['citizenshipBack'];
    _netLicensePhoto = kyc?['licenseImage'];
    _netSelfieLicense = kyc?['selfieWithLicense'];
    _netVehiclePhoto = kyc?['vehiclePhoto'];
    _netBillbookPage2 = kyc?['billbookPage2'];
    _netBillbookPage3 = kyc?['billbookPage3'];

    if (user?.riderStatus == 'pending' || user?.riderStatus == 'approved') {
      _isReadOnly = true;
    }
  }

  void _nextPage(BuildContext blocContext) {
    if (!_validateCurrentStep()) return;

    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
      setState(() => _currentStep++);
    } else {
      if (!_isReadOnly) _submitKYC(blocContext);
    }
  }

  void _prevPage() {
    if (_currentStep > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
      setState(() => _currentStep--);
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  bool _validateCurrentStep() {
    if (_isReadOnly) return true;

    if (_currentStep == 1) {
      if (_fullNameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
        _showError("Please fill all personal details.");
        return false;
      }
      if (_profileImage == null && (_netProfileImage == null || _netProfileImage!.isEmpty)) {
        _showError("Please upload a profile photo.");
        return false;
      }
    } else if (_currentStep == 2) {
      if ((_citizenshipFront == null && _netCitizenshipFront == null) || 
          (_citizenshipBack == null && _netCitizenshipBack == null)) {
        _showError("Please upload both sides of Citizenship/ID.");
        return false;
      }
    } else if (_currentStep == 3) {
      if (_licenseNumCtrl.text.isEmpty || _licenseExpiryCtrl.text.isEmpty || _licenseIssueCtrl.text.isEmpty) {
        _showError("Please fill all license details.");
        return false;
      }
      if ((_licensePhoto == null && _netLicensePhoto == null) || 
          (_selfieLicense == null && _netSelfieLicense == null)) {
        _showError("Please upload license photo and selfie.");
        return false;
      }
    } else if (_currentStep == 4) {
      if (_vehicleModelCtrl.text.isEmpty || _vehicleYearCtrl.text.isEmpty || _vehiclePlateCtrl.text.isEmpty) {
        _showError("Please fill all vehicle details.");
        return false;
      }
      if ((_vehiclePhoto == null && _netVehiclePhoto == null) || 
          (_billbookPage2 == null && _netBillbookPage2 == null) || 
          (_billbookPage3 == null && _netBillbookPage3 == null)) {
        _showError("Please upload Vehicle and Billbook photos.");
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }

  void _submitKYC(BuildContext blocContext) {
    blocContext.read<RiderKycViewModel>().add(SubmitKycEvent(
      context: blocContext,
      citizenshipFront: _citizenshipFront,
      citizenshipBack: _citizenshipBack,
      licenseNumber: _licenseNumCtrl.text,
      licenseExpiryDate: _licenseExpiryCtrl.text,
      licenseIssueDate: _licenseIssueCtrl.text,
      licenseImage: _licensePhoto,
      selfieWithLicense: _selfieLicense,
      vehicleModel: _vehicleModelCtrl.text,
      vehicleProductionYear: _vehicleYearCtrl.text,
      vehiclePlateNumber: _vehiclePlateCtrl.text,
      vehiclePhoto: _vehiclePhoto,
      billbookPage2: _billbookPage2,
      billbookPage3: _billbookPage3,
    ));
  }

  // --- Helper to clean paths for NetworkImage ---
  String _getNetUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    return "${ApiEndpoints.imageUrl}${path.replaceAll(r'\', '/')}";
  }

  Future<void> _selectDate(TextEditingController controller) async {
    if (_isReadOnly) return;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: brown, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => controller.text = DateFormat('MM/dd/yyyy').format(picked));
    }
  }

  void _showImagePicker(String title, Function(File) onSelected) {
    if (_isReadOnly) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFBF5), 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 30),
            Center(child: Icon(Icons.add_a_photo_outlined, size: 80, color: brown.withOpacity(0.5))),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera, onSelected),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Take Picture"),
                style: ElevatedButton.styleFrom(backgroundColor: brown, foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery, onSelected),
                icon: const Icon(Icons.photo_library),
                label: const Text("Choose from Gallery"),
                style: OutlinedButton.styleFrom(foregroundColor: brown, side: BorderSide(color: brown)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, Function(File) onSelected) async {
    final img = await ImagePicker().pickImage(source: source, imageQuality: 25, maxWidth: 1024);
    if (img != null) {
      setState(() => onSelected(File(img.path)));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<RiderKycViewModel>(),
      child: BlocListener<RiderKycViewModel, RiderKycState>(
        listener: (context, state) {
          if (state.isSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SubmissionSuccessView()),
              (route) => false,
            );
          }
          if (state.errorMessage != null) {
            _showError(state.errorMessage!);
          }
        },
        child: BlocBuilder<RiderKycViewModel, RiderKycState>(
          builder: (context, state) {
            return Scaffold(
              key: _scaffoldKey, 
              backgroundColor: beige,
              drawer: const CustomSideMenu(), 
              appBar: AppBar(
                backgroundColor: beige,
                elevation: 0,
                leadingWidth: 70, 
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.menu, color: brown, size: 28),
                    ),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rider Verification", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("Step $_currentStep of 4", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: List.generate(4, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: index < _currentStep ? brown : Colors.grey[300], 
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              body: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), 
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                      _buildStep4(),
                    ],
                  ),
                  if (state.isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(child: CircularProgressIndicator(color: brown)),
                    ),
                ],
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (_currentStep > 1)
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: _prevPage,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: brown),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text("Back", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: brown)),
                        ),
                      ),
                    if (_currentStep > 1) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : () => _nextPage(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brown, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _currentStep == 4 
                            ? (_isReadOnly ? "Status: ${widget.currentUser?.riderStatus.toUpperCase()}" : "Submit") 
                            : "Next Step",
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStep1() {
    ImageProvider? imageProvider;
    if (_profileImage != null) {
      imageProvider = FileImage(_profileImage!);
    } else if (_netProfileImage != null && _netProfileImage!.isNotEmpty) {
      imageProvider = NetworkImage(_getNetUrl(_netProfileImage));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Personal Information", Icons.person_outline),
          _inputField("Full Name", _fullNameCtrl, hint: "Enter full name"),
          _inputField("Email", _emailCtrl, hint: "Enter email", readOnly: true, isGrey: true),
          _inputField("Phone", _phoneCtrl, hint: "Enter phone number"),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: lightGrey,
                    shape: BoxShape.circle,
                    image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                  ),
                  child: imageProvider == null ? const Icon(Icons.person, color: Colors.grey) : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Profile Photo", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    Text("Clear face photo required", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => _showImagePicker("Profile Photo", (f) => _profileImage = f),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: const BorderSide(color: Colors.grey)),
                  child: const Text("Change"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _sectionHeader("Citizenship / ID", Icons.card_membership),
          _imageBox("Front Side", _citizenshipFront, _netCitizenshipFront, (f) => _citizenshipFront = f),
          const SizedBox(height: 16),
          _imageBox("Back Side", _citizenshipBack, _netCitizenshipBack, (f) => _citizenshipBack = f),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _sectionHeader("Driving License", Icons.drive_eta),
          _inputField("License Number", _licenseNumCtrl, hint: "XX-XX-XXXX"),
          _inputField("Expiry Date", _licenseExpiryCtrl, hint: "mm/dd/yyyy", isDate: true),
          _inputField("Issue Date", _licenseIssueCtrl, hint: "mm/dd/yyyy", isDate: true),
          const SizedBox(height: 16),
          _imageBox("Upload License Photo", _licensePhoto, _netLicensePhoto, (f) => _licensePhoto = f),
          const SizedBox(height: 16),
          _captureRow("Selfie with License", _selfieLicense, _netSelfieLicense, (f) => setState(() => _selfieLicense = f)),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _sectionHeader("Vehicle Details", Icons.two_wheeler),
          _inputField("Brand & Model", _vehicleModelCtrl, hint: "eg: Bajaj Pulsar 150"),
          _inputField("Production Year", _vehicleYearCtrl, hint: "2025"),
          _inputField("Plate Number", _vehiclePlateCtrl, hint: "BA 2 PA 5544"),
          const SizedBox(height: 16),
          _imageBox("Upload Bike Photo", _vehiclePhoto, _netVehiclePhoto, (f) => _vehiclePhoto = f),
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerLeft, child: Text("Billbook Photos", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey))),
          const SizedBox(height: 10),
          _imageBox("Billbook Registration Page", _billbookPage2, _netBillbookPage2, (f) => _billbookPage2 = f),
          const SizedBox(height: 10),
          _imageBox("Billbook Renew Page", _billbookPage3, _netBillbookPage3, (f) => _billbookPage3 = f),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D))),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {required String hint, bool readOnly = false, bool isGrey = false, bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: isDate || readOnly || _isReadOnly,
            onTap: isDate ? () => _selectDate(controller) : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
              filled: true,
              fillColor: isGrey ? Colors.grey[200] : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: isDate ? Icon(Icons.calendar_today, color: brown, size: 20) : null,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED: Supports local File? OR Network Path
  Widget _imageBox(String label, File? file, String? netPath, Function(File?) onSelected) {
    return GestureDetector(
      onTap: () => _showImagePicker(label, (f) => setState(() => onSelected(f))),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child: (file != null || (netPath != null && netPath.isNotEmpty)) 
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12), 
                  child: file != null 
                    ? Image.file(file, fit: BoxFit.contain)
                    : Image.network(_getNetUrl(netPath), fit: BoxFit.contain)
                ), 
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => onSelected(null)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                )
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 30),
                const SizedBox(height: 8),
                Text(label, style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w500)),
              ],
            ),
      ),
    );
  }

  Widget _captureRow(String label, File? file, String? netPath, Function(File?) onSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8), 
            child: file != null 
              ? Image.file(file, width: 40, height: 40, fit: BoxFit.cover)
              : (netPath != null && netPath.isNotEmpty)
                  ? Image.network(_getNetUrl(netPath), width: 40, height: 40, fit: BoxFit.cover)
                  : const Icon(Icons.camera_alt_outlined, color: Colors.grey)
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
          if(file != null) 
             IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => onSelected(null))),
          ElevatedButton(
            onPressed: () => _showImagePicker(label, (f) => setState(() => onSelected(f))),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFE0B2), foregroundColor: brown, elevation: 0),
            child: Text(file == null && (netPath == null || netPath.isEmpty) ? "Capture" : "Retake"),
          )
        ],
      ),
    );
  }
}