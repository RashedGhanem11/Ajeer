class CreateReviewRequest {
  final int bookingId;
  final int rating;
  final String? comment;

  CreateReviewRequest({
    required this.bookingId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {'BookingId': bookingId, 'Rating': rating, 'Comment': comment};
  }
}

class ReviewResult {
  final bool success;
  final String message;

  ReviewResult({required this.success, required this.message});
}

// Added to handle fetching existing reviews
class ReviewResponse {
  final int rating;
  final String comment;

  ReviewResponse({required this.rating, required this.comment});

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      rating: json['rating'] ?? 5, // Default to 5 if missing
      comment: json['comment'] ?? '', // Default to empty string
    );
  }
}
