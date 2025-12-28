using Ajeer.Api.Enums;

namespace Ajeer.Api.Services.Files;

public interface IFileService
{
    Task<string?> SaveFileAsync(IFormFile file, string folderName);

    Task<string?> SaveFileAsync(Stream fileStream, string fileName, string folderName);

    void DeleteFile(string folderName, string? fileName);

    string? GetPublicUrl(string folderName, string? fileName);

    (MimeType, FileType) GetFileTypes(string fileName);
}