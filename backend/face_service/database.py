import json
import os
import sqlite3
from contextlib import contextmanager
from typing import Dict, Iterator, List, Optional

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
DB_PATH = os.environ.get(
    'HOSTELCONNECT_DB_PATH',
    os.path.join(BASE_DIR, 'database', 'hostelconnect.db'),
)


class DatabaseError(Exception):
    pass


def get_connection() -> sqlite3.Connection:
    try:
        conn = sqlite3.connect(DB_PATH, check_same_thread=False)
        conn.row_factory = sqlite3.Row
        conn.execute('PRAGMA foreign_keys = ON')
        conn.execute('PRAGMA journal_mode = WAL')
        conn.execute('PRAGMA synchronous = NORMAL')
        conn.execute('PRAGMA busy_timeout = 5000')
        return conn
    except sqlite3.Error as exc:
        raise DatabaseError(f'Unable to connect to HostelConnect database: {exc}') from exc


@contextmanager
def db_cursor() -> Iterator[sqlite3.Cursor]:
    conn = get_connection()
    try:
        cursor = conn.cursor()
        yield cursor
        conn.commit()
    except sqlite3.Error as exc:
        conn.rollback()
        raise DatabaseError(f'Database operation failed: {exc}') from exc
    finally:
        conn.close()


def ensure_schema() -> None:
    with db_cursor() as cursor:
        cursor.execute("PRAGMA table_info(students)")
        student_columns = [row['name'] for row in cursor.fetchall()]
        if not student_columns:
            raise DatabaseError('students table does not exist; start the Node backend once to initialize the database')

        if 'face_encoding' not in student_columns:
            cursor.execute('ALTER TABLE students ADD COLUMN face_encoding TEXT')

        if 'face_data' in student_columns:
            cursor.execute(
                'UPDATE students SET face_encoding = face_data '
                'WHERE (face_encoding IS NULL OR TRIM(face_encoding) = "") '
                'AND face_data IS NOT NULL AND TRIM(face_data) != ""'
            )

        cursor.execute("PRAGMA table_info(attendance)")
        attendance_columns = [row['name'] for row in cursor.fetchall()]
        if not attendance_columns:
            raise DatabaseError('attendance table does not exist; start the Node backend once to initialize the database')

        cursor.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_attendance_student_date '
            'ON attendance(student_id, date)'
        )

        cursor.execute(
            'CREATE TABLE IF NOT EXISTS attendance_history ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'attendance_id TEXT UNIQUE, '
            'student_id INTEGER NOT NULL, '
            'user_id TEXT NOT NULL, '
            'student_name TEXT NOT NULL, '
            'status TEXT NOT NULL DEFAULT "Absent", '
            'year INTEGER NOT NULL, '
            'month TEXT NOT NULL, '
            'day TEXT NOT NULL, '
            'date TEXT NOT NULL, '
            'time TEXT NOT NULL, '
            'timestamp DATETIME NOT NULL, '
            'created_at DATETIME DEFAULT CURRENT_TIMESTAMP, '
            'FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE'
            ')'
        )


def get_student(student_id: int) -> Optional[Dict]:
    with db_cursor() as cursor:
        row = cursor.execute(
            'SELECT id, username, hostel_register_number, room_number, face_encoding '
            'FROM students WHERE id = ?',
            (student_id,),
        ).fetchone()
    return dict(row) if row is not None else None


def load_registered_faces() -> List[Dict]:
    with db_cursor() as cursor:
        rows = cursor.execute(
            'SELECT id, username, hostel_register_number, room_number, face_encoding '
            'FROM students '
            'WHERE face_encoding IS NOT NULL AND TRIM(face_encoding) != ""'
        ).fetchall()

    registered = []
    for row in rows:
        try:
            encoding = json.loads(row['face_encoding'])
        except (TypeError, json.JSONDecodeError):
            continue

        if not isinstance(encoding, list) or len(encoding) == 0:
            continue

        registered.append(
            {
                'id': row['id'],
                'name': row['username'],
                'hostel_register_number': row['hostel_register_number'],
                'room_number': row['room_number'],
                'encoding': encoding,
            }
        )
    return registered


def save_face_encoding(student_id: int, encoding: List[float]) -> None:
    with db_cursor() as cursor:
        cursor.execute(
            'UPDATE students SET face_encoding = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
            (json.dumps(encoding), student_id),
        )
        if cursor.rowcount == 0:
            raise DatabaseError('Student not found')


def fetch_attendance_records(
    student_id: Optional[int] = None,
    attendance_date: Optional[str] = None,
) -> List[Dict]:
    query = (
        'SELECT a.id, a.student_id, a.date, a.day, a.time_marked, a.status, '
        'a.latitude, a.longitude, a.is_morning, a.is_evening, '
        's.username, s.hostel_register_number, s.room_number '
        'FROM attendance a '
        'JOIN students s ON a.student_id = s.id'
    )
    parameters = []
    clauses = []

    if student_id is not None:
        clauses.append('a.student_id = ?')
        parameters.append(student_id)
    if attendance_date:
        clauses.append('a.date = ?')
        parameters.append(attendance_date)
    if clauses:
        query += ' WHERE ' + ' AND '.join(clauses)

    query += ' ORDER BY a.date DESC, a.time_marked DESC'

    with db_cursor() as cursor:
        rows = cursor.execute(query, tuple(parameters)).fetchall()
    return [dict(row) for row in rows]
