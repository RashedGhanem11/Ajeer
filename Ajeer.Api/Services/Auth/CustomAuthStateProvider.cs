using System.Security.Claims;
using System.Net.Http.Headers;
using System.IdentityModel.Tokens.Jwt; // The new library
using Microsoft.AspNetCore.Components.Authorization;
using Blazored.LocalStorage;

namespace Ajeer.Api.Services.Auth;

public class CustomAuthStateProvider : AuthenticationStateProvider
{
    private readonly ILocalStorageService _localStorage;
    private readonly HttpClient _http;
    private readonly JwtSecurityTokenHandler _tokenHandler = new();

    public CustomAuthStateProvider(ILocalStorageService localStorage, HttpClient http)
    {
        _localStorage = localStorage;
        _http = http;
    }

    public override async Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        try
        {
            string? token = await _localStorage.GetItemAsStringAsync("authToken");

            if (string.IsNullOrWhiteSpace(token))
                return GenerateState(new ClaimsPrincipal(new ClaimsIdentity())); // Logged Out

            var jwtToken = _tokenHandler.ReadJwtToken(token);

            var identity = new ClaimsIdentity(jwtToken.Claims, "jwt");
            var user = new ClaimsPrincipal(identity);

            _http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

            return GenerateState(user);
        }
        catch
        {
            // If token is invalid/expired, remove it and log out
            await Logout();
            return GenerateState(new ClaimsPrincipal(new ClaimsIdentity()));
        }
    }

    public async Task Login(string token)
    {
        await _localStorage.SetItemAsStringAsync("authToken", token);
        NotifyAuthenticationStateChanged(GetAuthenticationStateAsync());
    }

    public async Task Logout()
    {
        await _localStorage.RemoveItemAsync("authToken");
        _http.DefaultRequestHeaders.Authorization = null;
        NotifyAuthenticationStateChanged(GetAuthenticationStateAsync());
    }

    private AuthenticationState GenerateState(ClaimsPrincipal user) => new AuthenticationState(user);
}