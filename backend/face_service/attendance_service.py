import sqlite3
from datetime import datetime
from typing import Dict, Optional

from .database import DatabaseError, get_connection, get_student


class AttendanceError(Exception):
    pass


class DuplicateAttendanceError(AttendanceError):
    pass


def mark_attendance(student_id: int, status: str = 'Present') -> Dict:
    student = get_student(student_id)
    if student is None:
        raise AttendanceError('Student not found')

    now_dt = datetime.now()
    today = now_dt.date().isoformat()
    time_marked = now_dt.time().replace(microsecond=0).isoformat()
    day_of_week = now_dt.strftime('%A')
    history_date = now_dt.strftime('%d-%m-%Y')
    history_time = now_dt.strftime('%I:%M:%S %p')
    timestamp = now_dt.replace(microsecond=0).isoformat()

    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO attendance (student_id, date, day, time_marked, status, is_morning, is_evening) '
            'VALUES (?, ?, ?, ?, ?, ?, ?)',
            (student_id, today, day_of_week, time_marked, status, 0, 0),
        )
        attendance_id = cursor.lastrowid
        cursor.execute(
            'INSERT INTO attendance_history '
            '(attendance_id, student_id, user_id, student_name, status, year, month, day, date, time, timestamp) '
            'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            (
                f'AT{attendance_id:03d}',
                student_id,
                student['hostel_register_number'],
                student['username'],
                status,
                now_dt.year,
                now_dt.strftime('%B'),
                day_of_week,
                history_date,
                history_time,
                timestamp,
            ),
        )
        conn.commit()
    except sqlite3.IntegrityError as exc:
        conn.rollback()
        if 'UNIQUE' in str(exc).upper():
            raise DuplicateAttendanceError('Attendance already marked today') from exc
        raise AttendanceError(f'Unable to mark attendance: {exc}') from exc
    except DatabaseError:
        raise
    except sqlite3.Error as exc:
        conn.rollback()
        raise AttendanceError(f'Unable to mark attendance: {exc}') from exc
    finally:
        conn.close()

    return {
        'id': attendance_id,
        'student_id': student_id,
        'username': student['username'],
        'hostel_register_number': student['hostel_register_number'],
        'room_number': student['room_number'],
        'date': today,
        'day': day_of_week,
        'time_marked': time_marked,
        'status': status,
        'userId': student['hostel_register_number'],
        'studentName': student['username'],
        'year': now_dt.year,
        'month': now_dt.strftime('%B'),
        'dateFormatted': history_date,
        'timeFormatted': history_time,
        'timestamp': timestamp,
        'is_morning': 0,
        'is_evening': 0,
    }


def get_today_attendance(student_id: int) -> Optional[Dict]:
    today = datetime.now().date().isoformat()
    conn = get_connection()
    try:
        row = conn.execute(
            'SELECT * FROM attendance WHERE student_id = ? AND date = ?',
            (student_id, today),
        ).fetchone()
    finally:
        conn.close()
    return dict(row) if row is not None else None
