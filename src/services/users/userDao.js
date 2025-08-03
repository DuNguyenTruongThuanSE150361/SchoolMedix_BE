import { query } from "../../config/database.js";
import { generateStudentCode, updateProfileFor } from "./userUtils.js";

export async function insertAdmin(
  supabase_uid = null,
  email = null,
  name,
  dob,
  isMale,
  address,
  phone_number = null,
  profile_img_url = process.env.DEFAULT_AVATAR_URL
) {
  const result = await query(
    `
    INSERT INTO Admin (
      supabase_uid, email, name, dob, isMale, address,
      phone_number, profile_img_url
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
    RETURNING *
  `,
    [
      supabase_uid,
      email,
      name,
      dob,
      isMale,
      address,
      phone_number,
      profile_img_url,
    ]
  );
  return result.rows[0];
}

export async function insertNurse(
  supabase_uid = null,
  email = null,
  name,
  dob,
  isMale,
  address,
  phone_number = null,
  profile_img_url = process.env.DEFAULT_AVATAR_URL
) {
  const result = await query(
    `
    INSERT INTO Nurse (
      supabase_uid, email, name, dob, isMale, address,
      phone_number, profile_img_url
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
    RETURNING *
  `,
    [
      supabase_uid,
      email,
      name,
      dob,
      isMale,
      address,
      phone_number,
      profile_img_url,
    ]
  );
  return result.rows[0];
}

export async function insertParent(
  supabase_uid,
  email = null,
  name,
  dob,
  isMale,
  address,
  phone_number = null,
  profile_img_url = process.env.DEFAULT_AVATAR_URL
) {
  const result = await query(
    `
    INSERT INTO Parent (
      supabase_uid, email, name, dob, isMale, address,
      phone_number, profile_img_url
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
    RETURNING *
  `,
    [
      supabase_uid,
      email,
      name,
      dob,
      isMale,
      address,
      phone_number,
      profile_img_url,
    ]
  );
  return result.rows[0];
}

export async function insertStudent(
  supabase_uid = null,
  email = null,
  name,
  dob,
  isMale,
  address,
  phone_number = null,
  profile_img_url = process.env.DEFAULT_AVATAR_URL,
  class_id,
  year_of_enrollment,
  home_id = null
) {
  const student_id = await generateStudentCode(year_of_enrollment);

  const result = await query(
    `
    INSERT INTO Student (
      id, supabase_uid, email, name, dob, isMale, address,
      phone_number, profile_img_url, year_of_enrollment, class_id, home_id
    ) 
    VALUES (
      $1, $2, $3, $4, $5, $6, $7,
      $8, $9, $10, $11, $12
    ) RETURNING *
  `,
    [
      student_id,
      supabase_uid,
      email,
      name,
      dob,
      isMale,
      address,
      phone_number,
      profile_img_url,
      year_of_enrollment,
      class_id,
      home_id
    ]
  );

  return result.rows[0];
}

export async function getProfileOfAdminByID(admin_Id) {
  const result = await query(
    `select 'admin' as role, * from admin where id = $1 and is_deleted = false`,
    [admin_Id]
  );
  return result.rows[0];
}

export async function getProfileOfNurseByID(nurse_id) {
  const result = await query(
    `SELECT 'nurse' as role, * FROM nurse WHERE id = $1 and is_deleted = false`,
    [nurse_id]
  );
  return result.rows[0];
}

export async function getProfileOfParentByID(parent_id) {
  const result = await query(
    ` 
  SELECT 
  p.id,
  'parent' as role,
  p.supabase_uid,
  p.email,
  p.name,
  p.dob,
  DATE_PART('year', AGE(p.dob)) AS age,
  p.isMale,
  p.address,
  p.phone_number,
  p.profile_img_url,
  p.email_confirmed,
  p.last_invitation_at,
  p.created_at,
  h.id AS home_id,
  p.profile_updated,
  COALESCE(
    json_agg(
      json_build_object(
        'id', s.id,
        'supabase_uid', s.supabase_uid,
        'email', s.email,
        'name', s.name,
        'age', DATE_PART('year', AGE(s.dob)),
        'dob', s.dob,
        'isMale', s.isMale,
        'address', s.address,
        'phone_number', s.phone_number,
        'profile_img_url', s.profile_img_url,
        'year_of_enrollment', s.year_of_enrollment,
        'email_confirmed', s.email_confirmed,
        'class_id', c.id,
        'class_name', c.name,
        'mom_id', h.mom_id,
        'dad_id', h.dad_id,
        'last_invitation_at', s.last_invitation_at,
        'created_at', s.created_at
      )
    ) FILTER (WHERE s.id IS NOT NULL AND s.is_deleted = false),
    '[]'
  ) AS children

FROM parent p
LEFT JOIN home h ON h.mom_id = p.id OR h.dad_id = p.id
LEFT JOIN student s ON s.home_id = h.id
LEFT JOIN class c ON c.id = s.class_id
WHERE p.id = $1 AND p.is_deleted = false
GROUP BY p.id, h.id;


`,
    [parent_id]
  );
  return result.rows[0];
}

export async function getProfileOfStudentByID(student_id) {
  const result = await query(
    `
SELECT 
  s.id,
  s.supabase_uid,
  'student' as role,
  s.email,
  s.name,
  s.dob,
  DATE_PART('year', AGE(s.dob)) AS age,
  s.isMale,
  s.address,
  s.phone_number,
  s.profile_img_url,
  s.year_of_enrollment,
  s.email_confirmed,
  s.class_id,
  c.name AS class_name,
  s.last_invitation_at,
  s.created_at,
  s.home_id,
  h.mom_id,
  h.dad_id,

  CASE
    WHEN h.mom_id IS NOT NULL AND m.is_deleted = false THEN json_build_object(
      'id', m.id,
      'name', m.name,
      'dob', m.dob,
      'age', DATE_PART('year', AGE(m.dob)),
      'email', m.email,
      'phone_number', m.phone_number,
      'isMale', m.isMale,
      'address', m.address,
      'profile_img_url', m.profile_img_url,
      'supabase_uid', m.supabase_uid,
      'email_confirmed', m.email_confirmed,
      'last_invitation_at', m.last_invitation_at,
      'created_at', m.created_at,
      'profile_updated', m.profile_updated
    )
    ELSE NULL
  END AS mom_profile,

  CASE
    WHEN h.dad_id IS NOT NULL AND d.is_deleted = false THEN json_build_object(
      'id', d.id,
      'name', d.name,
      'dob', d.dob,
      'age', DATE_PART('year', AGE(d.dob)),
      'email', d.email,
      'phone_number', d.phone_number,
      'isMale', d.isMale,
      'address', d.address,
      'profile_img_url', d.profile_img_url,
      'supabase_uid', d.supabase_uid,
      'email_confirmed', d.email_confirmed,
      'last_invitation_at', d.last_invitation_at,
      'created_at', d.created_at,
      'profile_updated', d.profile_updated
    )
    ELSE NULL
  END AS dad_profile

FROM student s
LEFT JOIN home h ON h.id = s.home_id
LEFT JOIN parent m ON m.id = h.mom_id
LEFT JOIN parent d ON d.id = h.dad_id
JOIN class c ON c.id = s.class_id
WHERE s.id = $1 AND s.is_deleted = false;



`,
    [student_id]
  );
  return result.rows[0];
}
// Admin
export async function getProfileOfAdminByUUID(supabase_uid) {
  const result = await query(
    `SELECT 'admin' AS role, * FROM admin WHERE supabase_uid = $1 and is_deleted = false`,
    [supabase_uid]
  );
  return result.rows[0];
}

// Nurse
export async function getProfileOfNurseByUUID(supabase_uid) {
  const result = await query(
    `SELECT 'nurse' AS role, * FROM nurse WHERE supabase_uid = $1 and is_deleted = false`,
    [supabase_uid]
  );
  return result.rows[0];
}

// Parent
export async function getProfileOfParentByUUID(supabase_uid) {
  const result = await query(
    `SELECT 
      'parent' AS role,
      p_with_students.*
    FROM (
      SELECT 
        p.id,
        p.supabase_uid,
        p.email,
        p.name,
        p.dob,
        DATE_PART('year', AGE(p.dob)) AS age,
        p.isMale,
        p.address,
        p.phone_number,
        p.profile_img_url,
        p.email_confirmed,
        p.last_invitation_at,
        p.created_at,
        p.profile_updated,
        h.id AS home_id,

        COALESCE(
          json_agg(
            json_build_object(
              'id', s.id,
              'supabase_uid', s.supabase_uid,
              'email', s.email,
              'name', s.name,
              'age', DATE_PART('year', AGE(s.dob)),
              'dob', s.dob,
              'isMale', s.isMale,
              'address', s.address,
              'phone_number', s.phone_number,
              'profile_img_url', s.profile_img_url,
              'year_of_enrollment', s.year_of_enrollment,
              'email_confirmed', s.email_confirmed,
              'class_id', c.id,
              'class_name', c.name,
              'home_id', s.home_id,
              'mom_id', h.mom_id,
              'dad_id', h.dad_id,
              'last_invitation_at', s.last_invitation_at,
              'created_at', s.created_at
            )
          ) FILTER (WHERE s.id IS NOT NULL AND s.is_deleted = false),
          '[]'
        ) AS students

      FROM parent p
      LEFT JOIN home h ON h.mom_id = p.id OR h.dad_id = p.id
      LEFT JOIN student s ON s.home_id = h.id
      LEFT JOIN class c ON c.id = s.class_id
      WHERE p.supabase_uid = $1 AND p.is_deleted = false
      GROUP BY p.id, h.id
    ) p_with_students;
    `,
    [supabase_uid]
  );
  return result.rows[0];
}


// Student
export async function getProfileOfStudentByUUID(supabase_uid) {
  const result = await query(
    `SELECT 
      'student' AS role,
      s.id,
      s.supabase_uid,
      s.email,
      s.name,
      s.dob,
      DATE_PART('year', AGE(s.dob)) AS age,
      s.isMale,
      s.address,
      s.phone_number,
      s.profile_img_url,
      s.year_of_enrollment,
      s.email_confirmed,
      s.class_id,
      c.name AS class_name,
      g.name as grade_name,
      g.id as grade_id,
      s.home_id,
      h.mom_id,
      h.dad_id,
      s.last_invitation_at,
      s.created_at,

      CASE
        WHEN h.mom_id IS NOT NULL AND m.is_deleted = false THEN json_build_object(
          'id', m.id,
          'name', m.name,
          'dob', m.dob,
          'age', DATE_PART('year', AGE(m.dob)),
          'email', m.email,
          'phone_number', m.phone_number,
          'isMale', m.isMale,
          'address', m.address,
          'profile_img_url', m.profile_img_url,
          'supabase_uid', m.supabase_uid,
          'email_confirmed', m.email_confirmed,
          'last_invitation_at', m.last_invitation_at,
          'created_at', m.created_at,
          'profile_updated', m.profile_updated
        )
        ELSE NULL
      END AS mom_profile,

      CASE
        WHEN h.dad_id IS NOT NULL AND d.is_deleted = false THEN json_build_object(
          'id', d.id,
          'name', d.name,
          'dob', d.dob,
          'age', DATE_PART('year', AGE(d.dob)),
          'email', d.email,
          'phone_number', d.phone_number,
          'isMale', d.isMale,
          'address', d.address,
          'profile_img_url', d.profile_img_url,
          'supabase_uid', d.supabase_uid,
          'email_confirmed', d.email_confirmed,
          'last_invitation_at', d.last_invitation_at,
          'created_at', d.created_at,
          'profile_updated', d.profile_updated
        )
        ELSE NULL
      END AS dad_profile

    FROM student s
    LEFT JOIN home h ON h.id = s.home_id
    LEFT JOIN parent m ON m.id = h.mom_id
    LEFT JOIN parent d ON d.id = h.dad_id
    JOIN class c ON c.id = s.class_id
    JOIN grade g ON g.id = c.grade_id
    WHERE s.supabase_uid = $1 AND s.is_deleted = false;
    `,
    [supabase_uid]
  );
  return result.rows[0];
}

export async function getAllAdmins() {
  const result = await query(
    `SELECT 'admin' as role, * FROM admin where is_deleted = false ORDER BY id `
  );
  return result.rows;
}

export async function getAllNurses() {
  const result = await query(
    `SELECT 'nurse' as role, * FROM nurse where is_deleted = false ORDER BY id`
  );
  return result.rows;
}

export async function getAllParents() {
  const result = await query(`
    SELECT 
  row_to_json(p_with_students) AS parent_profile
FROM (
  SELECT 
    p.id,
    'parent' AS role,
    p.supabase_uid,
    p.email,
    p.name,
    p.dob,
    DATE_PART('year', AGE(p.dob)) AS age,
    p.isMale,
    p.address,
    p.phone_number,
    p.profile_img_url,
    p.email_confirmed,
    p.last_invitation_at,
    p.created_at,
    p.profile_updated,
    h.id AS home_id,

    COALESCE(
      json_agg(
        json_build_object(
          'id', s.id,
          'supabase_uid', s.supabase_uid,
          'email', s.email,
          'name', s.name,
          'age', DATE_PART('year', AGE(s.dob)),
          'dob', s.dob,
          'isMale', s.isMale,
          'address', s.address,
          'phone_number', s.phone_number,
          'profile_img_url', s.profile_img_url,
          'year_of_enrollment', s.year_of_enrollment,
          'email_confirmed', s.email_confirmed,
          'class_id', c.id,
          'class_name', c.name,
          'home_id', s.home_id,
          'mom_id', h.mom_id,
          'dad_id', h.dad_id,
          'last_invitation_at', s.last_invitation_at,
          'created_at', s.created_at
        )
      ) FILTER (
        WHERE s.id IS NOT NULL AND s.is_deleted = false
      ),
      '[]'
    ) AS students

  FROM parent p
  LEFT JOIN home h ON h.mom_id = p.id OR h.dad_id = p.id
  LEFT JOIN student s ON s.home_id = h.id
  LEFT JOIN class c ON c.id = s.class_id
  WHERE p.is_deleted = false
  GROUP BY p.id, h.id
  ORDER BY p.id
) p_with_students;

  `);

  return result.rows.map((row) => row.parent_profile);
}

export async function getAllStudents() {
  const result = await query(`
    SELECT json_build_object(
      'id', s.id,
      'role', 'student',
      'supabase_uid', s.supabase_uid,
      'email', s.email,
      'name', s.name,
      'dob', s.dob,
      'age', DATE_PART('year', AGE(s.dob)),
      'isMale', s.isMale,
      'address', s.address,
      'phone_number', s.phone_number,
      'profile_img_url', s.profile_img_url,
      'year_of_enrollment', s.year_of_enrollment,
      'email_confirmed', s.email_confirmed,
      'class_id', c.id,
      'class_name', c.name,
      'grade_id', g.id,
      'grade_name', g.name,
      'home_id', h.id,
      'mom_id', h.mom_id,
      'dad_id', h.dad_id,
      'last_invitation_at', s.last_invitation_at,
      'created_at', s.created_at,

      'mom_profile', CASE
        WHEN h.mom_id IS NOT NULL AND m.is_deleted = false THEN json_build_object(
          'id', m.id,
          'name', m.name,
          'dob', m.dob,
          'age', DATE_PART('year', AGE(m.dob)),
          'email', m.email,
          'phone_number', m.phone_number,
          'isMale', m.isMale,
          'address', m.address,
          'profile_img_url', m.profile_img_url,
          'supabase_uid', m.supabase_uid,
          'email_confirmed', m.email_confirmed,
          'last_invitation_at', m.last_invitation_at,
          'created_at', m.created_at,
          'profile_updated', m.profile_updated
        )
        ELSE NULL
      END,

      'dad_profile', CASE
        WHEN h.dad_id IS NOT NULL AND d.is_deleted = false THEN json_build_object(
          'id', d.id,
          'name', d.name,
          'dob', d.dob,
          'age', DATE_PART('year', AGE(d.dob)),
          'email', d.email,
          'phone_number', d.phone_number,
          'isMale', d.isMale,
          'address', d.address,
          'profile_img_url', d.profile_img_url,
          'supabase_uid', d.supabase_uid,
          'email_confirmed', d.email_confirmed,
          'last_invitation_at', d.last_invitation_at,
          'created_at', d.created_at,
          'profile_updated', d.profile_updated
        )
        ELSE NULL
      END
    ) AS student_profile
    FROM student s
    LEFT JOIN home h ON h.id = s.home_id
    LEFT JOIN parent m ON m.id = h.mom_id
    LEFT JOIN parent d ON d.id = h.dad_id
    LEFT JOIN class c ON c.id = s.class_id
    LEFT JOIN grade g ON g.id = c.grade_id
    WHERE s.is_deleted = false
    ORDER BY s.id;
  `);

  return result.rows.map((row) => row.student_profile);
}

export async function getAllStudentsByClassID(class_id) {
  const result = await query(`
    SELECT json_build_object(
      'id', s.id,
      'role', 'student',
      'supabase_uid', s.supabase_uid,
      'email', s.email,
      'name', s.name,
      'dob', s.dob,
      'age', DATE_PART('year', AGE(s.dob)),
      'isMale', s.isMale,
      'address', s.address,
      'phone_number', s.phone_number,
      'profile_img_url', s.profile_img_url,
      'year_of_enrollment', s.year_of_enrollment,
      'email_confirmed', s.email_confirmed,
      'class_id', c.id,
      'class_name', c.name,
      'home_id', h.id,
      'mom_id', h.mom_id,
      'dad_id', h.dad_id,
      'last_invitation_at', s.last_invitation_at,
      'created_at', s.created_at,

      'mom_profile', CASE
        WHEN h.mom_id IS NOT NULL AND m.is_deleted = false THEN json_build_object(
          'id', m.id,
          'name', m.name,
          'dob', m.dob,
          'age', DATE_PART('year', AGE(m.dob)),
          'email', m.email,
          'phone_number', m.phone_number,
          'isMale', m.isMale,
          'address', m.address,
          'profile_img_url', m.profile_img_url,
          'supabase_uid', m.supabase_uid,
          'email_confirmed', m.email_confirmed,
          'last_invitation_at', m.last_invitation_at,
          'created_at', m.created_at,
          'profile_updated', m.profile_updated
        )
        ELSE NULL
      END,

      'dad_profile', CASE
        WHEN h.dad_id IS NOT NULL AND d.is_deleted = false THEN json_build_object(
          'id', d.id,
          'name', d.name,
          'dob', d.dob,
          'age', DATE_PART('year', AGE(d.dob)),
          'email', d.email,
          'phone_number', d.phone_number,
          'isMale', d.isMale,
          'address', d.address,
          'profile_img_url', d.profile_img_url,
          'supabase_uid', d.supabase_uid,
          'email_confirmed', d.email_confirmed,
          'last_invitation_at', d.last_invitation_at,
          'created_at', d.created_at,
          'profile_updated', d.profile_updated
        )
        ELSE NULL
      END
    ) AS student_profile
    FROM student s
    LEFT JOIN home h ON h.id = s.home_id
    LEFT JOIN parent m ON m.id = h.mom_id
    LEFT JOIN parent d ON d.id = h.dad_id
    LEFT JOIN class c ON c.id = s.class_id
    WHERE s.is_deleted = false AND c.id = $1
    ORDER BY s.id;
  `, [class_id]);

  return result.rows.map((row) => row.student_profile);
}

export async function getAllStudentsByGradeID(grade_id) {
  const result = await query(`
    SELECT json_build_object(
      'id', s.id,
      'supabase_uid', s.supabase_uid,
      'role', 'student',
      'email', s.email,
      'name', s.name,
      'dob', s.dob,
      'age', DATE_PART('year', AGE(s.dob)),
      'isMale', s.isMale,
      'address', s.address,
      'phone_number', s.phone_number,
      'profile_img_url', s.profile_img_url,
      'year_of_enrollment', s.year_of_enrollment,
      'email_confirmed', s.email_confirmed,
      'class_id', c.id,
      'class_name', c.name,
      'grade_id', g.id,
      'grade_name', g.name,
      'home_id', h.id,
      'mom_id', h.mom_id,
      'dad_id', h.dad_id,
      'last_invitation_at', s.last_invitation_at,
      'created_at', s.created_at,

      'mom_profile', CASE
        WHEN h.mom_id IS NOT NULL AND m.is_deleted = false THEN json_build_object(
          'id', m.id,
          'name', m.name,
          'dob', m.dob,
          'age', DATE_PART('year', AGE(m.dob)),
          'email', m.email,
          'phone_number', m.phone_number,
          'isMale', m.isMale,
          'address', m.address,
          'profile_img_url', m.profile_img_url,
          'supabase_uid', m.supabase_uid,
          'email_confirmed', m.email_confirmed,
          'last_invitation_at', m.last_invitation_at,
          'created_at', m.created_at,
          'profile_updated', m.profile_updated
        )
        ELSE NULL
      END,

      'dad_profile', CASE
        WHEN h.dad_id IS NOT NULL AND d.is_deleted = false THEN json_build_object(
          'id', d.id,
          'name', d.name,
          'dob', d.dob,
          'age', DATE_PART('year', AGE(d.dob)),
          'email', d.email,
          'phone_number', d.phone_number,
          'isMale', d.isMale,
          'address', d.address,
          'profile_img_url', d.profile_img_url,
          'supabase_uid', d.supabase_uid,
          'email_confirmed', d.email_confirmed,
          'last_invitation_at', d.last_invitation_at,
          'created_at', d.created_at,
          'profile_updated', d.profile_updated
        )
        ELSE NULL
      END
    ) AS student_profile
    FROM student s
    LEFT JOIN home h ON h.id = s.home_id
    LEFT JOIN parent m ON m.id = h.mom_id
    LEFT JOIN parent d ON d.id = h.dad_id
    LEFT JOIN class c ON c.id = s.class_id
    LEFT JOIN grade g ON g.id = c.grade_id
    WHERE s.is_deleted = false AND c.grade_id = $1
    ORDER BY s.id;
  `, [grade_id]);

  return result.rows.map((row) => row.student_profile);
}

export async function linkParentsAndStudents(mom_id, dad_id, student_ids) {
  if (!Array.isArray(student_ids) || student_ids.length === 0) {
    throw new Error("Danh sách học sinh không hợp lệ.");
  }

  const result = await query(
    `
    UPDATE student
    SET
      mom_id = COALESCE($1, mom_id),
      dad_id = COALESCE($2, dad_id)
    WHERE id = ANY($3::text[])
    RETURNING id, mom_id, dad_id
  `,
    [mom_id, dad_id, student_ids]
  );

  return result.rows;
}

export async function removeMomByStudentId(student_id) {
  const result = await query(
    `UPDATE student SET mom_id = NULL WHERE id = $1 RETURNING id, mom_id`,
    [student_id]
  );
  return result.rows;
}

export async function removeDadByStudentId(student_id) {
  const result = await query(
    `UPDATE student SET dad_id = NULL WHERE id = $1 RETURNING id, dad_id`,
    [student_id]
  );
  return result.rows;
}

//---------------------------------------------------- update flow:

// admin is able to update all
export async function editUserProfileByAdmin(id, role, updates) {
  return await updateProfileFor(id, role, updates);
}

// below is used for self info modification
export async function updateAdminProfile(id, updates) {
  const allowedFields = ["address", "profile_img_url", "phone_number"];
  const filteredUpdates = Object.fromEntries(
    Object.entries(updates).filter(([key]) => allowedFields.includes(key))
  );

  if (Object.keys(filteredUpdates).length === 0) {
    throw new Error(
      "Chỉ được phép cập nhật trường địa chỉ, ảnh đại diện và số điện thoại."
    );
  }
  return await updateProfileFor(id, "admin", updates);
}

export async function updateNurseProfile(id, updates) {
  const allowedFields = ["address", "profile_img_url", "phone_number"];
  const filteredUpdates = Object.fromEntries(
    Object.entries(updates).filter(([key]) => allowedFields.includes(key))
  );

  if (Object.keys(filteredUpdates).length === 0) {
    throw new Error(
      "Chỉ được phép cập nhật trường địa chỉ, ảnh đại diện và số điện thoại."
    );
  }
  return await updateProfileFor(id, "nurse", updates);
}

// parent và student chỉ được update address, profile_img_url, phone_number
export async function updateStudentProfile(id, updates) {
  const allowedFields = ["address", "profile_img_url", "phone_number"];
  const filteredUpdates = Object.fromEntries(
    Object.entries(updates).filter(([key]) => allowedFields.includes(key))
  );

  if (Object.keys(filteredUpdates).length === 0) {
    throw new Error(
      "Chỉ được phép cập nhật trường địa chỉ, ảnh đại diện và số điện thoại."
    );
  }

  return await updateProfileFor(id, "student", filteredUpdates);
}

export async function updateParentProfile(id, updates) {
  const allowedFields = ["address", "profile_img_url", "phone_number"];
  const filteredUpdates = Object.fromEntries(
    Object.entries(updates).filter(([key]) => allowedFields.includes(key))
  );

  if (Object.keys(filteredUpdates).length === 0) {
    throw new Error(
      "Chỉ được phép cập nhật trường địa chỉ, ảnh đại diện và số điện thoại."
    );
  }

  return await updateProfileFor(id, "parent", filteredUpdates);
}

export async function deleteAccount(id, role) {
  const result = await query(
    `
    update ${role}
    set email_confirmed = false, last_invitation_at = null, supabase_uid = null, email = null
    where id = $1
    `,
    [id]
  )

  return result.rows > 0;
}

//---------------------------------------------------- end update flow:
export async function confirmEmailFor(role, id) {
  const result = await query(
    `
    update ${role}
    set email_confirmed = true
    where id = $1
    returning *
    `,
    [id]
  );
  return result.rows[0];
}

export async function unconfirmEmailFor(role, id) {
  const result = await query(
    `
    update ${role}
    set email_confirmed = false
    where id = $1
    returning *
    `,
    [id]
  );
  return result.rows[0];
}

export async function getSupabaseUIDOfAUser(role, id) {
  const result = await query(
    `SELECT supabase_uid FROM ${role} WHERE id = $1 LIMIT 1`,
    [id]
  );

  if (result.rows.length === 0) return null;

  return result.rows[0].supabase_uid;
}

export async function getProfileByUUID(role, supabase_uid) {
  if (!supabase_uid || !role) return null;

  switch (role) {
    case "admin":
      return await getProfileOfAdminByUUID(supabase_uid);

    case "nurse":
      return await getProfileOfNurseByUUID(supabase_uid);

    case "parent":
      return await getProfileOfParentByUUID(supabase_uid);

    case "student":
      return await getProfileOfStudentByUUID(supabase_uid);

    default:
      throw new Error("Role không hợp lệ");
  }
}

export async function getProfileByID(role, id) {
  if (!id || !role) return null;

  switch (role) {
    case "admin":
      return await getProfileOfAdminByID(id);

    case "nurse":
      return await getProfileOfNurseByID(id);

    case "parent":
      return await getProfileOfParentByID(id);

    case "student":
      return await getProfileOfStudentByID(id);

    default:
      throw new Error("Role không hợp lệ");
  }
}

export async function deleteUserByID(role, id) {
  const sql = `update ${role} set is_deleted = true, supabase_uid = null, email = null WHERE id = $1 returning *;`;
  const result = await query(sql, [id]);
  return result.rows[0];
}

export async function updateLastInvitationAtByID(id, role) {
  const sql = `update ${role} set last_invitation_at = now() where id = '${id}' returning *`;
  const result = await query(sql);
  return result.rowCount > 0;
}

export async function updateLastInvitationAtByUUID(supabase_uid, role) {
  const sql = `update ${role} set last_invitation_at = now() where supabase_uid = '${supabase_uid}' returning *`;
  const result = await query(sql);
  return result.rowCount > 0;
}


export async function updateAccount(id, role, email, supabase_uid) {
  const result = await query(`
    update ${role}
    set email = $1, supabase_uid = $2
    where id = $3
  `, [email, supabase_uid, id]);

  return result.rowCount > 0;
}