using Ajeer.Api.Enums;
using Ajeer.Api.Models;

namespace Ajeer.Api.Data;

public static class SeedData
{
    static string testPasswordHash = "$2b$10$3YEGSx9sDaSakYDcfrMBPuX0XWhe6yP0NXnyszsojsepfCOmzFnEe"; // Hashed value of "Password";

    public static List<User> GetUsers() => new()
    {
        new User
        {
            Id = -1,
            Name = "Rashed Ghanem",
            Email = "rashed@example.com",
            Phone = "0791111111",
            Password = testPasswordHash,
            Role = UserRole.ServiceProvider
        },
        new User
        {
            Id = -2,
            Name = "Sara Ahmad",
            Email = "sara@example.com",
            Phone = "0792222222",
            Password = testPasswordHash,
        },
        new User
        {
            Id = -3,
            Name = "Ali Saleh",
            Email = "ali@example.com",
            Phone = "0793333333",
            Password = testPasswordHash,
            Role = UserRole.ServiceProvider,
            ProfilePictureUrl = "ProfilePicture_-3.jpg"
        },
        new User
        {
            Id = -4,
            Name = "Hothifah Maen",
            Email = "hothifah@example.com",
            Phone = "0794444444",
            Password = testPasswordHash,
            Role = UserRole.ServiceProvider,
            IsActive = true,
        },
        new User
        {
            Id = -5,
            Name = "Saad Jbarah",
            Email = "saad@example.com",
            Phone = "0795555555",
            Password = testPasswordHash,
            Role = UserRole.ServiceProvider,
            IsActive = true,
        }
    };

    public static List<Models.ServiceProvider> GetServiceProviders() => new()
    {
        new Models.ServiceProvider
        {
            UserId = -1,
            Bio = "Experienced plumber with 10 years in Riyadh.",
            IsVerified = true
        },
        new Models.ServiceProvider
        {
            UserId = -3,
            Bio = "Professional cleaning services, available weekends.",
            Rating = 5,
            TotalReviews = 1
        }, new Models.ServiceProvider
        {
            UserId = -4,
            Bio = "Experienced plumber with 10 years in Cairo.",
            IsVerified = true
        },
        new Models.ServiceProvider
        {
            UserId = -5,
            Bio = "Experienced plumber with 10 years in Amman.",
            IsVerified = true
        }
    };

    public static List<Schedule> GetSchedules() => new()
    {
        new Schedule
        {
            Id = -1,
            ServiceProviderId = -1,
            DayOfWeek = DayOfWeek.Monday,
            StartTime = new TimeSpan(9, 0, 0),
            EndTime = new TimeSpan(17, 0, 0)
        },
        new Schedule
        {
            Id = -2,
            ServiceProviderId = -1,
            DayOfWeek = DayOfWeek.Tuesday,
            StartTime = new TimeSpan(9, 0, 0),
            EndTime = new TimeSpan(17, 0, 0)
        },
        new Schedule
        {
            Id = -3,
            ServiceProviderId = -3,
            DayOfWeek = DayOfWeek.Saturday,
            StartTime = new TimeSpan(10, 0, 0),
            EndTime = new TimeSpan(18, 0, 0)
        },
        new Schedule
        {
            Id = -4,
            ServiceProviderId = -4,
            DayOfWeek = DayOfWeek.Monday,
            StartTime = new TimeSpan(9, 0, 0),
            EndTime = new TimeSpan(17, 0, 0)
        },
        new Schedule
        {
            Id = -5,
            ServiceProviderId = -4,
            DayOfWeek = DayOfWeek.Tuesday,
            StartTime = new TimeSpan(9, 0, 0),
            EndTime = new TimeSpan(17, 0, 0)
        },
        new Schedule
        {
            Id = -6,
            ServiceProviderId = -5,
            DayOfWeek = DayOfWeek.Monday,
            StartTime = new TimeSpan(9, 0, 0),
            EndTime = new TimeSpan(17, 0, 0)
        },
        new Schedule
        {
            Id = -7,
            ServiceProviderId = -5,
            DayOfWeek = DayOfWeek.Tuesday,
            StartTime = new TimeSpan(9, 0, 0),
            EndTime = new TimeSpan(17, 0, 0)
        },
    };

    public static List<Message> GetMessages()
    {
        return new List<Message>
        {
            new Message
            {
                Id = -1,
                BookingId = -1,
                SenderId = -1,
                ReceiverId = -2,
                Content = "Hi Bob, can you confirm the scheduled date?",
                SentAt = new DateTime(2025, 11, 11, 2, 30, 0),
                IsRead = true
            },
            new Message
            {
                Id = -2,
                BookingId = -1,
                SenderId = -2,
                ReceiverId = -1,
                Content = "Yes, I'm confirmed for tomorrow at 10 AM.",
                SentAt = new DateTime(2025, 11, 11, 3, 30, 0),
                IsRead = false
            }
        };
    }

    public static List<Notification> GetNotifications()
    {
        return new List<Notification>
        {
            new Notification
            {
                Id = -1,
                UserId = -2,
                Title = "Booking Accepted",
                Type = NotificationType.BookingAccepted,
                Message = "Your booking with Rashed Provider has been confirmed.",
                CreatedAt = new DateTime(2025, 11, 11, 3, 30, 0),
                IsRead = false
            },
            new Notification
            {
                Id = -2,
                UserId = -2,
                Title = "New Message",
                Type = NotificationType.Chat,
                Message = "Alice sent you a new message regarding Booking #-1.",
                CreatedAt = new DateTime(2025, 11, 11, 3, 0, 0),
                IsRead = true
            }
        };
    }

    public static List<ServiceCategory> GetServiceCategories() => new()
    {
        new ServiceCategory { Id = -1, Name = "Plumbing", Description = "Leak repair, pipe installation, and maintenance.", IconUrl = "plumbing.png" },
        new ServiceCategory { Id = -2, Name = "Electrical", Description = "Electrical repairs, wiring, and installations.", IconUrl = "electrical.png" },
        new ServiceCategory { Id = -3, Name = "Cleaning", Description = "Home, office, and carpet cleaning.", IconUrl = "cleaning.png" },
        new ServiceCategory { Id = -4, Name = "Painting", Description = "Interior and exterior wall painting.", IconUrl = "painting.png" },
        new ServiceCategory { Id = -5, Name = "Carpentry", Description = "Wood furniture and door repair or installation.", IconUrl = "carpentry.png" },
        new ServiceCategory { Id = -6, Name = "Appliance Repair", Description = "Fixing washing machines, fridges, and ACs.", IconUrl = "appliance_repair.png" },
        new ServiceCategory { Id = -7, Name = "Gardening", Description = "Lawn care, trimming, and garden design.", IconUrl = "gardening.png" },
        new ServiceCategory { Id = -8, Name = "IT Support", Description = "Computer setup, repair, and software help.", IconUrl = "it_support.png" },
        new ServiceCategory { Id = -9, Name = "Moving & Delivery", Description = "Home and office moving or furniture delivery.", IconUrl = "moving_and_delivery.png" }
    };

    public static List<Service> GetServices() => new()
    {
        new Service { Id = -1, CategoryId = -1, Name = "Leak Repair", BasePrice = 10, EstimatedHours = 1.5m },
        new Service { Id = -2, CategoryId = -1, Name = "Pipe Installation", BasePrice = 25, EstimatedHours = 3 },
        new Service { Id = -3, CategoryId = -1, Name = "Drain Cleaning", BasePrice = 15, EstimatedHours = 2 },

        new Service { Id = -4, CategoryId = -2, Name = "Light Fixture Installation", BasePrice = 10, EstimatedHours = 1 },
        new Service { Id = -5, CategoryId = -2, Name = "Wiring Maintenance", BasePrice = 30, EstimatedHours = 2.5m },

        new Service { Id = -6, CategoryId = -3, Name = "Home Deep Cleaning", BasePrice = 40, EstimatedHours = 4 },
        new Service { Id = -7, CategoryId = -3, Name = "Office Cleaning", BasePrice = 30, EstimatedHours = 3 },
        new Service { Id = -8, CategoryId = -3, Name = "Carpet Cleaning", BasePrice = 20, EstimatedHours = 2 },

        new Service { Id = -9, CategoryId = -4, Name = "Interior Painting", BasePrice = 60, EstimatedHours = 6 },
        new Service { Id = -10, CategoryId = -4, Name = "Exterior Painting", BasePrice = 80, EstimatedHours = 8 },

        new Service { Id = -11, CategoryId = -5, Name = "Door Installation", BasePrice = 30, EstimatedHours = 3 },
        new Service { Id = -12, CategoryId = -5, Name = "Furniture Repair", BasePrice = 20, EstimatedHours = 2 },

        new Service { Id = -13, CategoryId = -6, Name = "AC Repair", BasePrice = 20, EstimatedHours = 2 },
        new Service { Id = -14, CategoryId = -6, Name = "Fridge Maintenance", BasePrice = 15, EstimatedHours = 1.5m },
        new Service { Id = -15, CategoryId = -6, Name = "Washing Machine Repair", BasePrice = 20, EstimatedHours = 2 },

        new Service { Id = -16, CategoryId = -7, Name = "Grass Cutting", BasePrice = 20, EstimatedHours = 2 },
        new Service { Id = -17, CategoryId = -7, Name = "Garden Design", BasePrice = 50, EstimatedHours = 5 },

        new Service { Id = -18, CategoryId = -8, Name = "Laptop Repair", BasePrice = 15, EstimatedHours = 1.5m },
        new Service { Id = -19, CategoryId = -8, Name = "Network Setup", BasePrice = 30, EstimatedHours = 3 },
        new Service { Id = -20, CategoryId = -8, Name = "Software Installation", BasePrice = 10, EstimatedHours = 1 },

        new Service { Id = -21, CategoryId = -9, Name = "Home Moving", BasePrice = 80, EstimatedHours = 8 },
        new Service { Id = -22, CategoryId = -9, Name = "Office Relocation", BasePrice = 100, EstimatedHours = 10 },
        new Service { Id = -23, CategoryId = -9, Name = "Furniture Delivery", BasePrice = 30, EstimatedHours = 2 }
    };

    public static List<ServiceArea> GetServiceAreas() => new()
    {
        new ServiceArea { Id = -1, AreaName = "Abdoun", CityName = "Amman" },
        new ServiceArea { Id = -2, AreaName = "Jabal Al-Weibdeh", CityName = "Amman" },
        new ServiceArea { Id = -3, AreaName = "Shmeisani", CityName = "Amman" },
        new ServiceArea { Id = -4, AreaName = "Al-Rabieh", CityName = "Amman" },
        new ServiceArea { Id = -5, AreaName = "Dabouq", CityName = "Amman" },
        new ServiceArea { Id = -6, AreaName = "Al-Jubeiha", CityName = "Amman" },
        new ServiceArea { Id = -7, AreaName = "Al-Bayader", CityName = "Amman" },
        new ServiceArea { Id = -8, AreaName = "Tla' Al-Ali", CityName = "Amman" }
    };

    public static List<ProviderService> GetProviderServices() => new()
    {
        new ProviderService { ServiceProviderId = -1, ServiceId = -1 },
        new ProviderService { ServiceProviderId = -1, ServiceId = -2 },
        new ProviderService { ServiceProviderId = -1, ServiceId = -3 },
        new ProviderService { ServiceProviderId = -3, ServiceId = -6 },
        new ProviderService { ServiceProviderId = -3, ServiceId = -7 },
        new ProviderService { ServiceProviderId = -3, ServiceId = -8 },
        new ProviderService { ServiceProviderId = -4, ServiceId = -1 },
        new ProviderService { ServiceProviderId = -4, ServiceId = -2 },
        new ProviderService { ServiceProviderId = -4, ServiceId = -3 },
        new ProviderService { ServiceProviderId = -5, ServiceId = -1 },
        new ProviderService { ServiceProviderId = -5, ServiceId = -2 },
        new ProviderService { ServiceProviderId = -5, ServiceId = -3 },
    };

    public static List<ProviderServiceArea> GetProviderServiceAreas() => new()
    {
        new ProviderServiceArea { ServiceProviderId = -1, ServiceAreaId = -1 },
        new ProviderServiceArea { ServiceProviderId = -1, ServiceAreaId = -2 },
        new ProviderServiceArea { ServiceProviderId = -3, ServiceAreaId = -4 },
        new ProviderServiceArea { ServiceProviderId = -3, ServiceAreaId = -5 },
        new ProviderServiceArea { ServiceProviderId = -4, ServiceAreaId = -1 },
        new ProviderServiceArea { ServiceProviderId = -4, ServiceAreaId = -2 },
        new ProviderServiceArea { ServiceProviderId = -5, ServiceAreaId = -1 },
        new ProviderServiceArea { ServiceProviderId = -5, ServiceAreaId = -2 },
    };

    public static List<Attachment> GetAttachments() => new()
    {
        new Attachment
        {
            Id = -1,
            FileUrl = "7c5c6692-c684-486a-a41f-eb5ad0ffcda7_test-image",
            MimeType = MimeType.Jpeg,
            FileType = FileType.Image,
            UploaderId = -2,
            BookingId = -1
        }
    };

    public static List<Booking> GetBookings() => new()
    {
        new Booking
        {
            Id = -1,
            UserId = -2,
            ServiceProviderId = -1,
            ServiceAreaId = -1,
            Status = BookingStatus.Active,
            ScheduledDate = new DateTime(2025, 11, 12),
            EstimatedHours = 2,
            TotalAmount = 25,
            Address = "Abdoun, Amman",
            Latitude = 31.9539m,
            Longitude = 35.9106m,
            Notes = "Water leaking under the sink.",
            CreatedAt = new DateTime(2025, 11, 10)
        },
        new Booking
        {
            Id = -2,
            UserId = -2,
            ServiceProviderId = -3,
            ServiceAreaId = -5,
            Status = BookingStatus.Completed,
            ScheduledDate = new DateTime(2025, 11, 8),
            EstimatedHours = 4,
            TotalAmount = 40,
            Address = "Dabouq, Amman",
            Latitude = 31.9762m,
            Longitude = 35.9105m,
            Notes = "Deep cleaning before guests arrive.",
            CreatedAt = new DateTime(2025, 11, 6)
        }
    };

    public static List<BookingServiceItem> GetBookingServiceItems() => new()
    {
        new BookingServiceItem
        {
            Id = -1,
            BookingId = -1,
            ServiceId = -1,
            PriceAtBooking = 25
        },
        new BookingServiceItem
        {
            Id = -2,
            BookingId = -2,
            ServiceId = -6,
            PriceAtBooking = 40
        }
    };

    public static List<Review> GetReviews() => new()
    {
        new Review
        {
            Id = -1,
            BookingId = -2,
            UserId = -2,
            ServiceProviderId = -3,
            Rating = 5,
            Comment = "Great cleaning service, very professional!",
            ReviewDate = new DateTime(2025, 11, 9)
        }
    };

    public static List<Payment> GetPayments() => new()
    {
        new Payment
        {
            Id = -1,
            SubscriptionId = -1,
            Amount = 50,
            PaymentDate = new DateTime(2025, 11, 1)
        },
        new Payment
        {
            Id = -2,
            SubscriptionId = -2,
            Amount = 50,
            PaymentDate = new DateTime(2025, 11, 6)
        }
    };

    public static List<Subscription> GetSubscriptions() => new()
    {
        new Subscription
        {
            Id = -1,
            ServiceProviderId = -1,
            Price = 50,
            StartDate = new DateTime(2025, 11, 1),
            EndDate = new DateTime(2025, 12, 1),
            IsActive = true
        },
        new Subscription
        {
            Id = -2,
            ServiceProviderId = -3,
            Price = 50,
            StartDate = new DateTime(2025, 11, 6),
            EndDate = new DateTime(2025, 12, 6),
            IsActive = true
        }
    };
}