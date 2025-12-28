using Ajeer.Api.Data;
using Ajeer.Api.Extensions;
using Ajeer.Api.Hubs;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationServices(builder.Configuration);

var app = builder.Build();

/*if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        // Sets the default page title and description
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Ajeer API v1");
    });
}*/

app.UseExceptionHandler();

app.UseStaticFiles();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.MapHub<ChatHub>("/hubs/chat");
app.MapHub<NotificationHub>("/hubs/notification");

app.MapBlazorHub("/admin/_blazor");
app.MapFallbackToPage("/admin/{*catchall}", "/_Host");

app.Run();