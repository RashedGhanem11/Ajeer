using Ajeer.Api.DTOs.Reviews;

namespace Ajeer.Api.Services.Reviews;

public interface IReviewService
{
    Task AddReviewAsync(int userId, CreateReviewRequest dto);
}