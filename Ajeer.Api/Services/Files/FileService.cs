using Ajeer.Api.Enums;

namespace Ajeer.Api.Services.Files;

public class FileService(IWebHostEnvironment _environment) : IFileService
{
    public async Task<string?> SaveFileAsync(IFormFile file, string folderName)
    {
        if (file == null || file.Length == 0) return null;

        string uploadsFolder = Path.Combine(_environment.WebRootPath, "uploads", folderName);
        if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

        string ext = Path.GetExtension(file.FileName);

        string uniqueFileName = $"{Guid.NewGuid()}{ext}";

        string filePath = Path.Combine(uploadsFolder, uniqueFileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        return uniqueFileName;
    }

    public void DeleteFile(string folderName, string? fileName)
    {
        if (string.IsNullOrEmpty(fileName)) return;

        string filePath = Path.Combine(_environment.WebRootPath, "uploads", folderName, fileName);

        if (File.Exists(filePath))
        {
            File.Delete(filePath);
        }
    }

    public string? GetPublicUrl(string folderName, string? fileName)
    {
        if (string.IsNullOrEmpty(fileName)) return null;
        return $"/uploads/{folderName}/{fileName}";
    }

    public (MimeType, FileType) GetFileTypes(string fileName)
    {
        string ext = Path.GetExtension(fileName).ToLower();
        return ext switch
        {
            ".jpg" or ".jpeg" => (MimeType.Jpeg, FileType.Image),
            ".png" => (MimeType.Png, FileType.Image),
            ".webp" => (MimeType.Webp, FileType.Image),
            ".mp4" => (MimeType.Mp4, FileType.Video),
            ".mov" => (MimeType.Mov, FileType.Video),
            ".mp3" => (MimeType.Mp3, FileType.Audio),
            ".wav" => (MimeType.Wav, FileType.Audio),
            ".m4a" => (MimeType.M4a, FileType.Audio),
            _ => (MimeType.Other, FileType.Image)
        };
    }
}