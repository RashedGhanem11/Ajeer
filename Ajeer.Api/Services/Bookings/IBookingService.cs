using Ajeer.Api.DTOs.Bookings;
using Ajeer.Api.Enums;

namespace Ajeer.Api.Services.Bookings;

public interface IBookingService
{
    Task<int> CreateBookingAsync(int userId, CreateBookingRequest dto);

    Task<List<BookingListResponse>> GetBookingsAsync(int userId, UserRole role);

    Task<BookingDetailResponse> GetBookingDetailsAsync(int userId, int bookingId);

    Task AcceptBookingAsync(int providerId, int bookingId);

    Task RejectBookingAsync(int providerId, int bookingId);

    Task CompleteBookingAsync(int providerId, int bookingId);

    Task CancelBookingAsync(int userId, int bookingId);
}