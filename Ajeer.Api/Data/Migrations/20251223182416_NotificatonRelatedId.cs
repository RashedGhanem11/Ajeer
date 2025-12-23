using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ajeer.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class NotificatonRelatedId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "BookingId",
                table: "Notifications",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_BookingId",
                table: "Notifications",
                column: "BookingId");

            migrationBuilder.AddForeignKey(
                name: "FK_Notifications_Bookings_BookingId",
                table: "Notifications",
                column: "BookingId",
                principalTable: "Bookings",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Notifications_Bookings_BookingId",
                table: "Notifications");

            migrationBuilder.DropIndex(
                name: "IX_Notifications_BookingId",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "BookingId",
                table: "Notifications");
        }
    }
}
