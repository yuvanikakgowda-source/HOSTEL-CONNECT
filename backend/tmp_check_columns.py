import sqlite3
import os
path = os.path.abspath(os.path.join('backend','database','hostelconnect.db'))
print('db', path)
conn = sqlite3.connect(path)
conn.row_factory = sqlite3.Row
cur = conn.cursor()
for table in ['students', 'rooms', 'room_allocations']:
    print('\nTABLE', table)
    for row in cur.execute(f'PRAGMA table_info({table})').fetchall():
        print(row['cid'], row['name'], row['type'])
conn.close()
