namespace Ajeer.Api.Services.Emails;

public interface IEmailService
{
    Task SendEmailAsync(string toEmail, string subject, string body);
}