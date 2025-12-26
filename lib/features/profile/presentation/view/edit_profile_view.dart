import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/features/profile/domain/entity/profile_entity.dart';
import 'package:tripmate/features/profile/data/data_source/remote_data_source/profile_remote_data_source.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_event.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:tripmate/features/ride/presentation/view/submission_success_view.dart';
import 'package:tripmate/features/home/presentation/view/home_view.dart';

class EditProfileView extends StatefulWidget {
  final ProfileEntity user;
  final bool isRiderMode;

  const EditProfileView({super.key, required this.user, required this.isRiderMode});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final Map<int, double> _pageHeights = {0: 360.0, 1: 480.0, 2: 580.0};

  late TextEditingController _nameCtrl, _emailCtrl, _phoneCtrl;
  late TextEditingController _licNoCtrl, _licIssCtrl, _licExpCtrl;
  late TextEditingController _vModelCtrl, _vYearCtrl, _vPlateCtrl;

  File? _imgProfile, _imgLicense, _imgSelfie, _imgBike, _imgBB2, _imgBB3;
  
  late Map<String, String?> _cachedNetworkImages;

  @override
  void initState() {
    super.initState();
    final k = widget.user.kycDetails;
    
    _nameCtrl = TextEditingController(text: widget.user.fullName);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phone);

    _licNoCtrl = TextEditingController(text: k?['licenseNumber']?.toString() ?? "");
    _licIssCtrl = TextEditingController(text: k?['licenseIssueDate']?.toString() ?? "");
    _licExpCtrl = TextEditingController(text: k?['licenseExpiryDate']?.toString() ?? "");
    _vModelCtrl = TextEditingController(text: k?['vehicleModel']?.toString() ?? "");
    _vYearCtrl = TextEditingController(text: k?['vehicleProductionYear']?.toString() ?? "");
    _vPlateCtrl = TextEditingController(text: k?['vehiclePlateNumber']?.toString() ?? "");

    _cachedNetworkImages = {
      'profile': widget.user.image,
      'license': k?['licenseImage']?.toString(),
      'selfie': k?['selfieWithLicense']?.toString(),
      'bike': k?['vehiclePhoto']?.toString(),
      'bb2': k?['billbookPage2']?.toString(),
      'bb3': k?['billbookPage3']?.toString(),
    };
  }

  void _handleSave() async {
    setState(() => _isLoading = true);

    bool kycChanged = _imgLicense != null || _imgBike != null || 
                      _imgSelfie != null || _imgBB2 != null || _imgBB3 != null ||
                      _licNoCtrl.text != (widget.user.kycDetails?['licenseNumber'] ?? "") ||
                      _vPlateCtrl.text != (widget.user.kycDetails?['vehiclePlateNumber'] ?? "");

    try {
      final updated = ProfileEntity(
        id: widget.user.id, fullName: _nameCtrl.text, phone: _phoneCtrl.text,
        email: _emailCtrl.text, gender: widget.user.gender, dob: widget.user.dob, role: widget.user.role,
        kycDetails: { ...?widget.user.kycDetails,
          'licenseNumber': _licNoCtrl.text, 'licenseExpiryDate': _licExpCtrl.text, 'licenseIssueDate': _licIssCtrl.text,
          'vehicleModel': _vModelCtrl.text, 'vehicleProductionYear': _vYearCtrl.text, 'vehiclePlateNumber': _vPlateCtrl.text,
        },
      );

      await serviceLocator<ProfileRemoteDataSource>().updateFullProfile(
        updated, profilePic: _imgProfile, licenseImg: _imgLicense, bikeImg: _imgBike,
        selfieImg: _imgSelfie, bb2: _imgBB2, bb3: _imgBB3
      );

      if (mounted) {
        context.read<ProfileViewModel>().add(LoadProfileEvent());
        
        if (kycChanged) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SubmissionSuccessView()));
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const HomeView()), 
                (route) => false
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Text("Profile updated successfully!", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ],
              ),
              backgroundColor: const Color(0xFF8B4513),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(20),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isRider = widget.isRiderMode;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), 
          onPressed: () => Navigator.pop(context)
        )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 15),
            _buildStatsCard(isRider),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              height: isRider ? _pageHeights[_currentPage] : _pageHeights[0],
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: isRider ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      children: [
                        _buildPersonalPage(),
                        if (isRider) ...[ _buildLicensePage(), _buildVehiclePage() ]
                      ],
                    ),
                  ),
                  if (isRider) _buildDots(),
                ],
              ),
            ),
            _buildSaveButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalPage() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title("Edit Profile"),
      _field("Full Name", _nameCtrl, Icons.person_outline),
      _field("Email", _emailCtrl, Icons.email_outlined, enabled: false),
      _field("Phone", _phoneCtrl, Icons.phone_android_outlined),
    ]);
  }

  Widget _buildLicensePage() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(), 
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title("License Details"),
        _field("License Number", _licNoCtrl, Icons.badge_outlined),
        Row(children: [
          Expanded(child: _field("Issue Date", _licIssCtrl, Icons.calendar_today_outlined, isDate: true)),
          const SizedBox(width: 10),
          Expanded(child: _field("Expiry Date", _licExpCtrl, Icons.event_available_outlined, isDate: true)),
        ]),
        _docTile("License Front", _imgLicense, _cachedNetworkImages['license'], (f) => _imgLicense = f),
        _docTile("Selfie with License", _imgSelfie, _cachedNetworkImages['selfie'], (f) => _imgSelfie = f),
      ])
    );
  }

  Widget _buildVehiclePage() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(), 
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title("Vehicle Details"),
        _field("Vehicle Model", _vModelCtrl, Icons.directions_bike),
        Row(children: [
          Expanded(child: _field("Year", _vYearCtrl, Icons.history_toggle_off_outlined)),
          const SizedBox(width: 10),
          Expanded(child: _field("Plate No", _vPlateCtrl, Icons.pin_outlined)),
        ]),
        _docTile("Bike Photo", _imgBike, _cachedNetworkImages['bike'], (f) => _imgBike = f),
        _docTile("Billbook P2", _imgBB2, _cachedNetworkImages['bb2'], (f) => _imgBB2 = f),
        _docTile("Billbook P3", _imgBB3, _cachedNetworkImages['bb3'], (f) => _imgBB3 = f),
      ])
    );
  }

  Widget _title(String t) => Text(
    t, 
    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF333333))
  );

  Widget _field(String l, TextEditingController c, IconData i, {bool enabled = true, bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 15), 
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: c, 
          enabled: enabled, 
          readOnly: isDate, 
          onTap: isDate ? () => _selectDate(c) : null, 
          decoration: InputDecoration(
            prefixIcon: Icon(i, size: 18, color: const Color(0xFF8B4513)), 
            filled: true, 
            fillColor: const Color(0xFFFFF9F6), 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), 
            contentPadding: const EdgeInsets.symmetric(horizontal: 12)
          )
        ),
      ])
    );
  }

  Future<void> _selectDate(TextEditingController c) async {
    DateTime? p = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime(1980), 
      lastDate: DateTime(2040), 
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF8B4513), 
            onPrimary: Colors.white, 
            surface: Colors.white, 
            onSurface: Colors.black
          )
        ), 
        child: child!
      )
    );
    if (p != null) setState(() => c.text = DateFormat('MM/dd/yyyy').format(p));
  }

  Widget _docTile(String label, File? local, String? cachedNetUrl, Function(File) onPick) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), 
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8), 
          child: Container(
            width: 40, height: 40, color: Colors.grey[100], 
            child: local != null 
              ? Image.file(local, fit: BoxFit.cover)
              : (cachedNetUrl != null && cachedNetUrl.isNotEmpty
                  ? Image.network(
                      "${ApiEndpoints.imageUrl}${cachedNetUrl.replaceAll(r'\', '/')}", 
                      fit: BoxFit.cover, 
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                      cacheWidth: 100,
                      cacheHeight: 100,
                    )
                  : const Icon(Icons.image, size: 20))
          )
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        TextButton(
          onPressed: () => _pickImg(onPick), 
          child: const Text("Replace", style: TextStyle(color: Color(0xFF8B4513), fontSize: 12))
        ),
      ])
    );
  }

  Widget _buildSaveButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25), 
    child: SizedBox(
      width: double.infinity, height: 55, 
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleSave, 
        icon: const Icon(Icons.save, size: 18),
        label: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B4513), 
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ), 
      )
    )
  );

  Widget _buildHeader() {
    double currentRating = widget.user.rating;
    if (currentRating == 0.0) currentRating = 5.0; 

    return Column(children: [
      Stack(children: [
        CircleAvatar(
          radius: 50, 
          backgroundImage: _imgProfile != null 
            ? FileImage(_imgProfile!) as ImageProvider 
            : (_cachedNetworkImages['profile'] != null 
                ? NetworkImage("${ApiEndpoints.imageUrl}${_cachedNetworkImages['profile']?.replaceAll(r'\', '/')}")
                : null),
          child: _imgProfile == null && _cachedNetworkImages['profile'] == null 
            ? const Icon(Icons.person, size: 40) 
            : null,
        ),
        Positioned(
          bottom: 0, right: 0, 
          child: GestureDetector(
            onTap: () => _pickImg((f) => _imgProfile = f), 
            child: Container(
              padding: const EdgeInsets.all(6), 
              decoration: const BoxDecoration(color: Color(0xFFD2B48C), shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))), 
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white)
            )
          )
        ),
      ]),
      const SizedBox(height: 8),
      Text(widget.user.fullName, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: List.generate(5, (i) => Icon(
          Icons.star, 
          // All stars orange for new users (5.0 standard)
          color: i < currentRating.floor() ? Colors.orange : Colors.grey[300], 
          size: 16
        ))
      ),
    ]);
  }

  Widget _buildStatsCard(bool isRider) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20), 
    padding: const EdgeInsets.all(15), 
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
      children: [
        _statItem(
          isRider ? "RIDES DONE" : "RIDES TAKEN", 
          isRider ? widget.user.ridesDone.toString() : widget.user.ridesTaken.toString()
        ), 
        _statItem(
          isRider ? "TOTAL EARNED" : "TOTAL SPENT", 
          // ✅ FIX: Removed 'k' to show exact amount
          "Rs ${isRider ? widget.user.totalEarned.toInt() : widget.user.totalSpent.toInt()}"
        )
      ]
    )
  );

  Widget _statItem(String l, String v) => Column(children: [
    Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)), 
    Text(v, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF8B4513)))
  ]);

  Widget _buildDots() => Padding(
    padding: const EdgeInsets.only(top: 10), 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: List.generate(3, (i) => Container(
        margin: const EdgeInsets.all(4), 
        width: _currentPage == i ? 12 : 8, 
        height: 6, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), 
          color: _currentPage == i ? const Color(0xFF8B4513) : Colors.grey[300]
        )
      ))
    )
  );

  Future<void> _pickImg(Function(File) onSelect) async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => onSelect(File(f.path)));
  }
}