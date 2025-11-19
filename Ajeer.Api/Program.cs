using Ajeer.Api.Data;
using Ajeer.Api.Extensions;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationServices(builder.Configuration);

var app = builder.Build();

app.UseStaticFiles();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.MapGet("/", (AppDbContext context) => {

    Console.WriteLine($"Users: {context.Users.Count()}");
    Console.WriteLine($"Providers: {context.ServiceProviders.Count()}");
    Console.WriteLine($"Categories: {context.ServiceCategories.Count()}");
    Console.WriteLine($"Bookings: {context.Bookings.Count()}");

});

app.Run();