using Ajeer.Api.DTOs.ServiceCategories;

namespace Ajeer.Api.Services.ServiceCategories;

public interface IServiceCategoryService
{
    Task<List<ServiceCategoryResponse>> GetAllCategoriesAsync();
}