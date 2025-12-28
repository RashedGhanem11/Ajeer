using Ajeer.Api.DTOs.Admin.Services;
using Ajeer.Api.DTOs.ServiceCategories;
using Ajeer.Api.Models;

namespace Ajeer.Api.Services.ServiceCategories;

public interface IServiceCategoryService
{
    Task<List<ServiceCategoryResponse>> GetAllCategoriesAsync();

    Task<List<ServiceCategory>> GetAdminCategoriesAsync();

    Task CreateCategoryAsync(CreateCategoryRequest category, Stream? iconStream, string? fileName);

    Task UpdateCategoryAsync(UpdateCategoryRequest category, Stream? iconStream, string? fileName);
}