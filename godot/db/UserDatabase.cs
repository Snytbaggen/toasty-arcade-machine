using System;
using System.Collections;
using System.Collections.Generic;
using Godot;
using Microsoft.Data.Sqlite;
using Toastmachine.models;
using Toastmachine.Utils;

namespace Toastmachine.db;

#pragma warning disable CA1822
public partial class UserDatabase : Node
{
    
    public long CreateGuid()
    {
        return DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
    }

    public string GetTimestamp()
    {
        return DateTime.Now.ToString("u");
    }
    
    // The database is disabled entirely for now, due to write
    // performance issues when running on a Raspberry Pi.
        
    /*
    private const string ConnString = "Data Source = toastmachine.db";
    private const string DebugConnString = "Data Source = toastmachine_dev.db";
    private SqliteConnection? _connection;

    private List<DateTime> cachedToasts = new ();
    
    public override void _Ready()
    {
        _connection = new SqliteConnection(OS.IsDebugBuild() ? DebugConnString : ConnString);
        _connection.Open();
        Create();
    }
    
    public override void _ExitTree()
    {
        base._ExitTree();
        _connection?.Close();
    }
    
    public bool CreateUser(string username, string tagId, string secondaryTagId = "", bool displayScore = true)
    {
        var success = false;
        CreateCommand(cmd =>
        {
            cmd.CommandText =
                """
                INSERT INTO User (TagId, SecondaryTagId, Username, Creation, DisplayToastScore)
                VALUES (@tagId, @secondaryTagId, @username, @creation, @displayScore);
                """;
            cmd.Parameters.Add(new SqliteParameter("@tagId", tagId));
            cmd.Parameters.Add(new SqliteParameter("@secondaryTagId", secondaryTagId));
            cmd.Parameters.Add(new SqliteParameter("@username", username));
            cmd.Parameters.Add(new SqliteParameter("@creation", DateTime.Now));
            cmd.Parameters.Add(new SqliteParameter("@displayScore", displayScore));
            success = cmd.ExecuteNonQuery() == 1;
        });
        return success;
    }

    public string[] GetToastHighScore()
    {
        var result = new List<string>();
        CreateCommand(cmd =>
        {
            cmd.CommandText =
                """
                SELECT
                    u.Username,
                    COUNT(t.UserId) AS ToastCount
                FROM User u
                INNER JOIN Toast t ON t.UserId = u.Id
                WHERE DisplayToastScore = 1
                GROUP BY u.Id, u.Username
                ORDER BY ToastCount DESC
                LIMIT 3;
                """;
            var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                result.Add($"{reader.GetString(1)} - {reader.GetString(0)}");
            }
        });
        return result.ToArray();
    }
    
    public int GetUserIdByTag(string tagId)
    {
        UserModel? user = null;
        CreateCommand(cmd =>
        {
            cmd.CommandText =
                """
                SELECT * FROM User
                WHERE (TagId = @TagId OR SecondaryTagId = @TagId);
                """;
            cmd.Parameters.Add(new SqliteParameter("@TagId", tagId));
            
            var reader = cmd.ExecuteReader();
            if (!reader.HasRows) return;
            
            reader.Read();
            user = reader.ReadUserModel();
        });
        GD.Print($"Found user: {user}");
        return user?.Id ?? -1;
    }

    public string GetUsernameById(int id)
    {
        var username = "";
        CreateCommand(cmd =>
        {
            cmd.CommandText =
                """
                SELECT Username FROM User
                WHERE Id = @id;
                """;
            cmd.Parameters.Add(new SqliteParameter("@id", id));
            var reader = cmd.ExecuteReader();
            if (!reader.HasRows) return;

            reader.Read();
            username = reader.GetString(0);
        });
        return username;
    }

    public void CacheToast()
    {
        cachedToasts.Add(DateTime.Now);
    }
    
    public void SaveToast(int userId)
    {
        CreateCommand(cmd =>
        {
            cmd.CommandText = "BEGIN";
            cmd.ExecuteNonQuery();
        });
        foreach (var cachedToast in cachedToasts)
        {
            
            CreateCommand(cmd =>
            {
                cmd.CommandText =
                    """
                    INSERT INTO Toast (UserId, Time)
                    VALUES (@id, @time);
                    """;
                cmd.Parameters.Add(new SqliteParameter("@id", userId));
                cmd.Parameters.Add(new SqliteParameter("@time", cachedToast));
                cmd.ExecuteNonQuery();   
            
            });
        }
        CreateCommand(cmd =>
        {
            cmd.CommandText = "END";
            cmd.ExecuteNonQuery();
        });
    }

    public int GetToastCount()
    {
        var rows = 0;
        CreateCommand(cmd =>
        {
            cmd.CommandText =
                """
                SELECT COUNT(*) FROM Toast;
                """;
            rows = Convert.ToInt32(cmd.ExecuteScalar());
        });
        return rows;
    }
    
    public int GetToastCountForUser(int userId)
    {
        var rows = 0;
        CreateCommand(cmd =>
        {
            cmd.CommandText =
                """
                SELECT COUNT(Time) FROM Toast
                WHERE UserId = @id;
                """;
            cmd.Parameters.Add(new SqliteParameter("@id", userId));
            rows = Convert.ToInt32(cmd.ExecuteScalar());
        });
        return rows;
    }
    
    private void Create()
    {
        CreateCommand(command =>
        {
            command.CommandText = 
                """
                CREATE TABLE IF NOT EXISTS User (
                    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                    TagId VARCHAR(128) NOT NULL,
                    SecondaryTagId VARCHAR(128) NOT NULL,
                    Username VARCHAR(30) NOT NULL,
                    MemberId INTEGER,
                    Creation DATETIME NOT NULL,
                    LastLogin DATETIME,
                    DisplayToastScore BOOLEAN
                );

                CREATE TABLE IF NOT EXISTS Toast (
                    UserId INTEGER NOT NULL,
                    Time DATETIME NOT NULL,
                    FOREIGN KEY (UserId) REFERENCES User(Id)
                );

                CREATE TABLE IF NOT EXISTS FlappyBird (
                    UserId INTEGER NOT NULL,
                    Score INTEGER NOT NULL,
                    FOREIGN KEY (UserId) REFERENCES User(Id)
                );
                """;
            command.ExecuteNonQuery();
        });
    }

    private void CreateCommand(Action<SqliteCommand> configureCommand)
    {
        if (_connection == null)
        {
            throw new NullReferenceException("Database connection was null!");
        }
        var command = _connection.CreateCommand();
        configureCommand(command);
    }
    */
}