import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/common/snackbar/my_snack_bar.dart'; // ✅ Added import
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';

class RatingFeedbackView extends StatefulWidget {
  final String rideId;
  final String targetRole; 

  const RatingFeedbackView({super.key, required this.rideId, required this.targetRole});

  @override
  State<RatingFeedbackView> createState() => _RatingFeedbackViewState();
}

class _RatingFeedbackViewState extends State<RatingFeedbackView> {
  double _rating = 0;
  bool _isSubmitting = false;
  final List<String> _selectedTags = [];
  final List<String> _availableTags = ["Friendly", "Safe", "Clean", "On Time"];

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _submit(bool isSkipped) async {
    // ✅ Custom SnackBar for validation
    if (!isSkipped && _rating == 0) {
      showMySnackBar(
        context: context, 
        message: "Please select stars or click Skip", 
        isError: true
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (!isSkipped) {
        await serviceLocator<RideRemoteDataSource>().submitFeedback(
          rideId: widget.rideId,
          rating: _rating,
          tags: _selectedTags,
          targetRole: widget.targetRole,
        );
      }

      if (mounted) {
        // ✅ Success SnackBar
        showMySnackBar(
          context: context, 
          message: isSkipped ? "Feedback skipped" : "Thank you for your feedback!"
        );
        
        // Return to Home Screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        // ✅ Error SnackBar
        showMySnackBar(
          context: context, 
          message: "Submission failed: $e", 
          isError: true
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Rate Your Experience",
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "How was the ride?",
                style: GoogleFonts.inter(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Star Rating
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _rating = index + 1.0),
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: index < _rating ? Colors.orange : Colors.grey[300],
                        size: 45,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 25),

              // Tags Selection
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _availableTags.map((tag) {
                  bool isSelected = _selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => _toggleTag(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF6D3F1E) : const Color(0xFFFDF7F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submit(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          "Submit Feedback",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              // Skip Button
              TextButton(
                onPressed: _isSubmitting ? null : () => _submit(true),
                child: Text(
                  "Skip",
                  style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}