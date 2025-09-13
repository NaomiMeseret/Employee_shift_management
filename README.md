# 🚀 ShiftMaster - Employee Shift Management System

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

A **professional-grade mobile application** built with **Flutter** and **Node.js** for comprehensive employee shift management. This system provides a complete solution for businesses to efficiently manage work schedules, track attendance, and generate detailed analytics reports.


## ✨ Key Features

### 🔐 **Authentication & Security**
- **JWT-based authentication** with secure token management
- **Role-based access control** (Admin/Employee)
- **Password encryption** using bcrypt
- **Input validation** and sanitization
- **Biometric authentication** support (fingerprint/face)

### 👨‍💼 **Admin Management**
- **Employee Registration** - Add new team members with detailed profiles
- **Shift Assignment** - Schedule shifts (morning, afternoon, night) with calendar view
- **Attendance Monitoring** - Real-time attendance tracking and reporting
- **Analytics Dashboard** - Visual charts and performance metrics
- **Team Overview** - Comprehensive employee status management
- **Report Generation** - Export attendance and shift reports

### 👤 **Employee Features**
- **Personal Dashboard** - View assigned shifts and upcoming schedules
- **Clock In/Out** - Simple attendance tracking with timestamp
- **Shift Calendar** - Interactive calendar view of personal shifts
- **Team Directory** - View team members and their status
- **Profile Management** - Update personal information and change password
- **Attendance History** - View personal attendance records

### 📊 **Analytics & Reporting**
- **Real-time Charts** - Weekly/monthly attendance visualization
- **Performance Metrics** - Attendance rates and trends
- **Custom Reports** - Generate detailed shift and attendance reports
- **Export Functionality** - Download reports in various formats

### 🎨 **Modern UI/UX**
- **Material Design 3** with custom theming
- **Responsive Design** for all screen sizes
- **Dark/Light Theme** support
- **Smooth Animations** and transitions
- **Professional Color Scheme** with consistent branding
- **Accessibility Features** for inclusive design

## 🏗️ Architecture

### **Frontend (Flutter)**
```
lib/
├── application/          # Business logic layer
│   └── services/        # Services (validation, notifications)
├── config/              # App configuration and themes
├── domain/              # Domain entities and models
├── infrastructure/      # External services and APIs
└── presentation/        # UI layer
    ├── screens/         # App screens
    ├── widgets/         # Reusable UI components
    └── states/          # State management (Riverpod)
```

### **Backend (Node.js)**
```
backend/
├── models/              # MongoDB schemas
├── routes/              # API endpoints
├── utils/               # Database connection and utilities
├── middleware/          # Authentication and validation
└── tests/               # API tests
```

## 🛠️ Tech Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **Frontend** | Flutter 3.0+ | Cross-platform mobile development |
| **State Management** | Riverpod | Reactive state management |
| **Backend** | Node.js + Express | RESTful API server |
| **Database** | MongoDB | Document-based data storage |
| **Authentication** | JWT | Secure token-based auth |
| **Charts** | FL Chart | Data visualization |
| **Testing** | Jest + Flutter Test | Unit and widget testing |
| **UI/UX** | Material Design 3 | Modern design system |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Node.js (16+)
- MongoDB (5.0+)
- Android Studio / Xcode
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/employee-shift-management.git
cd employee-shift-management
```

2. **Backend Setup**
```bash
cd backend
npm install
cp .env.example .env
# Configure your MongoDB connection in .env
npm start
```

3. **Frontend Setup**
```bash
cd frontend
flutter pub get
flutter run
```

### Environment Variables

Create a `.env` file in the backend directory:
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/shiftmaster
JWT_SECRET=your_jwt_secret_key
NODE_ENV=development
```

## 📱 Usage

### Admin Login
- Email: `admin@shiftmaster.com`
- Password: `admin123`

### Employee Login
- Email: `employee@shiftmaster.com`
- Password: `employee123`

## 🧪 Testing

### Frontend Tests
```bash
cd frontend
flutter test
```

### Backend Tests
```bash
cd backend
npm test
```

## 📈 Performance Features

- **Optimized State Management** with Riverpod
- **Lazy Loading** for large data sets
- **Caching Strategy** for improved performance
- **Offline Support** for core features
- **Background Sync** for attendance data
- **Memory Management** optimization

## 🔧 Development Features

- **Clean Architecture** implementation
- **SOLID Principles** adherence
- **Comprehensive Testing** (Unit, Widget, Integration)
- **CI/CD Pipeline** ready
- **Code Documentation** with detailed comments
- **Error Handling** with user-friendly messages
- **Logging System** for debugging
