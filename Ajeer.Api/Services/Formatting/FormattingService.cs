using System.Globalization;

namespace Ajeer.Api.Services.Formatting;

public class FormattingService : IFormattingService
{
    public string FormatCurrency(decimal amount)
    {
        return $"JOD {amount.ToString("N2", new CultureInfo("en-US"))}";
    }

    public string FormatEstimatedTime(decimal hours)
    {
        int totalMinutes = (int)(hours * 60);
        int wholeHours = totalMinutes / 60;
        int remainingMinutes = totalMinutes % 60;

        string timeString = "";

        if (wholeHours > 0)
        {
            timeString += $"{wholeHours} hr" + (wholeHours > 1 ? "s" : "");
            if (remainingMinutes > 0)
            {
                timeString += $" {remainingMinutes} mins";
            }
        }
        else if (remainingMinutes > 0)
        {
            timeString += $"{remainingMinutes} mins";
        }
        else
        {
            timeString += "less than 1 hr";
        }

        return "Est. Time: " + timeString;
    }

    public string FormatRelativeTime(DateTime messageTime)
    {
        var timeDifference = DateTime.Now.Subtract(messageTime);

        if (timeDifference.TotalMinutes < 1)
            return "Just now";

        if (timeDifference.TotalMinutes < 60)
            return $"{(int)timeDifference.TotalMinutes} mins ago";

        if (timeDifference.TotalHours < 24)
            return messageTime.ToString("h:mm tt");

        if (timeDifference.TotalDays < 2)
            return "Yesterday";

        if (timeDifference.TotalDays < 7)
            return $"{(int)timeDifference.TotalDays} days ago";

        return messageTime.ToString("MMM d, yyyy");
    }
}