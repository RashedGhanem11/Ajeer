using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Reviews;
using Ajeer.Api.Enums;
using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.Reviews;

public class ReviewService(AppDbContext _context) : IReviewService
{
    public async Task AddReviewAsync(int userId, CreateReviewRequest dto)
    {
        var booking = await _context.Bookings
            .Include(b => b.Review)
            .Include(b => b.ServiceProvider)
            .FirstOrDefaultAsync(b => b.Id == dto.BookingId);

        if (booking == null)
            throw new Exception("Booking not found.");

        if (booking.UserId != userId)
            throw new Exception("You are not authorized to review this booking.");

        if (booking.Status != BookingStatus.Completed)
            throw new Exception("You can only review completed bookings.");

        if (booking.Review != null)
            throw new Exception("You have already reviewed this booking.");

        var review = new Review
        {
            BookingId = booking.Id,
            UserId = userId,
            ServiceProviderId = booking.ServiceProviderId,
            Rating = dto.Rating,
            Comment = dto.Comment,
            ReviewDate = DateTime.Now
        };

        _context.Reviews.Add(review);

        var provider = booking.ServiceProvider;

        // ((OldRating * OldCount) + NewRating) / (OldCount + 1)
        decimal currentTotalScore = provider.Rating * provider.TotalReviews;
        decimal newTotalScore = currentTotalScore + dto.Rating;
        int newCount = provider.TotalReviews + 1;

        provider.TotalReviews = newCount;
        provider.Rating = newTotalScore / newCount;

        await _context.SaveChangesAsync();
    }
}