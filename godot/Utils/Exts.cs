using System;
using Microsoft.Data.Sqlite;

namespace Toastmachine.Utils;

public static class Exts
{
    public static object? GetOrNull(this SqliteDataReader reader, string name)
    {
        var value = reader[name];
        return value is DBNull ? null : value;
    }
}