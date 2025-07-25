import express from "express";
import {
  getSummary,
  getAccidentStats,
  getDiseaseStats,
  getHealthStats,
  getMedicalPlans,
  getHealthStatsByGradeID,
  getPendingRecords,
  getParentDashboardStats,
} from "../controllers/dashboard.controller.js";

const router = express.Router();

router.get("/dashboard/summary", getSummary);
router.get("/dashboard/accidents", getAccidentStats);
router.get("/dashboard/diseases/:disease_id?", getDiseaseStats);
router.get("/dashboard/health-stats", getHealthStats);
router.get("/dashboard/upcoming-health-plans", getMedicalPlans);
router.get("/dashboard/height-weight/:grade_id?", getHealthStatsByGradeID);
router.get("/dashboard/pending-records", getPendingRecords);
router.get("/dashboard/:student_id/parent-dashboard", getParentDashboardStats);
export default router;
