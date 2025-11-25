using Ajeer.Api.DTOs.Bookings;

namespace Ajeer.Api.Services.Bookings;

public interface IBookingService
{
    Task<int> CreateBookingAsync(int userId, CreateBookingRequest dto);
}