using Ajeer.Api.DTOs.Services;

namespace Ajeer.Api.Services.Services;

public interface IServiceService
{
    Task<List<ServiceResponse>> GetServicesByCategoryIdAsync(int categoryId);
}