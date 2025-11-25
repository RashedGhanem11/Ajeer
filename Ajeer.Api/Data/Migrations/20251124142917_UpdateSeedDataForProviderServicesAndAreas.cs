using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Ajeer.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateSeedDataForProviderServicesAndAreas : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "ProviderServiceAreas",
                keyColumns: new[] { "ServiceAreaId", "ServiceProviderId" },
                keyValues: new object[] { -5, -3 });

            migrationBuilder.DeleteData(
                table: "ProviderServiceAreas",
                keyColumns: new[] { "ServiceAreaId", "ServiceProviderId" },
                keyValues: new object[] { -4, -3 });

            migrationBuilder.DeleteData(
                table: "ProviderServiceAreas",
                keyColumns: new[] { "ServiceAreaId", "ServiceProviderId" },
                keyValues: new object[] { -2, -1 });

            migrationBuilder.DeleteData(
                table: "ProviderServiceAreas",
                keyColumns: new[] { "ServiceAreaId", "ServiceProviderId" },
                keyValues: new object[] { -1, -1 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -8, -3 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -7, -3 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -6, -3 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -3, -1 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -2, -1 });

            migrationBuilder.DeleteData(
                table: "ProviderServices",
                keyColumns: new[] { "ServiceId", "ServiceProviderId" },
                keyValues: new object[] { -1, -1 });
        }
    }
}
