using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Ajeer.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddNewProviders : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Email", "IsActive", "Name", "Password", "Phone", "ProfilePictureUrl", "Role" },
                values: new object[,]
                {
                    { -5, "saad@example.com", true, "Saad Jbarah", "$2b$10$3YEGSx9sDaSakYDcfrMBPuX0XWhe6yP0NXnyszsojsepfCOmzFnEe", "0795555555", null, (byte)1 },
                    { -4, "hothifah@example.com", true, "Hothifah Maen", "$2b$10$3YEGSx9sDaSakYDcfrMBPuX0XWhe6yP0NXnyszsojsepfCOmzFnEe", "0794444444", null, (byte)1 }
                });

            migrationBuilder.InsertData(
                table: "ServiceProviders",
                columns: new[] { "UserId", "Bio", "IdCardAttachmentId", "IsVerified" },
                values: new object[,]
                {
                    { -5, "Experienced plumber with 10 years in Amman.", null, true },
                    { -4, "Experienced plumber with 10 years in Cairo.", null, true }
                });

            migrationBuilder.InsertData(
                table: "ProviderServiceAreas",
                columns: new[] { "ServiceAreaId", "ServiceProviderId" },
                values: new object[,]
                {
                    { -2, -5 },
                    { -1, -5 },
                    { -2, -4 },
                    { -1, -4 }
                });

            migrationBuilder.InsertData(
                table: "ProviderServices",
                columns: new[] { "ServiceId", "ServiceProviderId" },
                values: new object[,]
                {
                    { -3, -5 },
                    { -2, -5 },
                    { -1, -5 },
                    { -3, -4 },
                    { -2, -4 },
                    { -1, -4 }
                });

            migrationBuilder.InsertData(
                table: "Schedules",
                columns: new[] { "Id", "DayOfWeek", "EndTime", "ServiceProviderId", "StartTime" },
                values: new object[,]
                {
                    { -7, (byte)2, new TimeSpan(0, 17, 0, 0, 0), -5, new TimeSpan(0, 9, 0, 0, 0) },
                    { -6, (byte)1, new TimeSpan(0, 17, 0, 0, 0), -5, new TimeSpan(0, 9, 0, 0, 0) },
                    { -5, (byte)2, new TimeSpan(0, 17, 0, 0, 0), -4, new TimeSpan(0, 9, 0, 0, 0) },
                    { -4, (byte)1, new TimeSpan(0, 17, 0, 0, 0), -4, new TimeSpan(0, 9, 0, 0, 0) }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "ProviderServiceAreas",
                keyColumns: new[] { "ServiceAreaId", "ServiceProviderId" },
                keyValues: new object[] { -2, -5 });

            migrationBuilder.DeleteData(
                table: "ProviderServiceAreas",
                keyColumns: new[] { "ServiceAreaId", "ServiceProviderId" },
                keyValues: new object[] { -1, -5 });

            migrationBuilder.DeleteData(
                table: "ProviderServiceAreas",
                keyColumns: new[] { "ServiceAreaId", "ServiceProviderId" },
                keyValues: new object[] { -2, -4 });

            migrationBuilder.DeleteData(
                table: "ProviderServiceAreas",
                keyColumns: new[] { "ServiceAreaId", "ServiceProviderId" },
                keyValues: new object[] { -1, -4 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -3, -5 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -2, -5 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -1, -5 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -3, -4 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -2, -4 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -1, -4 });

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: -7);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: -6);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: -5);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: -4);

            migrationBuilder.DeleteData(
                table: "ServiceProviders",
                keyColumn: "UserId",
                keyValue: -5);

            migrationBuilder.DeleteData(
                table: "ServiceProviders",
                keyColumn: "UserId",
                keyValue: -4);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -5);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -4);
        }
    }
}
