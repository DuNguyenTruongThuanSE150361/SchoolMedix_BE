import { query } from "../config/database.js";
import { sendCheckupRegister } from "../services/email/index.js";
import { excelToJson } from "../services/excel/importExcel.js";
import { generatePDFBufferFromHealthRecord } from "../services/pdf/index.js";
import {
  retrieveFileFromSupabaseStorage,
  uploadFileToSupabaseStorage,
} from "../services/supabase-storage/index.js";
import multer from "multer";
import exceljs from "exceljs";
import { admin } from "../config/supabase.js";
import { generatePDFBufferForFinalHealthReport } from "../services/index.js";
import { getProfileOfStudentByID } from "../services/index.js";
import { PDFDocument } from "pdf-lib";
import axios from "axios";

const BUCKET = process.env.SUPABASE_BUCKET || "diagnosis-url";

export async function getAllHealthRecordOfStudent(req, res) {
  const { student_id } = req.params;

  if (!student_id) {
    return res.status(400).json({
      error: true,
      message: "Không nhận được Student.",
    });
  }

  try {
    const check = await query(
      `SELECT * FROM student 
                                    WHERE id = $1`,
      [student_id]
    );
    if (check.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Student ID không tồn tại.",
      });
    }

    const rs = await query(
      `
SELECT
    s.id AS student_id,
    s.name AS student_name,
    hr.*
FROM
    HealthRecord hr
JOIN
    CheckupRegister cr ON hr.register_id = cr.id
JOIN
    Student s ON cr.student_id = s.id
WHERE
    s.id = $1`,
      [student_id]
    );

    const result = rs.rows;

    if (result.length === 0) {
      return res.status(200).json({
        error: false,
        message: "Không có Health Record",
        data: [],
      });
    }

    return res.status(200).json({
      error: false,
      message: "Lấy Health Record Thành Công",
      data: result,
    });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi server khi lấy Health Record." });
  }
}

export async function createCampaign(req, res) {
  const {
    name,
    description,
    location,
    start_date,
    end_date,
    specialist_exam_ids, // Admin chon các Special  Exam List
  } = req.body;

  if (
    !name ||
    !description ||
    !location ||
    !start_date ||
    !end_date ||
    !Array.isArray(specialist_exam_ids)
  ) {
    return res
      .status(400)
      .json({ error: true, message: "Thiếu các thông tin cần thiết." });
  }

  try {
    // STEPT 1: Tạo mới Campaign
    const result_campaign = await query(
      `INSERT INTO CheckupCampaign 
            (name, description, location, start_date, end_date) 
            VALUES ($1, $2, $3, $4, $5) 
            RETURNING *`,
      [name, description, location, start_date, end_date]
    );

    const campaign = result_campaign.rows[0]; //Lấy Record đầu tiên trong  ( Phải có RETURNING mới có Record)
    if (campaign === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Create Campaign không thành công." });
    }

    //STEP 2: Tạo mới campagincontainsspeexam
    if (Array.isArray(specialist_exam_ids)) {
      for (const exam_id of specialist_exam_ids) {
        const result_campagincontain = await query(
          "INSERT INTO CampaignContainSpeExam (campaign_id,specialist_exam_id) VALUES ($1,$2) RETURNING *",
          [campaign.id, exam_id]
        );

        if (result_campagincontain.rowCount === 0) {
          return res.status(400).json({
            error: true,
            message: "Create Campagincontainsspeexam không thành công.",
          });
        }
      }
    }

    return res
      .status(200)
      .json({ error: false, message: "Create Campaign Thành Công" });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi server khi tạo mới Campaign." });
  }
}

//Truyền vào ID campaign để gửi Register cho phụ huynh ( Status: PREPARING --> UPCOMING )
export async function sendRegister(req, res) {
  const { campaign_id } = req.params;

  try {
    if (!campaign_id) {
      return res.status(400).json({
        error: true,
        message: "Không nhận được ID.",
      });
    }

    const check = await query(
      `SELECT * FROM checkupcampaign
                                   WHERE id = $1`,
      [campaign_id]
    );

    if (check.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Không tồn tại Campaign ID.",
      });
    }

    //Step 1: Lấy tất cả danh sách Student
    const rs_student = await query(`SELECT * FROM student`);
    const list = rs_student.rows;

    if (list.length === 0) {
      return res.status(400).json({
        error: true,
        message: "Không lấy được danh sách Student.",
      });
    }
    // Step 2: Tạo Register

    const checkup_register = [];
    for (const student of list) {
      const result_checkup_register = await query(
        `INSERT INTO CheckupRegister (campaign_id, student_id, status)
                     VALUES ($1, $2, $3)  RETURNING*`,
        [campaign_id, student.id, "PENDING"]
      );

      if (result_checkup_register.rowCount === 0) {
        return res.status(400).json({
          error: true,
          message: "Create CheckUp Register không thành công.",
        });
      }

      checkup_register.push(result_checkup_register.rows[0]);
    }

    const rs = await query(
      `SELECT * FROM campaigncontainspeexam 
                                    WHERE campaign_id = $1`,
      [campaign_id]
    );

    const specialist_exam_ids = rs.rows;

    console.log(specialist_exam_ids);

    //Step 3: Tạo specialistExamRecord
    if (specialist_exam_ids || !specialist_exam_ids.length === 0) {
      for (const registerId of checkup_register) {
        for (const examId of specialist_exam_ids) {
          const result_update_speciallist = await query(
            `INSERT INTO specialistExamRecord (register_id,spe_exam_id,status)
                        VALUES ($1, $2, $3)`,
            [registerId.id, examId.specialist_exam_id, "CANNOT_ATTACH"]
          );

          if (result_update_speciallist.rowCount === 0) {
            return res.status(400).json({
              error: true,
              message: "Create Special List Exam Record không thành công.",
            });
          }
        }
      }
    }

    //Step 4: tạo Health Record

    for (const registerID of checkup_register) {
      const result_check_healthrecord = await query(
        `INSERT INTO HealthRecord (register_id) VALUES ($1)`,
        [registerID.id]
      );
      if (result_check_healthrecord.rowCount === 0) {
        return res.status(400).json({
          error: true,
          message: "Create Health Record không thành công.",
        });
      }
    }

    //Step 5: Đổi Status Campaign thành PREPARING

    const result = await query(
      `UPDATE checkupcampaign 
                                        SET status = $1 WHERE id = $2`,
      ["PREPARING", campaign_id]
    );

    return res
      .status(200)
      .json({ error: false, message: "Gửi Register Thành Công" });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi server khi gửi Register ." });
  }
}

//Truyền vào ID campaign để update
export async function updateCampaign(req, res) {
  const { campaign_id } = req.params;
  const {
    name,
    description,
    location,
    start_date,
    end_date,
    specialist_exam_ids,
  } = req.body;

  try {
    if (
      !name ||
      !description ||
      !location ||
      !start_date ||
      !end_date ||
      !Array.isArray(specialist_exam_ids)
    ) {
      return res.status(400).json({
        error: true,
        message: "Không nhận được dữ liệu.",
      });
    }

    //Step 1: DELETED campaigncontainspeexam

    const check_contain = await query(
      `SELECT * FROM campaigncontainspeexam 
                                            WHERE campaign_id = $1`,
      [campaign_id]
    );

    if (check_contain.rowCount !== 0) {
      const check_delete = await query(
        `DELETE FROM campaigncontainspeexam
                                          WHERE campaign_id = $1`,
        [campaign_id]
      );

      if (check_delete.rowCount === 0) {
        return res.status(400).json({
          error: true,
          message: "Không xóa được Campaigncontainspeexam!.",
        });
      }
    }

    // Step 2: check campaign có tồn tại không
    const check = await query(
      `SELECT * FROM checkupcampaign
                                   WHERE id = $1`,
      [campaign_id]
    );

    if (check.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Không tồn tại Campaign ID.",
      });
    }
    // Step 3: Update lại thông tin campaign
    const rs = await query(
      `UPDATE checkupcampaign
                                SET
                                 name = $1,
                                 description = $2,
                                 location = $3,
                                 start_date = $4,
                                 end_date = $5
                                WHERE id = $6;
`,
      [name, description, location, start_date, end_date, campaign_id]
    );

    if (rs.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Update Campain không thành công!.",
      });
    }

    //Step 4: Tạo lại Campaigncontainspeexam

    if (Array.isArray(specialist_exam_ids)) {
      for (const exam_id of specialist_exam_ids) {
        const result_campagincontain = await query(
          "INSERT INTO CampaignContainSpeExam (campaign_id,specialist_exam_id) VALUES ($1,$2) RETURNING *",
          [campaign_id, exam_id]
        );

        console.log("gắn spe exam id vào campaign: ", exam_id);

        if (result_campagincontain.rowCount === 0) {
          return res.status(400).json({
            error: true,
            message: "Create Campagincontainsspeexam không thành công.",
          });
        }
      }
    }

    return res
      .status(200)
      .json({ error: false, message: "Update Campaign thành công!" });
  } catch (err) {
    console.error("❌ Error Update Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi server khi Update Campaign." });
  }
}

export async function getAllCheckupCampaigns(req, res) {
  try {
    // Lấy tất cả các chiến dịch
    const result_campaigns = await query(`
            SELECT * FROM CheckupCampaign
            ORDER BY start_date DESC
        `);

    const campaigns = result_campaigns.rows;

    if (campaigns.length === 0) {
      return res
        .status(200)
        .json({ error: false, message: "Không có chiến dịch nào.", data: [] });
    }

    // Lặp qua từng chiến dịch để lấy thông tin SpecialistExam tương ứng
    for (const campaign of campaigns) {
      const result_exams = await query(
        `
                SELECT s.id, s.name, s.description
                FROM CampaignContainSpeExam c
                JOIN SpecialistExamList s ON c.specialist_exam_id = s.id
                WHERE c.campaign_id = $1
            `,
        [campaign.id]
      );

      campaign.specialist_exams = result_exams.rows;
    }

    return res.status(200).json({
      error: false,
      message: "Lấy danh sách chiến dịch thành công.",
      data: campaigns,
    });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi server lấy danh sách Campaign." });
  }
}

export async function getALLHealthRecord(req, res) {
  try {
    const result = await query(`SELECT * FROM healthrecord`);
    if (result.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "không lấy được Health Record." });
    }

    return res.status(200).json({ error: false, data: result.rows });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi server khi  nhận Health Record." });
  }
}

export async function getALLSpeciaListExamRecord(req, res) {
  try {
    const result = await query("SELECT * FROM specialistexamrecord");

    if (result.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "không lấy được SpeciaListExamRecord." });
    }

    return res.status(200).json({ error: false, data: result.rows });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi server lấy SpeciaListExamRecord." });
  }
}

export async function getALLRegisterByCampaignID(req, res) {
  const { id } = req.params;
  try {
    if (!id) {
      return res
        .status(400)
        .json({ error: true, message: "không lấy nhận được Campaign ID." });
    }

    const check = await query("SELECT * FROM checkupcampaign WHERE id = $1", [
      id,
    ]);
    if (check.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "không  tìm được Campaign." });
    }

    const result = await query(
      `
            SELECT c.id as register_id, c.status as register_status, cr.status as campaign_status, c.*,cr.*, s.name as student_name, s.class_id, cla.name as class_name
            FROM checkupregister c
            JOIN checkupcampaign cr ON c.campaign_id = cr.id
			join student s on s.id = c.student_id
			join class cla on cla.id = s.class_id
            WHERE cr.id = $1
            ORDER BY register_status DESC`,
      [id]
    );

    if (result.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "không lấy được đơn đăng ký." });
    }

    return res.status(200).json({ error: false, data: result.rows });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi Lấy Danh Sách CheckUp Register." });
  }
}

//Lấy tất cả các CheckUp Register theo parent_id (KHÔNG CẦN PHẢI PENDING)
export async function getCheckupRegisterByParentID(req, res) {
  const { id } = req.params;
  if (!id) {
    return res.status(400).json({ error: true, message: "Thiếu ID Parent." });
  }

  try {
    const result_check = await query("SELECT * FROM parent WHERE id = $1", [
      id,
    ]);

    if (result_check.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không tìm thấy ID của Parent." });
    }

    //Lấy tất cả Student có mon_id or dad_id là parent_id
    const result_student = await query(
      `SELECT * FROM Student WHERE mom_id = $1 OR dad_id = $2`,
      [id, id]
    );

    //Lấy student_id từ Prent
    const student_ids = [];
    for (const student of result_student.rows) {
      student_ids.push(student.id);
    }

    if (student_ids.length === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không tìm thấy ID của Student." });
    }

    //Lấy các CheckUpRegister và speciallistexamrecord từ Student_id

    const allRegisters = [];

    for (const student_id of student_ids) {
      const result_checkup_register = await query(
        ` SELECT 
                    r.id AS register_id,
                    r.campaign_id,
                    r.student_id,
                    r.submit_by,
                    r.submit_time,
                    r.reason,
                    r.status,
                    s.spe_exam_id,
                    s.status
                FROM checkupregister r
                JOIN specialistexamrecord s ON s.register_id = r.id
                WHERE r.student_id = $1
            `,
        [student_id]
      );

      allRegisters.push(...result_checkup_register.rows);
    }

    // 3. Group by register_id
    const mapByRegister = {};
    for (const row of allRegisters) {
      const id = row.register_id;
      if (!mapByRegister[id]) {
        // Khởi tạo lần đầu
        mapByRegister[id] = {
          register_id: row.register_id,
          campaign_id: row.campaign_id,
          student_id: row.student_id,
          submit_by: row.submit_by,
          submit_time: row.submit_time,
          reason: row.reason,
          status: row.status,
          exams: [],
        };
      }
      // Đẩy exam vào mảng
      mapByRegister[id].exams.push({
        spe_exam_id: row.spe_exam_id,
        status: row.status,
      });
    }

    // Chuyển về array
    const mergedRegisters = Object.values(mapByRegister);

    // 4. Trả về
    return res.status(200).json({ error: false, data: mergedRegisters });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi Parent nhận Register Form.",
    });
  }
}

//Lấy tất cả các CheckUp Register theo student_id (KHÔNG CẦN PHẢI PENDING)
export async function getCheckupRegisterByStudentID(req, res) {
  const { id } = req.params;
  if (!id) {
    return res.status(400).json({ error: true, message: "Thiếu ID Hoc sinh." });
  }

  try {
    //Lấy các CheckUpRegister và speciallistexamrecord từ Student_id

    const result_checkup_register = await query(
      ` SELECT 
                    r.id AS register_id,
                    r.campaign_id,
                    r.student_id,
                    r.submit_by,
                    r.submit_time,
                    r.reason,
                    r.status,
                    s.spe_exam_id,
                    s.status
                FROM checkupregister r
                JOIN specialistexamrecord s ON s.register_id = r.id
                WHERE r.student_id = $1
            `,
      [id]
    );

    const result = result_checkup_register.rows;

    if (result.length === 0) {
      return res
        .status(200)
        .json({ error: false, message: "Không có Register" });
    }

    const mapByRegister = {};
    for (const row of result) {
      const ids = row.result.register_id;
      if (!mapByRegister[ids]) {
        // Khởi tạo lần đầu
        mapByRegister[ids] = {
          register_id: row.register_id,
          campaign_id: row.campaign_id,
          student_id: row.student_id,
          submit_by: row.submit_by,
          submit_time: row.submit_time,
          reason: row.reason,
          status: row.status,
          exams: [],
        };
      }
      // Đẩy exam vào mảng
      mapByRegister[ids].exams.push({
        spe_exam_id: row.spe_exam_id,
        status: row.status,
      });
    }

    // Chuyển về array
    const mergedRegisters = Object.values(mapByRegister);

    // Trả về
    return res.status(200).json({ error: false, data: mergedRegisters });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi Parent nhận Register Form.",
    });
  }
}
export async function getWaitingSpecialistExams(req, res) {
  const { student_id, campaign_id } = req.params;

  try {
    // Validate input parameters
    if (!student_id || !campaign_id) {
      return res.status(400).json({
        error: true,
        message: "Thiếu student_id hoặc campaign_id.",
      });
    }

    // Check if student exists
    const checkStudent = await query("SELECT * FROM student WHERE id = $1", [
      student_id,
    ]);
    if (checkStudent.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Student ID không tồn tại.",
      });
    }

    // Check if campaign exists
    const checkCampaign = await query(
      "SELECT * FROM checkupcampaign WHERE id = $1",
      [campaign_id]
    );
    if (checkCampaign.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Campaign ID không tồn tại.",
      });
    }

    // Execute the query to get waiting specialist exams
    const result = await query(
      `SELECT el.name
       FROM checkupregister r
       JOIN specialistexamrecord s ON s.register_id = r.id
       JOIN specialistexamlist el ON el.id = s.spe_exam_id
       WHERE r.student_id = $1 AND r.campaign_id = $2 AND s.status = 'WAITING'`,
      [student_id, campaign_id]
    );

    // Return the result
    return res.status(200).json({
      error: false,
      message:
        result.rowCount > 0
          ? "Lấy danh sách khám chuyên khoa đang chờ thành công."
          : "Không có khám chuyên khoa nào đang chờ.",
      data: result.rows.map((row) => row.name), // Return array of specialist exam names
    });
  } catch (err) {
    console.error("❌ Error fetching waiting specialist exams:", err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi lấy danh sách khám chuyên khoa đang chờ.",
    });
  }
}
export async function getCheckupRegisterStatus(req, res) {
  const { campaign_id, student_id } = req.params;

  try {
    // Validate input parameters
    if (!campaign_id || !student_id) {
      return res.status(400).json({
        error: true,
        message: "Thiếu campaign_id hoặc student_id.",
      });
    }

    // Check if student exists
    const checkStudent = await query("SELECT * FROM student WHERE id = $1", [
      student_id,
    ]);
    if (checkStudent.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Student ID không tồn tại.",
      });
    }

    // Check if campaign exists
    const checkCampaign = await query(
      "SELECT * FROM checkupcampaign WHERE id = $1",
      [campaign_id]
    );
    if (checkCampaign.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Campaign ID không tồn tại.",
      });
    }

    // Execute the provided query
    const result = await query(
      `SELECT cr.campaign_id, cr.status
       FROM checkupregister cr
       JOIN checkupcampaign cc ON cr.campaign_id = cc.id
       WHERE cr.student_id = $1 AND cr.campaign_id = $2`,
      [student_id, campaign_id]
    );

    // Handle case where no record is found
    if (result.rowCount === 0) {
      return res.status(200).json({
        error: false,
        message: "Không tìm thấy đăng ký cho học sinh trong chiến dịch này.",
        data: null,
      });
    }

    // Return the result
    return res.status(200).json({
      error: false,
      message: "Lấy dữ liệu thành công.",
      data: result.rows[0], // Return the first row (single record expected)
    });
  } catch (err) {
    console.error("❌ Error fetching checkup register status:", err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi lấy trạng thái đăng ký.",
    });
  }
}
// Parent nhấn Submit Register truyền vào Register_id
export async function submitRegister(req, res) {
  const { id } = req.params;
  const { parent_id, submit_time, reason, exams } = req.body;
  try {
    if (!id || !parent_id || !reason) {
      return res
        .status(400)
        .json({ error: true, message: "Không có nội dung." });
    }

    if (!Array.isArray(exams)) {
      return res.status(400).json({ error: true, message: "Không có exams." });
    }

    const result_submit = await query(
      `UPDATE checkupregister
         SET
           reason      = $1,
           status      = $2,
           submit_by   = $3,
           submit_time = $4
       WHERE id = $5`,
      [reason, "SUBMITTED", parent_id, submit_time, id]
    );

    if (result_submit.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Submit Register không thành công." });
    }

    const result_update_speciallis = [];

    for (const ex of exams) {
      const { spe_exam_id, status } = ex;
      const result_update = await query(
        `UPDATE specialistexamrecord
            SET status = $1
            WHERE register_id = $2
            AND spe_exam_id  = $3`,
        [status, id, spe_exam_id]
      );

      result_update_speciallis.push(result_update.rows);
    }

    if (result_update_speciallis.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Submit Register không thành công." });
    } else {
      return res
        .status(200)
        .json({ error: false, message: "Submit thành công" });
    }
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi server khi Submit Register Form." });
  }
}

//Admin đóng form Register truyền vào ID Campaign
export async function closeRegister(req, res) {
  const { id } = req.params;
  if (!id) {
    return res.status(400).json({ error: true, message: "Thiếu ID Campaign." });
  }

  try {
    const result_check = await query(
      "SELECT * FROM CheckupCampaign WHERE id = $1",
      [id]
    );
    if (result_check.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không tìm thấy id Campaign ." });
    }

    // Step 1: Cập nhật trạng thái UPCOMING cho Campaign
    const result = await query(
      "UPDATE CheckupCampaign SET status = $1 WHERE id = $2",
      ["UPCOMING", id]
    );

    // Step 2: cập nhật trạng thái cho Register

    // 2.1 Lấy tất cả các Register từ campaign_id và Status = 'PENDING'

    // const result_checkup_register = await query(
    //     "SELECT * FROM checkupregister WHERE status = $1 AND campaign_id = $2",
    //     ["PENDING", id]
    // );
    // const data = result_checkup_register.rows;

    // if (data.length < 0) {
    //     return res
    //         .status(400)
    //         .json({ error: true, message: "Không tìm thấy Register." });
    // }

    // 2.2 Chuyển trạng thái Register sang CANCELLED
    // const rs = [];

    // for (const register_id of data) {
    //     const res = await query(
    //         "UPDATE checkupregister SET status = $1 WHERE id = $2",
    //         ["CANCELLED", register_id.id]
    //     );

    //     rs.push(res.rows[0]);
    // }

    if (result.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Đóng form Register không thành công .",
      });
    }
    return res
      .status(200)
      .json({ error: false, message: "Đóng form Register thành công" });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi đóng Register." });
  }
}

//Admin cancel Campaign chuyển status thành CANCELLED
export async function cancelRegister(req, res) {
  const { id } = req.params;
  if (!id) {
    return res.status(400).json({ error: true, message: "Thiếu ID." });
  }

  try {
    const result_check = await query(
      "SELECT * FROM CheckupCampaign WHERE id = $1",
      [id]
    );
    if (result_check.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không tìm thấy id Campaign ." });
    }

    const status = result_check.rows[0].status;

    if (status === "DRAFTED") {
      const result = await query(
        "UPDATE CheckupCampaign SET status = $1 WHERE id = $2",
        ["CANCELLED", id]
      );
      return res
        .status(200)
        .json({ error: false, message: "CANCEL thành công" });
    }

    //Cập nhật trạng thái Cancel cho CheckUpCampaign
    const result = await query(
      "UPDATE CheckupCampaign SET status = $1 WHERE id = $2",
      ["CANCELLED", id]
    );

    //Cập nhật trạng thái cho CheckUp Register
    const result_checkup_register = await query(
      "UPDATE checkupregister SET status = $1 WHERE campaign_id = $2",
      ["CANCELLED", id]
    );
    //Lấy checkup register id từ campaign_id

    const result_checkup_register_id = await query(
      "SELECT * FROM checkupregister WHERE campaign_id = $1",
      [id]
    );

    const rs = result_checkup_register_id.rows.map((r) => r.id);

    //Cập nhật trạng thái cho Health Record

    for (const register_id of rs) {
      const result_health_record = await query(
        "UPDATE healthrecord SET status = $1 WHERE register_id = $2",
        ["CANCELLED", register_id]
      );
    }

    if (result.rowCount === 0 || result_checkup_register.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "CANCEL không thành công." });
    } else
      return res
        .status(200)
        .json({ error: false, message: "CANCEL thành công" });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi đóng Register." });
  }
}
// Nurse or Doctor Update Health  Recordcho Student theo Register ID
export async function updateHealthRecord(req, res) {
  const { record_id } = req.params;
  const {
    height,
    weight,
    blood_pressure,
    left_eye,
    right_eye,
    ear,
    nose,
    throat,
    teeth,
    gums,
    skin_condition,
    heart,
    lungs,
    spine,
    posture,
    final_diagnosis,
  } = req.body;

  // Validation cho các trường bắt buộc
  if (
    !height ||
    !weight ||
    !blood_pressure ||
    !left_eye ||
    !right_eye ||
    !ear ||
    !nose ||
    !record_id
  ) {
    return res
      .status(400)
      .json({ error: true, message: "Các chỉ số cơ bản không thể trống." });
  }

  // Validation định dạng
  if (isNaN(height) || height <= 0 || height > 250) {
    return res
      .status(400)
      .json({ error: true, message: "Chiều cao phải là số từ 0 đến 250 cm." });
  }
  if (isNaN(weight) || weight <= 0 || weight > 200) {
    return res
      .status(400)
      .json({ error: true, message: "Cân nặng phải là số từ 0 đến 200 kg." });
  }
  if (!/^\d{1,3}\/\d{1,3}$/.test(blood_pressure)) {
    return res
      .status(400)
      .json({
        error: true,
        message: "Huyết áp phải có định dạng ví dụ: 120/80.",
      });
  }
  if (isNaN(left_eye) || left_eye < 0 || left_eye > 10) {
    return res
      .status(400)
      .json({
        error: true,
        message: "Thị lực mắt trái phải là số từ 0 đến 10.",
      });
  }
  if (isNaN(right_eye) || right_eye < 0 || right_eye > 10) {
    return res
      .status(400)
      .json({
        error: true,
        message: "Thị lực mắt phải phải là số từ 0 đến 10.",
      });
  }

  try {
    // Kiểm tra bản ghi tồn tại
    const result_check = await query(
      "SELECT * FROM healthrecord WHERE id = $1",
      [record_id]
    );

    if (result_check.rowCount === 0) {
      return res.status(404).json({
        error: true,
        message: "Không tìm thấy hồ sơ sức khỏe.",
      });
    }

    // Cập nhật bản ghi sức khỏe
    const result = await query(
      `UPDATE healthrecord
             SET
                height = $1,
                weight = $2,
                blood_pressure = $3,
                left_eye = $4,
                right_eye = $5,
                ear = $6,
                nose = $7,
                throat = $8,
                teeth = $9,
                gums = $10,
                skin_condition = $11,
                heart = $12,
                lungs = $13,
                spine = $14,
                posture = $15,
                final_diagnosis = $16
             WHERE id = $17
             RETURNING *`,
      [
        height,
        weight,
        blood_pressure,
        left_eye,
        right_eye,
        ear,
        nose,
        throat,
        teeth,
        gums,
        skin_condition,
        heart,
        lungs,
        spine,
        posture,
        final_diagnosis,
        record_id,
      ]
    );

    if (result.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Không thể cập nhật hồ sơ sức khỏe.",
      });
    }

    return res.status(200).json({
      error: false,
      message: "Cập nhật hồ sơ sức khỏe thành công.",
      data: result.rows[0],
    });
  } catch (err) {
    console.error("❌ Lỗi khi cập nhật hồ sơ sức khỏe:", err);
    return res
      .status(500)
      .json({
        error: true,
        message: "Lỗi server khi cập nhật hồ sơ sức khỏe.",
      });
  }
}

//Student xem CheckUpRegister của mình cần truyền vào student_id
export async function getCheckupRegisterStudent(req, res) {
  const { id } = req.params;

  try {
    const result = await query(
      "SELECT * FROM checkupregister WHERE student_id = $1",
      [id]
    );
    const data_ = result.rows;
    if (result.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không Campaign đang diễn ra" });
    } else {
      return res.status(200).json({ error: false, data: data_ });
    }
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi tạo record." });
  }
}

export async function getHealthRecordsOfAStudent(req, res) {
  const { id } = req.params;

  if (!id) {
    return res
      .status(400)
      .json({ error: true, message: "Không Nhận được ID Student." });
  }

  try {
    const check_student = await query(`SELECT * FROM student WHERE id = $1`, [
      id,
    ]);

    //Check ID Student có tồn tại không
    if (check_student.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Student ID không tồn tại." });
    }

    //Lấy HealthRecod từ Student ID
    const rs = await query(
      ` SELECT 
                cr.campaign_id,
                campaign.name as campaign_name,
                campaign.description as campaign_description,
                hr.id AS health_record_id,
                hr.record_url,
                hr.register_id,
                cr.student_id,
                stu.name as student_name,
                stu.dob as student_dob,
                clas.name as class_name,
                hr.is_checked,
                hr.status AS record_status
            FROM HealthRecord hr
            JOIN CheckupRegister cr ON hr.register_id = cr.id
            Join student stu on stu.id = cr.student_id
            join class clas on clas.id = stu.class_id	
            join checkupcampaign campaign on campaign.id = cr.campaign_id
            WHERE cr.student_id = $1;
            `,
      [id]
    );

    if (rs.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không tồn tại  Health Record." });
    }

    const result = rs.rows;

    return res.status(200).json({ error: false, data: result });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi lấy danh sách Record." });
  }
}

export async function getSpecialRecordsOfAStudent(req, res) {
  const { id } = req.params;

  if (!id) {
    return res
      .status(400)
      .json({ error: true, message: "Không Nhận được ID Student." });
  }

  try {
    const check_student = await query(`SELECT * FROM student WHERE id = $1`, [
      id,
    ]);

    //Check ID Student có tồn tại không
    if (check_student.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Student ID không tồn tại." });
    }

    //Lấy SpecialistExamRecord từ Student ID
    const rs = await query(
      ` SELECT json_build_object(
  'student_id', s.id,
  'student_name', s.name,
  'class_name', c.name,
  'specialist_exam_records', json_object_agg(
    r.campaign_id,
    json_build_object(
      'campaign_name', r.campaign_name,
      'campaign_description', r.campaign_description,
      'records', r.records
    )
  )
) AS student_exam_detail
FROM student s
JOIN class c ON c.id = s.class_id
JOIN (
    SELECT
        stu.id AS student_id,
        camp.id AS campaign_id,
        camp.name AS campaign_name,
        camp.description AS campaign_description,
        json_agg(
            json_build_object(
                'spe_exam_id', spe.id,
                'specialist_name', spe.name,
				'record_status', rec.status,
				'record_url', rec.diagnosis_paper_urls,
				'doctor_name', rec.dr_name,
                'result', rec.result,
                'date_record', rec.date_record,
                'is_checked', rec.is_checked
            )
        ) AS records
    FROM student stu
    JOIN checkupregister reg ON reg.student_id = stu.id
    JOIN checkupcampaign camp ON camp.id = reg.campaign_id
    JOIN specialistexamrecord rec ON rec.register_id = reg.id
    JOIN campaigncontainspeexam contain ON contain.campaign_id = camp.id
    JOIN specialistexamlist spe ON spe.id = contain.specialist_exam_id
    WHERE rec.status != 'CANNOT_ATTACH'
      AND stu.id = $1
    GROUP BY stu.id, camp.id, camp.name, camp.description
) r ON r.student_id = s.id
WHERE s.id = $2
GROUP BY s.id, s.name, c.name;
            `,
      [id, id]
    );

    if (rs.rowCount === 0) {
      return res
        .status(400)
        .json({
          error: true,
          message: "Không tồn tại Record khám chuyên khoa.",
        });
    }

    const result = rs.rows;

    return res.status(200).json({ error: false, data: result[0] });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi lấy danh sách Record." });
  }
}

export async function getFullHealthAndSpecialRecordsOfAStudent(req, res) {
  const { id } = req.params;

  if (!id) {
    return res
      .status(400)
      .json({ error: true, message: "Không Nhận được ID Student." });
  }

  try {
    const check_student = await query(`SELECT * FROM student WHERE id = $1`, [
      id,
    ]);

    if (check_student.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Student ID không tồn tại." });
    }

    // Lấy health record
    const healthResult = await query(
      `SELECT 
    campaign.status as campaign_status,
    cr.campaign_id,
    campaign.name AS campaign_name,
    campaign.description AS campaign_description,
    hr.id AS health_record_id,
    hr.record_url,
    hr.register_id,
    cr.student_id,
    stu.name AS student_name,
    stu.dob AS student_dob,
    clas.name AS class_name,

    hr.height,
    hr.weight,
    hr.blood_pressure,
    hr.left_eye,
    hr.right_eye,
    hr.ear,
    hr.nose,
    hr.throat,
    hr.teeth,
    hr.gums,
    hr.skin_condition,
    hr.heart,
    hr.lungs,
    hr.spine,
    hr.posture,
    hr.final_diagnosis,
    hr.is_checked,
    hr.status AS record_status

FROM HealthRecord hr
JOIN CheckupRegister cr ON hr.register_id = cr.id
JOIN student stu ON stu.id = cr.student_id
JOIN class clas ON clas.id = stu.class_id
JOIN checkupcampaign campaign ON campaign.id = cr.campaign_id
WHERE cr.student_id = $1
`,
      [id]
    );

    if (healthResult.rowCount === 0) {
      return res.status(200).json({ error: false, data: [] });
    }

    // Map register_id to health records
    const healthRecords = healthResult.rows;
    const registerIds = healthRecords.map((r) => r.register_id);

    // Lấy specialist exam record
    const specialResult = await query(
      `SELECT 
                rec.register_id,
                rec.spe_exam_id,
                spe.name AS specialist_name,
                rec.status AS record_status,
                rec.diagnosis_paper_urls AS record_url,
                rec.is_checked
            FROM specialistExamRecord rec
            JOIN specialistExamList spe ON spe.id = rec.spe_exam_id
            WHERE rec.status != 'CANNOT_ATTACH' AND rec.register_id = ANY($1)`,
      [registerIds]
    );

    const specialRecordsMap = {};
    specialResult.rows.forEach((record) => {
      if (!specialRecordsMap[record.register_id]) {
        specialRecordsMap[record.register_id] = [];
      }
      specialRecordsMap[record.register_id].push({
        spe_exam_id: record.spe_exam_id,
        specialist_name: record.specialist_name,
        record_status: record.record_status,
        record_url: record.record_url,
        is_checked: record.is_checked,
      });
    });

    const mergedData = healthRecords.map((r) => ({
      ...r,
      specialist_exam_records: specialRecordsMap[r.register_id] || [],
    }));

    return res.status(200).json({ error: false, data: mergedData });
  } catch (err) {
    console.error("❌ Error fetching full record:", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi lấy danh sách Record." });
  }
}

export async function getFullRecordOfAStudentInACampaign(req, res) {
  const { campaign_id, student_id } = req.params;

  if (!campaign_id || !student_id) {
    return res
      .status(400)
      .json({ error: true, message: "Thiếu campaign_id hoặc student_id." });
  }

  try {
    const check_student = await query(`SELECT * FROM student WHERE id = $1`, [
      student_id,
    ]);

    if (check_student.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Student ID không tồn tại." });
    }

    // Lấy health record của học sinh trong chiến dịch cụ thể
    const healthResult = await query(
      `SELECT 
                cr.campaign_id,
                campaign.name AS campaign_name,
                campaign.description AS campaign_description,
                hr.id AS health_record_id,
                hr.record_url,
                hr.register_id,
                cr.student_id,
                stu.name AS student_name,
                stu.dob AS student_dob,
                clas.name AS class_name,

                hr.height,
                hr.weight,
                hr.blood_pressure,
                hr.left_eye,
                hr.right_eye,
                hr.ear,
                hr.nose,
                hr.throat,
                hr.teeth,
                hr.gums,
                hr.skin_condition,
                hr.heart,
                hr.lungs,
                hr.spine,
                hr.posture,
                hr.final_diagnosis,
                hr.is_checked,
                hr.status AS record_status

            FROM HealthRecord hr
            JOIN CheckupRegister cr ON hr.register_id = cr.id
            JOIN student stu ON stu.id = cr.student_id
            JOIN class clas ON clas.id = stu.class_id
            JOIN checkupcampaign campaign ON campaign.id = cr.campaign_id
            WHERE cr.student_id = $1 AND cr.campaign_id = $2`,
      [student_id, campaign_id]
    );

    if (healthResult.rowCount === 0) {
      return res.status(200).json({ error: false, data: [] });
    }

    const healthRecords = healthResult.rows;
    const registerIds = healthRecords.map((r) => r.register_id);

    const specialResult = await query(
      `SELECT 
                rec.register_id,
                rec.spe_exam_id,
                spe.name AS specialist_name,
                rec.status AS record_status,
                rec.diagnosis_paper_urls AS record_url,
                rec.is_checked
            FROM specialistExamRecord rec
            JOIN specialistExamList spe ON spe.id = rec.spe_exam_id
            WHERE rec.status != 'CANNOT_ATTACH' AND rec.register_id = ANY($1)`,
      [registerIds]
    );

    const specialRecordsMap = {};
    specialResult.rows.forEach((record) => {
      if (!specialRecordsMap[record.register_id]) {
        specialRecordsMap[record.register_id] = [];
      }
      specialRecordsMap[record.register_id].push({
        spe_exam_id: record.spe_exam_id,
        specialist_name: record.specialist_name,
        record_status: record.record_status,
        record_url: record.record_url,
        is_checked: record.is_checked,
      });
    });

    const mergedData = healthRecords.map((r) => ({
      ...r,
      specialist_exam_records: specialRecordsMap[r.register_id] || [],
    }));

    return res.status(200).json({ error: false, data: mergedData });
  } catch (err) {
    console.error("❌ Error fetching record in campaign:", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi lấy record theo chiến dịch." });
  }
}

export async function getHealthRecordByID(req, res) {
  const { record_id } = req.params;

  if (!record_id) {
    return res.status(400).json({ error: true, message: "Thiếu record_id." });
  }

  try {
    const result = await query(
      `SELECT 
                hr.id AS health_record_id,
                hr.record_url,
                hr.register_id,
                cr.student_id,
                stu.name AS student_name,
                stu.dob AS student_dob,
                stu.ismale AS student_gender,
                clas.name AS class_name,
                campaign.id AS campaign_id,
                campaign.name AS campaign_name,
                campaign.description AS campaign_description,

                hr.height,
                hr.weight,
                hr.blood_pressure,
                hr.left_eye,
                hr.right_eye,
                hr.ear,
                hr.nose,
                hr.throat,
                hr.teeth,
                hr.gums,
                hr.skin_condition,
                hr.heart,
                hr.lungs,
                hr.spine,
                hr.posture,
                hr.final_diagnosis,
                hr.is_checked,
                hr.status AS record_status

            FROM HealthRecord hr
            JOIN CheckupRegister cr ON hr.register_id = cr.id
            JOIN student stu ON stu.id = cr.student_id
            JOIN class clas ON clas.id = stu.class_id
            JOIN checkupcampaign campaign ON campaign.id = cr.campaign_id
            WHERE hr.id = $1`,
      [record_id]
    );

    if (result.rowCount === 0) {
      return res
        .status(404)
        .json({ error: true, message: "Không tìm thấy health record." });
    }

    return res.status(200).json({ error: false, data: result.rows[0] });
  } catch (err) {
    console.error("❌ Error fetching health record by ID:", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi lấy health record." });
  }
}

export async function getHealthRecordParentDetails(req, res) {
  const { health_record_id } = req.body;
  try {
    if (!health_record_id) {
      return res
        .status(400)
        .json({ error: true, message: "Không nhận được ID Health Record." });
    }

    const rs = await query(`SELECT * FROM HealthRecord WHERE id = $1`, [
      health_record_id,
    ]);

    const result = rs.rows;

    if (result.length === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không lấy được Details." });
    } else {
      return res.status(200).json({ error: false, data: result });
    }
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi tạo record." });
  }
}

export async function getSpecialRecordParent(req, res) {
  const { id } = req.params;

  if (!id) {
    return res
      .status(400)
      .json({ error: true, message: "Không Nhận được ID Student." });
  }

  try {
    const check_student = await query(`SELECT * FROM student WHERE id = $1`, [
      id,
    ]);

    //Check ID Student có tồn tại không
    if (check_student.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Student ID không tồn tại." });
    }

    const rs = await query(
      `SELECT ser.register_id, ser.spe_exam_id ,sel.name AS exam_name , ser.is_checked,ser.status
        FROM specialistExamRecord ser
        JOIN CheckupRegister cr ON ser.register_id = cr.id
        JOIN SpecialistExamList sel ON ser.spe_exam_id = sel.id
        WHERE cr.student_id = $1`,
      [id]
    );

    if (rs.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không tồn tại  Health Record." });
    }

    const result = rs.rows;

    return res.status(200).json({ error: false, data: result });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi lấy danh sách special record." });
  }
}

export async function getSpecialRecordParentDetails(req, res) {
  const { register_id, spe_exam_id } = req.body;

  try {
    if (!register_id || !spe_exam_id) {
      return res.status(400).json({
        error: true,
        message: "Không nhận được Register ID và Specail Exam ID.",
      });
    }

    const rs = await query(
      `SELECT * FROM specialistexamrecord WHERE register_id=$1 AND spe_exam_id = $2`,
      [register_id, spe_exam_id]
    );

    const result = rs.rows;

    if (result.length === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không lấy được Details." });
    } else {
      return res.status(200).json({ error: false, data: result });
    }
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi lấy Special Record Detail." });
  }
}

//Student xem HealthRecord của mình cần truyền vào student_id và camaign_id
export async function getHealthRecordStudent(req, res) {
  const { student_id, campaign_id } = req.params;

  try {
    //Lấy register_id từ student id
    const result = await query(
      "SELECT * FROM checkupregister WHERE student_id = $1 and campaign_id = $2",
      [student_id, campaign_id]
    );

    const rs = result.rows[0];
    console.log(rs);
    if (!rs) {
      return res
        .status(400)
        .json({ error: true, message: "Không tìm thấy health record." });
    }

    if (rs.length === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không tìm thấy Register." });
    }

    //Lấy Health Record từ Student
    const result_check_healthrecord = await query(
      "SELECT * FROM healthrecord WHERE register_id = $1",
      [rs.id]
    );

    const data = result_check_healthrecord.rows;

    if (data.length === 0) {
      return res.status(200).json({
        error: false,
        message: "Không tìm thấy Health Record của Student.",
      });
    } else {
      return res.status(200).json({ error: false, data });
    }
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi xem Health Record." });
  }
}

export async function findHealthRecordByStudentName(params) {
  try {
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi xem Health Record." });
  }
}

//Cần truyền vào student_id và campaign_id
export async function UpdateCheckinHealthRecord(req, res) {
  const { student_id, campaign_id } = req.body;

  try {
    if (!student_id || !campaign_id) {
      return res.status(400).json({
        error: true,
        message: "Không nhận được Student ID or Campaign ID.",
      });
    }

    const checkStudent = await query("SELECT * FROM student WHERE id = $1", [
      student_id,
    ]);

    if (checkStudent.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Student ID không tồn tại." });
    }

    const checkCampaign = await query(
      "SELECT * FROM checkupcampaign WHERE id = $1",
      [campaign_id]
    );

    if (checkCampaign.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Campaign ID không tồn tại." });
    }

    // Tìm ID của HealthRecord
    const result = await query(
      "SELECT hr.* FROM HealthRecord hr JOIN CheckupRegister cr ON hr.register_id = cr.id WHERE cr.student_id =$1 AND cr.campaign_id = $2 ",
      [student_id, campaign_id]
    );

    const result_health_record = result.rows;

    if (result_health_record.length === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không tìm thấy Health Record ." });
    }

    //Update is_checkin cho HealthRecord

    const result_update = await query(
      "UPDATE healthrecord SET is_checked = $1 WHERE id = $2",
      [true, result_health_record[0].id]
    );

    if (result_update.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Cập nhật Health Record thất bại." });
    }

    return res
      .status(200)
      .json({ error: false, message: "Checkin thành công." });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res.status(500).json({ error: true, message: "Lỗi khi Check-in." });
  }
}

//Check in khám chuyên khoa
export async function UpdateCheckinSpecialRecord(req, res) {
  const { student_id, campaign_id, spe_exam_id } = req.body;
  try {
    if (!student_id || !campaign_id || !spe_exam_id) {
      return res.status(400).json({
        error: true,
        message:
          "Không nhận được Student ID or Campaign ID or Special List Exam ID.",
      });
    }

    const checkStudent = await query("SELECT * FROM student WHERE id = $1", [
      student_id,
    ]);

    if (checkStudent.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Student ID không tồn tại." });
    }

    const checkCampaign = await query(
      "SELECT * FROM checkupcampaign WHERE id = $1",
      [campaign_id]
    );

    if (checkCampaign.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Campaign ID không tồn tại." });
    }

    const checkSpecialExam = await query(
      "SELECT * FROM specialistexamlist WHERE id = $1",
      [spe_exam_id]
    );

    if (checkSpecialExam.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Special List Exam ID không tồn tại." });
    }

    //Lấy SpecialListExamRecord

    const result = await query(
      `SELECT ser.*
            FROM specialistExamRecord ser
            JOIN CheckupRegister cr ON ser.register_id = cr.id
            WHERE cr.student_id = $1 AND cr.campaign_id = $2 AND ser.spe_exam_id = $3`,
      [student_id, campaign_id, spe_exam_id]
    );

    const result_check = result.rows;

    if (result_check.length === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không tìm thấy Record ." });
    }

    console.log(result_check);
    //Check-in

    const result_update = await query(
      "UPDATE specialistexamrecord SET is_checked = $1 WHERE register_id = $2 AND spe_exam_id = $3",
      [true, result_check[0].register_id, spe_exam_id]
    );

    if (result_update.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Cập nhật Health Record thất bại." });
    }

    return res
      .status(200)
      .json({ error: false, message: "Checkin thành công." });
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi Lỗi khi Check-in." });
  }
}

//Lấy danh sách Student tham gia vào Campaign với Status ON-GOING
export async function getListStudentByCampaignAccept(req, res) {
  const { id } = req.params;

  try {
    if (!id) {
      return res
        .status(400)
        .json({ error: true, message: "Không nhận đươc Campaign ID." });
    }

    const result_check_campaign = await query(
      "SELECT * FROM checkupcampaign WHERE id = $1",
      [id]
    );

    if (result_check_campaign.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Campaign ID không tồn tại." });
    }

    const result = await query(
      `SELECT s.id AS student_id ,cr.id AS register_id, s.email, s.name, s.dob,s.isMale,s.phone_number,s.address
    FROM Student s
    JOIN CheckupRegister cr ON s.id = cr.student_id
    WHERE cr.campaign_id = $1
`,
      [id]
    );

    const rs = result.rows;

    if (rs.length === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Không Tìm thấy Danh Sách Student." });
    }
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi Lỗi khi Check-in." });
  }
}

export async function startCampaig(req, res) {
  const { id } = req.params;

  try {
    if (!id) {
      return res
        .status(400)
        .json({ error: true, message: "Không lấy được ID." });
    }

    const check = await query(`SELECT * FROM checkupcampaign WHERE id = $1`, [
      id,
    ]);

    if (check.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Campaign ID không tồn tại." });
    }

    // Update status On-going cho CheckUp campaign

    const rs = await query(
      `UPDATE checkupcampaign SET status = $1 WHERE id = $2`,
      ["ONGOING", id]
    );

    if (rs.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Start Campaign không thành công." });
    } else {
      return res
        .status(200)
        .json({ error: false, message: "Start Campaign thành công" });
    }
  } catch (err) {
    console.error("❌ Error Start Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi Start Campaign" });
  }
}

export async function finishCampaign(req, res) {
  const { id } = req.params;

  try {
    if (!id) {
      return res
        .status(400)
        .json({ error: true, message: "Không lấy được ID." });
    }

    const check = await query(`SELECT * FROM checkupcampaign WHERE id = $1`, [
      id,
    ]);

    if (check.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Campaign ID không tồn tại." });
    }

    // Update status On-going cho CheckUp campaign

    const rs = await query(
      `UPDATE checkupcampaign SET status = $1 WHERE id = $2`,
      ["DONE", id]
    );

    if (rs.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Finish Campaign không thành công." });
    } else {
      return res
        .status(200)
        .json({ error: false, message: "Finish Campaign thành công" });
    }
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi Start Campaign" });
  }
}

export async function getCampaignDetail(req, res) {
  const { id } = req.params;

  try {
    // Kiểm tra ID hợp lệ
    if (!id || isNaN(id)) {
      return res.status(400).json({
        error: true,
        message: "ID chiến dịch không hợp lệ.",
      });
    }

    // Kiểm tra chiến dịch tồn tại
    const check = await query(`SELECT * FROM checkupcampaign WHERE id = $1`, [
      id,
    ]);
    if (check.rowCount === 0) {
      return res.status(404).json({
        error: true,
        message: "Chiến dịch không tồn tại.",
      });
    }

    // Lấy chi tiết chiến dịch và xét nghiệm chuyên môn
    const rs = await query(
      `SELECT 
                c.id AS campaign_id, 
                c.name AS campaign_name, 
                c.description AS campaign_des,
                c.location AS campaign_location, 
                c.start_date, 
                c.end_date,
                sel.id AS sel_id, 
                sel.name AS spe_name, 
                sel.description AS sel_des
            FROM checkupcampaign c
            LEFT JOIN campaigncontainspeexam cp ON cp.campaign_id = c.id
            LEFT JOIN specialistexamlist sel ON sel.id = cp.specialist_exam_id
            WHERE c.id = $1`,
      [id]
    );

    // Định dạng dữ liệu trả về
    const campaign = {
      campaign_id: check.rows[0].id,
      campaign_name: check.rows[0].name,
      campaign_des: check.rows[0].description || null,
      campaign_location: check.rows[0].location || null,
      start_date: check.rows[0].start_date,
      end_date: check.rows[0].end_date,
      status: check.rows[0].status,
      specialist_exams: rs.rows
        .filter((row) => row.sel_id) // Lọc các hàng có xét nghiệm
        .map((row) => ({
          id: row.sel_id,
          name: row.spe_name,
          description: row.sel_des || null,
        })),
    };

    return res.status(200).json({
      error: false,
      message: "Lấy chi tiết chiến dịch thành công.",
      data: campaign,
    });
  } catch (err) {
    console.error("❌ Error fetching Campaign details: ", err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi lấy chi tiết chiến dịch.",
    });
  }
}

export async function getRegisterID(req, res) {
  {
  }
  const { student_id, campaign_id } = req.params;
  console.log(campaign_id);

  try {
    if (!student_id || !campaign_id) {
      return res.status(400).json({
        error: true,
        message: "Không nhận được Student ID or Campaign ID.",
      });
    }

    const check_student = await query(
      `SELECT * FROM student
                WHERE id = $1`,
      [student_id]
    );

    if (check_student.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Student ID không tồn tại" });
    }

    const check_campaign = await query(
      `SELECT * FROM checkupcampaign
                WHERE id = $1`,
      [campaign_id]
    );

    if (check_campaign.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Campaign ID không tồn tại" });
    }

    const rs = await query(
      `SELECT id
             FROM checkupregister
             WHERE student_id = $1
             AND campaign_id= $2`,
      [student_id, campaign_id]
    );

    if (rs.rowCount === 0) {
      return res
        .status(200)
        .json({ error: true, message: "Không tìm thấy Register ID" });
    } else {
      return res.status(200).json({ error: false, data: rs.rows[0] });
    }
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi lấy Campaign details" });
  }
}

export async function getALLHealthRecordOfACampaign(req, res) {
  const { campaign_id } = req.params;
  if (!campaign_id) {
    return res.status(400).json({
      error: true,
      message: "Không nhận được Campaign ID.",
    });
  }

  try {
    const result = await query(
      `select hr.*,stu.id, stu.name as student_name, clas.name as class_name from HealthRecord hr
join checkupregister reg on hr.register_id = reg.id
join student stu on stu.id = reg.student_id
join class clas on clas.id = stu.class_id
where reg.campaign_id = $1`,
      [campaign_id]
    );

    return res.status(200).json({ error: false, data: result.rows });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: true, message: "Lỗi server" });
  }
}
export async function completeAHealthRecordForStudent(req, res) {
  const { id } = req.params;

  if (!id) {
    return res.status(400).json({
      error: true,
      message: "Không nhận được id khám tổng quát.",
    });
  }

  try {
    // Kiểm tra bản ghi tồn tại
    const result_check = await query(
      "SELECT * FROM healthrecord WHERE id = $1",
      [id]
    );

    if (result_check.rowCount === 0) {
      return res.status(404).json({
        error: true,
        message: "Không tìm thấy hồ sơ sức khỏe.",
      });
    }

    // Cập nhật trạng thái
    const result = await query(
      `UPDATE healthrecord
             SET status = $1
             WHERE id = $2
             RETURNING *`,
      ["DONE", id]
    );

    if (result.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Không update được trạng thái cho khám tổng quát.",
      });
    }

    return res.status(200).json({
      error: false,
      message: "Cập nhật trạng thái khám tổng quát thành công.",
      data: result.rows[0],
    });
  } catch (err) {
    console.error("❌ Lỗi khi cập nhật trạng thái:", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi server khi cập nhật trạng thái." });
  }
}

export async function getRegisterStatus(req, res) {
  {
  }
  const { student_id, campaign_id } = req.body;

  try {
    if (!student_id || !campaign_id) {
      return res.status(400).json({
        error: true,
        message: "Không nhận được Student ID or Campaign ID.",
      });
    }

    const check_student = await query(
      `SELECT * FROM student
                WHERE id = $1`,
      [student_id]
    );

    if (check_student.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Student ID không tồn tại" });
    }

    const check_campaign = await query(
      `SELECT * FROM checkupcampaign
                WHERE id = $1`,
      [campaign_id]
    );

    if (check_campaign.rowCount === 0) {
      return res
        .status(400)
        .json({ error: true, message: "Campaign ID không tồn tại" });
    }

    const rs = await query(
      `SELECT status
             FROM checkupregister
             WHERE student_id = $1
             AND campaign_id= $2`,
      [student_id, campaign_id]
    );

    if (rs.rowCount === 0) {
      return res
        .status(200)
        .json({ error: true, message: "Không tìm thấy Register ID" });
    } else {
      return res.status(200).json({ error: false, data: rs.rows[0] });
    }
  } catch (err) {
    console.error("❌ Error creating Campaign ", err);
    return res
      .status(500)
      .json({ error: true, message: "Lỗi khi lấy Register Status" });
  }
}

export async function getALLSpeciaListExams(req, res) {
  try {
    const result = await query(`
            SELECT * FROM SpecialistExamList
        `);

    return res.status(200).json({
      error: false,
      message: "Lấy danh sách chuyên khoa khám thành công.",
      data: result.rows, // ✅ trả về tất cả rows (không phải rows[0])
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi lấy danh sách chuyên khoa khám.",
    });
  }
}

export async function getAllRecordsOfEachSpeExamInACampaign(req, res) {
  const { campaign_id } = req.params;
  if (!campaign_id) {
    return res.status(400).json({
      error: true,
      message: "Không nhận được Campaign ID.",
    });
  }
  try {
    const contained_exams_res = await query(
      `
            select exam.* from checkupcampaign cc
            join campaigncontainspeexam contain on cc.id = contain.campaign_id
            join specialistExamList exam on contain.specialist_exam_id = exam.id
            where campaign_id = $1
        `,
      [campaign_id]
    );
    if (!contained_exams_res.rowCount) {
      return res.status(200).json({
        error: false,
        message: "Chiến dịch khám định kỳ không khám chuyên khoa.",
      });
    }
    // console.log(contained_exams_res.rows);
    let final_result = [];
    const contained_exams = contained_exams_res.rows;
    for (const exam of contained_exams) {
      const records_response = await query(
        `select rec.*, stu.name as student_name, cla.name as class_name from specialistExamRecord rec
join checkupregister reg on reg.id = rec.register_id join student stu on stu.id = reg.student_id join class cla on cla.id = stu.class_id
where reg.campaign_id = $1 and spe_exam_id = $2 and rec.status != 'CANNOT_ATTACH'`,
        [campaign_id, exam.id]
      );
      final_result.push({ ...exam, records: records_response.rows });
    }
    return res.status(200).json({
      error: false,
      message: "Lấy danh sách record của từng chuyên khoa khám thành công.",
      data: final_result, // ✅ trả về tất cả rows (không phải rows[0])
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi lấy danh sách record của chuyên khoa khám.",
    });
  }
}
export async function completeARecordForSpeExam(req, res) {
  const { spe_exam_id, register_id } = req.params;

  if (!spe_exam_id || !register_id) {
    return res.status(400).json({
      error: true,
      message: "Thiếu thông tin spe_exam_id hoặc register_id.",
    });
  }

  try {
    const result = await query(
      `UPDATE specialistExamRecord
             SET status = 'DONE', is_checked = TRUE
             WHERE spe_exam_id = $1 AND register_id = $2
             RETURNING *`,
      [spe_exam_id, register_id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: true,
        message: "Không tìm thấy bản ghi để cập nhật.",
      });
    }

    return res.status(200).json({
      error: false,
      message: "Cập nhật trạng thái thành công.",
      data: result.rows[0],
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi cập nhật bản ghi chuyên khoa.",
    });
  }
}

export async function handleUploadHealthRecordResult(req, res) {
  const upload = multer({ storage: multer.memoryStorage() }).single("file");

  upload(req, res, async function (err) {
    if (err) {
      return res
        .status(500)
        .json({ error: true, message: "Lỗi khi xử lý file." });
    }

    const { campaign_id } = req.params;
    const file = req.file;

    if (!file) {
      return res
        .status(400)
        .json({ error: true, message: "Không có file Excel nào được upload." });
    }

    try {
      const bucket = "health-record-list-result-excel";
      const path = `health-records-${campaign_id}.xlsx`;

      // 1. Upload file Excel vào Supabase
      await uploadFileToSupabaseStorage(file, bucket, path);

      // 2. Lấy lại file từ Supabase (stream)
      const fileStream = await retrieveFileFromSupabaseStorage(bucket, path);

      // 3. Đọc Excel → JSON
      const json = await excelToJson(fileStream); // trả về mảng object
      const header = Object.keys(json[0]);

      let message = "Xử lý file thành công!";
      let success = true;

      for (const record of json) {
        try {
          const pdfBuffer = await generatePDFBufferFromHealthRecord(record);

          const recordId = record[header[0]]; // cột ID đầu tiên
          const pdfFile = {
            buffer: pdfBuffer,
            mimetype: "application/pdf",
          };

          const publicUrl = await uploadFileToSupabaseStorage(
            pdfFile,
            "health-record-pdf-result",
            `record-${recordId}.pdf`
          );

          const updateRes = await query(
            "UPDATE HealthRecord SET record_url = $1 WHERE id = $2",
            [publicUrl, recordId]
          );

          if (updateRes.rowCount === 0) {
            message += `\n❌ Không tìm thấy record với id ${recordId}`;
            success = false;
          }
        } catch (err) {
          message += `\n❌ Lỗi xử lý record ID ${record[header[0]]}: ${
            err.message
          }`;
          success = false;
        }
      }

      return res.status(200).json({
        error: !success,
        message,
      });
    } catch (err) {
      console.error("❌ Upload thất bại:", err);
      return res.status(500).json({
        error: true,
        message: `Lỗi hệ thống: ${err.message || err}`,
      });
    }
  });
}

export async function handleRetrieveHealthRecordResultByCampaignID(req, res) {
  try {
    const { campaign_id } = req.params;
    const bucket = "health-record-list-result-excel";
    const path = `health-records-${campaign_id}.xlsx`;

    const fileBuffer = await retrieveFileFromSupabaseStorage(bucket, path);

    // Thiết lập headers để cho phép tải file về
    res.setHeader(
      "Content-Type",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    );
    res.setHeader("Content-Disposition", `attachment; filename="${path}"`);

    // Gửi file về client
    res.send(fileBuffer);
  } catch (err) {
    console.error("❌ Lỗi khi tải file:", err.message);
    return res.status(500).json({
      error: true,
      message: `Không thể lấy file: ${err.message || err}`,
    });
  }
}

export async function handleRetrieveSampleImportHealthRecordForm(req, res) {
  try {
    const { campaign_id } = req.params;

    // 1. Lấy danh sách học sinh từ campaign
    const { rows } = await query(
      `SELECT 
            hr.id, 
            s.id AS student_id, 
            s.name AS student_name, 
            c.name AS class_name,  
            s.dob AS dob, 
            CASE 
                WHEN s.isMale = true THEN 'Nam'
                ELSE 'Nữ'
            END AS gender
            FROM HealthRecord hr
            JOIN checkupregister register ON register.id = hr.register_id
            JOIN student s ON s.id = register.student_id
            JOIN class c ON c.id = s.class_id
            WHERE campaign_id = $1;`,
      [campaign_id]
    );

    if (!rows.length) {
      return res
        .status(404)
        .json({
          error: true,
          message: "Không tìm thấy hồ sơ nào trong chiến dịch này.",
        });
    }

    // 2. Tạo workbook Excel
    const workbook = new exceljs.Workbook();
    const worksheet = workbook.addWorksheet("Health Record Template");

    // 3. Tạo cột mẫu
    const headers = [
      "Mã hồ sơ",
      "Mã học sinh",
      "Họ tên",
      "Ngày sinh",
      "Lớp",
      "Giới tính",
      "Chiều cao",
      "Cân nặng",
      "Huyết áp",
      "Mắt trái",
      "Mắt phải",
      "Tai",
      "Mũi",
      "Họng",
      "Răng",
      "Lợi",
      "Da",
      "Tim",
      "Phổi",
      "Cột sống",
      "Tư thế",
    ];

    worksheet.addRow(headers);

    // 4. Thêm dữ liệu mẫu (không có dữ liệu khám)
    rows.forEach((row) => {
      worksheet.addRow([
        row.id,
        row.student_id,
        row.student_name,
        row.dob,
        row.class_name,
        row.gender,
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
      ]);
    });

    // 5. Gửi về file Excel
    res.setHeader(
      "Content-Type",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    );
    res.setHeader(
      "Content-Disposition",
      "attachment; filename=health-record-template.xlsx"
    );

    await workbook.xlsx.write(res); // ghi trực tiếp stream vào response
    res.end();
  } catch (err) {
    console.error("❌ Lỗi tạo file mẫu:", err);
    return res.status(500).json({
      error: true,
      message: "Không thể tạo file mẫu",
    });
  }
}

export async function updateSpecialRecord(req, res) {
  const { register_id, spe_exam_id } = req.params;

  const { result, diagnosis, diagnosis_url, dr_name } = req.body;

  try {
    if (
      !register_id ||
      !spe_exam_id ||
      !result ||
      !diagnosis ||
      !diagnosis_url
    ) {
      return res.status(404).json({
        error: true,
        message: "Không nhận được đầy đủ dữ liệu.",
      });
    }

    const check_register = await query(
      `SELECT * FROM checkupregister WHERE id = $1`,
      [register_id]
    );
    if (check_register.rowCount === 0) {
      return res.status(404).json({
        error: true,
        message: "Register ID không tồn tại.",
      });
    }

    const check_spe = await query(
      `SELECT * FROM specialistexamlist WHERE id = $1`,
      [spe_exam_id]
    );
    if (check_spe.rowCount === 0) {
      return res.status(404).json({
        error: true,
        message: "Special-Exam ID không tồn tại.",
      });
    }

    const diagnosisUrls = Array.isArray(diagnosis_url)
      ? diagnosis_url
      : [diagnosis_url];

    const rs = await query(
      `UPDATE specialistexamrecord
        SET result = $1, diagnosis = $2, diagnosis_paper_urls = $3 ,dr_name = $4
        WHERE register_id = $5 AND spe_exam_id = $6
        RETURNING *`,
      [result, diagnosis, diagnosisUrls, dr_name, register_id, spe_exam_id]
    );

    if (rs.rowCount === 0) {
      return res.status(404).json({
        error: true,
        message: "Update Special-Exam Record không thành công.",
      });
    }

    return res.status(200).json({
      error: false,
      message: "Update Special-Exam Record thành công.",
      data: rs.rows[0],
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi Update Special-Exam Record.",
    });
  }
}
export async function uploadDiagnosisURL(req, res) {
  const { register_id, spe_exam_id } = req.params;
  const files = req.files;

  try {
    if (!register_id || !spe_exam_id) {
      return res.status(400).json({
        error: true,
        message: "Thiếu register_id hoặc spe_exam_id trong URL.",
      });
    }

    if (!files || files.length === 0) {
      return res.status(400).json({
        error: true,
        message: "Không có ảnh nào được upload.",
      });
    }

    const urls = [];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const fileExt = file.originalname.split(".").pop();
      const index = i + 1;
      const fileName = `${register_id}_${spe_exam_id}_${index}.${fileExt}`;
      const filePath = `special-exams/${fileName}`;

      // Upload ảnh lên Supabase Storage với quyền admin
      const { error: uploadError } = await admin.storage
        .from(BUCKET)
        .upload(filePath, file.buffer, {
          contentType: file.mimetype,
          upsert: true,
        });

      if (uploadError) {
        console.error(`❌ Lỗi khi upload ${fileName}:`, uploadError);
        continue;
      }

      // Lấy public URL từ storage
      const { data } = admin.storage.from(BUCKET).getPublicUrl(filePath);

      urls.push(data.publicUrl);
    }

    if (urls.length === 0) {
      return res.status(500).json({
        error: true,
        message: "Tất cả ảnh đều upload thất bại.",
      });
    }

    return res.status(200).json({
      error: false,
      message: "Upload ảnh thành công.",
      urls: urls,
    });
  } catch (err) {
    console.error("❌ Lỗi upload ảnh:", err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi upload ảnh.",
    });
  }
}

// duy khanh -- export pdf file for general medical checkup record + specialist exam record
export async function handleDownloadFinalReportOfAStudentInCampaign(req, res) {
  const { student_id, campaign_id } = req.params;

  if (!student_id || !campaign_id) {
    return res.status(400).json({
      error: true,
      message: "Thiếu student_id hoặc campaign_id.",
    });
  }

  try {
    const [
      campaignInfoResult,
      studentInfo,
      generalHealthResult,
      specialistExamResult,
    ] = await Promise.all([
      query(`SELECT * FROM checkupcampaign WHERE id = $1`, [campaign_id]),
      getProfileOfStudentByID(student_id),
      query(
        `SELECT hr.*
            FROM HealthRecord hr
            JOIN CheckupRegister cr ON hr.register_id = cr.id
            WHERE cr.student_id = $1 AND cr.campaign_id = $2`,
        [student_id, campaign_id]
      ),
      query(
        `SELECT json_agg(
                            json_build_object(
                                'spe_exam_id', spe.id,
                                'specialist_name', spe.name,
                                'record_status', rec.status,
                                'record_urls', rec.diagnosis_paper_urls,
                                'doctor_name', rec.dr_name,
                                'result', rec.result,
                                'date_record', rec.date_record,
                                'is_checked', rec.is_checked,
                                'diagnosis', rec.diagnosis
                            )
                            ) AS records
                        FROM student stu
                        JOIN checkupregister reg ON reg.student_id = stu.id
                        JOIN checkupcampaign camp ON camp.id = reg.campaign_id
                        JOIN specialistexamrecord rec ON rec.register_id = reg.id
                        JOIN specialistexamlist spe ON spe.id = rec.spe_exam_id
                        WHERE rec.status != 'CANNOT_ATTACH'
                        AND stu.id = $1
                        AND camp.id = $2
                        GROUP BY stu.id, camp.id`,
        [student_id, campaign_id]
      ),
    ]);

    if (
      !campaignInfoResult.rows.length ||
      !generalHealthResult.rows.length ||
      !studentInfo
    ) {
      return res.status(404).json({
        error: true,
        message: "Không tìm thấy dữ liệu để tạo báo cáo.",
      });
    }

    const campaign_info = campaignInfoResult.rows[0];
    const student_profile = studentInfo;
    const general_health = generalHealthResult.rows[0];
    const specialist_exam_records = specialistExamResult.rows[0]?.records || [];

    const pdfBuffer = await generatePDFBufferForFinalHealthReport(
      campaign_info,
      student_profile,
      general_health,
      specialist_exam_records
    );

    const finalMergedBuffer = await mergeFinalReportWithSpecialistPdfs(
      pdfBuffer,
      specialist_exam_records
    );
    console.log("🧾 Final PDF size:", finalMergedBuffer.length);
    res.writeHead(200, {
      "Content-Type": "application/pdf",
      "Content-Disposition": `attachment; filename="final_report_${student_id}_${campaign_id}.pdf"`,
      "Content-Length": finalMergedBuffer.length,
    });
    res.end(finalMergedBuffer);
  } catch (err) {
    console.error("❌ Error downloading report:", err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi tải báo cáo.",
      detail: err.message,
    });
  }
}

export async function uploadPdfForDiagnosisUrls(req, res) {
  const { register_id, spe_exam_id } = req.params;
  const files = req.files;

  try {
    if (!register_id || !spe_exam_id) {
      return res.status(400).json({
        error: true,
        message: "Thiếu register_id hoặc spe_exam_id trong URL.",
      });
    }

    if (!files || files.length === 0) {
      return res.status(400).json({
        error: true,
        message: "Không có file PDF nào được upload.",
      });
    }

    const urls = [];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const fileExt = file.originalname.split(".").pop().toLowerCase();

      if (fileExt !== "pdf" || file.mimetype !== "application/pdf") {
        console.warn(`❌ File không hợp lệ: ${file.originalname}`);
        continue;
      }

      const index = i + 1;
      const fileName = `${register_id}_${spe_exam_id}_${index}.pdf`;
      const filePath = `special-exams/${fileName}`;

      const { error: uploadError } = await admin.storage
        .from(BUCKET)
        .upload(filePath, file.buffer, {
          contentType: "application/pdf",
          upsert: true,
        });

      if (uploadError) {
        console.error(`❌ Lỗi khi upload ${fileName}:`, uploadError);
        continue;
      }

      const { data } = admin.storage.from(BUCKET).getPublicUrl(filePath);

      urls.push(data.publicUrl);
    }

    if (urls.length === 0) {
      return res.status(500).json({
        error: true,
        message: "Tất cả file PDF đều upload thất bại.",
      });
    }

    return res.status(200).json({
      error: false,
      message: "Upload file PDF thành công.",
      urls: urls,
    });
  } catch (err) {
    console.error("❌ Lỗi upload file PDF:", err);
    return res.status(500).json({
      error: true,
      message: "Lỗi server khi upload file PDF.",
    });
  }
}

async function mergeFinalReportWithSpecialistPdfs(
  mainPdfBuffer,
  specialistRecords
) {
  const mergedPdf = await PDFDocument.create();

  // 1. Thêm file khám tổng quát
  const mainPdfDoc = await PDFDocument.load(mainPdfBuffer);
  const copiedPages = await mergedPdf.copyPages(
    mainPdfDoc,
    mainPdfDoc.getPageIndices()
  );
  copiedPages.forEach((page) => mergedPdf.addPage(page));

  // 2. Thêm từng file từ specialist_exam_records
  for (const record of specialistRecords) {
    const urls = record?.record_urls || [];
    for (const url of urls) {
      try {
        const response = await axios.get(url, { responseType: "arraybuffer" });
        const pdfDoc = await PDFDocument.load(response.data);
        const pages = await mergedPdf.copyPages(
          pdfDoc,
          pdfDoc.getPageIndices()
        );
        pages.forEach((page) => mergedPdf.addPage(page));
        console.log(url);
      } catch (err) {
        console.warn(`❌ Lỗi tải hoặc xử lý PDF từ URL: ${url}`, err.message);
      }
    }
  }

  const mergedBuffer = await mergedPdf.save();
  return mergedBuffer;
}

export async function sendMailRegister(req, res) {
  const { campaign_id } = req.params;

  if (!campaign_id) {
    return res.status(400).json({
      error: true,
      message: "Thiếu dữ liệu!",
    });
  }

  try {
    const check = await query(
      `SELECT * FROM checkupcampaign 
            WHERE id = $1 `,
      [campaign_id]
    );

    if (check.rowCount === 0) {
      return res.status(400).json({
        error: true,
        message: "Không tìm thấy Campaign!",
      });
    }

    const campaign = check.rows;

    const parentList = await query(`
SELECT 
    p.id AS parent_id,
    p.name AS parent_name,
    p.email AS email,
    s.id AS student_id,
    s.name AS student_name
FROM parent p
LEFT JOIN home h ON h.mom_id = p.id OR h.dad_id = p.id
LEFT JOIN student s ON s.home_id = h.id
WHERE p.email IS NOT NULL
ORDER BY p.id;
`);

    const parent_list = parentList.rows;

    if (!parent_list || parent_list.length === 0) {
      return res.status(400).json({
        error: true,
        message: "Không tìm thấy Parent List!",
      });
    }

    const result = await sendCheckupRegister(
      parent_list,
      campaign[0].name,
      campaign[0].description,
      campaign[0].location,
      campaign[0].start_date,
      campaign[0].end_date
    );
    return res.status(200).json({
      error: false,
      message: `Đã gửi email thành công`,
    });
  } catch (err) {
    console.error("❌ Error:", err);
    return res.status(500).json({
      error: true,
      message: "Lỗi khi gửi mail",
      detail: err.message,
    });
  }
}
