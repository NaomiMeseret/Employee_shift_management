# ShiftMaster API Documentation

## 🔗 Base URL
```
Development: http://localhost:3000/api
Production: https://your-domain.com/api
```

## 🔐 Authentication

All authenticated endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## 📋 API Endpoints

### Authentication Endpoints

#### Register User
```http
POST /register
```

**Request Body:**
```json
{
  "name": "Kidst Teka",
  "email": "kidst.teka@example.com",
  "id": "EMP001",
  "password": "securePassword123",
  "phone": "+251911234567",
  "position": "Software Developer"
}
```

**Response (201):**
```json
{
  "message": "User created successfully",
  "employee": {
    "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
    "name": "Kidst Teka",
    "email": "kidst.teka@example.com",
    "id": "EMP001",
    "phone": "+251911234567",
    "position": "Software Developer",
    "status": "pending",
    "isAdmin": false,
    "createdAt": "2023-09-16T10:30:00.000Z",
    "updatedAt": "2023-09-16T10:30:00.000Z"
  }
}
```

#### Login
```http
POST /login
```

**Request Body:**
```json
{
  "email": "kidst.teka@example.com",
  "password": "securePassword123"
}
```

**Response (200):**
```json
{
  "message": "Login successful",
  "employee": {
    "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
    "name": "Kidst Teka",
    "email": "kidst.teks@example.com",
    "id": "EMP001",
    "status": "active",
    "isAdmin": false
  }
}
```

**Error Responses:**
- `403`: Account pending approval or inactive
- `404`: User not found
- `401`: Invalid credentials

#### Create Admin User
```http
POST /createAdmin
```

**Request Body:**
```json
{
  "name": "Dawit Mekonnen",
  "email": "dawit.mekonnen@company.com",
  "id": "ADMIN001",
  "password": "adminPassword123",
  "phone": "+251922345678",
  "position": "System Administrator"
}
```

**Response (201):**
```json
{
  "message": "Admin user created successfully",
  "employee": {
    "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
    "name": "Admin User",
    "email": "admin@company.com",
    "id": "ADMIN001",
    "status": "active",
    "isAdmin": true
  }
}
```

### User Management Endpoints

#### Get All Employees
```http
GET /employees
```

**Response (200):**
```json
[
  {
    "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
    "name": "Kidst Teka",
    "email": "kidst.teka@example.com",
    "id": "EMP001",
    "status": "active",
    "position": "Software Developer",
    "isAdmin": false
  }
]
```

#### Get Single Employee
```http
GET /employees/:id
```

**Response (200):**
```json
{
  "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
  "name": "Kidst Teka",
  "email": "kidst.teka@example.com",
  "id": "EMP001",
  "status": "active",
  "position": "Software Developer",
  "phone": "+251911234567",
  "isAdmin": false
}
```

#### Update Employee
```http
PUT /updateEmployee/:id
```

**Request Body:**
```json
{
  "name": "John Smith",
  "email": "john.smith@example.com",
  "position": "Senior Developer",
  "status": "active"
}
```

#### Delete Employee
```http
DELETE /deleteEmployee/:id
```

**Response (200):**
```json
{
  "message": "Employee and their shifts deleted successfully"
}
```

### Admin User Management

#### Get Pending Users
```http
GET /pending
```

**Response (200):**
```json
[
  {
    "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
    "name": "Jane Doe",
    "email": "jane.doe@example.com",
    "id": "EMP002",
    "status": "pending",
    "position": "Designer",
    "phone": "+1234567891",
    "isAdmin": false,
    "createdAt": "2023-09-16T10:30:00.000Z"
  }
]
```

#### Approve User
```http
PUT /approve/:id
```

**Response (200):**
```json
{
  "message": "User approved successfully",
  "employee": {
    "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
    "name": "Jane Doe",
    "status": "active"
  }
}
```

#### Reject User
```http
DELETE /reject/:id
```

**Response (200):**
```json
{
  "message": "User rejected and removed successfully"
}
```

### Shift Management

#### Assign Shift
```http
POST /assignShift/:id
```

**Request Body:**
```json
{
  "date": "2023-09-16",
  "shiftType": "morning",
  "shiftId": "SHIFT001"
}
```

#### Get Employee Shifts
```http
GET /assignedShift/:id
```

**Response (200):**
```json
{
  "message": "Shift(s) found successfully",
  "shifts": [
    {
      "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
      "id": "SHIFT001",
      "employeeId": "EMP001",
      "date": "2023-09-16",
      "shiftType": "morning",
      "attendance": []
    }
  ]
}
```

#### Get All Shifts
```http
GET /assignedShift
```

#### Update Shift
```http
PUT /shift/:id
```

**Request Body:**
```json
{
  "date": "2023-09-17",
  "shiftType": "evening",
  "attendance": [
    {
      "actionType": "Clock In",
      "time": "09:00:00",
      "date": "2023-09-16",
      "status": "active"
    }
  ]
}
```

#### Delete Shift
```http
DELETE /shift/:id
```

### Attendance Management

#### Clock In
```http
POST /clockin/:id
```

**Request Body:**
```json
{
  "shiftId": "SHIFT001"
}
```

**Response (200):**
```json
{
  "message": "Clock-in successful",
  "shift": {
    "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
    "attendance": [
      {
        "actionType": "Clock In",
        "time": "09:00:00",
        "date": "2023-09-16",
        "status": "active"
      }
    ]
  }
}
```

#### Clock Out
```http
POST /clockout/:id
```

**Request Body:**
```json
{
  "shiftId": "SHIFT001"
}
```

#### Get Employee Status
```http
GET /status/:id
```

**Response (200):**
```json
{
  "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
  "name": "John Doe",
  "id": "EMP001",
  "status": "active"
}
```

#### Get All Employee Statuses
```http
GET /status
```

#### Get Employee Attendance
```http
GET /attendance/:id
```

**Response (200):**
```json
{
  "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
  "name": "John Doe",
  "id": "EMP001",
  "attendance": [
    {
      "date": "2023-09-16",
      "clockIn": "09:00:00",
      "clockOut": "17:00:00",
      "hoursWorked": 8
    }
  ]
}
```

#### Get All Employee Attendance
```http
GET /attendance
```

### Utility Endpoints

#### Change Password
```http
POST /changePassword/:id
```

**Request Body:**
```json
{
  "currentPassword": "oldPassword123",
  "newPassword": "newSecurePassword456"
}
```

**Response (200):**
```json
{
  "message": "Password changed successfully"
}
```

#### Logout
```http
POST /logout
```

**Response (200):**
```json
{
  "message": "Logout successful"
}
```

## 📊 Data Models

### Employee Model
```json
{
  "_id": "ObjectId",
  "name": "String (required)",
  "email": "String (required, unique)",
  "id": "String (required, unique)",
  "password": "String (required, hashed)",
  "profilePicture": "String (default: 'default.jpg')",
  "phone": "String (required)",
  "position": "String (required)",
  "status": "String (enum: ['active', 'inactive', 'pending', 'on leave'], default: 'pending')",
  "isAdmin": "Boolean (default: false)",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Shift Model
```json
{
  "_id": "ObjectId",
  "id": "String (required, unique)",
  "employeeId": "String (required)",
  "date": "String (required)",
  "shiftType": "String (required)",
  "attendance": [
    {
      "actionType": "String",
      "time": "String",
      "date": "String",
      "status": "String"
    }
  ],
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

## 🚨 Error Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Internal Server Error |

## 📝 Error Response Format

```json
{
  "message": "Error description",
  "error": "Detailed error information (development only)"
}
```

## 🔒 Security Notes

1. **Password Security**: All passwords are hashed using bcrypt with salt rounds
2. **Input Validation**: All inputs are validated and sanitized
3. **Rate Limiting**: API endpoints are rate-limited to prevent abuse
4. **CORS**: Cross-origin requests are controlled via CORS policy
5. **Environment Variables**: Sensitive data stored in environment variables

## 📚 Usage Examples

### JavaScript/Fetch
```javascript
// Login example
const response = await fetch('http://localhost:3000/api/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123'
  })
});

const data = await response.json();
```

### Flutter/Dart
```dart
// Register example
final response = await dio.post('/register', data: {
  'name': 'Kidst Teka',
  'email': 'kidst.teka@example.com',
  'id': 'EMP001',
  'password': 'password123',
  'phone': '+251911234567',
  'position': 'Developer'
});
```

### cURL
```bash
# Get all employees
curl -X GET http://localhost:3000/api/employees \
  -H "Authorization: Bearer your-jwt-token"

# Register new user
curl -X POST http://localhost:3000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Kidst Teka",
    "email": "kidst.teka@example.com",
    "id": "EMP001",
    "password": "password123",
    "phone": "+251911234567",
    "position": "Developer"
  }'
```

---

**Last Updated:** September 16, 2023  
**API Version:** 1.0.0
