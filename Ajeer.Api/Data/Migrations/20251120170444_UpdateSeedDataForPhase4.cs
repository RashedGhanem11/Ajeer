using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ajeer.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateSeedDataForPhase4 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -9,
                column: "IconUrl",
                value: "moving_and_delivery.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -8,
                column: "IconUrl",
                value: "it_support.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -7,
                column: "IconUrl",
                value: "gardening.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -6,
                column: "IconUrl",
                value: "appliance_repair.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -5,
                column: "IconUrl",
                value: "carpentry.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -4,
                column: "IconUrl",
                value: "painting.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -3,
                column: "IconUrl",
                value: "cleaning.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -2,
                column: "IconUrl",
                value: "electrical.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -1,
                column: "IconUrl",
                value: "plumbing.png");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -3,
                columns: new[] { "Password", "ProfilePictureUrl" },
                values: new object[] { "$2a$11$E8c1z9.I.d4dO2jXf1z6S.u7W0f1o.g1R5O9V4f1e4I0f1t.s0z4", "ProfilePicture_-3.jpg" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -2,
                column: "Password",
                value: "$2a$11$E8c1z9.I.d4dO2jXf1z6S.u7W0f1o.g1R5O9V4f1e4I0f1t.s0z4");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -1,
                column: "Password",
                value: "$2a$11$E8c1z9.I.d4dO2jXf1z6S.u7W0f1o.g1R5O9V4f1e4I0f1t.s0z4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -9,
                column: "IconUrl",
                value: "icons/moving.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -8,
                column: "IconUrl",
                value: "icons/it.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -7,
                column: "IconUrl",
                value: "icons/gardening.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -6,
                column: "IconUrl",
                value: "icons/appliance.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -5,
                column: "IconUrl",
                value: "icons/carpentry.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -4,
                column: "IconUrl",
                value: "icons/painting.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -3,
                column: "IconUrl",
                value: "icons/cleaning.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -2,
                column: "IconUrl",
                value: "icons/electrical.png");

            migrationBuilder.UpdateData(
                table: "ServiceCategories",
                keyColumn: "Id",
                keyValue: -1,
                column: "IconUrl",
                value: "icons/plumbing.png");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -3,
                columns: new[] { "Password", "ProfilePictureUrl" },
                values: new object[] { "hashed_password_3", null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -2,
                column: "Password",
                value: "hashed_password_2");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: -1,
                column: "Password",
                value: "hashed_password_1");
        }
    }
}
