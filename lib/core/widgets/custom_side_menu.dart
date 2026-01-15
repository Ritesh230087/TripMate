import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/network/socket_service.dart';
import 'package:tripmate/features/notifications/presentation/view/notification_view.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_event.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_state.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/presentation/view/help_view.dart';
import 'package:tripmate/features/ride/presentation/view/passenger_requests_view.dart';
import 'package:tripmate/features/ride/presentation/view/passenger_upcomong%20ride_view.dart';
import 'package:tripmate/features/ride/presentation/view/rider_home_view.dart';
import 'package:tripmate/features/ride/presentation/view/rider_rejected_view.dart';
import 'package:tripmate/features/ride/presentation/view/rider_upcoming_rides_view.dart';
import 'package:tripmate/features/ride/presentation/view/submission_success_view.dart';
import 'package:tripmate/features/ride/presentation/view/rider_verification_view.dart';
import 'package:tripmate/features/ride/presentation/view/rider_requests_view.dart';
import 'package:tripmate/features/ride/presentation/view/ride_history_view.dart';
import 'package:tripmate/features/profile/presentation/view/edit_profile_view.dart';
import 'package:tripmate/features/ride/presentation/view_model/rider_kyc_view_model.dart';
import 'package:tripmate/features/home/presentation/view/home_view.dart';

class CustomSideMenu extends StatefulWidget {
  final bool isRiderMode;
  const CustomSideMenu({super.key, this.isRiderMode = false});

  @override
  State<CustomSideMenu> createState() => _CustomSideMenuState();
}

class _CustomSideMenuState extends State<CustomSideMenu> {
  int _notificationCount = 0;
  int _requestCount = 0;
  int _upcomingCount = 0;
  final SocketService _socket = serviceLocator<SocketService>();

  @override
  void initState() {
    super.initState();
    context.read<ProfileViewModel>().add(LoadProfileEvent());
    _fetchRealCounts();
    _setupSocketListeners();
  }

  Future<void> _fetchRealCounts() async {
    try {
      final response = await serviceLocator<RideRemoteDataSource>().getSidebarCounts();
      if (mounted) {
        setState(() {
          _notificationCount = response['unreadNotifications'] ?? 0;
          _requestCount = response['pendingRequests'] ?? 0;
          _upcomingCount = widget.isRiderMode 
              ? (response['riderUpcoming'] ?? 0) 
              : (response['passengerUpcoming'] ?? 0);
        });
      }
    } catch (e) { debugPrint("Error: $e"); }
  }

  void _setupSocketListeners() {
    final user = context.read<ProfileViewModel>().state.profile;
    if (user != null) {
      _socket.socket.emit('identify_user', user.id);
    }
    _socket.socket.on('sidebar_update', (_) => _fetchRealCounts());
    _socket.socket.on('new_notification', (_) => _fetchRealCounts());
  }

  // ✅ LOGOUT DIALOG FIXED (No Text Wrapping)
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        title: Center(child: Text("Logout?", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18))),
        content: Text("Are you sure you want to logout? You will need to login again to use the app.", 
          textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
        actionsPadding: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEEEEE),
                      foregroundColor: const Color(0xFF616161),
                      elevation: 0,
                      padding: EdgeInsets.zero, // Minimal padding
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("No, Back", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<ProfileViewModel>().add(LogoutEvent(context: context));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEAEA),
                      foregroundColor: const Color(0xFFD32F2F),
                      elevation: 0,
                      padding: EdgeInsets.zero, // Minimal padding
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Yes, Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socket.socket.off('sidebar_update');
    _socket.socket.off('new_notification');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CircleAvatar(backgroundColor: const Color(0xFFF9F5E9), radius: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 20), onPressed: () => Navigator.pop(context))),
              ),
              const SizedBox(height: 20),
              
              BlocBuilder<ProfileViewModel, ProfileState>(
                builder: (context, state) {
                  final user = state.profile;
                  final imagePath = user?.image?.trim();
                  return Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), color: const Color(0xFFF9F5E9),
                          image: imagePath != null && imagePath.isNotEmpty ? DecorationImage(image: NetworkImage("${ApiEndpoints.imageUrl}${imagePath.replaceAll(r'\', '/')}"), fit: BoxFit.cover) : null,
                        ),
                        child: imagePath == null || imagePath.isEmpty ? const Icon(Icons.person, color: Color(0xFF8B4513)) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user?.fullName ?? "Loading...", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(widget.isRiderMode ? "Rider Dashboard" : "Verified Member", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                      ])),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),
              
              _menuItem(Icons.person_outline, "Edit Profile", onTap: () {
                final user = context.read<ProfileViewModel>().state.profile;
                if (user != null) {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => serviceLocator<RiderKycViewModel>(), child: EditProfileView(user: user, isRiderMode: widget.isRiderMode))));
                }
              }),

              if (widget.isRiderMode) ...[
                _menuItem(Icons.calendar_month, "My Upcoming Rides", badge: _upcomingCount > 0 ? _upcomingCount.toString() : null, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RiderUpcomingRidesView())); }),
                _menuItem(Icons.history, "Ride History", onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RideHistoryView(isRider: true))); }),
                _menuItem(Icons.list_alt, "Ride Requests", badge: _requestCount > 0 ? _requestCount.toString() : null, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RiderRequestsView())); }),
              ] else ...[
                _menuItem(Icons.calendar_today_outlined, "Upcoming Rides", badge: _upcomingCount > 0 ? _upcomingCount.toString() : null, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerUpcomingRidesView())); }),
                _menuItem(Icons.history, "Ride History", onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RideHistoryView(isRider: false))); }),
                _menuItem(Icons.list_alt, "My Requests", onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerRequestsView())); }),
              ],

              // ✅ NOTIFICATION INDICATOR RESTORED TO ORIGINAL BEIGE
              _menuItem(Icons.notifications_outlined, "Notifications", badge: _notificationCount > 0 ? _notificationCount.toString() : null, onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView())).then((_) => _fetchRealCounts());
              }),

              _menuItem(
  Icons.help_center_outlined, 
  "Help Center", 
  onTap: () {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => HelpView()),
    );
  }
),

              const Spacer(),

              InkWell(
                onTap: () {
                  final user = context.read<ProfileViewModel>().state.profile;
                  if (user == null) return;
                  Navigator.pop(context);
                  if (widget.isRiderMode) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeView()));
                  } else {
                    if (user.riderStatus == 'approved') { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RiderHomeView())); }
                    else if (user.riderStatus == 'pending') { Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmissionSuccessView())); }
                    else if (user.riderStatus == 'rejected') { Navigator.push(context, MaterialPageRoute(builder: (_) => RiderRejectedView(user: user))); }
                    else { Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider(create: (_) => serviceLocator<RiderKycViewModel>(), child: RiderVerificationView(currentUser: user)))); }
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: const Color(0xFFF9F5E9), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.swap_horiz, color: Color(0xFF5D4037)), const SizedBox(width: 10), Text(widget.isRiderMode ? "Switch to Passenger" : "Switch to Rider Mode", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF5D4037)))]))),
              
              const SizedBox(height: 20),
              
              TextButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text("Logout", style: GoogleFonts.inter(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {String? badge, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5D4037), size: 24),
            const SizedBox(width: 16),
            Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF1A1A1A))),
            const Spacer(),
            if (badge != null) 
              Container(
                width: 24, height: 24, 
                decoration: const BoxDecoration(color: Color(0xFFE8D5C4), shape: BoxShape.circle), 
                alignment: Alignment.center, 
                child: Text(badge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)))
              )
          ],
        ),
      ),
    );
  }
}