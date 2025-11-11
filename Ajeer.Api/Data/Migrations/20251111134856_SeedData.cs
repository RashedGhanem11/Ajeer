using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Ajeer.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class SeedData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "ServiceAreas",
                columns: new[] { "Id", "AreaName", "CityName" },
                values: new object[,]
                {
                    { -8, "Tla' Al-Ali", "Amman" },
                    { -7, "Al-Bayader", "Amman" },
                    { -6, "Al-Jubeiha", "Amman" },
                    { -5, "Dabouq", "Amman" },
                    { -4, "Al-Rabieh", "Amman" },
                    { -3, "Shmeisani", "Amman" },
                    { -2, "Jabal Al-Weibdeh", "Amman" },
                    { -1, "Abdoun", "Amman" }
                });

            migrationBuilder.InsertData(
                table: "ServiceCategories",
                columns: new[] { "Id", "Description", "IconUrl", "Name" },
                values: new object[,]
                {
                    { -9, "Home and office moving or furniture delivery.", "icons/moving.png", "Moving & Delivery" },
                    { -8, "Computer setup, repair, and software help.", "icons/it.png", "IT Support" },
                    { -7, "Lawn care, trimming, and garden design.", "icons/gardening.png", "Gardening" },
                    { -6, "Fixing washing machines, fridges, and ACs.", "icons/appliance.png", "Appliance Repair" },
                    { -5, "Wood furniture and door repair or installation.", "icons/carpentry.png", "Carpentry" },
                    { -4, "Interior and exterior wall painting.", "icons/painting.png", "Painting" },
                    { -3, "Home, office, and carpet cleaning.", "icons/cleaning.png", "Cleaning" },
                    { -2, "Electrical repairs, wiring, and installations.", "icons/electrical.png", "Electrical" },
                    { -1, "Leak repair, pipe installation, and maintenance.", "icons/plumbing.png", "Plumbing" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Email", "Name", "Password", "Phone", "ProfilePictureUrl", "Role" },
                values: new object[] { -3, "ali@example.com", "Ali Saleh", "hashed_password_3", "0793333333", null, (byte)1 });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Email", "Name", "Password", "Phone", "ProfilePictureUrl" },
                values: new object[] { -2, "sara@example.com", "Sara Ahmad", "hashed_password_2", "0792222222", null });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Email", "Name", "Password", "Phone", "ProfilePictureUrl", "Role" },
                values: new object[] { -1, "rashed@example.com", "Rashed Ghanem", "hashed_password_1", "0791111111", null, (byte)1 });

            migrationBuilder.InsertData(
                table: "Attachments",
                columns: new[] { "Id", "BookingId", "FileType", "FileUrl", "MimeType", "UploaderId" },
                values: new object[,]
                {
                    { -2, null, "IdCard", "uploads/idcards/3_Id.png", "Png", -3 },
                    { -1, null, "IdCard", "uploads/idcards/1_Id.png", "Png", -1 }
                });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "Id", "CreatedAt", "IsRead", "Message", "Title", "Type", "UserId" },
                values: new object[] { -2, new DateTime(2025, 11, 11, 3, 0, 0, 0, DateTimeKind.Unspecified), true, "Alice sent you a new message regarding Booking #-1.", "New Message", "Chat", -2 });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "Id", "CreatedAt", "Message", "Title", "Type", "UserId" },
                values: new object[] { -1, new DateTime(2025, 11, 11, 3, 30, 0, 0, DateTimeKind.Unspecified), "Your booking with Rashed Provider has been confirmed.", "Booking Accepted", "BookingAccepted", -2 });

            migrationBuilder.InsertData(
                table: "Services",
                columns: new[] { "Id", "BasePrice", "CategoryId", "EstimatedHours", "Name" },
                values: new object[,]
                {
                    { -23, 30m, -9, 2m, "Furniture Delivery" },
                    { -22, 100m, -9, 10m, "Office Relocation" },
                    { -21, 80m, -9, 8m, "Home Moving" },
                    { -20, 10m, -8, 1m, "Software Installation" },
                    { -19, 30m, -8, 3m, "Network Setup" },
                    { -18, 15m, -8, 1.5m, "Laptop Repair" },
                    { -17, 50m, -7, 5m, "Garden Design" },
                    { -16, 20m, -7, 2m, "Grass Cutting" },
                    { -15, 20m, -6, 2m, "Washing Machine Repair" },
                    { -14, 15m, -6, 1.5m, "Fridge Maintenance" },
                    { -13, 20m, -6, 2m, "AC Repair" },
                    { -12, 20m, -5, 2m, "Furniture Repair" },
                    { -11, 30m, -5, 3m, "Door Installation" },
                    { -10, 80m, -4, 8m, "Exterior Painting" },
                    { -9, 60m, -4, 6m, "Interior Painting" },
                    { -8, 20m, -3, 2m, "Carpet Cleaning" },
                    { -7, 30m, -3, 3m, "Office Cleaning" },
                    { -6, 40m, -3, 4m, "Home Deep Cleaning" },
                    { -5, 30m, -2, 2.5m, "Wiring Maintenance" },
                    { -4, 10m, -2, 1m, "Light Fixture Installation" },
                    { -3, 15m, -1, 2m, "Drain Cleaning" },
                    { -2, 25m, -1, 3m, "Pipe Installation" },
                    { -1, 10m, -1, 1.5m, "Leak Repair" }
                });

            migrationBuilder.InsertData(
                table: "ServiceProviders",
                columns: new[] { "UserId", "Bio", "IdCardAttachmentId", "Rating", "TotalReviews" },
                values: new object[] { -3, "Professional cleaning services, available weekends.", -2, 5m, 1 });

            migrationBuilder.InsertData(
                table: "ServiceProviders",
                columns: new[] { "UserId", "Bio", "IdCardAttachmentId", "IsVerified" },
                values: new object[] { -1, "Experienced plumber with 10 years in Riyadh.", -1, true });

            migrationBuilder.InsertData(
                table: "Bookings",
                columns: new[] { "Id", "Address", "CreatedAt", "EstimatedHours", "Latitude", "Longitude", "Notes", "ScheduledDate", "ServiceProviderId", "Status", "TotalAmount", "UserId" },
                values: new object[,]
                {
                    { -2, "Shmeisani, Amman", new DateTime(2025, 11, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), 4m, 31.9762m, 35.9105m, "Deep cleaning before guests arrive.", new DateTime(2025, 11, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), -3, "Completed", 40m, -2 },
                    { -1, "Abdoun, Amman", new DateTime(2025, 11, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 2m, 31.9539m, 35.9106m, "Water leaking under the sink.", new DateTime(2025, 11, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), -1, "Active", 25m, -2 }
                });

            migrationBuilder.InsertData(
                table: "Schedules",
                columns: new[] { "Id", "DayOfWeek", "EndTime", "ServiceProviderId", "StartTime" },
                values: new object[,]
                {
                    { -3, (byte)6, new TimeSpan(0, 18, 0, 0, 0), -3, new TimeSpan(0, 10, 0, 0, 0) },
                    { -2, (byte)2, new TimeSpan(0, 17, 0, 0, 0), -1, new TimeSpan(0, 9, 0, 0, 0) },
                    { -1, (byte)1, new TimeSpan(0, 17, 0, 0, 0), -1, new TimeSpan(0, 9, 0, 0, 0) }
                });

            migrationBuilder.InsertData(
                table: "Subscriptions",
                columns: new[] { "Id", "EndDate", "IsActive", "Price", "ServiceProviderId", "StartDate" },
                values: new object[,]
                {
                    { -2, new DateTime(2025, 12, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), true, 50m, -3, new DateTime(2025, 11, 6, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { -1, new DateTime(2025, 12, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, 50m, -1, new DateTime(2025, 11, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "BookingServiceItems",
                columns: new[] { "Id", "BookingId", "PriceAtBooking", "ServiceId" },
                values: new object[,]
                {
                    { -2, -2, 40m, -6 },
                    { -1, -1, 25m, -1 }
                });

            migrationBuilder.InsertData(
                table: "Messages",
                columns: new[] { "Id", "BookingId", "Content", "ReceiverId", "SenderId", "SentAt" },
                values: new object[] { -2, -1, "Yes, I'm confirmed for tomorrow at 10 AM.", -1, -2, new DateTime(2025, 11, 11, 3, 30, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.InsertData(
                table: "Messages",
                columns: new[] { "Id", "BookingId", "Content", "IsRead", "ReceiverId", "SenderId", "SentAt" },
                values: new object[] { -1, -1, "Hi Bob, can you confirm the scheduled date?", true, -2, -1, new DateTime(2025, 11, 11, 2, 30, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.InsertData(
                table: "Payments",
                columns: new[] { "Id", "Amount", "PaymentDate", "SubscriptionId" },
                values: new object[,]
                {
                    { -2, 50m, new DateTime(2025, 11, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), -2 },
                    { -1, 50m, new DateTime(2025, 11, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), -1 }
                });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "Id", "BookingId", "Comment", "Rating", "ReviewDate", "ServiceProviderId", "UserId" },
                values: new object[] { -1, -2, "Great cleaning service, very professional!", 5, new DateTime(2025, 11, 9, 0, 0, 0, 0, DateTimeKind.Unspecified), -3, -2 });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "BookingServiceItems",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "BookingServiceItems",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: -3);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "ServiceAreas",
                keyColumn: "Id",
                keyValue: -8);

            migrationBuilder.DeleteData(
                table: "ServiceAreas",
                keyColumn: "Id",
                keyValue: -7);

            migrationBuilder.DeleteData(
                table: "ServiceAreas",
                keyColumn: "Id",
                keyValue: -6);

            migrationBuilder.DeleteData(
                table: "ServiceAreas",
                keyColumn: "Id",
                keyValue: -5);

            migrationBuilder.DeleteData(
                table: "ServiceAreas",
                keyColumn: "Id",
                keyValue: -4);

            migrationBuilder.DeleteData(
                table: "ServiceAreas",
                keyColumn: "Id",
                keyValue: -3);

            migrationBuilder.DeleteData(
                table: "ServiceAreas",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "ServiceAreas",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -23);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -22);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -21);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -20);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -19);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -18);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -17);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -16);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -15);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -14);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -13);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -12);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -11);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -10);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -9);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -8);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -7);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -5);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -4);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -3);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "Bookings",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "Bookings",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -9);

            migrationBuilder.DeleteData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -8);

            migrationBuilder.DeleteData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -7);

            migrationBuilder.DeleteData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -6);

            migrationBuilder.DeleteData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -5);

            migrationBuilder.DeleteData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -4);

            migrationBuilder.DeleteData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -6);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "Subscriptions",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "Subscriptions",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -3);

            migrationBuilder.DeleteData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "ServiceProviders",
                keyColumn: "UserId",
                keyValue: -3);

            migrationBuilder.DeleteData(
                table: "ServiceProviders",
                keyColumn: "UserId",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "Attachments",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "Attachments",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -3);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -1);
        }
    }
}
