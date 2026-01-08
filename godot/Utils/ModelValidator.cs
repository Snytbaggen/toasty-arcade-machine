using System;
using Toastmachine.models;

namespace Toastmachine.Utils;

public static class ModelValidator
{
    public static bool ValidateUser(this UserModel user)
    {
        return user.Id > 0 &&
               user.Creation != DateTime.MinValue &&
               !string.IsNullOrEmpty(user.TagId) &&
               !string.IsNullOrEmpty(user.Username);
    }
}