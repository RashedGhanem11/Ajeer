using Ajeer.Api.DTOs.Admin.Services;
using Ajeer.Api.DTOs.Services;
using Ajeer.Api.Models;

namespace Ajeer.Api.Services.Services;

public interface IServiceService
{
    Task<List<ServiceResponse>> GetServicesByCategoryIdAsync(int categoryId);

    Task CreateServiceAsync(CreateServiceRequest service);

    Task UpdateServiceAsync(UpdateServiceRequest service);

}