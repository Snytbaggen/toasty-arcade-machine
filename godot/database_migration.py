import sqlite3
import sys
import json
from datetime import datetime

if len(sys.argv) <= 2:
    print("Missing argument(s), run again with JSON data and database path as argument (python3 database_migration.py path/to/data.json path/to/database.db)")
    exit()

json_path = sys.argv[1]
con_str = sys.argv[2]

try:
    with open(json_path) as f:
        data = f.read()
        users = json.loads(data)
except:
    print("Failed to load JSON data")
    exit()

try:
    con = sqlite3.connect(con_str)
    cur = con.cursor()
except:
    print("Failed to open database")
    exit(0)

for user in users.values():
    print("Migrating user", user["name"])

    cur.execute("""
        SELECT Id FROM user WHERE Username = ?;
        """,
        (user["name"],)
    )
    db_user_id = cur.fetchone()

    # Create or update user
    if db_user_id is None:
        # Create new user
        cur.execute("""
            INSERT INTO User (TagId, SecondaryTagId, Username, Creation, DisplayToastScore)
            VALUES (?, '', ?, '2025-02-01', true);
            """,
            (user["userId"], user["name"])
        )
        con.commit()

        tag_id = user["userId"]
        cur.execute("""
            SELECT Id FROM user WHERE (TagId = ? OR SecondaryTagId = ?);
            """,
            (tag_id, tag_id)
        )
        db_user_id = cur.fetchone()[0]
    else:
        # Update with new tag (this should only be true for Lisse)
        db_user_id = db_user_id[0] #Converts from tuple to actual value
        cur.execute("""
            UPDATE User
            SET SecondaryTagId = ?
            WHERE Id = ?;
            """,
            (user["userId"], db_user_id)
        )
        con.commit()
    
    # Update toasts
    for toast in user["toastDates"]:
        toast_time = datetime.fromtimestamp(toast)

        cur.execute("""
            INSERT INTO Toast (UserId, Time)
            VALUES (?, ?)
            """,
            (db_user_id, toast_time.strftime("%Y-%m-%d %H:%M:%S.%s"))
        )
        con.commit()

print("All users migrated!")
