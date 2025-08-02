import express from "express";
import multer from "multer";
import {
  cancelRegister,
  closeRegister,
  createCampaign,
  getCheckupRegisterByParentID,
  updateHealthRecord,
  submitRegister,
  getCheckupRegisterStudent,
  getHealthRecordsOfAStudent,
  getHealthRecordStudent,
  getCheckupRegisterByStudentID,
  getAllCheckupCampaigns,
  getALLHealthRecord,
  getALLRegisterByCampaignID,
  getALLSpeciaListExamRecord,
  UpdateCheckinHealthRecord,
  UpdateCheckinSpecialRecord,
  getHealthRecordParentDetails,
  getSpecialRecordParent,
  getSpecialRecordParentDetails,
  startCampaig,
  finishCampaign,
  getCampaignDetail,
  getRegisterID,
  getRegisterStatus,
  getALLHealthRecordOfACampaign,
  completeAHealthRecordForStudent,
  getALLSpeciaListExams,
  getAllRecordsOfEachSpeExamInACampaign,
  completeARecordForSpeExam,
  handleUploadHealthRecordResult,
  handleRetrieveHealthRecordResultByCampaignID,
  handleRetrieveSampleImportHealthRecordForm,
  getSpecialRecordsOfAStudent,
  getFullHealthAndSpecialRecordsOfAStudent,
  sendRegister,
  updateCampaign,
  getAllHealthRecordOfStudent,
  getFullRecordOfAStudentInACampaign,
  getHealthRecordByID,
  updateSpecialRecord,
  uploadDiagnosisURL,
  handleDownloadFinalReportOfAStudentInCampaign,
  getCheckupRegisterStatus,
  getWaitingSpecialistExams,
  uploadPdfForDiagnosisUrls,
  sendMailRegister
} from "../controllers/checkUp.controller.js";

const upload = multer();
const router = express.Router();

//Orther

router.post('/checkup/:campaign_id/send-mail-register', sendMailRegister) // API gửi mail cho phụ huynh để thông báo có Register mới 

router.post('/checkup/:campaign_id/send-register', sendRegister);//Truyền vào ID Campaign để gửi Register cho phụ huynh
router.put('/checkup/:campaign_id/update-info', updateCampaign);//Truyền vào ID Campaign để Update thông tin Campaign

router.get('/health-record/:student_id', getAllHealthRecordOfStudent); //Truyền vào Student_id lấy tất cả ds healthrecord của Student


router.get('/checkup/campaign_id/:campaign_id/student_id/:student_id', getRegisterID); //Lấy Register ID 
router.get('/checkup/survey/status', getRegisterStatus);//Lay Register Status

router.get("/health-record", getALLHealthRecord); // Lấy tất cả DS Health Record có status DONE // bỏ cái check done đi anh ui
router.get("/special-record", getALLSpeciaListExamRecord); //Lấy tất cả SpeciaListExamRecord có status DONE // bỏ cái check done đi anh ui

router.get("/health-record/campaign/:campaign_id", getALLHealthRecordOfACampaign); // Lấy tất cả DS Health Record có status DONE // bỏ cái check done đi anh ui
router.patch("/health-record/:id/done", completeAHealthRecordForStudent)

router.get("/checkup-register/campaign/:campaign_id/student/:student_id/status", getCheckupRegisterStatus);
router.get('/checkup-register/:id', getALLRegisterByCampaignID);//Lấy tất cả các CheckUp register cần tuyền vào campaign_id 

router.get('/checkup-register/parent/:id', getCheckupRegisterByParentID);   //Lấy các CheckUpRegister và speciallistexamrecord từ parent_id
router.get('/checkup-register/student/:id', getCheckupRegisterByStudentID);   //Lấy các CheckUpRegister và speciallistexamrecord từ Student_id 
router.get("/checkup-register/:student_id/:campaign_id/specialist-exams/waiting", getWaitingSpecialistExams); // lấy ra tên khám chuyên khoa đã được khảo sát và chờ khám 

router.get("/parent/:id/checkup-register", getCheckupRegisterByParentID); //Lấy các CheckUpRegister và speciallistexamrecord từ parent_id
router.get("/student/:id/checkup-register", getCheckupRegisterByStudentID
); //Lấy các CheckUpRegister và speciallistexamrecord từ Student_id

router.get("/checkup-campaign-detail/:id", getCampaignDetail); //Lấy Campain Detail truyền vào campaign_id (P)

//Admin
router.post("/checkup-campaign", createCampaign); // admin tạo campaign
router.get("/checkup-campaign", getAllCheckupCampaigns); // lấy tất cả DS campaign
router.patch("/checkup-campaign/:id/close", closeRegister); // Amdin đóng form Register
router.patch("/checkup-campaign/:id/cancel", cancelRegister); //Admin cancel form Register

router.patch("/checkup-campaign/:id/start", startCampaig); // Admin start campaign ( status : ONGOING) truyền vào body campaign_id
router.patch("/checkup-campaign/:id/finish", finishCampaign); //Admin finish Campaign ( status : DONE) truyền vào body campaign_id

//Parent
router.patch("/checkup-register/:id/submit", submitRegister); // Parent submit form Register

router.get("/student/:id/checkup-health-record", getHealthRecordsOfAStudent); // duy khanh
router.get("/student/:id/specialist-record", getSpecialRecordsOfAStudent); // duy khanh
router.get("/student/:id/full-record", getFullHealthAndSpecialRecordsOfAStudent); // duy khanh
router.get("/checkup-health-record/detail", getHealthRecordParentDetails); //Parenet xem chi tiết Health Record của Student truyền vào health_reocd_id

router.get("/checkup-special-record", getSpecialRecordParent); // Parent xem tất cả Special Record của Student truyền vào body Student_id
router.get("/checkup-special-record/detail", getSpecialRecordParentDetails); //paretn xem chi tiết Special Record  truyền vào register_id và spe_exam_id

//Nurse

//Update Special-Exam Record
router.put('/special-exam-record/:register_id/:spe_exam_id', updateSpecialRecord); //update result , diagnosis cho Spe-Exam-Record
router.post('/upload-diagnosis_url/:register_id/:spe_exam_id', upload.array("files"), uploadDiagnosisURL); //Lưu  DiagnosisURL vào supabase


//CHECK-IN
router.patch('/checkup-checkin/register_id/:register_id/campaign/:campaign_id/', UpdateCheckinHealthRecord);//Nurse Checkin Khám Định kỳ cần truyền vào Student_id và Campain_id trong body
router.patch('/checkup-checkin/special-record', UpdateCheckinSpecialRecord); //Nurse Checkin Khám Chuyên khoa truyền vào student_id,campaign_id,spex_exam_id

router.patch('/checkup/:record_id/record', updateHealthRecord) // Doctor or Nurse update Heatlh Record for Student
router.get('/checkup-register/student/:id', getCheckupRegisterStudent);  // Student lấy các lịch sử registers
router.get('/health-record/campaign/:campaign_id/student/:student_id', getHealthRecordStudent);//Student view Health Record

router.get("/full-record/campaign/:campaign_id/student/:student_id", getFullRecordOfAStudentInACampaign); // lấy toàn bộ khám chuyên khoa, khám tổng quát của một học sinh trong một đợt khám định kỳ
router.get("/health-record/:record_id/detail", getHealthRecordByID);
router.get("/specialist-exam", getALLSpeciaListExams); // lấy toàn bộ các chuyên môn khám có sẵn
router.get("/campaign/:campaign_id/specialist-exam/record", getAllRecordsOfEachSpeExamInACampaign); //
router.patch("/checkup-register/:register_id/specialist-exam/:spe_exam_id/done", completeARecordForSpeExam);
// duy khanh
router.post("/campaign/:campaign_id/upload-health-record-result", handleUploadHealthRecordResult); //excel upload file then retrieve each row to update record result_url
router.get("/campaign/:campaign_id/import-health-record-form", handleRetrieveSampleImportHealthRecordForm); // trả về form gồm tất cả các record của một chiến dịch để làm smaple mẫu cho nurse cập nhật thông tin khám
router.get("/campaign/:campaign_id/download-health-record-result", handleRetrieveHealthRecordResultByCampaignID);
router.get("/campaign/:campaign_id/student/:student_id/download-final-report", handleDownloadFinalReportOfAStudentInCampaign); // file pdf chua all general health reccord + kham chuyen sau

router.post("/register/:register_id/spe-exam/:spe_exam_id/pdf-diagnosis-urls", uploadPdfForDiagnosisUrls);

export default router;
