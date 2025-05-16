import sqlite3, os

print("Exists test.db?", os.path.exists("test.db"))

conn = sqlite3.connect("test.db")
cursor = conn.cursor()
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
print("Tables:", [r[0] for r in cursor.fetchall()])
conn.close()
