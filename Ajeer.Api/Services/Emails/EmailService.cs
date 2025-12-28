using System.Net;
using System.Net.Mail;
using Ajeer.Api.Services.Emails;

namespace Ajeer.Api.Services.Email;

public class EmailSettings
{
    public string SmtpServer { get; set; } = "";
    public int Port { get; set; }
    public string SenderName { get; set; } = "";
    public string SenderEmail { get; set; } = "";
    public string Password { get; set; } = "";
    public bool EnableSsl { get; set; }
}

public class EmailService : IEmailService
{
    private readonly EmailSettings _settings;

    public EmailService(IConfiguration configuration)
    {
        _settings = configuration.GetSection("EmailSettings").Get<EmailSettings>()
                    ?? new EmailSettings();
    }

    public Task SendEmailAsync(string toEmail, string subject, string body)
    {
        _ = Task.Run(async () =>
        {
            try
            {
                var message = new MailMessage
                {
                    From = new MailAddress(_settings.SenderEmail, _settings.SenderName),
                    Subject = subject,
                    Body = body,
                    IsBodyHtml = true
                };
                message.To.Add(toEmail);

                using var client = new SmtpClient(_settings.SmtpServer, _settings.Port)
                {
                    Credentials = new NetworkCredential(_settings.SenderEmail, _settings.Password),
                    EnableSsl = _settings.EnableSsl
                };

                await client.SendMailAsync(message);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Email Background Error] {ex.Message}");
            }
        });

        return Task.CompletedTask;
    }

}