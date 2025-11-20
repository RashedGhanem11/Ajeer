using Ajeer.Api.Data;
using Ajeer.Api.Extensions;
using Microsoft.Extensions.FileProviders;

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