import bcrypt from "bcryptjs";
import Employee from "../modals/modal.employee.js";
import Shift from "../modals/modal.shift.js";

// Register
async function register(req, res) {
  const {
    name, email, id, password, profilePicture, phone,
    position, shift, status, isAdmin,
  } = req.body;

  try {
    const existingEmployee = await Employee.findOne({ $or: [{ email }, { id }] });
    if (existingEmployee) {
      return res.status(400).json({ message: "Email or ID already in use" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const employee = new Employee({
      name, email, id, password: hashedPassword,
      profilePicture, phone, position, shift, status, isAdmin
    });

    const savedEmployee = await employee.save();
    return res.status(201).json({ message: "User created successfully", employee: savedEmployee });
  } catch (error) {
    console.log(error);
    return res.status(400).json({ message: "Error creating user", error });
  }
}

async function changePassword(req, res) {
  const { id } = req.params;
  const { currentPassword, newPassword } = req.body;

  try {
    const employee = await Employee.findOne({ id });
    if (!employee) return res.status(404).json({ message: "Employee not found" });

    const isMatch = await bcrypt.compare(currentPassword, employee.password);
    if (!isMatch) return res.status(401).json({ message: "Incorrect current password" });

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);
    employee.password = hashedPassword;
    await employee.save();

    return res.status(200).json({ message: "Password changed successfully" });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error changing password", error });
  }
}

async function login(req, res) {
  const { email, password } = req.body;

  try {
    const employee = await Employee.findOne({ email });
    if (!employee) return res.status(404).json({ message: "User not found" });

    const isMatch = await bcrypt.compare(password, employee.password);
    if (!isMatch) return res.status(401).json({ message: "Invalid credentials" });

    return res.status(200).json({ message: "Login successful", employee });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Login error", error });
  }
}
async function getOneEmployee(req, res) {
  const { id } = req.params;
  try {
    const employee = await Employee.findOne({ id });
    if (!employee) return res.status(404).json({ message: "Employee not found" });
    return res.status(200).json(employee);
  } catch (error) {
    return res.status(500).json({ message: "Error fetching employee", error });
  }
}

async function getAllEmployees(req, res) {
  try {
    const employees = await Employee.find();
    if (!employees.length) return res.status(404).json({ message: "No employees found" });
    return res.status(200).json(employees);
  } catch (error) {
    return res.status(500).json({ message: "Error fetching employees", error });
  }
}

async function updateEmployee(req, res) {
  const { id } = req.params;
  const { name, email, password, profilePicture, phone, position, shift, status, isAdmin } = req.body;
  try {
    const employee = await Employee.findOneAndUpdate(
      { id },
      { name, email, password, profilePicture, phone, position, shift, status, isAdmin },
      { new: true }
    );
    if (!employee) return res.status(404).json({ message: "Employee not found" });
    return res.status(200).json(employee);
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Error updating employee", error });
  }
}

async function deleteEmployee(req, res) {
  const { id } = req.params;
  try {
    const employee = await Employee.findOneAndDelete({ id });
    if (!employee) return res.status(404).json({ message: "Employee not found" });
    await Shift.deleteMany({ employeeId: Number(id) });
    return res.status(200).json({ message: "Employee and their shifts deleted successfully" });
  } catch (error) {
    return res.status(500).json({ message: "Error deleting employee", error });
  }
}
// ================= Commit 3: Clock-In / Clock-Out =================
async function clockin(req, res) {
  const { id } = req.params;
  const { shiftId } = req.body;
  const currentTime = new Date().toLocaleTimeString();
  const date = new Date().toISOString().split("T")[0];

  try {
    const employee = await Employee.findOne({ id });
    if (!employee) return res.status(404).json({ message: "Employee not found" });

    const shift = await Shift.findOne({ id: shiftId, employeeId: Number(id) });
    if (!shift) return res.status(404).json({ message: "Shift not found for this employee" });

    const existingClockIn = shift.attendance.find(
      (a) => a.date === date && a.actionType === "Clock In"
    );
    if (existingClockIn) return res.status(400).json({ message: "Already clocked in today" });

    shift.attendance.push({
      actionType: "Clock In",
      time: currentTime,
      date,
      status: "active"
    });

    employee.status = "active";
    await employee.save();
    await shift.save();

    res.status(200).json({ message: "Clock-in successful", shift });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Clock-in failed", error });
  }
}

async function clockout(req, res) {
  const { id } = req.params;
  const { shiftId } = req.body;
  const currentTime = new Date().toLocaleTimeString();
  const date = new Date().toISOString().split("T")[0];

  try {
    const employee = await Employee.findOne({ id });
    if (!employee) return res.status(404).json({ message: "Employee not found" });

    const shift = await Shift.findOne({ id: shiftId, employeeId: Number(id) });
    if (!shift) return res.status(404).json({ message: "Shift not found for this employee" });

    const clockInRecord = shift.attendance.find(
      (a) => a.date === date && a.actionType === "Clock In"
    );
    if (!clockInRecord) return res.status(400).json({ message: "You haven't clocked in today" });

    const existingClockOut = shift.attendance.find(
      (a) => a.date === date && a.actionType === "Clock Out"
    );
    if (existingClockOut) return res.status(400).json({ message: "Already clocked out today" });

    shift.attendance.push({
      actionType: "Clock Out",
      time: currentTime,
      date,
      status: "on leave"
    });

    employee.status = "on leave";
    await employee.save();
    await shift.save();

    res.status(200).json({ message: "Clock-out successful", shift });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Clock-out failed", error });
  }
}
