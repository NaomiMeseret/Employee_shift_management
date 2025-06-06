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
