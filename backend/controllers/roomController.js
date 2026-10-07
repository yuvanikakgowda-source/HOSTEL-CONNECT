const db = require('../config/database');

const roomSelect = `
  SELECT r.id, r.room_id, r.floor, r.room_type, r.room_number, r.capacity,
         COALESCE(COUNT(ra.id), 0) AS occupied,
         r.created_at, r.updated_at,
         GROUP_CONCAT(
           CASE
             WHEN s.id IS NOT NULL THEN s.username || '|' || s.hostel_register_number || '|' || s.id
           END
         ) AS students_csv
  FROM rooms r
  LEFT JOIN room_allocations ra ON ra.room_id = r.id AND ra.status = 'Active'
  LEFT JOIN students s ON s.id = ra.student_id
`;

const normalizeRoom = (row) => {
  const students = row.students_csv
    ? row.students_csv.split(',').filter(Boolean).map((item) => {
        const [username, hostelRegisterNumber, id] = item.split('|');
        return {
          id: Number(id),
          username,
          hostel_register_number: hostelRegisterNumber,
          label: `${username}(${hostelRegisterNumber})`,
        };
      })
    : [];

  const occupied = Number(row.occupied || 0);
  return {
    id: row.id,
    roomId: row.room_id,
    room_id: row.room_id,
    floor: row.floor,
    room_type: row.room_type,
    room_number: row.room_number,
    capacity: row.capacity,
    occupied,
    current_occupancy: occupied,
    student_count: occupied,
    students,
    status: occupied > 0 ? 'Occupied' : 'Vacant',
    created_at: row.created_at,
    updated_at: row.updated_at,
  };
};

const roomIdFor = (floor, roomNumber) => `RM${roomNumber}`;

const recalculateRoomOccupancy = (roomId, callback = () => {}) => {
  db.run(
    `UPDATE rooms
     SET occupied = (
       SELECT COUNT(*) FROM room_allocations
       WHERE room_id = ? AND status = 'Active'
     ),
     current_occupancy = (
       SELECT COUNT(*) FROM room_allocations
       WHERE room_id = ? AND status = 'Active'
     ),
     updated_at = CURRENT_TIMESTAMP
     WHERE id = ?`,
    [roomId, roomId, roomId],
    callback
  );
};

const findRoom = (value, callback) => {
  db.get(
    `SELECT * FROM rooms WHERE id = ? OR room_id = ?`,
    [value, value],
    callback
  );
};

const findStudent = (value, callback) => {
  db.get(
    `SELECT id, username, hostel_register_number, email, phone FROM students
     WHERE id = ? OR hostel_register_number = ?`,
    [value, value],
    callback
  );
};

const getAllRooms = (req, res) => {
  try {
    db.all(
      `${roomSelect}
       GROUP BY r.id
       ORDER BY r.floor, r.room_number`,
      (err, rows) => {
        if (err) {
          return res.status(500).json({ success: false, message: 'Error fetching rooms' });
        }

        res.json({ success: true, data: rows.map(normalizeRoom) });
      }
    );
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getStudentRoom = (req, res) => {
  try {
    const studentId = req.user.userId;

    db.get(
      `SELECT r.id, r.room_id, r.floor, r.room_type, r.room_number, r.capacity
       FROM room_allocations ra
       JOIN rooms r ON r.id = ra.room_id
       WHERE ra.student_id = ? AND ra.status = 'Active'
       ORDER BY ra.allocated_at DESC
       LIMIT 1`,
      [studentId],
      (err, room) => {
        if (err) {
          return res.status(500).json({ success: false, message: 'Error fetching room' });
        }
        if (!room) {
          return res.json({ success: true, data: null });
        }

        db.all(
          `SELECT s.id, s.username, s.hostel_register_number
           FROM room_allocations ra
           JOIN students s ON s.id = ra.student_id
           WHERE ra.room_id = ? AND ra.status = 'Active'
           ORDER BY s.username`,
          [room.id],
          (studentErr, students) => {
            if (studentErr) {
              return res.status(500).json({ success: false, message: 'Error fetching occupants' });
            }

            res.json({
              success: true,
              data: {
                roomId: room.room_id,
                room_id: room.room_id,
                floor: room.floor,
                room_type: room.room_type,
                room_number: room.room_number,
                capacity: room.capacity,
                occupied: students.length,
                current_occupants: students.length,
                students,
                student_count: students.length,
              },
            });
          }
        );
      }
    );
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const createRoom = (req, res) => {
  try {
    const { floor, room_type, roomType, room_number, roomNumber, capacity } = req.body;
    const normalizedFloor = String(floor ?? '').trim();
    const normalizedRoomNumber = String(room_number ?? roomNumber ?? '').trim();
    const normalizedRoomType = String(room_type ?? roomType ?? '').trim();
    const normalizedCapacity = Number(capacity);

    if (!normalizedFloor || !normalizedRoomNumber || !normalizedRoomType || !Number.isInteger(normalizedCapacity) || normalizedCapacity <= 0) {
      return res.status(400).json({ success: false, message: 'Floor, room type, room number and valid capacity are required' });
    }

    db.run(
      `INSERT INTO rooms (room_id, floor, room_type, room_number, capacity, occupied, current_occupancy)
       VALUES (?, ?, ?, ?, ?, 0, 0)`,
      [roomIdFor(normalizedFloor, normalizedRoomNumber), normalizedFloor, normalizedRoomType, normalizedRoomNumber, normalizedCapacity],
      function (err) {
        if (err) {
          return res.status(400).json({ success: false, message: 'Room creation failed: ' + err.message });
        }

        res.status(201).json({ success: true, message: 'Room created', id: this.lastID });
      }
    );
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const updateRoom = (req, res) => {
  try {
    const { roomId } = req.params;
    const { floor, room_type, roomType, room_number, roomNumber, capacity } = req.body;
    const normalizedFloor = String(floor ?? '').trim();
    const normalizedRoomNumber = String(room_number ?? roomNumber ?? '').trim();
    const normalizedRoomType = String(room_type ?? roomType ?? '').trim();
    const normalizedCapacity = Number(capacity);

    if (!normalizedFloor || !normalizedRoomNumber || !normalizedRoomType || !Number.isInteger(normalizedCapacity) || normalizedCapacity <= 0) {
      return res.status(400).json({ success: false, message: 'Floor, room type, room number and valid capacity are required' });
    }

    findRoom(roomId, (findErr, room) => {
      if (findErr || !room) {
        return res.status(404).json({ success: false, message: 'Room not found' });
      }

      db.get(
        `SELECT COUNT(*) AS occupied FROM room_allocations WHERE room_id = ? AND status = 'Active'`,
        [room.id],
        (countErr, countRow) => {
          if (countErr) {
            return res.status(500).json({ success: false, message: 'Error checking room occupancy' });
          }
          if (Number(countRow.occupied) > normalizedCapacity) {
            return res.status(400).json({ success: false, message: 'Capacity cannot be less than current occupancy' });
          }

          db.run(
            `UPDATE rooms
             SET floor = ?, room_type = ?, room_number = ?, capacity = ?, room_id = ?, updated_at = CURRENT_TIMESTAMP
             WHERE id = ?`,
            [normalizedFloor, normalizedRoomType, normalizedRoomNumber, normalizedCapacity, roomIdFor(normalizedFloor, normalizedRoomNumber), room.id],
            (updateErr) => {
              if (updateErr) {
                return res.status(400).json({ success: false, message: 'Room update failed: ' + updateErr.message });
              }

              db.run(
                `UPDATE room_allocations SET floor = ?, room_number = ?, updated_at = CURRENT_TIMESTAMP WHERE room_id = ?`,
                [normalizedFloor, normalizedRoomNumber, room.id],
                () => res.json({ success: true, message: 'Room updated successfully' })
              );
            }
          );
        }
      );
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const updateRoomAllocation = (req, res) => {
  try {
    const { studentId } = req.params;
    const targetRoom = req.body?.room_id ?? req.body?.roomId;

    if (!targetRoom) {
      return res.status(400).json({ success: false, message: 'Target room is required' });
    }

    findStudent(studentId, (studentErr, student) => {
      if (studentErr || !student) {
        return res.status(404).json({ success: false, message: 'Student not found' });
      }

      findRoom(targetRoom, (roomErr, room) => {
        if (roomErr || !room) {
          return res.status(400).json({ success: false, message: 'Invalid target room' });
        }

        db.get(
          `SELECT COUNT(*) AS occupied FROM room_allocations WHERE room_id = ? AND status = 'Active'`,
          [room.id],
          (countErr, countRow) => {
            if (countErr) {
              return res.status(500).json({ success: false, message: 'Error checking room occupancy' });
            }

            const occupied = Number(countRow.occupied || 0);
            if (occupied >= Number(room.capacity)) {
              return res.status(400).json({ success: false, message: 'Room is full' });
            }

            db.get(
              `SELECT room_id FROM room_allocations WHERE student_id = ? AND status = 'Active'`,
              [student.id],
              (activeErr, activeAllocation) => {
                if (activeErr) {
                  return res.status(500).json({ success: false, message: 'Error checking existing allocation' });
                }
                if (activeAllocation && activeAllocation.room_id === room.id) {
                  return res.status(400).json({ success: false, message: 'Student already in this room' });
                }

                const oldRoomId = activeAllocation?.room_id;
                db.serialize(() => {
                  db.run('BEGIN TRANSACTION');
                  db.run(
                    `DELETE FROM room_allocations WHERE student_id = ?`,
                    [student.id],
                    (deleteErr) => {
                      if (deleteErr) {
                        db.run('ROLLBACK');
                        return res.status(500).json({ success: false, message: 'Unable to clear previous allocation' });
                      }

                      db.run(
                        `INSERT INTO room_allocations
                         (allocation_id, student_id, user_id, room_id, floor, room_number, allocation_date, allocated_at, status)
                         VALUES (?, ?, ?, ?, ?, ?, CURRENT_DATE, CURRENT_TIMESTAMP, 'Active')`,
                        [`AL${Date.now()}`, student.id, student.hostel_register_number, room.id, room.floor, room.room_number],
                        (insertErr) => {
                          if (insertErr) {
                            db.run('ROLLBACK');
                            return res.status(500).json({ success: false, message: 'Unable to allocate student: ' + insertErr.message });
                          }

                          db.run(
                            `UPDATE students SET floor = ?, room_number = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
                            [room.floor, room.room_number, student.id],
                            (studentUpdateErr) => {
                              if (studentUpdateErr) {
                                db.run('ROLLBACK');
                                return res.status(500).json({ success: false, message: 'Unable to update student room details' });
                              }

                              recalculateRoomOccupancy(room.id, (newCountErr) => {
                                if (newCountErr) {
                                  db.run('ROLLBACK');
                                  return res.status(500).json({ success: false, message: 'Unable to update occupancy' });
                                }
                                if (oldRoomId) {
                                  recalculateRoomOccupancy(oldRoomId);
                                }
                                db.run('COMMIT');
                                res.json({ success: true, message: 'Student allocated successfully' });
                              });
                            }
                          );
                        }
                      );
                    }
                  );
                });
              }
            );
          }
        );
      });
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const removeRoomAllocation = (req, res) => {
  try {
    const { studentId } = req.params;

    findStudent(studentId, (studentErr, student) => {
      if (studentErr || !student) {
        return res.status(404).json({ success: false, message: 'Student not found' });
      }

      db.get(
        `SELECT room_id FROM room_allocations WHERE student_id = ? AND status = 'Active'`,
        [student.id],
        (activeErr, activeAllocation) => {
          if (activeErr) {
            return res.status(500).json({ success: false, message: 'Error fetching allocation' });
          }

          db.run(
            `DELETE FROM room_allocations WHERE student_id = ?`,
            [student.id],
            (deleteErr) => {
              if (deleteErr) {
                return res.status(500).json({ success: false, message: 'Update failed' });
              }

              db.run(
                `UPDATE students SET floor = NULL, room_number = NULL, updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
                [student.id],
                (studentUpdateErr) => {
                  if (studentUpdateErr) {
                    return res.status(500).json({ success: false, message: 'Unable to update student room details' });
                  }

                  if (activeAllocation?.room_id) {
                    recalculateRoomOccupancy(activeAllocation.room_id);
                  }
                  res.json({ success: true, message: 'Removed from room' });
                }
              );
            }
          );
        }
      );
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getRoomsWithStudents = getAllRooms;

const getUnallocatedStudents = (req, res) => {
  try {
    db.all(
      `SELECT s.id, s.username, s.hostel_register_number, s.email, s.phone
       FROM students s
       LEFT JOIN room_allocations ra ON ra.student_id = s.id AND ra.status = 'Active'
       WHERE ra.id IS NULL
       ORDER BY s.username`,
      (err, rows) => {
        if (err) {
          return res.status(500).json({ success: false, message: 'Error fetching students' });
        }
        res.json({ success: true, data: rows });
      }
    );
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const filterRoomsByFloor = (req, res) => {
  try {
    const { floor } = req.query;
    db.all(
      `${roomSelect}
       WHERE r.floor = ?
       GROUP BY r.id
       ORDER BY r.room_number`,
      [floor],
      (err, rows) => {
        if (err) {
          return res.status(500).json({ success: false, message: 'Error fetching rooms' });
        }
        res.json({ success: true, data: rows.map(normalizeRoom) });
      }
    );
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const filterRoomsByStatus = (req, res) => {
  try {
    const { status } = req.query;
    db.all(
      `${roomSelect}
       GROUP BY r.id
       ORDER BY r.floor, r.room_number`,
      (err, rows) => {
        if (err) {
          return res.status(500).json({ success: false, message: 'Error fetching rooms' });
        }
        const rooms = rows.map(normalizeRoom);
        const filtered = rooms.filter((room) =>
          status === 'Occupied' ? room.occupied > 0 : room.occupied === 0
        );
        res.json({ success: true, data: filtered });
      }
    );
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const searchRooms = (req, res) => {
  try {
    const { query } = req.query;
    db.all(
      `${roomSelect}
       WHERE r.room_number LIKE ? OR r.floor LIKE ? OR r.room_type LIKE ?
       GROUP BY r.id
       ORDER BY r.floor, r.room_number`,
      [`%${query}%`, `%${query}%`, `%${query}%`],
      (err, rows) => {
        if (err) {
          return res.status(500).json({ success: false, message: 'Search failed' });
        }
        res.json({ success: true, data: rows.map(normalizeRoom) });
      }
    );
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getAllRooms,
  getStudentRoom,
  updateRoomAllocation,
  updateRoom,
  createRoom,
  removeRoomAllocation,
  getRoomsWithStudents,
  getUnallocatedStudents,
  filterRoomsByFloor,
  filterRoomsByStatus,
  searchRooms,
};
