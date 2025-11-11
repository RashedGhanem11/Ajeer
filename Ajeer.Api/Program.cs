using Ajeer.Api.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseSqlServer(connectionString);
});

var app = builder.Build();

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(
        Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads")),
    RequestPath = "/uploads"
});

app.MapGet("/", (AppDbContext context) => {

    Console.WriteLine($"Users: {context.Users.Count()}");
    Console.WriteLine($"Providers: {context.ServiceProviders.Count()}");
    Console.WriteLine($"Categories: {context.ServiceCategories.Count()}");
    Console.WriteLine($"Bookings: {context.Bookings.Count()}");

});

app.Run();
