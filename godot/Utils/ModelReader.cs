using System;
using Microsoft.Data.Sqlite;
using Toastmachine.models;

namespace Toastmachine.Utils;

public static class ModelReader
{
    public static UserModel? ReadUserModel(this SqliteDataReader reader)
    {
        var lastLogin = Convert.ToDateTime(reader.GetOrNull("LastLogin"));
        var user = new UserModel
        {
            Id = Convert.ToInt32(reader.GetOrNull("Id")),
            Creation = Convert.ToDateTime(reader.GetOrNull("Creation")),
            LastLogin = lastLogin == DateTime.MinValue ? null : lastLogin,
            MemberId = Convert.ToInt32(reader.GetOrNull("MemberId")),
            TagId = Convert.ToString(reader.GetOrNull("TagId")) ?? "",
            SecondaryTagId = Convert.ToString(reader.GetOrNull("SecondaryTagId")),
            Username = Convert.ToString(reader.GetOrNull("Username")) ?? ""
        };

        return user.ValidateUser() ? user : null;
    }
}