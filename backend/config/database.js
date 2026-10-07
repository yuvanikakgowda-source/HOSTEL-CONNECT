// backend/config/database.js
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

const dbPath = path.join(__dirname, '..', 'database', 'hostelconnect.db');

// Create database directory if it doesn't exist
const dbDir = path.dirname(dbPath);
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

// Open or create database safely; if corruption occurs, back up and recreate
function openDatabase(path) {
  return new Promise((resolve, reject) => {
    const attemptOpen = () => {
      const db = new sqlite3.Database(path, sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE, (err) => {
        if (err) {
          return reject(err);
        }

        // Set pragmas for better concurrency and safety
        db.serialize(() => {
          db.run('PRAGMA busy_timeout = 5000');
          db.run('PRAGMA journal_mode = WAL');
          db.run('PRAGMA synchronous = NORMAL');
          db.run('PRAGMA foreign_keys = ON');
        });

        return resolve(db);
      });
    };

    attemptOpen();
  });
}

// Open database synchronously and initialize
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database:', err.message);
  } else {
    console.log('Opened SQLite database at', dbPath);
    db.serialize(() => {
      db.run('PRAGMA busy_timeout = 5000');
      db.run("PRAGMA journal_mode = WAL");
      db.run('PRAGMA synchronous = NORMAL');
      db.run('PRAGMA foreign_keys = ON');
    });
    initializeDatabase();
  }
});

// Initialize database tables
function initializeDatabase() {
  const runSql = (sql, params = []) => {
    return new Promise((resolve, reject) => {
      db.run(sql, params, (err) => {
        if (err) {
          return reject(err);
        }
        resolve();
      });
    });
  };

  const columnExists = (table, column) => {
    return new Promise((resolve, reject) => {
      db.all(`PRAGMA table_info(${table})`, (err, columns) => {
        if (err) {
          return reject(err);
        }
        resolve(columns.some((col) => col.name === column));
      });
    });
  };

  const addColumnIfMissing = async (table, column, definition) => {
    const exists = await columnExists(table, column);
    if (!exists) {
      await runSql(`ALTER TABLE ${table} ADD COLUMN ${definition}`);
    }
  };

  const ensureSchema = async () => {
    // Students table
    await runSql(`
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        hostel_register_number TEXT UNIQUE NOT NULL,
        email TEXT,
        phone TEXT,
        room_number TEXT,
        floor INTEGER,
        face_data TEXT,
        face_encoding TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Wardens table
    await runSql(`
      CREATE TABLE IF NOT EXISTS wardens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        hostel_name TEXT,
        hostel_id TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Attendance table
    await runSql(`
      CREATE TABLE IF NOT EXISTS attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        date DATE NOT NULL,
        day TEXT,
        time_marked TIME,
        status TEXT DEFAULT 'Absent',
        latitude REAL,
        longitude REAL,
        is_morning INTEGER DEFAULT 0,
        is_evening INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        UNIQUE(student_id, date)
      )
    `);

    // Complaints table
    await runSql(`
      CREATE TABLE IF NOT EXISTS complaints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        complaint_text TEXT NOT NULL,
        status TEXT DEFAULT 'Processing',
        date_filed DATE DEFAULT CURRENT_DATE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    `);

    // Notices table
    await runSql(`
      CREATE TABLE IF NOT EXISTS notices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        warden_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date_posted DATE DEFAULT CURRENT_DATE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (warden_id) REFERENCES wardens(id) ON DELETE CASCADE
      )
    `);

    // Mess Menu table
    await runSql(`
      CREATE TABLE IF NOT EXISTS mess_menu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_of_week TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        menu_item TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(day_of_week, meal_type)
      )
    `);

    // Rooms table
    await runSql(`
      CREATE TABLE IF NOT EXISTS rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        room_id TEXT UNIQUE,
        floor INTEGER NOT NULL,
        room_number TEXT NOT NULL,
        room_type TEXT DEFAULT 'Double',
        capacity INTEGER NOT NULL,
        current_occupancy INTEGER DEFAULT 0,
        occupied INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(floor, room_number)
      )
    `);

    // Room Allocations table (tracks which student is in which room)
    await runSql(`
      CREATE TABLE IF NOT EXISTS room_allocations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        allocation_id TEXT UNIQUE,
        student_id INTEGER NOT NULL,
        user_id TEXT,
        room_id INTEGER NOT NULL,
        floor INTEGER NOT NULL,
        room_number TEXT NOT NULL,
        allocation_date DATE DEFAULT CURRENT_DATE,
        allocated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        status TEXT DEFAULT 'Active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
        UNIQUE(student_id, room_id)
      )
    `);

    // Attendance History table (one row for every successful attendance mark)
    await runSql(`
      CREATE TABLE IF NOT EXISTS attendance_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attendance_id TEXT UNIQUE,
        student_id INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        student_name TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Absent',
        year INTEGER NOT NULL,
        month TEXT NOT NULL,
        day TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        timestamp DATETIME NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    `);

    await addColumnIfMissing('students', 'face_data', 'face_data TEXT');
    await addColumnIfMissing('students', 'face_encoding', 'face_encoding TEXT');
    await addColumnIfMissing('rooms', 'room_id', 'room_id TEXT');
    await addColumnIfMissing('rooms', 'occupied', 'occupied INTEGER DEFAULT 0');
    await addColumnIfMissing('room_allocations', 'allocation_id', 'allocation_id TEXT');
    await addColumnIfMissing('room_allocations', 'user_id', 'user_id TEXT');
    await addColumnIfMissing('room_allocations', 'allocated_at', 'allocated_at DATETIME');

    await runSql(`UPDATE students SET face_encoding = face_data WHERE (face_encoding IS NULL OR TRIM(face_encoding) = '') AND face_data IS NOT NULL AND TRIM(face_data) != ''`);
    await runSql(`UPDATE rooms SET room_id = 'RM' || room_number WHERE room_id IS NULL OR TRIM(room_id) = ''`);
    await runSql(`UPDATE rooms SET occupied = current_occupancy WHERE occupied IS NULL`);
  };

  ensureSchema().then(() => {
    console.log('Database tables initialized successfully');
  }).catch((error) => {
    console.error('Database initialization failed:', error.message);
  });
}

module.exports = db;
