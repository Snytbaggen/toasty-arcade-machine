using Godot;
using Microsoft.Data.Sqlite;

namespace Toastmachine.db;

public partial class UserDatabase : Node
{
    public override void _Ready()
    {
        Create();
    }

    private static void Create()
    {
        using var connection = new SqliteConnection("Data Source = toastmachine.db");
        
        connection.Open();

        var command = connection.CreateCommand();
        command.CommandText = 
            """
            CREATE TABLE IF NOT EXISTS User (
                Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                TagId VARCHAR(128) NOT NULL,
                SecondaryTagId VARCHAR(128) NOT NULL,
                Username VARCHAR(30) NOT NULL,
                MemberId INTEGER,
                Creation DATE NOT NULL,
                LastLogin DATE
            );

            CREATE TABLE IF NOT EXISTS Toast (
                UserId INTEGER NOT NULL,
                Time DATE NOT NULL,
                FOREIGN KEY (UserId) REFERENCES User(Id)
            );

            CREATE TABLE IF NOT EXISTS FlappyBird (
                UserId INTEGER NOT NULL,
                Score INTEGER NOT NULL,
                FOREIGN KEY (UserId) REFERENCES User(Id)
            );
            """;
        command.ExecuteNonQuery();
    }
}