import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpView extends StatefulWidget {
  const HelpView({super.key});

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Theme Colors
  final Color primaryBrown = const Color(0xFF8B4513);
  final Color accentBeige = const Color(0xFFF9F5E9);
  final Color textDark = const Color(0xFF2D2D2D);
  final Color greyLight = const Color(0xFFF5F5F5);

  // Updated Helper to open Video Links using external application mode
  Future<void> _launchTutorial() async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=jfQ6Nt9HBNo'); // Replace with your actual video ID/URL
    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("Could not launch $url: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryBrown, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "Help & Support",
          style: GoogleFonts.inter(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildVideoTutorialCard(),
                const SizedBox(height: 30),
                _buildSectionTitle("App Journey Guide"),
                const SizedBox(height: 15),
                _buildHelpItems(),
                const SizedBox(height: 30),
                _buildContactCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBrown.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
          decoration: InputDecoration(
            hintText: "Search for 'Smart Match' or 'KYC'...",
            hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: primaryBrown),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoTutorialCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryBrown,
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          // Using your local asset image here
          image: const AssetImage('assets/images/tripmate_thumbnail.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            primaryBrown.withOpacity(0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "NEW TUTORIAL",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "How TripMate Works?",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Watch this 2-minute guide to master\nPassenger and Rider modes.",
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _launchTutorial,
              icon: const Icon(Icons.play_circle_fill, size: 24),
              label: const Text("Watch Now"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
    );
  }

  Widget _buildHelpItems() {
    final List<Map<String, dynamic>> helpData = [
      {
        "category": "1. Account & Modes",
        "icon": Icons.person_outline,
        "items": [
          {
            "q": "What is Dual-Mode functionality?",
            "a": "TripMate allows every user to act as both a Passenger and a Rider. You can switch modes instantly via the Sidebar. By default, everyone starts as a Passenger."
          },
          {
            "q": "Session Management",
            "a": "Once logged in, your session is maintained. You don't need to log in again even after closing the app until you manually logout."
          },
        ]
      },
      {
        "category": "2. Passenger Experience",
        "icon": Icons.location_on_outlined,
        "items": [
          {
            "q": "Detour Match Explained",
            "a": "The rider detours up to 500m to pick you up and drop you off exactly at your door. No walking required."
          },
          {
            "q": "Smart Match Explained",
            "a": "Rider and Passenger share the effort. Total radius is 1000m (500m Rider detour + 500m Passenger walk). You meet at a calculated meeting point."
          },
          {
            "q": "Map Visuals",
            "a": "Polylines (route lines) only appear after a ride is accepted to keep the search screen clean. Brown dotted lines represent your walking path in Smart Match."
          },
        ]
      },
      {
        "category": "3. Rider Verification",
        "icon": Icons.verified_user_outlined,
        "items": [
          {
            "q": "How to verify my account?",
            "a": "Switch to Rider mode and upload your License, Bluebook (Billbook), and vehicle photos. Admin verifies these within 24 hours."
          },
          {
            "q": "What if my KYC is rejected?",
            "a": "You will receive a notification with the reason. You can re-edit your details and resubmit for verification immediately."
          },
        ]
      },
      {
        "category": "4. Payments & Real-time Flow",
        "icon": Icons.sync_alt,
        "items": [
          {
            "q": "Payment Synchronization",
            "a": "We use WebSockets for real-time payment updates. Whether it's Cash or eSewa, the rider and passenger screens update simultaneously."
          },
          {
            "q": "Cancellations",
            "a": "You can cancel a ride if needed. Note that frequent cancellations after a ride is 'Booked' may impact community trust."
          },
        ]
      }
    ];

    return Column(
      children: helpData.map((section) {
        var filteredItems = section['items'].where((item) =>
            item['q']!.toLowerCase().contains(_searchQuery) ||
            item['a']!.toLowerCase().contains(_searchQuery)).toList();

        if (filteredItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(section['icon'], size: 18, color: primaryBrown),
                  const SizedBox(width: 10),
                  Text(
                    section['category'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryBrown,
                    ),
                  ),
                ],
              ),
            ),
            ...filteredItems.map<Widget>((item) => _buildExpandableCard(item['q']!, item['a']!)).toList(),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildExpandableCard(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: primaryBrown,
          collapsedIconColor: Colors.grey,
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: accentBeige,
            radius: 25,
            child: Icon(Icons.headset_mic_rounded, color: primaryBrown),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Still have questions?",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Our support team is online 24/7.",
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Action for support contact
            },
            child: Text(
              "Contact",
              style: GoogleFonts.inter(
                color: primaryBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}