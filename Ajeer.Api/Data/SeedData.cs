using Ajeer.Api.Enums;
using Ajeer.Api.Models;

namespace Ajeer.Api.Data;

public static class SeedData
{
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

    public static List<SubscriptionPlan> GetSubscriptionPlans() => new()
    {
        new SubscriptionPlan
        {
            Id = -1,
            Name = "1 Month Plan",
            Price = 20.00m,
            DurationInDays = 30
        },
        new SubscriptionPlan
        {
            Id = -2,
            Name = "3 Month Plan",
            Price = 50.00m,
            DurationInDays = 90
        }
    };
}