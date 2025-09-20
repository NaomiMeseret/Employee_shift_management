// routes/employee.routes.js
import express from "express";

import {
  assignShift,
  clockin,
  clockout,
  deleteEmployee,
  getAllAssignedShifts,
  getAllEmployees,
  getAllEmployeesWithAttendance,
  getAllEmployeesWithStatus,
  getAssignedShift,
  getOneEmployee,
  login,
  register,
  singleAttendance,
  singleStatus,
  updateEmployee,
  logout,
  updateShift,
  deleteShift,
  changePassword,
  getPendingUsers,
  approveUser,
  rejectUser,
  createAdmin
} from "./routes.js";


const router = express.Router();

// Register
router.post("/register", register); //works

// Login
router.post("/login", login); //works

// Login
router.post("/logout", logout); //works

// Change password
router.post("/changePassword/:id", changePassword); // works

// Get all
router.get("/employees", getAllEmployees); //works

// Get one
router.get("/employees/:id", getOneEmployee); //works

// Update
router.put("/updateEmployee/:id", updateEmployee); //works

// Delete
router.delete("/deleteEmployee/:id", deleteEmployee); //works

//clock in
router.post("/clockin/:id", clockin); //works

//clock out
router.post("/clockout/:id", clockout); //works

//assign shift
router.post("/assignShift/:id", assignShift); //works

//get assigned shift for a single employee
router.get("/assignedShift/:id", getAssignedShift); //works

//get all assigned shifts
router.get("/assignedShift", getAllAssignedShifts); //works

// update a shift by ID
router.put("/shift/:id", updateShift); //works

// delete a shift by ID
router.delete("/shift/:id", deleteShift); //works

//get all Employee with status
router.get("/status", getAllEmployeesWithStatus); //works

// get sigle employee with status
router.get("/status/:id", singleStatus);
//get all employees with attendance
router.get("/attendance", getAllEmployeesWithAttendance); //works

router.get("/attendance/:id", singleAttendance); //works

// Admin user management routes
router.get("/pending", getPendingUsers); // Get pending users for approval
router.put("/approve/:id", approveUser); // Approve user
router.delete("/reject/:id", rejectUser); // Reject user
router.post("/createAdmin", createAdmin); // Create first admin user

export default router;