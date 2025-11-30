using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Ajeer.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class InitialSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ServiceAreas",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AreaName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    CityName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceAreas", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ServiceCategories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: false),
                    IconUrl = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceCategories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Phone = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Password = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Role = table.Column<byte>(type: "tinyint", nullable: false, defaultValueSql: "0"),
                    ProfilePictureUrl = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: true),
                    LastLoginAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Services",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CategoryId = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    BasePrice = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    EstimatedHours = table.Column<decimal>(type: "decimal(5,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Services", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Services_ServiceCategories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "ServiceCategories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Type = table.Column<string>(type: "nvarchar(50)", nullable: false),
                    Message = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    IsRead = table.Column<bool>(type: "bit", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notifications", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Notifications_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Attachments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BookingId = table.Column<int>(type: "int", nullable: true),
                    UploaderId = table.Column<int>(type: "int", nullable: false),
                    FileUrl = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: false),
                    MimeType = table.Column<string>(type: "nvarchar(50)", nullable: false),
                    FileType = table.Column<string>(type: "nvarchar(50)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Attachments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Attachments_Users_UploaderId",
                        column: x => x.UploaderId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ServiceProviders",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    IdCardAttachmentId = table.Column<int>(type: "int", nullable: true),
                    Bio = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Rating = table.Column<decimal>(type: "decimal(3,2)", nullable: false, defaultValue: 0m),
                    TotalReviews = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    IsVerified = table.Column<bool>(type: "bit", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceProviders", x => x.UserId);
                    table.ForeignKey(
                        name: "FK_ServiceProviders_Attachments_IdCardAttachmentId",
                        column: x => x.IdCardAttachmentId,
                        principalTable: "Attachments",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ServiceProviders_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Bookings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ServiceProviderId = table.Column<int>(type: "int", nullable: false),
                    ServiceAreaId = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    ScheduledDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EstimatedHours = table.Column<decimal>(type: "decimal(5,2)", nullable: false),
                    TotalAmount = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    Address = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: false),
                    Latitude = table.Column<decimal>(type: "decimal(10,8)", nullable: false),
                    Longitude = table.Column<decimal>(type: "decimal(11,8)", nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Bookings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Bookings_ServiceAreas_ServiceAreaId",
                        column: x => x.ServiceAreaId,
                        principalTable: "ServiceAreas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Bookings_ServiceProviders_ServiceProviderId",
                        column: x => x.ServiceProviderId,
                        principalTable: "ServiceProviders",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Bookings_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ProviderServiceAreas",
                columns: table => new
                {
                    ServiceProviderId = table.Column<int>(type: "int", nullable: false),
                    ServiceAreaId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProviderServiceAreas", x => new { x.ServiceProviderId, x.ServiceAreaId });
                    table.ForeignKey(
                        name: "FK_ProviderServiceAreas_ServiceAreas_ServiceAreaId",
                        column: x => x.ServiceAreaId,
                        principalTable: "ServiceAreas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ProviderServiceAreas_ServiceProviders_ServiceProviderId",
                        column: x => x.ServiceProviderId,
                        principalTable: "ServiceProviders",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ProviderServices",
                columns: table => new
                {
                    ServiceProviderId = table.Column<int>(type: "int", nullable: false),
                    ServiceId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProviderServices", x => new { x.ServiceProviderId, x.ServiceId });
                    table.ForeignKey(
                        name: "FK_ProviderServices_ServiceProviders_ServiceProviderId",
                        column: x => x.ServiceProviderId,
                        principalTable: "ServiceProviders",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ProviderServices_Services_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "Services",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Schedules",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceProviderId = table.Column<int>(type: "int", nullable: false),
                    DayOfWeek = table.Column<byte>(type: "tinyint", nullable: false),
                    StartTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    EndTime = table.Column<TimeSpan>(type: "time", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Schedules", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Schedules_ServiceProviders_ServiceProviderId",
                        column: x => x.ServiceProviderId,
                        principalTable: "ServiceProviders",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Subscriptions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceProviderId = table.Column<int>(type: "int", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Subscriptions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Subscriptions_ServiceProviders_ServiceProviderId",
                        column: x => x.ServiceProviderId,
                        principalTable: "ServiceProviders",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "BookingServiceItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    BookingId = table.Column<int>(type: "int", nullable: false),
                    PriceAtBooking = table.Column<decimal>(type: "decimal(10,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BookingServiceItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BookingServiceItems_Bookings_BookingId",
                        column: x => x.BookingId,
                        principalTable: "Bookings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_BookingServiceItems_Services_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "Services",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Messages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BookingId = table.Column<int>(type: "int", nullable: false),
                    SenderId = table.Column<int>(type: "int", nullable: false),
                    ReceiverId = table.Column<int>(type: "int", nullable: false),
                    Content = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    SentAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    IsRead = table.Column<bool>(type: "bit", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Messages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Messages_Bookings_BookingId",
                        column: x => x.BookingId,
                        principalTable: "Bookings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Messages_Users_ReceiverId",
                        column: x => x.ReceiverId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Messages_Users_SenderId",
                        column: x => x.SenderId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BookingId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ServiceProviderId = table.Column<int>(type: "int", nullable: false),
                    Rating = table.Column<int>(type: "int", nullable: false),
                    Comment = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    ReviewDate = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reviews", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reviews_Bookings_BookingId",
                        column: x => x.BookingId,
                        principalTable: "Bookings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Reviews_ServiceProviders_ServiceProviderId",
                        column: x => x.ServiceProviderId,
                        principalTable: "ServiceProviders",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Reviews_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Payments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SubscriptionId = table.Column<int>(type: "int", nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    PaymentDate = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Payments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Payments_Subscriptions_SubscriptionId",
                        column: x => x.SubscriptionId,
                        principalTable: "Subscriptions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

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
                    { -9, "Home and office moving or furniture delivery.", "moving_and_delivery.png", "Moving & Delivery" },
                    { -8, "Computer setup, repair, and software help.", "it_support.png", "IT Support" },
                    { -7, "Lawn care, trimming, and garden design.", "gardening.png", "Gardening" },
                    { -6, "Fixing washing machines, fridges, and ACs.", "appliance_repair.png", "Appliance Repair" },
                    { -5, "Wood furniture and door repair or installation.", "carpentry.png", "Carpentry" },
                    { -4, "Interior and exterior wall painting.", "painting.png", "Painting" },
                    { -3, "Home, office, and carpet cleaning.", "cleaning.png", "Cleaning" },
                    { -2, "Electrical repairs, wiring, and installations.", "electrical.png", "Electrical" },
                    { -1, "Leak repair, pipe installation, and maintenance.", "plumbing.png", "Plumbing" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Email", "IsActive", "Name", "Password", "Phone", "ProfilePictureUrl", "Role" },
                values: new object[] { -3, "ali@example.com", true, "Ali Saleh", "$2b$10$3YEGSx9sDaSakYDcfrMBPuX0XWhe6yP0NXnyszsojsepfCOmzFnEe", "0793333333", "ProfilePicture_-3.jpg", (byte)1 });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Email", "IsActive", "Name", "Password", "Phone", "ProfilePictureUrl" },
                values: new object[] { -2, "sara@example.com", true, "Sara Ahmad", "$2b$10$3YEGSx9sDaSakYDcfrMBPuX0XWhe6yP0NXnyszsojsepfCOmzFnEe", "0792222222", null });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Email", "IsActive", "Name", "Password", "Phone", "ProfilePictureUrl", "Role" },
                values: new object[] { -1, "rashed@example.com", true, "Rashed Ghanem", "$2b$10$3YEGSx9sDaSakYDcfrMBPuX0XWhe6yP0NXnyszsojsepfCOmzFnEe", "0791111111", null, (byte)1 });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "Id", "CreatedAt", "IsRead", "Message", "Title", "Type", "UserId" },
                values: new object[] { -2, new DateTime(2025, 11, 11, 3, 0, 0, 0, DateTimeKind.Unspecified), true, "Alice sent you a new message regarding Booking #-1.", "New Message", "Chat", -2 });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "Id", "CreatedAt", "Message", "Title", "Type", "UserId" },
                values: new object[] { -1, new DateTime(2025, 11, 11, 3, 30, 0, 0, DateTimeKind.Unspecified), "Your booking with Rashed Provider has been confirmed.", "Booking Accepted", "BookingAccepted", -2 });

            migrationBuilder.InsertData(
                table: "ServiceProviders",
                columns: new[] { "UserId", "Bio", "IdCardAttachmentId", "Rating", "TotalReviews" },
                values: new object[] { -3, "Professional cleaning services, available weekends.", null, 5m, 1 });

            migrationBuilder.InsertData(
                table: "ServiceProviders",
                columns: new[] { "UserId", "Bio", "IdCardAttachmentId", "IsVerified" },
                values: new object[] { -1, "Experienced plumber with 10 years in Riyadh.", null, true });

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
                table: "Bookings",
                columns: new[] { "Id", "Address", "CreatedAt", "EstimatedHours", "Latitude", "Longitude", "Notes", "ScheduledDate", "ServiceAreaId", "ServiceProviderId", "Status", "TotalAmount", "UserId" },
                values: new object[,]
                {
                    { -2, "Dabouq, Amman", new DateTime(2025, 11, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), 4m, 31.9762m, 35.9105m, "Deep cleaning before guests arrive.", new DateTime(2025, 11, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), -5, -3, "Completed", 40m, -2 },
                    { -1, "Abdoun, Amman", new DateTime(2025, 11, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 2m, 31.9539m, 35.9106m, "Water leaking under the sink.", new DateTime(2025, 11, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), -1, -1, "Active", 25m, -2 }
                });

            migrationBuilder.InsertData(
                table: "ProviderServiceAreas",
                columns: new[] { "ServiceAreaId", "ServiceProviderId" },
                values: new object[,]
                {
                    { -5, -3 },
                    { -4, -3 },
                    { -2, -1 },
                    { -1, -1 }
                });

            migrationBuilder.InsertData(
                table: "ProviderServices",
                columns: new[] { "ServiceId", "ServiceProviderId" },
                values: new object[,]
                {
                    { -8, -3 },
                    { -7, -3 },
                    { -6, -3 },
                    { -3, -1 },
                    { -2, -1 },
                    { -1, -1 }
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
                table: "Attachments",
                columns: new[] { "Id", "BookingId", "FileType", "FileUrl", "MimeType", "UploaderId" },
                values: new object[] { -1, -1, "Image", "7c5c6692-c684-486a-a41f-eb5ad0ffcda7_test-image", "Jpeg", -2 });

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

            migrationBuilder.CreateIndex(
                name: "IX_Attachments_BookingId",
                table: "Attachments",
                column: "BookingId");

            migrationBuilder.CreateIndex(
                name: "IX_Attachments_UploaderId",
                table: "Attachments",
                column: "UploaderId");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_ServiceAreaId",
                table: "Bookings",
                column: "ServiceAreaId");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_ServiceProviderId",
                table: "Bookings",
                column: "ServiceProviderId");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_UserId",
                table: "Bookings",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_BookingServiceItems_BookingId",
                table: "BookingServiceItems",
                column: "BookingId");

            migrationBuilder.CreateIndex(
                name: "IX_BookingServiceItems_ServiceId",
                table: "BookingServiceItems",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_BookingId",
                table: "Messages",
                column: "BookingId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_ReceiverId",
                table: "Messages",
                column: "ReceiverId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_SenderId",
                table: "Messages",
                column: "SenderId");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_UserId",
                table: "Notifications",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_SubscriptionId",
                table: "Payments",
                column: "SubscriptionId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ProviderServiceAreas_ServiceAreaId",
                table: "ProviderServiceAreas",
                column: "ServiceAreaId");

            migrationBuilder.CreateIndex(
                name: "IX_ProviderServices_ServiceId",
                table: "ProviderServices",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_BookingId",
                table: "Reviews",
                column: "BookingId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_ServiceProviderId",
                table: "Reviews",
                column: "ServiceProviderId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId",
                table: "Reviews",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Schedules_ServiceProviderId",
                table: "Schedules",
                column: "ServiceProviderId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceProviders_IdCardAttachmentId",
                table: "ServiceProviders",
                column: "IdCardAttachmentId",
                unique: true,
                filter: "[IdCardAttachmentId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Services_CategoryId",
                table: "Services",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_Subscriptions_ServiceProviderId",
                table: "Subscriptions",
                column: "ServiceProviderId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_Phone",
                table: "Users",
                column: "Phone",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Attachments_Bookings_BookingId",
                table: "Attachments",
                column: "BookingId",
                principalTable: "Bookings",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Attachments_Bookings_BookingId",
                table: "Attachments");

            migrationBuilder.DropTable(
                name: "BookingServiceItems");

            migrationBuilder.DropTable(
                name: "Messages");

            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DropTable(
                name: "Payments");

            migrationBuilder.DropTable(
                name: "ProviderServiceAreas");

            migrationBuilder.DropTable(
                name: "ProviderServices");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "Schedules");

            migrationBuilder.DropTable(
                name: "Subscriptions");

            migrationBuilder.DropTable(
                name: "Services");

            migrationBuilder.DropTable(
                name: "ServiceCategories");

            migrationBuilder.DropTable(
                name: "Bookings");

            migrationBuilder.DropTable(
                name: "ServiceAreas");

            migrationBuilder.DropTable(
                name: "ServiceProviders");

            migrationBuilder.DropTable(
                name: "Attachments");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
