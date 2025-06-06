// routes/employee.routes.js
import express from "express";
import {
  register,
  login,
  logout,
  changePassword,
  getAllEmployees,
  getOneEmployee,
  updateEmployee,
  deleteEmployee,
  assignShift,
  getAssignedShift,
  getAllAssignedShifts,
  updateShift,
  deleteShift,
  clockin,
  clockout,
  singleAttendance,
  getAllEmployeesWithAttendance,
  getAllEmployeesWithStatus,
  singleStatus
} from "./routes.js";

const router = express.Router();

// Register
router.post("/register", register); //works

// Login
router.post("/login", login); //works

// Logout
router.post("/logout", logout); //works

// Change password
router.post("/changePassword/:id", changePassword); // works

// Get all employees
router.get("/employees", getAllEmployees); //works

// Get one employee
router.get("/employees/:id", getOneEmployee); //works

// Update employee
router.put("/updateEmployee/:id", updateEmployee); //works

// Delete employee
router.delete("/deleteEmployee/:id", deleteEmployee); //works

// Employee clock in
router.post("/clockin/:id", clockin); // works

// Employee clock out
router.post("/clockout/:id", clockout); // works

// Get all employees with attendance records
router.get("/attendance", getAllEmployeesWithAttendance); // works

// Get attendance for a single employee
router.get("/attendance/:id", singleAttendance); // works


// Assign shift
router.post("/assignShift/:id", assignShift); //works

// Get assigned shift for single employee
router.get("/assignedShift/:id", getAssignedShift); //works

// Get all assigned shifts
router.get("/assignedShift", getAllAssignedShifts); //works

// Update a shift by ID
router.put("/shift/:id", updateShift); //works

// Delete a shift by ID
router.delete("/shift/:id", deleteShift); //works

// Get all employees with status info
router.get("/status", getAllEmployeesWithStatus); // works

// Get status info for a single employee
router.get("/status/:id", singleStatus); // works

export default router;


