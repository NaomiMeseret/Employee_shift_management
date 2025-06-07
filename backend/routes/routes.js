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