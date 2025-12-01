# ClockIn System Requirements Specification (SRS)

## 📱 Project Overview

**Project Name:** ClockIn+  
**Team:** ChillCode  
**Platform:** Mobile App (Flutter) + Web Admin Panel (Laravel + Filament)  
**Purpose:** Smart Mobile Attendance System with GPS-based tracking and real-time reporting  

---

## 🎯 System Objectives

### Primary Goals
1. **Simplify employee attendance tracking** through mobile app with GPS verification
2. **Automate attendance calculation** including work hours, late arrivals, and overtime
3. **Digitalize leave request process** with approval workflow
4. **Provide real-time attendance insights** for both employees and management
5. **Ensure location accuracy** through GPS-based radius verification

---

## 👥 User Roles & Access Levels

### 1. **Super Admin**
- Full system access
- Manage multiple companies
- System-wide configuration

### 2. **Company Admin**
- Manage company settings
- Manage employees (CRUD)
- Approve/reject leave requests
- View all company attendance reports
- Configure company location & radius

### 3. **Employee**
- Clock in/out with photo
- View personal attendance history
- Submit leave requests
- Track work hours and statistics
- View company information

---

## 🏗️ System Architecture

### Frontend (Mobile App)
- **Platform:** Flutter (Dart)
- **State Management:** Provider
- **API Communication:** HTTP REST API
- **Local Storage:** SharedPreferences
- **Location Services:** Geolocator
- **Camera:** Image Picker

### Backend (API & Admin)
- **Framework:** Laravel 10+
- **Admin Panel:** Filament 3+
- **Authentication:** Laravel Sanctum (Token-based)
- **Database:** MySQL
- **Storage:** Local File System / S3
- **API Format:** RESTful JSON

---

## 📋 Core Features & Functional Requirements

### 1. **Authentication & Authorization**

#### 1.1 User Registration
- **Actor:** Employee (new user)
- **Input:**
  - Company ID (link to company)
  - Full Name
  - Email (unique)
  - Password + Confirmation
  - Phone Number
  - Employee ID (unique per company)
  - Position/Job Title
- **Process:**
  - Validate email uniqueness
  - Validate employee_id uniqueness within company
  - Hash password
  - Create user account with role='employee'
  - Generate authentication token
- **Output:**
  - User profile data
  - Access token (Bearer)
  - Success message

#### 1.2 User Login
- **Actor:** All users (Employee, Company Admin, Super Admin)
- **Input:**
  - Email
  - Password
- **Process:**
  - Validate credentials
  - Generate Sanctum token
  - Load user + company data
- **Output:**
  - User profile with company info
  - Access token
  - Token type

#### 1.3 Logout
- **Actor:** Authenticated users
- **Process:**
  - Revoke current access token
  - Clear local session
- **Output:** Success confirmation

#### 1.4 Profile Management
- **Actor:** Authenticated users
- **Features:**
  - View profile
  - Update profile (name, phone, photo)
  - Upload profile picture
- **Restrictions:**
  - Cannot change email
  - Cannot change employee_id
  - Cannot change role

---

### 2. **Company Management**

#### 2.1 Company Configuration
- **Actor:** Company Admin, Super Admin
- **Company Attributes:**
  - Company Name
  - Email & Phone
  - Office Address
  - **GPS Location** (Latitude, Longitude)
  - **Attendance Radius** (meters, e.g., 100m)
  - **Work Schedule:**
    - Work Start Time (e.g., 08:00)
    - Work End Time (e.g., 17:00)
  - Company Logo
  - Active Status

#### 2.2 Company Info for Employees
- **Actor:** Employee
- **Accessible Data:**
  - Company name
  - Work schedule
  - Office location
  - Attendance radius
- **Purpose:** Know attendance requirements

---

### 3. **Clock In/Out (Core Feature)**

#### 3.1 Clock In Process
- **Actor:** Employee
- **Trigger:** Start of workday
- **Input:**
  - Current GPS Location (latitude, longitude)
  - Selfie Photo (mandatory)
  - Notes (optional)
- **Validation Steps:**
  1. **Check if already clocked in today**
     - If yes → Show error: "Already clocked in"
  2. **GPS Distance Validation:**
     - Calculate distance from company office location
     - If distance > company radius → Reject with error:
       - "You are not within office location. Distance: X meters"
  3. **Photo Validation:**
     - Must upload selfie photo
  4. **Time Recording:**
     - Record exact clock-in timestamp
- **Process:**
  - Create attendance record
  - Save clock_in, GPS coordinates, photo, notes
  - Determine status:
    - **on_time:** clock_in <= work_start_time
    - **late:** clock_in > work_start_time
    - **half_day:** clock_in > work_start_time + 2 hours
- **Output:**
  - Attendance record with status
  - Clock-in timestamp
  - Success message

#### 3.2 Clock Out Process
- **Actor:** Employee
- **Trigger:** End of workday
- **Input:**
  - Current GPS Location
  - Selfie Photo (mandatory)
  - Notes (optional)
- **Validation Steps:**
  1. **Check if clocked in today**
     - If no → Error: "You haven't clocked in today"
  2. **Check if already clocked out**
     - If yes → Error: "Already clocked out"
  3. **GPS Distance Validation** (same as clock-in)
  4. **Photo Validation**
- **Process:**
  - Update today's attendance record
  - Save clock_out, GPS coordinates, photo, notes
  - Calculate work_duration = clock_out - clock_in (in minutes)
  - Final status determination
- **Output:**
  - Updated attendance with clock-out time
  - Total work duration
  - Success message

#### 3.3 GPS Distance Calculation
- **Algorithm:** Haversine Formula
- **Inputs:**
  - User's current location (lat, lng)
  - Company office location (lat, lng)
- **Output:** Distance in meters
- **Acceptance Criteria:**
  - Distance <= company radius → Allowed
  - Distance > company radius → Rejected

---

### 4. **Attendance History & Statistics**

#### 4.1 Today's Attendance
- **Actor:** Employee
- **Display:**
  - Clock-in time & photo
  - Clock-out time & photo (if available)
  - Work duration
  - Status (on_time, late, half_day)
  - Location data
  - Notes

#### 4.2 Attendance History
- **Actor:** Employee
- **Filters:**
  - Month & Year selection
  - Pagination (15 per page)
- **Display per record:**
  - Date
  - Clock-in & Clock-out times
  - Work duration
  - Status badge
  - Photos (thumbnail)

#### 4.3 Attendance Statistics
- **Actor:** Employee
- **Filters:** Month & Year
- **Metrics:**
  - Total working days
  - On-time count
  - Late count
  - Half-day count
  - Absent count
  - Total work hours
- **Visual:** Cards with icons & counts

#### 4.4 Admin Reports (Web Panel)
- **Actor:** Company Admin, Super Admin
- **Features:**
  - View all employees' attendance
  - Filter by employee, date range
  - Export to Excel/PDF
  - Attendance summary per employee
  - Late arrival trends
  - Absence tracking

---

### 5. **Leave Request Management**

#### 5.1 Submit Leave Request
- **Actor:** Employee
- **Input:**
  - Leave Type:
    - Sick Leave
    - Annual Leave
    - Maternity/Paternity Leave
    - Unpaid Leave
    - Emergency Leave
  - Start Date
  - End Date
  - Reason (text description)
  - Attachment (optional: medical certificate, etc.)
- **Process:**
  - Validate dates (end_date >= start_date)
  - Calculate total_days automatically
  - Set status = 'pending'
  - Save to database
  - Notify company admin (optional)
- **Output:**
  - Leave request ID
  - Total days calculated
  - Pending status confirmation

#### 5.2 View Leave Requests (Employee)
- **Actor:** Employee
- **Filters:**
  - Status: All / Pending / Approved / Rejected
  - Pagination
- **Display per request:**
  - Leave type with icon
  - Date range
  - Total days
  - Status badge (color-coded)
  - Submission date
  - Approval/rejection info

#### 5.3 Cancel Leave Request
- **Actor:** Employee
- **Condition:** Only if status = 'pending'
- **Process:**
  - Delete leave request
  - Show confirmation
- **Restriction:** Cannot cancel approved/rejected requests

#### 5.4 Approve/Reject Leave Request (Admin)
- **Actor:** Company Admin
- **Actions:**
  - **Approve:**
    - Set status = 'approved'
    - Record approved_by (admin user_id)
    - Record approved_at (timestamp)
  - **Reject:**
    - Set status = 'rejected'
    - Record rejection_reason
    - Record approved_by (admin user_id)
- **Notification:** Inform employee of decision

#### 5.5 Leave Statistics
- **Actor:** Employee
- **Display:**
  - Total leave requests (current year)
  - Approved count
  - Rejected count
  - Pending count
  - Total days taken

---

### 6. **User Interface Flows**

#### 6.1 App Launch Flow
```
1. App Opens
   ↓
2. Native Splash Screen (instant)
   ↓
3. Custom Splash Screen (3 seconds, fade animation)
   ↓
4. Check onboarding status (SharedPreferences)
   ↓
   ├─ First time user?
   │  └─ YES → Show Onboarding (4 pages)
   │            ↓
   │            User completes → Mark onboarding as seen
   │            ↓
   └─ NO → Check authentication token
              ↓
              ├─ Token exists & valid?
              │  └─ YES → Navigate to Home Screen
              │  └─ NO → Navigate to Login Screen
```

#### 6.2 Onboarding Pages
- **Page 1:** Welcome to ClockIn
  - Introduction to app
  - Color: Blue (#4A90E2)
- **Page 2:** Easy Attendance
  - Explain clock in/out feature
  - Color: Green (#50C878)
- **Page 3:** Track Your Time
  - Explain history & statistics
  - Color: Red (#FF6B6B)
- **Page 4:** Real-time Reports
  - Explain reporting features
  - Color: Orange (#FFB84D)
- **Controls:**
  - Skip button (go to login)
  - Next/Previous navigation
  - Get Started button (page 4)

#### 6.3 Home Screen
- **Display:**
  - User profile card (name, position, photo)
  - Live clock with timezone (WIB/WITA/WIT)
  - Today's attendance status card:
    - If not clocked in → Show "Clock In" button
    - If clocked in → Show clock-in time & "Clock Out" button
    - If clocked out → Show summary (in/out times, duration)
  - Quick statistics (this month):
    - Total days worked
    - On-time count
    - Late count
  - Quick action buttons:
    - View Attendance History
    - Submit Leave Request
    - View Leave Requests
- **Pull-to-refresh:** Reload today's data

#### 6.4 Clock In Screen
- **Layout:** 3-step process
  1. **Take Photo:**
     - Camera interface
     - Retake option
  2. **Add Description (optional):**
     - Text field for notes
  3. **Verify Location:**
     - Show current location
     - Distance from office
     - Status indicator (in/out of range)
- **Submit Button:**
  - Validate all data
  - Show loading indicator
  - Handle success/error

#### 6.5 Clock Out Screen
- **Same layout as Clock In**
- **Additional info:**
  - Show clock-in time
  - Calculate work duration preview
  - Warn if clocking out too early

#### 6.6 Attendance History Screen
- **Filters:**
  - Month & Year picker
- **Display:** List of attendance cards
  - Date
  - Clock-in & out times
  - Status badge
  - Work duration
  - Tap to view details
- **Empty state:** "No attendance data"

#### 6.7 Leave Request Form Screen
- **Form Fields:**
  - Leave type dropdown
  - Start date picker
  - End date picker
  - Reason text area
  - Attachment upload (optional)
  - Total days (auto-calculated)
- **Submit validation**

#### 6.8 Leave Request List Screen
- **Tabs/Filter:**
  - All
  - Pending
  - Approved
  - Rejected
- **Cards display:**
  - Leave type icon
  - Date range
  - Status badge
  - Tap for details
- **Actions:**
  - Cancel (if pending)
  - View details

#### 6.9 Profile Screen
- **Display:**
  - Profile photo (editable)
  - Name
  - Email
  - Phone
  - Employee ID
  - Position
  - Company name
- **Actions:**
  - Edit profile
  - Logout

---

### 7. **Admin Panel (Web - Filament)**

#### 7.1 Dashboard
- **Widgets:**
  - Total employees
  - Today's attendance rate
  - Pending leave requests
  - Late arrivals (this week)
- **Charts:**
  - Attendance trends (last 30 days)
  - Leave requests by type

#### 7.2 User Management
- **CRUD Operations:**
  - Create employee account
  - Edit employee info
  - Deactivate/activate account
  - View employee attendance summary
- **Bulk Actions:**
  - Export employee list
  - Bulk activation/deactivation

#### 7.3 Company Management
- **Features:**
  - Edit company info
  - Set GPS location (map picker)
  - Configure attendance radius
  - Set work schedule
  - Upload company logo

#### 7.4 Attendance Management
- **View:**
  - All attendance records
  - Filter by employee, date range, status
  - View clock-in/out photos
  - Export to Excel/PDF
- **Actions:**
  - Edit attendance (admin correction)
  - Delete invalid attendance
  - Add manual attendance

#### 7.5 Leave Request Management
- **View:**
  - All leave requests
  - Filter by status, employee, type
- **Actions:**
  - Approve with comment
  - Reject with reason
  - View attachments
  - Export leave report

---

## 🔒 Security Requirements

### 1. Authentication
- Token-based (Laravel Sanctum)
- Tokens expire after inactivity
- Secure password hashing (bcrypt)

### 2. Authorization
- Role-based access control
- API middleware validation
- Company-level data isolation

### 3. Data Privacy
- Employees can only view their own data
- Admins can only view their company's data
- Sensitive data encryption (photos, locations)

### 4. GPS Validation
- Server-side distance calculation
- Prevent GPS spoofing (challenge: implement additional checks)
- Log all location attempts

---

## 📊 Data Models

### 1. Users
```
- id (primary key)
- company_id (foreign key)
- name
- email (unique)
- password (hashed)
- phone
- position
- employee_id (unique per company)
- photo (path)
- role (super_admin, company_admin, employee)
- is_active (boolean)
- timestamps
```

### 2. Companies
```
- id (primary key)
- name
- email
- phone
- address
- latitude (decimal)
- longitude (decimal)
- radius (integer, meters)
- work_start_time (time)
- work_end_time (time)
- logo (path)
- is_active (boolean)
- timestamps
- soft_deletes
```

### 3. Attendances
```
- id (primary key)
- user_id (foreign key)
- company_id (foreign key)
- clock_in (datetime)
- clock_in_latitude
- clock_in_longitude
- clock_in_photo (path)
- clock_in_notes
- clock_out (datetime, nullable)
- clock_out_latitude
- clock_out_longitude
- clock_out_photo (path, nullable)
- clock_out_notes
- work_duration (integer, minutes)
- status (on_time, late, half_day, absent)
- timestamps
```

### 4. Leave Requests
```
- id (primary key)
- user_id (foreign key)
- company_id (foreign key)
- type (sick, annual, maternity, unpaid, emergency)
- start_date
- end_date
- total_days (integer)
- reason (text)
- attachment (path, nullable)
- status (pending, approved, rejected)
- approved_by (foreign key, nullable)
- approved_at (datetime, nullable)
- rejection_reason (text, nullable)
- timestamps
```

---

## 🔄 API Endpoints Summary

### Authentication
- `POST /api/register` - Create new employee account
- `POST /api/login` - Authenticate user
- `POST /api/logout` - Revoke token
- `GET /api/profile` - Get user profile
- `PUT /api/profile` - Update profile

### Company
- `GET /api/company` - Get company info (for employee)

### Attendance
- `POST /api/attendance/clock-in` - Clock in with GPS & photo
- `POST /api/attendance/clock-out` - Clock out with GPS & photo
- `GET /api/attendance/today` - Get today's attendance
- `GET /api/attendance/history` - Get attendance history (paginated, filtered)
- `GET /api/attendance/statistics` - Get attendance stats

### Leave Requests
- `GET /api/leave-requests` - Get leave requests (filtered by status)
- `POST /api/leave-requests` - Submit new leave request
- `GET /api/leave-requests/{id}` - Get leave request details
- `DELETE /api/leave-requests/{id}` - Cancel leave request (if pending)
- `GET /api/leave-requests/statistics/summary` - Get leave statistics

---

## 🎨 UI/UX Requirements

### Design Principles
- **Clean & Modern:** Material Design / Cupertino style
- **Intuitive Navigation:** Bottom navigation bar
- **Visual Feedback:** Loading indicators, success/error messages
- **Responsive:** Adapt to different screen sizes
- **Accessible:** High contrast, readable fonts

### Color Scheme
- **Primary:** Blue (#4A90E2)
- **Success:** Green (#50C878)
- **Warning:** Orange (#FFB84D)
- **Error:** Red (#FF6B6B)
- **Background:** White / Light grey
- **Text:** Dark grey (#333333)

### Icons
- Use Material Icons or Cupertino Icons
- Consistent icon style throughout app

### Typography
- **Headers:** Bold, larger size
- **Body:** Regular, readable size (14-16px)
- **Captions:** Smaller, grey color

---

## 📱 Technical Requirements

### Mobile App (Flutter)
- **Minimum SDK:** Android 21+ (Lollipop), iOS 12+
- **Permissions:**
  - Location (GPS)
  - Camera
  - Storage (photo access)
- **Dependencies:**
  - provider (state management)
  - http (API calls)
  - geolocator (location)
  - image_picker (camera)
  - shared_preferences (local storage)
  - intl (date formatting)
  - smooth_page_indicator (onboarding)

### Backend (Laravel)
- **PHP:** 8.1+
- **Laravel:** 10+
- **Database:** MySQL 8+
- **Packages:**
  - Laravel Sanctum (authentication)
  - Filament 3+ (admin panel)
  - Spatie Media Library (optional, file management)

---

## 🧪 Testing Scenarios

### 1. Clock In Testing
- ✅ Success: Within radius, valid photo
- ❌ Error: Outside radius
- ❌ Error: Already clocked in
- ❌ Error: No photo
- ❌ Error: Invalid GPS

### 2. Clock Out Testing
- ✅ Success: After clock in, within radius
- ❌ Error: Not clocked in yet
- ❌ Error: Already clocked out
- ❌ Error: Outside radius

### 3. Leave Request Testing
- ✅ Success: Valid dates & reason
- ❌ Error: End date before start date
- ✅ Cancel: Only pending requests
- ❌ Cannot cancel: Approved/rejected

### 4. Authentication Testing
- ✅ Login: Valid credentials
- ❌ Login: Invalid credentials
- ✅ Token: Valid & not expired
- ❌ Token: Expired or revoked

---

## 🚀 Future Enhancements (Nice to Have)

### Phase 2 Features
1. **Face Recognition** for clock in/out (AI-based verification)
2. **Overtime Tracking** with approval workflow
3. **Shift Management** (different work schedules per employee)
4. **Push Notifications:**
   - Remind to clock in/out
   - Leave request updates
   - Announcements
5. **Multi-language Support** (English, Indonesian)
6. **Payroll Integration** (calculate salary based on attendance)
7. **QR Code Attendance** (alternative to GPS)
8. **Offline Mode** (sync when online)
9. **Chat/Communication** between employees & admin
10. **Reports Export** (PDF, Excel) from mobile app

### Phase 3 Features
1. **Biometric Authentication** (fingerprint, face unlock)
2. **Geofencing Alerts** (notify when entering/leaving office radius)
3. **Wearable Integration** (smartwatch clock in/out)
4. **AI-based Fraud Detection** (detect patterns, GPS spoofing)
5. **Advanced Analytics** (predictive attendance, trends)

---

## 📊 Success Metrics

### Key Performance Indicators (KPIs)
1. **Attendance Accuracy:** 99%+ GPS validation success rate
2. **User Adoption:** 90%+ employees actively using app
3. **Response Time:** API response < 500ms
4. **App Performance:** Load time < 3 seconds
5. **Leave Approval Time:** < 24 hours average
6. **User Satisfaction:** 4+ star rating

---

## 🎯 Project Goals Summary

### Primary Objectives Achieved
✅ **Automated Attendance:** Replace manual attendance sheets  
✅ **GPS Verification:** Ensure on-site attendance  
✅ **Digital Leave Requests:** Streamline approval process  
✅ **Real-time Reporting:** Instant attendance insights  
✅ **Mobile-First:** Easy access for all employees  
✅ **Admin Control:** Centralized management panel  

### Business Value
- **Time Savings:** Reduce admin workload by 70%
- **Accuracy:** Eliminate manual errors & fraud
- **Transparency:** Clear attendance records for everyone
- **Compliance:** Maintain proper attendance logs
- **Insights:** Data-driven workforce management

---

## 📝 Notes for Use Case & Flowchart Creation

### Use Case Diagram Elements
- **Actors:** Employee, Company Admin, Super Admin, System
- **Use Cases:** 
  - Register, Login, Logout
  - Clock In, Clock Out
  - View Attendance History
  - Submit Leave Request, Cancel Leave Request
  - Approve/Reject Leave Request (Admin)
  - Manage Company Settings (Admin)
  - Generate Reports (Admin)

### Flowchart Types Needed
1. **User Registration Flow**
2. **Login & Authentication Flow**
3. **Clock In Process Flow** (with GPS validation)
4. **Clock Out Process Flow**
5. **Leave Request Submission Flow**
6. **Leave Request Approval Flow** (Admin)
7. **App Launch & Navigation Flow**
8. **Onboarding Flow** (first-time user)

### Sequence Diagrams
1. Clock In Sequence (Mobile → API → Database)
2. Leave Request Approval (Employee → API → Admin → API → Employee)
3. Authentication (Login → Token → Protected Endpoint)

---

## 🎓 Development Team Notes

**Team ChillCode Motto:**  
> "Santai aja, yang penting commit masuk!" ☕

**Current Status:**
- ✅ Splash Screen & Onboarding: Complete
- ✅ Authentication API: Complete
- ✅ Attendance API: Complete
- ✅ Leave Request API: Complete
- ✅ Admin Panel: Complete
- 🔄 Mobile UI: In Progress (login, home, clock in/out screens done)
- ⏳ Testing: Ongoing
- ⏳ Documentation: In Progress

**Tech Stack:**
- Frontend: Flutter (Dart)
- Backend: Laravel 10 + Filament 3
- Database: MySQL
- Authentication: Laravel Sanctum
- Deployment: TBD (AWS, DigitalOcean, or local server)

---

## 📞 Contact & Support

**Project Repository:** GitHub - ClockIn  
**Current Branch:** cobaLiat_backend-apip  
**Developer:** Team ChillCode  

---

**Last Updated:** November 20, 2025  
**Version:** 1.0  
**Document Status:** Ready for Use Case & Flowchart Creation

---

## 🎯 PROMPT FOR GPT (Use Case & Flowchart Generation)

```
You are a software analyst and UML expert. Based on the complete System Requirements Specification (SRS) above for the ClockIn+ application, please create:

1. **Complete Use Case Diagram** with:
   - All actors (Employee, Company Admin, Super Admin)
   - All use cases (minimum 15-20 use cases)
   - Relationships (include, extend, generalization)
   - System boundary

2. **Detailed Use Case Descriptions** (text format) for:
   - Clock In Process (with GPS validation)
   - Clock Out Process
   - Submit Leave Request
   - Approve/Reject Leave Request
   - User Registration
   - User Login

3. **Activity Diagrams/Flowcharts** for:
   - Clock In Process (swimlanes: Employee, System, Database)
   - Leave Request Approval Workflow (swimlanes: Employee, Admin, System)
   - App Launch & Navigation Flow
   - User Authentication Flow

4. **Sequence Diagrams** for:
   - Clock In API Call (Mobile App → API → Database → Response)
   - Leave Request Submission & Approval (end-to-end)

5. **State Diagrams** for:
   - Attendance Status (not_clocked_in → clocked_in → clocked_out)
   - Leave Request Status (pending → approved/rejected)

Please use PlantUML syntax or draw.io format for all diagrams so they can be easily generated and edited.

Focus on:
- GPS validation logic in clock in/out
- Token-based authentication flow
- Role-based access control
- Error handling scenarios
- Happy path and alternative paths

Make the diagrams clear, professional, and comprehensive enough for developers to implement the system.
```

---

**END OF SYSTEM REQUIREMENTS SPECIFICATION**
