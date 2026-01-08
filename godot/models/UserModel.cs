using System;

namespace Toastmachine.models;

public class UserModel
{
    public required int Id { get; set; }
    public required string TagId { get; set; }
    public string? SecondaryTagId { get; set; }
    public required string Username { get; set; }
    public int MemberId { get; set; }
    public required DateTime Creation { get; set; }
    public DateTime? LastLogin { get; set; }
}