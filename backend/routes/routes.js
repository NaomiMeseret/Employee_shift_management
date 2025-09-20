import bcrypt from "bcryptjs";
import Employee from "../modals/modal.employee.js";
import Shift from "../modals/modal.shift.js";

// Register
async function register(req, res) {
  const {
    name,
    email,
    id,
    password,
    profilePicture,
    phone,
    position,
    shift,
    status,
    isAdmin,
  } = req.body;

  try {
    // Check if email or id already exists
    const existingEmployee = await Employee.findOne({
      $or: [{ email }, { id }],
    });
    if (existingEmployee) {
      return res.status(400).json({ message: "Email or ID already in use" });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    
    const employee = new Employee({
      name,
      email,
      id,
      password: hashedPassword,
      profilePicture: profilePicture || "default.jpg",
      phone,
      position,
      shift,
      status: status || "pending", // New users need admin approval
      isAdmin: isAdmin || false, // Default to false for security
    });

    const savedEmployee = await employee.save();
    return res
      .status(201)
      .json({ message: "User created successfully", employee: savedEmployee });
  } catch (error) {
    console.log(error)
    return res.status(400).json({ message: "Error creating user", error });
  }
}

async function changePassword(req, res) {
  const { id } = req.params;
  const { currentPassword, newPassword } = req.body;
  

  try {
    // 1. Find the employee by ID
    const employee = await Employee.findOne({ id });
    if (!employee) {
      console.log( "Employee not found")
      return res.status(404).json({ message: "Employee not found" });
    }

    // 2. Verify the current password
    const isMatch = await bcrypt.compare(currentPassword, employee.password);
    if (!isMatch) {
      console.log("Incorrect current password")
      return res.status(401).json({ message: "Incorrect current password" });
    }

    // 3. Hash the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // 4. Update and save the new password
    employee.password = hashedPassword;
    await employee.save();

    return res.status(200).json({ message: "Password changed successfully" });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error changing password", error });
  }
}

// Login endpoint: POST /api/login
async function login(req, res) {
  const { email, password } = req.body;

  try {
    const employee = await Employee.findOne({ email });
    if (!employee) {
      return res.status(404).json({ message: "User not found" });
    }

    // Check if user account is pending approval
    if (employee.status === "pending") {
      return res.status(403).json({ 
        message: "Your account is pending admin approval. Please contact your administrator." 
      });
    }

    // Check if user account is inactive
    if (employee.status === "inactive") {
      return res.status(403).json({ 
        message: "Your account has been deactivated. Please contact your administrator." 
      });
    }

    const isMatch = await bcrypt.compare(password, employee.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }
   
    return res.status(200).json({ message: "Login successful", employee });
  } catch (error) {
    console.log(error)
    return res.status(500).json({ message: "Login error", error });
  }
}

//get one employee

async function getOneEmployee(req, res) {
  const { id } = req.params;
  try {
    const employee = await Employee.findOne({ id });
    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }
    return res.status(200).json(employee);
  } catch (error) {
    return res.status(500).json({ message: "Error fetching employee", error });
  }
}

//get all employees

async function getAllEmployees(req, res) {
  try {
    const employees = await Employee.find();
    if (!employees) {
      return res.status(404).json({ message: "No employees found" });
    }
    return res.status(200).json(employees);
  } catch (error) {
    return res.status(500).json({ message: "Error fetching employees", error });
  }
}

//update employee

async function updateEmployee(req, res) {
  const { id } = req.params;
  const {
    name,
    email,
    password,
    profilePicture,
    phone,
    position,
    shift,
    status,
    isAdmin,
  } = req.body;

  try {
    const employee = await Employee.findOneAndUpdate(
      { id },
      {
        name,
        email,
        password,
        profilePicture,
        phone,
        position,
        shift,
        status,
        isAdmin,
      },
      { new: true }
    );

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    return res.status(200).json(employee);
  } catch (error) {
    console.log(error)
    return res.status(500).json({ message: "Error updating employee", error });
  }
}

//delete employee

async function deleteEmployee(req, res) {
  const { id } = req.params;

  try {
    const employee = await Employee.findOneAndDelete({ id });

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }
    try {
      await Shift.deleteMany({ 
        $or: [
          { employeeId: id },           // String ID
          { employeeId: Number(id) },   // Numeric ID (if valid)
          { employeeId: parseInt(id) }  // Parsed integer ID
        ]
      });
    } catch (shiftError) {
      console.log('Note: Could not delete shifts for employee:', id, shiftError.message);
      // Continue with employee deletion even if shift deletion fails
    }

    return res.status(200).json({ message: "Employee deleted successfully" });
  } catch (error) {
    console.error('Delete employee error:', error);
    return res.status(500).json({ message: "Error deleting employee", error: error.message });
  }
}

//clock in
async function clockin(req, res) {
  const { id } = req.params;
  const { shiftId } = req.body;
  const currentTime = new Date().toLocaleTimeString();
  const date = new Date().toISOString().split("T")[0];

  try {
    const employee = await Employee.findOne({ id });
    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    const shift = await Shift.findOne({ id: shiftId, employeeId: Number(id) });
    if (!shift) {
      return res.status(404).json({ message: "Shift not found for this employee" });
    }

    // Check if already clocked in today
    const existingClockIn = shift.attendance.find(
      (a) => a.date === date && a.actionType === "Clock In"
    );
    if (existingClockIn) {
      return res.status(400).json({ message: "Already clocked in today" });
    }

    // Add clock in record
    shift.attendance.push({
      actionType: "Clock In",
      time: currentTime,
      date: date,
      status: "active"
    });

    // Update employee status
    employee.status = "active";
    await employee.save();
    await shift.save();

    res.status(200).json({ message: "Clock-in successful", shift });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Clock-in failed", error });
  }
}

//clock out
async function clockout(req, res) {
  const { id } = req.params;
  const { shiftId } = req.body;
  const currentTime = new Date().toLocaleTimeString();
  const date = new Date().toISOString().split("T")[0];

  try {
    const employee = await Employee.findOne({ id });
    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    const shift = await Shift.findOne({ id: shiftId, employeeId: Number(id) });
    if (!shift) {
      return res.status(404).json({ message: "Shift not found for this employee" });
    }

    // Check if clocked in today
    const clockInRecord = shift.attendance.find(
      (a) => a.date === date && a.actionType === "Clock In"
    );
    if (!clockInRecord) {
      return res.status(400).json({ message: "You haven't clocked in today" });
    }

    // Check if already clocked out
    const existingClockOut = shift.attendance.find(
      (a) => a.date === date && a.actionType === "Clock Out"
    );
    if (existingClockOut) {
      return res.status(400).json({ message: "Already clocked out today" });
    }

    // Add clock out record
    shift.attendance.push({
      actionType: "Clock Out",
      time: currentTime,
      date: date,
      status: "on leave"
    });

    // Update employee status
    employee.status = "on leave";
    await employee.save();
    await shift.save();

    res.status(200).json({ message: "Clock-out successful", shift });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Clock-out failed", error });
  }
}

// assign shift to employee
async function assignShift(req, res) {
  const { date, shiftType, shiftId } = req.body;
  const { id } = req.params;

  try {
    
    console.log("here are the data sent", date, shiftType, shiftId)
  
    const existingId = await Employee.findOne({
     shiftId 
    });
    if (existingId) {
      return res.status(400).json({ message: "ID already in use" });
    }
    const shift = new Shift({
      id: shiftId,
      employeeId: Number(id),
      date,
      shiftType
    });
    

    const savedShift = await shift.save();
    
    return res.status(201).json({ message: "Shift assigned successfully", shift: savedShift });
  } catch (error) {
    console.log(error)
    return res.status(500).json({ message: "Error assigning shift", error });
  }
}

//get assgined shift for single employee

async function getAssignedShift(req, res) {
  const { id } = req.params;

  try {
    const shift = await Shift.find({ employeeId: id });

    if (!shift) {
      return res.status(404).json({ message: "Shift not found for employee" });
    }

    return res.status(200).json({message:"Shift(s) found successfully", shifts: shift});
  } catch (error) {
    console.log(error)
    return res.status(500).json({ message: "Error retrieving shift", error });
  }
}

//get all assigned shifts

async function getAllAssignedShifts(req, res) {
  try {
    const shifts = await Shift.find();

    if (!shifts.length) {
      return res.status(404).json({ message: "No assigned shifts found" });
    }

    return res.status(200).json(shifts);
  } catch (error) {
    console.log(error)
    return res.status(500).json({ message: "Error retrieving shifts", error });
  }
}

// update shift by ID
async function updateShift(req, res) {
  const { id } = req.params;
  const { date, shiftType, attendance } = req.body;
  
  try {
    const updateFields = {};
    if (date) updateFields.date = date;
    if (shiftType) updateFields.shiftType = shiftType;

    let updatedShift = await Shift.findOneAndUpdate(
      { id },
      { $set: updateFields },
      { new: true }
    );

    if (attendance && attendance.length > 0) {
      await Shift.updateOne(
        { id },
        { $push: { attendance: { $each: attendance } } }
      );
      updatedShift = await Shift.findOne({ id });
    }
    
    if (!updatedShift) {
      return res.status(404).json({ message: "Shift not found" });
    }
    console.log(updatedShift)
   
    return res.status(200).json({
      message: "Shift updated",
      shift: {
        id: updatedShift.id,
        date: updatedShift.date,
        shiftType: updatedShift.shiftType,
        employeeId: updatedShift.employeeId,
        attendance: updatedShift.attendance,
      },
    });
  } catch (error) {
    console.log(error)
    return res.status(500).json({ message: "Error updating shift", error });
  }
}

// delete shift by ID
async function deleteShift(req, res) {
  const { id } = req.params;
 console.log(id, typeof id )
  try {
    const deletedShift = await Shift.findOneAndDelete({id});

    if (!deletedShift) {
      console.log("issue")
      return res.status(404).json({ message: "Shift not found" });
    }

    return res.status(200).json({ message: "Shift deleted successfully" });
  } catch (error) {
    console.log(error)
    return res.status(500).json({ message: "Error deleting shift", error });
  }
}

// get single employee with status

async function singleStatus(req, res) {
  const id = req.params.id;
  try {
    const employee = await Employee.findOne({ id }, "name id status");
    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    return res.status(200).json(employee);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Error retrieving employee", error });
  }
}

//get all employees with status

async function getAllEmployeesWithStatus(req, res) {
  try {
    const employees = await Employee.find({}, "name id status");

    if (!employees) {
      return res.status(404).json({ message: "No employees found" });
    }

    return res.status(200).json(employees);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Error retrieving employees", error });
  }
}

//get single employee with attendance
async function singleAttendance(req, res) {
  const { id } = req.params;

  try {
    const employee = await Employee.findOne({ id }, "name id attendance");

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    return res.status(200).json(employee);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Error retrieving employee", error });
  }
}
//get all employees with attendance

async function getAllEmployeesWithAttendance(req, res) {
  try {
    const employees = await Employee.find({}, "name id attendance");

    if (!employees) {
      return res.status(404).json({ message: "No employees found" });
    }

    return res.status(200).json(employees);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Error retrieving employees", error });
  }
}

// logout user
async function logout(req, res) {
  // Since there's no token/session mechanism, we'll assume logout is client-handled
  // This function is kept for API completeness
  return res.status(200).json({ message: "Logout successful" });
}

// Get pending users for admin approval
async function getPendingUsers(req, res) {
  try {
    const pendingUsers = await Employee.find({ status: "pending" }, "-password");
    return res.status(200).json(pendingUsers);
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Error fetching pending users", error });
  }
}

// Approve user by admin
async function approveUser(req, res) {
  const { id } = req.params;
  
  try {
    const employee = await Employee.findOneAndUpdate(
      { id },
      { status: "active" },
      { new: true }
    );

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    return res.status(200).json({ 
      message: "User approved successfully", 
      employee: { ...employee.toObject(), password: undefined }
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Error approving user", error });
  }
}

// Reject user by admin
async function rejectUser(req, res) {
  const { id } = req.params;
  
  try {
    const employee = await Employee.findOneAndDelete({ id });

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    return res.status(200).json({ message: "User rejected and removed successfully" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Error rejecting user", error });
  }
}

// Create first admin user (for initial setup)
async function createAdmin(req, res) {
  const { name, email, id, password, phone, position } = req.body;

  try {
    // Check if any admin already exists
    const existingAdmin = await Employee.findOne({ isAdmin: true });
    if (existingAdmin) {
      return res.status(400).json({ message: "Admin user already exists" });
    }

    // Check if email or id already exists
    const existingEmployee = await Employee.findOne({
      $or: [{ email }, { id }],
    });
    if (existingEmployee) {
      return res.status(400).json({ message: "Email or ID already in use" });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    
    const admin = new Employee({
      name,
      email,
      id,
      password: hashedPassword,
      profilePicture: "default.jpg",
      phone,
      position: position || "Administrator",
      status: "active",
      isAdmin: true,
    });

    const savedAdmin = await admin.save();
    return res.status(201).json({ 
      message: "Admin user created successfully", 
      employee: { ...savedAdmin.toObject(), password: undefined }
    });
  } catch (error) {
    console.log(error);
    return res.status(400).json({ message: "Error creating admin user", error });
  }
}

export {
  register,
  changePassword,
  login,
  getAllEmployees,
  getOneEmployee,
  updateEmployee,
  deleteEmployee,
  clockin,
  clockout,
  assignShift,
  getAssignedShift,
  getAllAssignedShifts,
  updateShift,
  deleteShift,
  getAllEmployeesWithStatus,
  getAllEmployeesWithAttendance,
  singleAttendance,
  singleStatus,
  logout,
  getPendingUsers,
  approveUser,
  rejectUser,
  createAdmin,
};