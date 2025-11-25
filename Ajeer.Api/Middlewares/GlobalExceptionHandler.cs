using Microsoft.AspNetCore.Diagnostics;

namespace Ajeer.Api.Middlewares;

public class GlobalExceptionHandler(ILogger<GlobalExceptionHandler> _logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        _logger.LogError(exception, "Exception occurred: {Message}", exception.Message);

        int statusCode = StatusCodes.Status400BadRequest;

        httpContext.Response.StatusCode = statusCode;

        var response = new
        {
            message = exception.Message
        };

        await httpContext.Response.WriteAsJsonAsync(response, cancellationToken);

        return true;
    }
}