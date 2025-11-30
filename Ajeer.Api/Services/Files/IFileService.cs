using Ajeer.Api.Enums;

namespace Ajeer.Api.Services.Files;

public interface IFileService
{
    Task<string?> SaveFileAsync(IFormFile file, string folderName);

    string? GetPublicUrl(string folderName, string? fileName);

    (MimeType, FileType) GetFileTypes(string fileName);
}